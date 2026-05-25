#!/usr/bin/env bash

# ────────────────────────────────────────────────────────────────
# Module Guard - Prevent Direct Execution
# ────────────────────────────────────────────────────────────────
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
echo "====== [11.5] INSTALLING CODE-NOTIFY ========"
echo "=============================================="

CODE_NOTIFY_INSTALLED=false

install_via_homebrew() {
    if ! command -v brew &> /dev/null; then
        return 1
    fi

    echo "Installing Code-Notify via Homebrew..."
    brew tap mylee04/tools 2>/dev/null || true

    if brew list code-notify &> /dev/null; then
        echo "→ Reinstalling code-notify..."
        brew reinstall code-notify || brew upgrade code-notify || true
    else
        echo "→ Installing code-notify..."
        brew install code-notify
    fi

    echo "Installing optional dependencies (terminal-notifier, jq)..."
    brew install terminal-notifier jq 2>/dev/null || true

    command -v cn &> /dev/null
}

install_via_npm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

    if ! command -v npm &> /dev/null; then
        echo "⚠️  npm not found. Install Node.js first (script 05-install-node-nvm.sh)"
        return 1
    fi

    echo "Installing Code-Notify via npm..."
    if npm list -g code-notify &> /dev/null; then
        echo "→ Reinstalling code-notify..."
        npm install -g code-notify --force
    else
        echo "→ Installing code-notify..."
        npm install -g code-notify
    fi

    command -v cn &> /dev/null
}

if install_via_homebrew; then
    CODE_NOTIFY_INSTALLED=true
    echo "✓ Code-Notify installed via Homebrew"
elif install_via_npm; then
    CODE_NOTIFY_INSTALLED=true
    echo "✓ Code-Notify installed via npm"
else
    echo "❌ Failed to install Code-Notify"
    exit 1
fi

if [ "$CODE_NOTIFY_INSTALLED" = true ]; then
    if command -v cn &> /dev/null; then
        cn --version 2>/dev/null || cn version 2>/dev/null || true
        echo ""
        echo "Enabling desktop notifications for detected AI tools..."
        cn on 2>/dev/null || echo "⚠️  Run 'cn on' manually after restarting your terminal"
        echo ""
        echo "✓ Code-Notify ready (cn test — send a test notification)"
    else
        echo "⚠️  cn command not found in PATH"
        echo "   Restart your terminal or run: exec \$SHELL"
    fi
fi

echo "=============================================="
echo "============ [11.5] DONE ====================="
echo "=============================================="
echo "▶ Next, run: bash 12-configure-terminal.sh"
