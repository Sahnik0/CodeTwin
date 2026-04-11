import { cmd } from "./cmd"
import { UI } from "../ui"
import {
  getRemoteBridgeStatePath,
  normalizeHttpUrl,
  normalizeWsUrl,
  readRemoteBridgeState,
  writeRemoteBridgeState,
} from "../remote-bridge"
import QRCode from "qrcode"

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function postJson(url: string, payload: unknown) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(payload),
  })

  let body: any = {}
  try {
    body = await response.json()
  } catch {
    body = {}
  }

  if (!response.ok) {
    const message = typeof body?.error === "string" ? body.error : `Request failed with ${response.status}`
    throw new Error(message)
  }

  return body
}

export const RemoteLoginCommand = cmd({
  command: "login [url]",
  describe: "pair this CLI device with a remote CodeTwin bridge",
  builder: (yargs) =>
    yargs
      .positional("url", {
        type: "string",
        describe: "Remote bridge API URL (e.g. https://bridge.example.com)",
      })
      .option("device-name", {
        type: "string",
        describe: "Human-readable name for this CLI device",
      })
      .option("timeout", {
        type: "number",
        default: 600,
        describe: "Maximum wait time in seconds for mobile confirmation",
      })
      .option("poll-interval", {
        type: "number",
        default: 2000,
        describe: "Polling interval in milliseconds",
      })
      .option("show-token", {
        type: "boolean",
        default: false,
        describe: "Print worker token after pairing (debug only)",
      }),
  handler: async (args) => {
    const existing = await readRemoteBridgeState()

    const rawUrl =
      (typeof args.url === "string" && args.url) ||
      process.env.CODETWIN_REMOTE_URL ||
      process.env.REMOTE_EXEC_PUBLIC_BASE_URL ||
      existing?.server.apiBaseUrl

    if (!rawUrl) {
      throw new Error(
        "Missing bridge URL. Pass it as `codetwin login <url>` or set CODETWIN_REMOTE_URL environment variable.",
      )
    }

    const baseUrl = normalizeHttpUrl(rawUrl)
    const timeoutSeconds = Math.max(30, Number(args.timeout ?? 600))
    const pollInterval = Math.max(500, Number(args["poll-interval"] ?? 2000))
    const cliDeviceId = existing?.cliDeviceId || `cli-${crypto.randomUUID()}`
    const cliDeviceName =
      (typeof args["device-name"] === "string" && args["device-name"].trim()) ||
      process.env.CODETWIN_DEVICE_NAME ||
      process.env.HOSTNAME ||
      "CodeTwin CLI"

    UI.empty()
    UI.println(UI.Style.TEXT_INFO_BOLD + "Starting secure device pairing..." + UI.Style.TEXT_NORMAL)
    UI.println(UI.Style.TEXT_DIM + `Bridge: ${baseUrl}` + UI.Style.TEXT_NORMAL)

    const started = await postJson(`${baseUrl}/pair/cli/start`, {
      cliDeviceId,
      cliDeviceName,
    })

    const code = String(started?.code ?? "").toUpperCase()
    const pairingSessionId = String(started?.pairingSessionId ?? "")
    const pollToken = String(started?.pollToken ?? "")
    const expiresAt = Number(started?.expiresAt ?? 0)
    const serverApi =
      typeof started?.apiBaseUrl === "string" && started.apiBaseUrl
        ? normalizeHttpUrl(started.apiBaseUrl)
        : baseUrl
    const serverWs =
      typeof started?.wsUrl === "string" && started.wsUrl ? normalizeWsUrl(started.wsUrl) : normalizeWsUrl(baseUrl)

    if (!code || !pairingSessionId || !pollToken || !Number.isFinite(expiresAt)) {
      throw new Error("Pairing start response is invalid")
    }

    UI.empty()
    UI.println(UI.Style.TEXT_HIGHLIGHT_BOLD + "Enter this 12-character code in the mobile app:" + UI.Style.TEXT_NORMAL)
    UI.println(UI.Style.TEXT_SUCCESS_BOLD + code + UI.Style.TEXT_NORMAL)

    const qrPayload = JSON.stringify({
      type: "codetwin-pairing",
      v: 1,
      apiBaseUrl: serverApi,
      code,
    })

    try {
      const terminalQr = await QRCode.toString(qrPayload, {
        type: "terminal",
        small: true,
        errorCorrectionLevel: "M",
        margin: 1,
      })

      UI.empty()
      UI.println(UI.Style.TEXT_INFO_BOLD + "Scan this QR in the mobile app:" + UI.Style.TEXT_NORMAL)
      UI.println(terminalQr)
      UI.println(UI.Style.TEXT_DIM + "(Manual fallback: enter the code shown above)" + UI.Style.TEXT_NORMAL)
    } catch {
      UI.println(UI.Style.TEXT_DIM + "Could not render QR in this terminal. Use the code above instead." + UI.Style.TEXT_NORMAL)
    }

    UI.println(
      UI.Style.TEXT_DIM +
        `Code expires at ${new Date(expiresAt).toISOString()} (UTC). Waiting for mobile confirmation...` +
        UI.Style.TEXT_NORMAL,
    )

    const waitUntil = Date.now() + timeoutSeconds * 1000
    let pairing: any

    while (Date.now() < waitUntil) {
      const polled = await postJson(`${baseUrl}/pair/cli/poll`, {
        pairingSessionId,
        pollToken,
      })

      const status = String(polled?.status ?? "")
      if (status === "paired") {
        pairing = polled?.pairing
        break
      }

      if (status === "expired") {
        throw new Error("Pairing code expired. Run `codetwin login` again.")
      }

      await sleep(pollInterval)
    }

    if (!pairing) {
      throw new Error("Timed out waiting for mobile pairing confirmation")
    }

    const workerToken = typeof pairing.workerToken === "string" ? pairing.workerToken : ""
    const workerId = typeof pairing.workerId === "string" ? pairing.workerId : ""
    const pairingId = typeof pairing.pairingId === "string" ? pairing.pairingId : ""
    const tokenExpiresAt = Number(pairing.tokenExpiresAt ?? 0)
    const finalApi =
      typeof pairing.apiBaseUrl === "string" && pairing.apiBaseUrl ? normalizeHttpUrl(pairing.apiBaseUrl) : serverApi
    const finalWs = typeof pairing.wsUrl === "string" && pairing.wsUrl ? normalizeWsUrl(pairing.wsUrl) : serverWs

    if (!workerToken || !workerId || !pairingId || !Number.isFinite(tokenExpiresAt)) {
      throw new Error("Pairing result is missing required credentials")
    }

    await writeRemoteBridgeState({
      version: 1,
      updatedAt: Date.now(),
      pairingId,
      cliDeviceId,
      workerId,
      workerToken,
      tokenExpiresAt,
      server: {
        apiBaseUrl: finalApi,
        wsUrl: finalWs,
      },
    })

    UI.empty()
    UI.println(UI.Style.TEXT_SUCCESS_BOLD + "Pairing complete." + UI.Style.TEXT_NORMAL)
    UI.println(UI.Style.TEXT_DIM + `Credentials saved to ${getRemoteBridgeStatePath()}` + UI.Style.TEXT_NORMAL)
    const nextStep = "codetwin worker"
    UI.println(UI.Style.TEXT_INFO_BOLD + "Next step:" + UI.Style.TEXT_NORMAL + ` ${nextStep}`)

    if (args["show-token"]) {
      UI.println(UI.Style.TEXT_WARNING + `Worker token: ${workerToken}` + UI.Style.TEXT_NORMAL)
    }
  },
})
