#!/usr/bin/env bash
# CodeTwin installer for Linux/macOS.
# Usage: curl -fsSL https://code-twin.vercel.app/install.sh | bash

set -euo pipefail

REPO_URL="${CODETWIN_REPO_URL:-https://github.com/Sahnik0/CodeTwin.git}"
REPO_BRANCH="${CODETWIN_BRANCH:-main}"
INSTALL_HOME="${CODETWIN_HOME:-$HOME/.codetwin}"
REPO_DIR="$INSTALL_HOME/repo"
BIN_DIR="$HOME/.local/bin"
LAUNCHER_PATH="$BIN_DIR/codetwin"
NO_PATH_UPDATE="${CODETWIN_NO_PATH_UPDATE:-0}"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

detect_os() {
  case "$(uname -s)" in
    Linux) echo "linux" ;;
    Darwin) echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unsupported" ;;
  esac
}

resolve_shell_rc() {
  local shell_path="${SHELL:-}"
  local shell_name="${shell_path##*/}"
  case "$shell_name" in
    zsh) echo "$HOME/.zshrc" ;;
    bash) echo "$HOME/.bashrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *) echo "" ;;
  esac
}

ensure_path() {
  local rc_file
  rc_file="$(resolve_shell_rc)"

  if [ -z "$rc_file" ]; then
    log "Could not detect a supported shell rc file."
    log "Add this to your shell startup file manually:"
    log "  export PATH=\"$BIN_DIR:\$PATH\""
    return
  fi

  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"

  if grep -Fq '# >>> codetwin >>>' "$rc_file"; then
    return
  fi

  local shell_path="${SHELL:-}"
  local shell_name="${shell_path##*/}"

  {
    printf '\n# >>> codetwin >>>\n'
    if [ "$shell_name" = "fish" ]; then
      printf 'set -gx PATH %s $PATH\n' "$BIN_DIR"
    else
      printf 'export PATH="%s:$PATH"\n' "$BIN_DIR"
    fi
    printf '# <<< codetwin <<<\n'
  } >>"$rc_file"

  log "Updated PATH in $rc_file"
}

main() {
  local os
  os="$(detect_os)"

  if [ "$os" = "windows" ]; then
    fail "This script targets Linux/macOS shells. For Windows, use the PowerShell setup in the repository README."
  fi

  if [ "$os" = "unsupported" ]; then
    fail "Unsupported operating system."
  fi

  require_cmd git
  if ! command -v bun >/dev/null 2>&1; then
    fail "Bun is required. Install it first: https://bun.sh/install"
  fi

  log "Installing CodeTwin from $REPO_URL ($REPO_BRANCH)..."
  mkdir -p "$INSTALL_HOME"

  if [ -d "$REPO_DIR/.git" ]; then
    log "Existing install found, updating..."
    git -C "$REPO_DIR" fetch --depth=1 origin "$REPO_BRANCH"
    git -C "$REPO_DIR" checkout -B "$REPO_BRANCH" "origin/$REPO_BRANCH"
  else
    log "Cloning repository..."
    git clone --depth=1 --branch "$REPO_BRANCH" "$REPO_URL" "$REPO_DIR"
  fi

  log "Installing CLI dependencies (this may take a minute)..."
  bun install --cwd "$REPO_DIR/CLI/codetwin-cli"

  mkdir -p "$BIN_DIR"
  cat >"$LAUNCHER_PATH" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${CODETWIN_HOME:-$HOME/.codetwin}/repo"
exec "$ROOT/CLI/codetwin" "$@"
EOF
  chmod +x "$LAUNCHER_PATH"

  if [ "$NO_PATH_UPDATE" != "1" ]; then
    ensure_path
  fi

  log ""
  log "CodeTwin installed successfully."
  log ""
  log "Next steps:"
  log "  1) Open a new terminal (or source your shell rc)."
  log "  2) Run: codetwin --help"
  log "  3) Pair with bridge: codetwin login https://codetwin-1quv.onrender.com"
  log "  4) Start worker: codetwin worker"
}

main "$@"
