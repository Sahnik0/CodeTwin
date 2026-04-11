# CodeTwin

CodeTwin is a terminal-first AI coding agent with a paired mobile app for remote control and approvals.

Public links:

- Website: https://code-twin.vercel.app/
- GitHub: https://github.com/Sahnik0/CodeTwin

This README is a full install and run guide for new users on Windows and Linux/macOS.

## What Is In This Repository

- App: Flutter mobile app (pairing, approvals, dashboard, timeline)
- CLI: Core codetwin runtime and local launchers
- codetwin-remote-server: Bridge service between mobile app and worker
- Website: Marketing/docs site and public install script

## Installation Paths

You have 2 supported ways to start using CodeTwin:

1. Source install (Windows, Linux, macOS)
2. One-liner shell install (Linux/macOS):

```bash
curl -fsSL https://code-twin.vercel.app/install.sh | bash
```

After one-liner install, use:

```bash
codetwin login https://codetwin-1quv.onrender.com
codetwin worker
```

For Windows, use the source install path below.

## Prerequisites

### Required for CLI

- Git
- Bun

### Required for mobile app development

- Flutter SDK
- Android Studio (Android target) and/or Xcode (iOS target)

## Source Install (Windows)

Open PowerShell:

```powershell
git clone https://github.com/Sahnik0/CodeTwin.git
cd CodeTwin
```

Pair CLI device with bridge:

```powershell
.\CLI\codetwin.cmd login https://codetwin-1quv.onrender.com
```

The CLI prints a 12-character pairing code.

In mobile app Pair screen, enter:

- Server URL: https://codetwin-1quv.onrender.com
- Pairing code: value shown in terminal

Then start worker:

```powershell
.\CLI\codetwin.cmd worker
```

Run mobile app:

```powershell
cd .\App
flutter pub get
flutter run
```

## Source Install (Linux/macOS)

Open your shell:

```bash
git clone https://github.com/Sahnik0/CodeTwin.git
cd CodeTwin
```

Pair CLI device with bridge:

```bash
./CLI/codetwin login https://codetwin-1quv.onrender.com
```

The CLI prints a 12-character pairing code.

In mobile app Pair screen, enter:

- Server URL: https://codetwin-1quv.onrender.com
- Pairing code: value shown in terminal

Start worker:

```bash
./CLI/codetwin worker
```

Run mobile app:

```bash
cd App
flutter pub get
flutter run
```

## Daily Workflow After First Pairing

### Windows

```powershell
.\CLI\codetwin.cmd worker
```

### Linux/macOS

```bash
./CLI/codetwin worker
```

If installed with the one-liner and your PATH is set:

```bash
codetwin worker
```

## Pairing And Tokens Explained

Normal user flow does not require manually supplying REMOTE_EXEC_TOKEN.

What happens during normal pairing:

1. You run login and get a short pairing code.
2. Mobile app confirms the code.
3. Bridge issues scoped tokens automatically.
4. CLI stores worker credentials.
5. App stores client token securely.

Use REMOTE_EXEC_TOKEN only for admin-style direct access in self-hosted bridge setups.

## Troubleshooting

- Worker does not connect:
  - Re-run login, then start worker again.
  - Ensure server URL is the same in both CLI and mobile app.
- Pairing code expired:
  - Run login again and enter the new code.
- Command not found after one-liner install:
  - Open a new terminal.
  - Ensure ~/.local/bin is in PATH.

## Command Reference

Pair device:

- Windows: .\CLI\codetwin.cmd login https://codetwin-1quv.onrender.com
- Linux/macOS: ./CLI/codetwin login https://codetwin-1quv.onrender.com

Start worker:

- Windows: .\CLI\codetwin.cmd worker
- Linux/macOS: ./CLI/codetwin worker
- One-liner install: codetwin worker