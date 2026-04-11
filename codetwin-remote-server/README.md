# CodeTwin Remote Bridge Server

This service is designed to be deployed separately from the CLI workspace and act as a bridge between:

- your mobile app
- your local CodeTwin CLI running on laptop/server

It provides:

- command execution
- full CodeTwin CLI command control
- live output updates over SSE and WebSocket
- stdin and terminate controls for running jobs

## Start

### Recommended (pairing-enabled)

Set a signing secret and start:

PowerShell:

$env:REMOTE_EXEC_SIGNING_SECRET="replace-me"
bun run server.ts

Bash:

REMOTE_EXEC_SIGNING_SECRET=replace-me bun run server.ts

This enables:

- POST /pair/cli/start
- POST /pair/cli/poll
- POST /pair/mobile/complete

### Optional admin token mode

If you also set REMOTE_EXEC_TOKEN, that token can be used for admin-style direct requests.

PowerShell:

$env:REMOTE_EXEC_TOKEN="replace-me"

Bash:

REMOTE_EXEC_TOKEN=replace-me

Defaults:

- host: 0.0.0.0
- port: 8787
- codetwin binary: codetwin

## Environment

- REMOTE_EXEC_SIGNING_SECRET: enables secure CLI+mobile pairing and signs pair tokens
- REMOTE_EXEC_PAIRING_SECRET: legacy alias for REMOTE_EXEC_SIGNING_SECRET
- REMOTE_EXEC_TOKEN: optional admin bearer/query token (not required for normal pairing flow)
- REMOTE_EXEC_HOST: bind host (default 0.0.0.0)
- REMOTE_EXEC_PORT: bind port (default 8787)
- REMOTE_EXEC_SHELL: shell path (default /bin/bash)
- REMOTE_EXEC_MAX_LOGS: in-memory log chunks per job (default 4000)
- REMOTE_EXEC_DEFAULT_CWD: default working dir when cwd is omitted
- REMOTE_EXEC_PUBLIC_BASE_URL: public API base URL returned in pairing responses
- REMOTE_EXEC_PUBLIC_WS_URL: public WS URL returned in pairing responses
- CODETWIN_BIN: path to codetwin executable (default codetwin)

## HTTP API

Health:

GET /health

Features:

GET /features

List jobs:

GET /jobs

Start shell command:

POST /jobs

Body example:

{
  "command": "ls -la",
  "cwd": "/home/user/project"
}

Start CodeTwin CLI command directly:

POST /cli/exec

Body example:

{
  "args": ["run", "Fix lint errors", "--format", "json"],
  "cwd": "/home/user/project"
}

Job details:

GET /jobs/:id

Send input to running job:

POST /jobs/:id/input

Body example:

{
  "text": "yes",
  "appendNewline": true
}

Terminate running job:

POST /jobs/:id/terminate

Body example:

{
  "signal": "SIGTERM"
}

SSE stream:

GET /jobs/:id/stream

or global stream:

GET /stream

## WebSocket

Connect:

ws://HOST:PORT/ws?token=PAIR_OR_ADMIN_TOKEN

Supported client messages:

- { "type": "subscribe", "jobId": "..." }
- { "type": "execute", "command": "pwd", "cwd": "/path" }
- { "type": "cliExecute", "args": ["models"], "cwd": "/path" }
- { "type": "input", "jobId": "...", "text": "hello", "appendNewline": true }
- { "type": "terminate", "jobId": "...", "signal": "SIGTERM" }

The server pushes live events such as start, stdout, stderr, exit, and error.

## Auth

There are two credential types:

1. Pair tokens (normal user flow)

- Generated automatically by login + mobile pair.
- Worker uses worker token.
- Mobile app uses client token.

2. Admin token (optional)

- Only if REMOTE_EXEC_TOKEN is configured.

Accepted credential transport:

- Authorization: Bearer YOUR_TOKEN
- X-Remote-Token: YOUR_TOKEN
- query string token=YOUR_TOKEN

## Normal End-User Flow

1. CLI device: codetwin login <bridge-url>
2. Mobile app: complete pairing with code shown by CLI
3. CLI device: codetwin worker
4. Mobile app connects and runs tasks

Users do not need to manually provide REMOTE_EXEC_TOKEN in this flow.

## Mobile app recommendation

1. Use /cli/exec for feature-safe CodeTwin control.
2. Use /jobs/:id/stream or WebSocket for live updates.
3. Use /jobs/:id/input for interactive prompts.
4. Use /jobs/:id/terminate for cancellation.

This lets your mobile app control all CLI features exposed by the codetwin command.
