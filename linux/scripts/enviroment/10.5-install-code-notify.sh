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
echo "====== [10.5] INSTALLING CODE-NOTIFY ========"
echo "=============================================="

CODE_NOTIFY_INSTALLED=false

echo "Installing Linux notification dependencies..."
sudo apt update -y 2>/dev/null || true
for pkg in jq libnotify-bin; do
    sudo apt install -y "$pkg" 2>/dev/null || echo "⚠️  Could not install $pkg via apt (may already be present)"
done

install_via_script() {
    echo "Installing Code-Notify via official install script..."
    curl -fsSL https://raw.githubusercontent.com/mylee04/code-notify/main/scripts/install.sh | bash

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

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

if install_via_script; then
    CODE_NOTIFY_INSTALLED=true
    echo "✓ Code-Notify installed via install.sh"
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
        echo "   Add to ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "   Then restart your terminal or run: exec \$SHELL"
    fi
fi

echo "=============================================="
echo "============ [10.5] DONE ====================="
echo "=============================================="
echo "▶ Next, run: bash 11-configure-terminal.sh"
