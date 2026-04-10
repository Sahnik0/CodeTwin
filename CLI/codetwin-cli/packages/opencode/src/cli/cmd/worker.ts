import { cmd } from "./cmd"
import { existsSync } from "fs"
import { spawn } from "child_process"
import { resolve } from "path"
import { normalizeWsUrl, readRemoteBridgeState } from "../remote-bridge"

type JobMode = "shell" | "cli"
type RunningProcess = ReturnType<typeof spawn>

const OPEN = 1

function normalizeUrl(input: string) {
  return normalizeWsUrl(input)
}

function normalizeEnv(input: unknown) {
  const env: NodeJS.ProcessEnv = { ...process.env }
  if (!input || typeof input !== "object" || Array.isArray(input)) return env
  for (const [key, value] of Object.entries(input as Record<string, unknown>)) {
    if (typeof value === "string") {
      env[key] = value
    }
  }
  return env
}

function normalizeArgs(input: unknown) {
  if (!Array.isArray(input)) return []
  return input.filter((item): item is string => typeof item === "string")
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function safeSend(ws: WebSocket, payload: unknown) {
  if (ws.readyState !== OPEN) return false
  ws.send(JSON.stringify(payload))
  return true
}

async function decodeMessageData(data: unknown) {
  if (typeof data === "string") return data
  if (data instanceof ArrayBuffer) return Buffer.from(data).toString("utf8")
  if (ArrayBuffer.isView(data)) {
    return Buffer.from(data.buffer, data.byteOffset, data.byteLength).toString("utf8")
  }
  if (typeof Blob !== "undefined" && data instanceof Blob) {
    return await data.text()
  }
  return undefined
}

export const WorkerCommand = cmd({
  command: "worker [url]",
  describe: "connect to a remote execution broker as a worker",
  builder: (yargs) =>
    yargs
      .positional("url", {
        type: "string",
        describe: "URL of the broker (e.g. ws://remote:8787/ws)",
      })
      .option("token", {
        type: "string",
        describe: "Authentication token for the broker",
      })
      .option("id", {
        type: "string",
        describe: "Worker identifier shown by the broker",
      })
      .option("shell", {
        type: "string",
        describe: "Shell used for execute jobs",
      })
      .option("codetwin-bin", {
        type: "string",
        describe: "Binary used for cliExecute jobs",
      })
      .option("reconnect-delay", {
        type: "number",
        default: 2000,
        describe: "Initial reconnect delay in milliseconds",
      })
      .option("max-reconnect-delay", {
        type: "number",
        default: 30000,
        describe: "Maximum reconnect delay in milliseconds",
      }),
  handler: async (args) => {
    const stored = await readRemoteBridgeState()

    const rawUrl =
      (typeof args.url === "string" && args.url.trim()) ||
      stored?.server.wsUrl ||
      process.env.CODETWIN_REMOTE_URL ||
      process.env.REMOTE_EXEC_PUBLIC_BASE_URL ||
      ""

    if (!rawUrl) {
      throw new Error(
        "Missing worker URL. Pass `codetwin worker <url>` or run `codetwin login` once to save connection settings.",
      )
    }

    const wsUrl = normalizeUrl(String(rawUrl))
    const token = typeof args.token === "string" ? args.token : stored?.workerToken
    const workerId =
      typeof args.id === "string" && args.id.trim() ? args.id.trim() : stored?.workerId || `worker-${process.pid}`
    const shell =
      typeof args.shell === "string" && args.shell.trim()
        ? args.shell.trim()
        : process.env.SHELL || process.env.REMOTE_EXEC_SHELL || "/bin/bash"
    const codetwinBin =
      typeof args["codetwin-bin"] === "string" && args["codetwin-bin"].trim()
        ? args["codetwin-bin"].trim()
        : process.env.CODETWIN_BIN || "codetwin"

    const reconnectDelayInput = Number(args["reconnect-delay"])
    const maxReconnectDelayInput = Number(args["max-reconnect-delay"])
    const reconnectDelay = Number.isFinite(reconnectDelayInput) && reconnectDelayInput > 0 ? reconnectDelayInput : 2000
    const maxReconnectDelay =
      Number.isFinite(maxReconnectDelayInput) && maxReconnectDelayInput >= reconnectDelay
        ? maxReconnectDelayInput
        : 30000

    let shouldRun = true
    const running = new Map<string, RunningProcess>()

    function stopAllRunning(reason: string) {
      if (!running.size) return
      console.error(`Stopping ${running.size} running job(s): ${reason}`)
      for (const proc of running.values()) {
        try {
          proc.kill("SIGTERM")
        } catch {
          // ignore process termination failures during shutdown
        }
      }
      running.clear()
    }

    const shutdown = () => {
      shouldRun = false
      stopAllRunning("worker shutdown")
    }

    process.once("SIGINT", shutdown)
    process.once("SIGTERM", shutdown)

    if (stored && typeof stored.tokenExpiresAt === "number" && Date.now() > stored.tokenExpiresAt) {
      console.error("Saved worker token appears expired. Run `codetwin login` again to refresh credentials.")
    }

    const headers: Record<string, string> = {
      "CodeTwin-Role": "worker",
    }
    if (token) {
      headers["Authorization"] = `Bearer ${token}`
    }

    function runJob(ws: WebSocket, msg: any) {
      const mode: JobMode = msg.type === "cliExecute" ? "cli" : "shell"
      const jobId = typeof msg.jobId === "string" ? msg.jobId : ""
      if (!jobId) {
        safeSend(ws, {
          type: "error",
          ts: Date.now(),
          message: "Missing jobId",
        })
        return
      }
      if (running.has(jobId)) {
        safeSend(ws, {
          type: "error",
          jobId,
          ts: Date.now(),
          message: "Duplicate jobId",
        })
        return
      }

      const cwd = typeof msg.cwd === "string" ? resolve(msg.cwd) : process.cwd()
      if (!existsSync(cwd)) {
        safeSend(ws, {
          type: "error",
          jobId,
          ts: Date.now(),
          message: `Working directory does not exist: ${cwd}`,
        })
        return
      }

      const env = normalizeEnv(msg.env)
      let proc: RunningProcess
      let displayCommand = ""
      let displayArgs: string[] = []

      try {
        if (mode === "shell") {
          const command = typeof msg.command === "string" ? msg.command.trim() : ""
          if (!command) throw new Error("command is required")
          displayCommand = command
          displayArgs = []
          proc = spawn(shell, ["-lc", command], {
            cwd,
            env,
            stdio: ["pipe", "pipe", "pipe"],
          })
        } else {
          const execArgs = normalizeArgs(msg.args)
          if (!execArgs.length) throw new Error("args must be a non-empty string array")

          // Standardize background execution: 
          // 1. Bypass the .cmd wrapper which mangles quotes on Windows.
          // 2. Use process.argv[0] (bun) and process.argv[1] (index.ts) directly.
          // 3. Force --use-system-ca and --conditions=browser.
          const entryPoint = process.argv[1]
          const bunArgs = [
            "run",
            "--use-system-ca",
            "--conditions=browser",
            entryPoint,
            ...execArgs,
          ]

          displayCommand = `${process.argv[0]} ${bunArgs.join(" ")}`
          displayArgs = bunArgs

          console.log(`[Worker] Executing job ${jobId}: ${displayCommand}`)
          console.log(`[Worker] CWD: ${cwd}`)

          proc = spawn(process.argv[0], bunArgs, {
            cwd,
            env,
            stdio: ["pipe", "pipe", "pipe"],
            windowsHide: true,
          })
        }
      } catch (error) {
        console.error(`[Worker] Spawn error for job ${jobId}:`, error)
        safeSend(ws, {
          type: "error",
          jobId,
          ts: Date.now(),
          message: error instanceof Error ? error.message : String(error),
        })
        return
      }

      console.log(`[Worker] Job ${jobId} started (PID ${proc.pid})`)

      running.set(jobId, proc)

      // Close stdin after a small delay to ensure the process has started
      setTimeout(() => {
        if (running.has(jobId)) {
          console.log(`[Worker] Ending stdin for job ${jobId}`)
          proc.stdin?.end()
        }
      }, 500)

      safeSend(ws, {
        type: "start",
        jobId,
        ts: Date.now(),
        mode,
        command: displayCommand,
        args: displayArgs,
        cwd,
        pid: proc.pid,
      })

      proc.stdout?.on("data", (chunk: Buffer | string) => {
        const text = chunk.toString()
        console.log(`[Worker] Job ${jobId} stdout: ${text.trim()}`)
        safeSend(ws, {
          type: "stdout",
          jobId,
          ts: Date.now(),
          text,
        })
      })

      proc.stderr?.on("data", (chunk: Buffer | string) => {
        const text = chunk.toString()
        console.log(`[Worker] Job ${jobId} stderr: ${text.trim()}`)
        safeSend(ws, {
          type: "stderr",
          jobId,
          ts: Date.now(),
          text,
        })
      })

      proc.on("error", (err) => {
        console.error(`[Worker] Job ${jobId} process error:`, err)
      })

      proc.on("error", (error) => {
        safeSend(ws, {
          type: "error",
          jobId,
          ts: Date.now(),
          message: error.message,
        })
      })

      proc.on("close", (code) => {
        console.log(`[Worker] Job ${jobId} exited with code ${code}`)
        running.delete(jobId)
        safeSend(ws, {
          type: "exit",
          jobId,
          ts: Date.now(),
          code: code ?? -1,
        })
      })
    }

    function forwardInput(ws: WebSocket, msg: any) {
      const jobId = typeof msg.jobId === "string" ? msg.jobId : ""
      if (!jobId) return
      const proc = running.get(jobId)
      if (!proc || !proc.stdin) return

      const text = typeof msg.text === "string" ? msg.text : ""
      const appendNewline = msg.appendNewline !== false
      const payload = appendNewline ? text + "\n" : text
      if (!payload) return

      proc.stdin.write(payload)

      safeSend(ws, {
        type: "input",
        jobId,
        ts: Date.now(),
        bytes: Buffer.byteLength(payload),
      })
    }

    function forwardTerminate(ws: WebSocket, msg: any) {
      const jobId = typeof msg.jobId === "string" ? msg.jobId : ""
      if (!jobId) return
      const proc = running.get(jobId)
      if (!proc) return

      const signal = typeof msg.signal === "string" && /^[A-Z0-9]+$/.test(msg.signal) ? msg.signal : "SIGTERM"
      proc.kill(signal as NodeJS.Signals)

      safeSend(ws, {
        type: "terminate",
        jobId,
        ts: Date.now(),
        signal,
      })
    }

    let delay = reconnectDelay

    while (shouldRun) {
      const fullUrl = `${wsUrl}${wsUrl.includes("?") ? "&" : "?"}workerId=${encodeURIComponent(workerId)}`
      console.log(`Connecting to broker at ${fullUrl} as ${workerId}...`)

      const ws = new WebSocket(fullUrl, { headers })

      let pingTimer: any
      const closeCode = await new Promise<number>((resolveClose) => {
        ws.addEventListener("open", () => {
          delay = reconnectDelay
          console.log("Connected to broker as worker.")
          pingTimer = setInterval(() => {
            safeSend(ws, { type: "ping", workerId })
          }, 20000)
        })

        ws.addEventListener("error", (event) => {
          console.error("WebSocket error:", event)
        })

        ws.addEventListener("message", async (event) => {
          try {
            const text = await decodeMessageData(event.data)
            if (!text) return
            const msg = JSON.parse(text)

            if (msg.type === "execute" || msg.type === "cliExecute") {
              runJob(ws, msg)
              return
            }

            if (msg.type === "input") {
              forwardInput(ws, msg)
              return
            }

            if (msg.type === "terminate") {
              forwardTerminate(ws, msg)
              return
            }
          } catch (error) {
            console.error("Failed to handle broker message:", error)
          }
        })

        ws.addEventListener("close", (event) => {
          clearInterval(pingTimer)
          resolveClose(event.code)
        })
      })

      stopAllRunning("broker connection closed")

      if (!shouldRun) break

      console.error(`Disconnected from broker (code ${closeCode}). Reconnecting in ${delay}ms...`)
      await sleep(delay)
      delay = Math.min(delay * 2, maxReconnectDelay)
    }

    stopAllRunning("worker stopped")

    if (!shouldRun) {
      console.log("Worker exited")
      return
    }

    throw new Error("Worker stopped unexpectedly")
  },
})
