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
echo "======= [19] INSTALLING CURSOR CLI =========="
echo "=============================================="

echo "Installing Cursor CLI..."

# Check if cursor-agent is already installed
if command -v cursor-agent &> /dev/null; then
    echo "✓ Cursor CLI (cursor-agent) is already installed"
    cursor-agent --version 2>/dev/null || echo "⚠️  Version check failed, but Cursor CLI is installed"
    echo "=============================================="
    echo "============== [19] DONE ===================="
    echo "=============================================="
    echo "▶ Next, run: bash 20-install-gemini-cli.sh"
    exit 0
fi

# Install Cursor CLI
echo "Downloading and installing Cursor CLI..."
if curl -fsS https://cursor.com/install | bash; then
    echo "✓ Cursor CLI installation script executed"
    
    # Wait a moment for installation to complete
    sleep 2
    
    # Ensure ~/.local/bin is in PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Add to PATH in .zshrc if not already present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            echo "✓ Added ~/.local/bin to PATH in .zshrc"
        fi
    fi
    
    # Verify installation
    if command -v cursor-agent &> /dev/null; then
        echo "✓ Cursor CLI (cursor-agent) installed successfully"
        cursor-agent --version 2>/dev/null || echo "⚠️  Version check failed, but Cursor CLI is installed"
    else
        # Try to find it in common locations
        if [ -f "$HOME/.local/bin/cursor-agent" ]; then
            echo "✓ Cursor CLI found at ~/.local/bin/cursor-agent"
            echo "⚠️  You may need to restart your terminal for 'cursor-agent' command to be available"
        else
            echo "⚠️  Cursor CLI installation completed, but command not found"
            echo "   Please restart your terminal or check ~/.local/bin"
        fi
    fi
else
    echo "❌ Failed to install Cursor CLI"
    echo ""
    echo "You can try installing manually:"
    echo "  curl -fsS https://cursor.com/install | bash"
    exit 1
fi

echo "=============================================="
echo "============== [19] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 20-install-gemini-cli.sh"

