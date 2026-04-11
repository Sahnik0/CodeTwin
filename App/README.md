# CodeTwin Mobile App

## Pairing And Run Guide

This app connects to a remote CodeTwin bridge and a CLI worker.

### Normal user flow (hosted bridge)

Use this with a hosted URL, for example:

- https://codetwin-1quv.onrender.com

1. In CLI terminal:
	.\codetwin.cmd login https://codetwin-1quv.onrender.com
2. Copy the 12-character pairing code shown by CLI.
3. In app Pair screen, enter:
	- Server URL: https://codetwin-1quv.onrender.com
	- Pairing code: code from CLI
4. Tap Pair Device.
5. Start worker:
	.\codetwin.cmd worker
6. Run app:
	flutter run

After first pairing, you usually only need steps 5 and 6.

### Do users need REMOTE_EXEC_TOKEN?

No, not for normal pairing.

The login + pairing flow automatically creates and stores scoped credentials:

- App stores client token securely.
- CLI stores worker token in its remote bridge state.

### When to re-run login

Run login again if:

- token expired,
- bridge URL changed,
- stored credentials were cleared.

Then start worker again.

## Troubleshooting

- Worker not connecting: run .\codetwin.cmd worker from the CLI folder and check terminal output.
- App returns to Pair screen: token likely expired or pairing was cleared; run login again.
- Bridge mismatch: ensure app server URL and worker bridge URL are from the same environment.
