#!/usr/bin/env bash
# DevTwin installer
# Usage: curl -fsSL https://devtwin.dev/install.sh | bash

set -euo pipefail

REPO="devtwin/devtwin"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="devtwin"

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
    echo "  npm install -g devtwin"
    exit 1
  fi

  echo "Detected: $OS/$ARCH"
  echo ""
  echo "This is a stub installer. The npm package is the canonical install method:"
  echo ""
  echo "  npm install -g devtwin"
  echo ""
  echo "Or use your preferred package manager:"
  echo "  pnpm add -g devtwin"
  echo "  bun add -g devtwin"
  echo ""
  echo "After installation:"
  echo "  devtwin --version"
  echo "  cd your-project && devtwin config init"
}

main "$@"
