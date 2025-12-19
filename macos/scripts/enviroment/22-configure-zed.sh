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
echo "========= [22] CONFIGURING ZED ================"
echo "=============================================="

# Determine Zed user directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  ZED_USER_DIR="$HOME/.config/zed"
else
  echo "❌ This script is only for macOS."
  exit 1
fi

mkdir -p "$ZED_USER_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_PATH="$ZED_USER_DIR/settings.json"

echo "Detected Zed directory: $ZED_USER_DIR"
echo ""

echo "Copying settings.json..."
cp "$SCRIPT_DIR/../../config/zed/settings.json" "$SETTINGS_PATH"
echo "→ settings.json updated successfully!"

echo "=============================================="
echo "============== [22] DONE ===================="
echo "=============================================="
echo "🎉 Zed configured successfully!"
echo "   Open Zed again to apply everything."
echo ""
echo "▶ Next, run: bash 23-install-something-else.sh"

