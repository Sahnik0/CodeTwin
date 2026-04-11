# CodeTwin

## Mobile + CLI Quick Start (Recommended)

This is the normal flow used with a hosted bridge URL such as:

- https://codetwin-1quv.onrender.com

You do not need to manually create or copy a remote token for this flow.

### 1. One-time pairing

From the CLI folder:

1. Run:
	.\codetwin.cmd login https://codetwin-1quv.onrender.com
2. CLI shows a 12-character pairing code.
3. Open the mobile app Pair screen.
4. Enter:
	- Server URL: https://codetwin-1quv.onrender.com
	- Pairing code: the code shown by CLI
5. Tap Pair Device.

Result:

- App stores a client token.
- CLI stores worker credentials in its config.
- Pairing is complete.

### 2. Daily run (after pairing)

From the CLI folder:

1. Start worker:
	.\codetwin.cmd worker
2. Start app:
	flutter run

Notes:

- You can still run .\codetwin.cmd worker wss://codetwin-1quv.onrender.com/ws, but it is optional once login has saved state.
- If worker token expires, run login again, then start worker again.

## What Is REMOTE_EXEC_TOKEN?

REMOTE_EXEC_TOKEN is only for direct admin-style access to a self-hosted bridge server.

It is not required for the normal user pairing flow above.

In normal pairing:

- login creates a short pairing code,
- mobile completes pairing,
- server issues scoped client/worker tokens automatically,
- worker uses stored credentials when you run .\codetwin.cmd worker.