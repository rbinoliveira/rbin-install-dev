#!/usr/bin/env bash

# ────────────────────────────────────────────────────────────────
# Module Guard - Prevent Direct Execution
# ────────────────────────────────────────────────────────────────
# This script should only be executed by 00-install-all.sh
if [ -z "$INSTALL_ALL_RUNNING" ]; then
    SCRIPT_NAME=$(basename "$0")
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    INSTALL_SCRIPT="$SCRIPT_DIR/00-install-all.sh"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  This script should not be executed directly"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The script \"$SCRIPT_NAME\" is a module and should only be"
    echo "executed as part of the complete installation process."
    echo ""
    echo "To run the complete installation, use:"
    echo "  bash $INSTALL_SCRIPT"
    echo ""
    echo "Or from the project root:"
    echo "  bash run.sh"
    echo ""
    exit 1
fi


set -e

echo "=============================================="
echo "========= [09] INSTALLING CURSOR ============"
echo "=============================================="

echo "Installing Cursor Editor (desktop IDE)..."

# Check if already installed
if command -v cursor &> /dev/null; then
    echo "✓ Cursor is already installed: $(cursor --version 2>&1 | head -1)"
    echo "=============================================="
    echo "============== [09] DONE ===================="
    echo "=============================================="
    echo "▶ Next, run: bash 10-install-claude.sh"
    exit 0
fi

# Detect architecture for the download API
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)  API_PLATFORM="linux-x64";;
    arm64|aarch64) API_PLATFORM="linux-arm64";;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Query the official download API for the latest stable .deb
echo "→ Fetching latest Cursor release info..."
API_URL="https://cursor.com/api/download?platform=${API_PLATFORM}&releaseTrack=stable"
API_RESPONSE="$(curl -fsSL "$API_URL")"

DEB_URL="$(echo "$API_RESPONSE" | grep -o '"debUrl":"[^"]*"' | cut -d'"' -f4)"
VERSION="$(echo "$API_RESPONSE" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)"

if [ -z "$DEB_URL" ]; then
    echo "❌ Could not resolve the .deb download URL from $API_URL"
    echo ""
    echo "Please install Cursor manually:"
    echo "  1. Visit: https://cursor.com/downloads"
    echo "  2. Download the Linux .deb package"
    echo "  3. Install with: sudo dpkg -i ~/Downloads/cursor*.deb"
    exit 1
fi

echo "→ Latest version: ${VERSION:-unknown}"
echo "→ Downloading: $DEB_URL"

DEB_FILE="$(mktemp /tmp/cursor-XXXXXX.deb)"
trap 'rm -f "$DEB_FILE"' EXIT

if ! curl -fL --progress-bar "$DEB_URL" -o "$DEB_FILE"; then
    echo "❌ Download failed. Please check your internet connection."
    exit 1
fi

echo "→ Installing Cursor ${VERSION:-}..."
if ! sudo dpkg -i "$DEB_FILE"; then
    echo "→ Fixing dependencies..."
    sudo apt-get --fix-broken install -y
    sudo dpkg -i "$DEB_FILE"
fi

# Verify installation
if command -v cursor &> /dev/null; then
    echo "✓ Cursor installed successfully!"
    cursor --version 2>/dev/null | head -1 || true
else
    echo "❌ Cursor installation failed (command 'cursor' not found)"
    exit 1
fi

echo "=============================================="
echo "============== [09] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 10-install-claude.sh"
