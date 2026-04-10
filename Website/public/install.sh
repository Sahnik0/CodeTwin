#!/usr/bin/env bash
# CodeTwin installer
# Usage: curl -fsSL https://CodeTwin.dev/install.sh | bash

set -euo pipefail

REPO="CodeTwin/CodeTwin"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="CodeTwin"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)  echo "linux"  ;;
    *)      echo "unsupported" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64)  echo "amd64" ;;
    arm64)   echo "arm64" ;;
    aarch64) echo "arm64" ;;
    *)       echo "unsupported" ;;
  esac
}

main() {
  OS=$(detect_os)
  ARCH=$(detect_arch)

  if [ "$OS" = "unsupported" ] || [ "$ARCH" = "unsupported" ]; then
    echo "Unsupported platform. Install via npm instead:"
    echo "  npm install -g CodeTwin"
    exit 1
  fi

  echo "Detected: $OS/$ARCH"
  echo ""
  echo "This is a stub installer. The npm package is the canonical install method:"
  echo ""
  echo "  npm install -g CodeTwin"
  echo ""
  echo "Or use your preferred package manager:"
  echo "  pnpm add -g CodeTwin"
  echo "  bun add -g CodeTwin"
  echo ""
  echo "After installation:"
  echo "  CodeTwin --version"
  echo "  cd your-project && CodeTwin config init"
}

main "$@"
