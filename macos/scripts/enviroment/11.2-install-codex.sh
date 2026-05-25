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
echo "========= [11.2] INSTALLING CODEX CLI ========="
echo "=============================================="

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

install_via_npm() {
    if ! command -v npm &> /dev/null; then
        echo "⚠️  npm not found. Codex CLI requires Node.js/npm."
        echo "   Please install Node.js first (script 05-install-node-nvm.sh)"
        return 1
    fi

    echo "Installing OpenAI Codex CLI via npm..."
    if npm list -g @openai/codex &> /dev/null; then
        echo "→ Reinstalling @openai/codex..."
        npm install -g @openai/codex --force
    else
        echo "→ Installing @openai/codex..."
        npm install -g @openai/codex
    fi

    npm list -g @openai/codex &> /dev/null
}

install_via_homebrew() {
    if ! command -v brew &> /dev/null; then
        return 1
    fi

    echo "Installing Codex CLI via Homebrew cask..."
    if brew list --cask codex &> /dev/null; then
        echo "→ Reinstalling codex cask..."
        brew reinstall --cask codex || brew upgrade --cask codex || true
    else
        echo "→ Installing codex cask..."
        brew install --cask codex
    fi

    command -v codex &> /dev/null
}

CODEX_INSTALLED=false

if install_via_npm; then
    CODEX_INSTALLED=true
    echo "✓ Codex CLI installed via npm"
elif install_via_homebrew; then
    CODEX_INSTALLED=true
    echo "✓ Codex CLI installed via Homebrew"
else
    echo "❌ Failed to install Codex CLI"
    exit 1
fi

if [ "$CODEX_INSTALLED" = true ]; then
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
fi

echo "=============================================="
echo "============ [11.2] DONE ====================="
echo "=============================================="
echo "▶ Next, run: bash 11.5-install-code-notify.sh"
