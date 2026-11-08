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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

if [ -f "$PROJECT_ROOT/lib/brew_helper.sh" ]; then
    # shellcheck source=lib/brew_helper.sh
    source "$PROJECT_ROOT/lib/brew_helper.sh"
    ensure_homebrew_in_path
fi

echo "=============================================="
echo "========== [10] INSTALLING ZED =============="
echo "=============================================="

ZED_APP="/Applications/Zed.app"

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Install Homebrew first or download Zed from https://zed.dev/download"
    exit 1
fi

if brew list --cask zed &> /dev/null; then
    echo "✓ Zed is already installed via Homebrew"
elif [ -d "$ZED_APP" ]; then
    echo "→ Registering existing Zed.app with Homebrew (--adopt)..."
    brew install --cask --adopt zed || echo "⚠️  Homebrew could not adopt Zed.app (app is still usable)"
else
    echo "→ Installing Zed via Homebrew..."
    brew install --cask zed
fi

if [ ! -d "$ZED_APP" ]; then
    echo "❌ Zed.app not found after installation"
    exit 1
fi

version="$(defaults read "$ZED_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")"
echo "✓ Zed version: $version"
command -v zed &> /dev/null && echo "✓ 'zed' command available (zed . opens the current folder)"

echo "=============================================="
echo "============== [10] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 11-install-claude.sh"
