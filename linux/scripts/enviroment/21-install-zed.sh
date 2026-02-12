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


# Don't use set -e here because we need to handle installation failures gracefully
set +e

echo "=============================================="
echo "========= [21] INSTALLING ZED ==============="
echo "=============================================="

echo "Installing Zed editor..."

INSTALLED=false

# Check if Zed is already installed
if command -v zed &> /dev/null; then
    echo "✓ Zed is already installed"
    zed --version 2>/dev/null || echo "⚠️  Version check failed, but Zed is installed"
    INSTALLED=true
fi

# Install via installation script if not installed
if [ "$INSTALLED" = false ]; then
    echo "Downloading and installing Zed..."
    
    if curl -fsSL https://zed.dev/install.sh | bash; then
        echo "✓ Zed installation script executed"
        
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
        if command -v zed &> /dev/null; then
            INSTALLED=true
            echo "✓ Zed installed successfully"
            zed --version 2>/dev/null || echo "⚠️  Version check failed, but Zed is installed"
        else
            # Try to find it in common locations
            if [ -f "$HOME/.local/bin/zed" ]; then
                echo "✓ Zed found at ~/.local/bin/zed"
                echo "⚠️  You may need to restart your terminal for 'zed' command to be available"
                INSTALLED=true
            fi
        fi
    fi
fi

if [ "$INSTALLED" = true ]; then
    echo ""
    echo "📝 Note: Zed supports integration with:"
    echo "   • Claude Code (built-in support)"
    echo "   • Cursor CLI (external agent)"
    echo ""
    echo "=============================================="
    echo "============== [21] DONE ===================="
    echo "=============================================="
    echo "▶ Installation complete!"
else
    echo "⚠️  Automatic installation failed"
    echo ""
    echo "Please install Zed manually:"
    echo "  1. Visit: https://zed.dev"
    echo "  2. Click 'Download' and select Linux"
    echo "  3. Follow the installation instructions"
    echo ""
    echo "Or try the installation script manually:"
    echo "  curl -fsSL https://zed.dev/install.sh | bash"
    exit 1
fi

