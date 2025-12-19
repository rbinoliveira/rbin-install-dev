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
echo "======= [20] INSTALLING GEMINI CLI =========="
echo "=============================================="

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

# Check if Node.js/npm is available
if ! command -v npm &> /dev/null; then
    echo "⚠️  npm not found. Gemini CLI requires Node.js/npm."
    echo "   Please install Node.js first (script 05-install-node-nvm.sh)"
    echo "   Gemini CLI will be installed when Node.js is available."
    exit 0
fi

echo "Installing Gemini CLI via npm..."

# Reinstall if already installed
if npm list -g @google/gemini-cli &> /dev/null; then
    echo "→ Reinstalling @google/gemini-cli..."
    npm install -g @google/gemini-cli@latest --force
else
    echo "→ Installing @google/gemini-cli..."
    npm install -g @google/gemini-cli@latest
fi

if npm list -g @google/gemini-cli &> /dev/null; then
    echo "✓ Gemini CLI installed successfully"

    # Verify installation and check version
    if command -v gemini &> /dev/null; then
        echo "✓ Gemini command is available"
        GEMINI_VERSION=$(gemini --version 2>/dev/null | head -1 || echo "unknown")
        if [ "$GEMINI_VERSION" != "unknown" ]; then
            echo "  Version: $GEMINI_VERSION"
        else
            echo "⚠️  Version check failed, but Gemini CLI is installed"
        fi
    else
        echo "⚠️  Gemini command not found in PATH"
        echo "   You may need to restart your terminal or add npm global bin to PATH"
        echo "   Try running: gemini --help (after restarting terminal)"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 SETUP INSTRUCTIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  Authenticate Gemini CLI (first time only):"
    echo "   → Run: gemini"
    echo "   → Follow the authentication prompts"
    echo ""
    echo "2️⃣  Enable Gemini 3 Pro and Gemini 3 Flash:"
    echo "   → Run: gemini"
    echo "   → Type: /settings"
    echo "   → Set 'Preview Features' to: true"
    echo "   → Type: /model"
    echo "   → Select: Auto (Gemini 3)"
    echo ""
    echo "📚 For more info: https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/gemini-3.md"
    echo ""
    echo "⚠️  Note: Gemini 3 requires version 0.21.1 or later."
    echo "   If you don't have access, you may need to:"
    echo "   - Have a paid subscription (Google AI Pro/Ultra, Gemini Code Assist)"
    echo "   - Or be on the waitlist for free tier access"
    echo ""
else
    echo "❌ Failed to install Gemini CLI"
    exit 1
fi

echo "=============================================="
echo "============== [20] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 21-install-zed.sh"
