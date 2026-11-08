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
echo "========== [09] INSTALLING ZED =============="
echo "=============================================="

export PATH="$HOME/.local/bin:$PATH"

if command -v zed &> /dev/null; then
    echo "✓ Zed is already installed: $(zed --version 2>&1 | head -1)"
else
    echo "→ Installing Zed with the official script (~/.local/zed.app)..."
    if ! curl -fsSL https://zed.dev/install.sh | sh; then
        echo "❌ Failed to install Zed. Install manually: https://zed.dev/docs/linux"
        exit 1
    fi
fi

if command -v zed &> /dev/null; then
    echo "✓ Zed ready: $(zed --version 2>&1 | head -1)"
else
    echo "❌ 'zed' command not found (check that ~/.local/bin is in PATH)"
    exit 1
fi

echo "=============================================="
echo "============== [09] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 10-install-claude.sh"
