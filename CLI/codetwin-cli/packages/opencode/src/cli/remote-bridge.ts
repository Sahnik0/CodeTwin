import path from "path"
import { Global } from "../global"
import { Filesystem } from "../util/filesystem"
import { readFile } from "fs/promises"

export interface RemoteBridgeState {
  version: 1
  updatedAt: number
  pairingId: string
  cliDeviceId: string
  workerId: string
  workerToken: string
  tokenExpiresAt: number
  server: {
    apiBaseUrl: string
    wsUrl: string
  }
}

const STORE_FILE = path.join(Global.Path.config, "remote-bridge.json")

export function getRemoteBridgeStatePath() {
  return STORE_FILE
}

/** Read JSON tolerating a UTF-8 BOM that PowerShell/Windows editors may add. */
async function readJsonNoBom<T = any>(p: string): Promise<T> {
  let text = await readFile(p, "utf-8")
  // Strip UTF-8 BOM (EF BB BF) if present — Node does not strip it automatically
  if (text.charCodeAt(0) === 0xfeff) text = text.slice(1)
  return JSON.parse(text) as T
}

export async function readRemoteBridgeState(): Promise<RemoteBridgeState | undefined> {
  try {
    const parsed = await readJsonNoBom<RemoteBridgeState>(STORE_FILE)
    if (!parsed || parsed.version !== 1) return undefined
    if (typeof parsed.workerToken !== "string" || !parsed.workerToken) return undefined
    if (typeof parsed.workerId !== "string" || !parsed.workerId) return undefined
    if (typeof parsed.pairingId !== "string" || !parsed.pairingId) return undefined
    if (typeof parsed.server?.apiBaseUrl !== "string" || !parsed.server.apiBaseUrl) return undefined
    if (typeof parsed.server?.wsUrl !== "string" || !parsed.server.wsUrl) return undefined
    return parsed
  } catch {
    return undefined
  }
}

export async function writeRemoteBridgeState(next: RemoteBridgeState) {
  // Explicitly write as UTF-8 WITHOUT BOM so readFile("utf-8") can parse it cleanly
  // on all platforms. Filesystem.writeJson delegates to Node writeFile which may
  // add a BOM on some Windows environments.
  const json = JSON.stringify(next, null, 2)
  await Filesystem.write(STORE_FILE, json, 0o600)
}

export function normalizeHttpUrl(input: string) {
  let value = input.trim()
  if (!value) throw new Error("server URL is required")
  if (!/^https?:\/\//.test(value)) {
    value = `https://${value}`
  }
  return value.replace(/\/+$/, "")
}

export function normalizeWsUrl(input: string) {
  let value = input.trim()
  if (!value) throw new Error("worker websocket URL is required")

  // Recover from common misconfiguration: "wss://https://host/ws"
  value = value.replace(/^wss?:\/\/https?:\/\/?/i, (prefix) =>
    prefix.toLowerCase().startsWith("wss://") ? "wss://" : "ws://",
  )

  if (value.startsWith("http://")) value = "ws://" + value.slice("http://".length)
  if (value.startsWith("https://")) value = "wss://" + value.slice("https://".length)
  if (!value.startsWith("ws://") && !value.startsWith("wss://")) {
    value = "ws://" + value
  }

  let parsed: URL
  try {
    parsed = new URL(value)
  } catch {
    throw new Error("invalid worker websocket URL")
  }

  const normalizedPath = parsed.pathname.replace(/\/+$/, "")
  parsed.pathname = /\/ws$/i.test(normalizedPath) ? normalizedPath || "/ws" : `${normalizedPath || ""}/ws`
  parsed.hash = ""

  return parsed.toString()
}
