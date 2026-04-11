<div align="center">
  <pre>
 +------------------------------------------------------------------+
 |           ______          __        _______       _              |
 |          / ____/___  ____/ /__     /_  __(_)_  __(_)___          |
 |         / /   / __ \/ __  / _ \     / / / / / / / / __ \         |
 |        / /___/ /_/ / /_/ /  __/    / / / / /_/ / / / / /         |
 |        \____/\____/\__,_/\___/    /_/ /_/\__,_/_/_/ /_/          |
 +------------------------------------------------------------------+
 |            TERMINAL-FIRST AI CODING AGENT + MOBILE               |
 +------------------------------------------------------------------+
  </pre>
  <p><strong>CodeTwin</strong> | <strong>Run local. Control anywhere.</strong></p>
</div>

CodeTwin is a terminal-first AI coding agent.

The CLI is the main product. Launching the CLI with no arguments opens the interactive TUI.

The mobile app is the remote control surface for the CLI agent running on your laptop.

Public links:

- Website: https://code-twin.vercel.app/
- GitHub: https://github.com/Sahnik0/CodeTwin

## Product Model

- Main experience: local CLI + TUI in your terminal.
- Companion mobile app for remote task control and approvals.
- Provider model: BYOK supported (bring your own API key).
- Free usage path: opencode provider supports no-cost models, with an upsell prompt when free usage is exhausted.

## What Is In This Repository

- `App`: Flutter mobile remote companion.
- `CLI`: codetwin runtime, wrappers, and TUI.
- `codetwin-remote-server`: bridge between mobile app and worker.
- `Website`: landing/docs and install scripts.

## Basic User Guide (Recommended)

### 1) Install CLI (One-Liner)

Windows PowerShell:

```powershell
irm https://code-twin.vercel.app/install.ps1 | iex
```

Linux/macOS:

```bash
curl -fsSL https://code-twin.vercel.app/install.sh | bash
```

After install, open a new terminal and verify:

```bash
codetwin --help
```

If you installed with one-liner, you can run `codetwin` from any project folder.

### 2) Open the TUI (Main Experience)

From your project folder:

```bash
codetwin
```

This starts the interactive CodeTwin TUI.

You can also run a one-shot task:

```bash
codetwin run "refactor auth module and add tests"
```

You can tune autonomy per run using:

```bash
codetwin run "task" --dependence-level 3
```

### 3) Provider Setup (Free Tier + BYOK)

Option A: start with the built-in free usage path (opencode provider no-cost models).

Option B: BYOK for full provider choice and limits:

```bash
codetwin providers login
codetwin providers list
codetwin models
```

Supported provider set includes OpenAI, Anthropic, Groq, Gemini, Mistral, Ollama, Azure, and others via the provider system.

### 4) Mobile Connection

Mobile connection is a core part of the CodeTwin idea, not an afterthought.

CodeTwin is built as a two-surface workflow:

1. The CLI device (your laptop/desktop) runs the agent, tools, and file operations.
2. The mobile app acts as your remote control layer for task submission, approvals, decisions, and live logs.

This design keeps execution and credentials on your own machine while giving you real-time control from anywhere.

Mobile app download link:

- Google Drive: https://drive.google.com/drive/folders/12f3pnUAb6GOitnHyF_JeRF02tre8YJ8N?usp=sharing

Remote pairing flow:

```bash
codetwin login https://codetwin-1quv.onrender.com
```

Then:

1. Copy the 12-character pairing code shown in terminal.
2. Open the mobile app Pair screen.
3. Enter the same bridge URL and pairing code.
4. Start worker:

```bash
codetwin worker
```

5. Confirm the app shows your CLI device as connected.

QR flow (faster pairing):

- Open the mobile app Pair screen and tap Scan QR.
- Scan the pairing QR shown by your CLI environment.
- If QR is not available, use the 12-character code flow above.

### 5) Choose Dependence Level (1-5)

CodeTwin has five dependence levels (autonomy levels). You can set them per run with `--dependence-level`.

Example:

```bash
codetwin run "refactor auth service" --dependence-level 3
```

Level summary:

1. Level 1 - Full supervision: asks before every write/delete/shell action.
2. Level 2 - Reads are free: auto-allows read-only actions and asks before write-like actions.
3. Level 3 - Smart checkpoints (default): allows most actions with explicit approval checkpoints.
4. Level 4 - Destructive only: asks only for destructive classes.
5. Level 5 - Full delegation: allows all actions and suppresses question prompts.

Valid range is 1 through 5. If omitted, behavior is equivalent to level 3.

## Developer Guide

Use this if you want to change CodeTwin code, not just use it.

### Prerequisites

- Git
- Bun
- Flutter SDK (only if editing mobile app)
- Android Studio/Xcode (only if building mobile targets)

### Clone Source

```bash
git clone https://github.com/Sahnik0/CodeTwin.git
cd CodeTwin
```

### Run CLI From Source

Windows:

```powershell
.\CLI\codetwin.cmd
```

Linux/macOS:

```bash
./CLI/codetwin
```

With no args, both wrappers open the TUI.

To verify launcher from source:

Windows:

```powershell
.\CLI\codetwin.cmd --help
```

Linux/macOS:

```bash
./CLI/codetwin --help
```

### Run Mobile App Locally (Only If You Are Developing App Changes)

If you are just a normal user, skip this section.

```bash
cd App
flutter pub get
flutter run
```

### Remote Worker Dev Flow

Windows:

```powershell
.\CLI\codetwin.cmd login https://codetwin-1quv.onrender.com
.\CLI\codetwin.cmd worker
```

Linux/macOS:

```bash
./CLI/codetwin login https://codetwin-1quv.onrender.com
./CLI/codetwin worker
```

## Quick Command Map

- Start TUI: `codetwin`
- One-shot task: `codetwin run "task"`
- Provider login: `codetwin providers login`
- List providers: `codetwin providers list`
- List models: `codetwin models`
- Pair remote app: `codetwin login <bridge-url>`
- Start remote worker: `codetwin worker`
- Set autonomy level: `codetwin run "task" --dependence-level <1..5>`
- Usage/cost stats: `codetwin stats`

## Troubleshooting

- `codetwin` not found after one-liner install:
  - open a new terminal
  - ensure your PATH update is applied
- Pairing code expired:
  - rerun `codetwin login` and enter the new code
- Worker not connecting:
  - confirm the same bridge URL is used in both CLI and app
- App not showing your device:
  - confirm `codetwin worker` is running
  - confirm laptop internet is available
- Unexpected behavior at high autonomy:
  - rerun with `--dependence-level 2` or `--dependence-level 3`

## Notes On Free Usage

- Free usage can be exhausted depending on provider path and limits.
- When exceeded on opencode free usage, the CLI may surface an upsell message.
- For production reliability, BYOK is recommended.

## Documentation

- Getting Started: https://code-twin.vercel.app/docs/getting-started
- Dependence Levels: https://code-twin.vercel.app/docs/dependence-levels
- Mobile Connection: https://code-twin.vercel.app/docs/mobile-connection
- Remote Control: https://code-twin.vercel.app/docs/remote-control
- CLI Reference: https://code-twin.vercel.app/docs/cli-reference