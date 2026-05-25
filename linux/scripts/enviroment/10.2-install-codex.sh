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
echo "========= [10.2] INSTALLING CODEX CLI ========="
echo "=============================================="

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

if ! command -v npm &> /dev/null; then
    echo "⚠️  npm not found. Codex CLI requires Node.js/npm."
    echo "   Please install Node.js first (script 05-install-node-nvm.sh)"
    echo "   Codex CLI will be skipped until Node.js is available."
    exit 0
fi

echo "Installing OpenAI Codex CLI via npm..."

if npm list -g @openai/codex &> /dev/null; then
    echo "→ Reinstalling @openai/codex..."
    npm install -g @openai/codex --force
else
    echo "→ Installing @openai/codex..."
    npm install -g @openai/codex
fi

if npm list -g @openai/codex &> /dev/null; then
    echo "✓ Codex CLI installed successfully"

    if command -v codex &> /dev/null; then
        echo "✓ codex command is available"
        codex --version 2>/dev/null || echo "⚠️  Version check failed, but Codex is installed"
        echo ""
        echo "  Run 'codex' in the terminal to start the agent."
        echo "  Sign in with ChatGPT or configure OPENAI_API_KEY as needed."
    else
        echo "⚠️  codex command not found in PATH"
        echo "   Restart your terminal or add npm global bin to PATH"
    fi
else
    echo "❌ Failed to install Codex CLI"
    exit 1
fi

echo "=============================================="
echo "============ [10.2] DONE ====================="
echo "=============================================="
echo "▶ Next, run: bash 10.5-install-code-notify.sh"
