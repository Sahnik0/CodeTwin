# CodeTwin Mobile App

This Flutter app pairs with the CodeTwin CLI worker through the remote bridge.

For full setup (CLI + app + direct installer), see the root guide:

- ../README.md

## Quick Pairing Flow

Bridge URL example:

- https://codetwin-1quv.onrender.com

### Windows

```powershell
.\CLI\codetwin.cmd login https://codetwin-1quv.onrender.com
```

### Linux/macOS

```bash
./CLI/codetwin login https://codetwin-1quv.onrender.com
```

In the app Pair screen:

1. Enter bridge URL.
2. Enter the 12-character code from CLI.
3. Tap Pair Device.

Start worker:

- Windows: .\CLI\codetwin.cmd worker
- Linux/macOS: ./CLI/codetwin worker
- One-liner install users: codetwin worker

Run app:

```bash
flutter pub get
flutter run
```

## Token Notes

REMOTE_EXEC_TOKEN is not required for normal user pairing.

Pairing auto-issues and stores scoped client/worker tokens.

## Troubleshooting

- Pairing code expired: run login again.
- Worker offline: restart worker command for your OS.
- App returns to Pair screen: credentials likely expired/cleared, pair again.
