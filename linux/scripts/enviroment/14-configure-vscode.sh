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
echo "========= [14] CONFIGURING VS CODE ==========="
echo "=============================================="

# Determine VS Code user directory based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  VSCODE_USER_DIR="$HOME/.config/Code/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
else
  echo "❌ Operating system not automatically supported."
  exit 1
fi

mkdir -p "$VSCODE_USER_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYBINDINGS_PATH="$VSCODE_USER_DIR/keybindings.json"

echo "Detected VS Code directory: $VSCODE_USER_DIR"
echo ""

echo "Copying keybindings.json..."
cp "$SCRIPT_DIR/../../config/vscode-keybindings.json" "$KEYBINDINGS_PATH"
echo "→ keybindings.json updated successfully!"

echo "=============================================="
echo "============== [14] DONE ===================="
echo "=============================================="
echo "🎉 VS Code configured successfully!"
echo "   Open VS Code again to apply keybindings."
echo ""
echo "▶ Next, run: bash 15-configure-cursor.sh"
