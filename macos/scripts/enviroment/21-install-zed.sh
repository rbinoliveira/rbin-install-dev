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
echo "========= [21] INSTALLING ZED ==============="
echo "=============================================="

echo "Installing Zed editor..."

INSTALLED=false

# Check if Zed is already installed
if command -v zed &> /dev/null || [ -d "/Applications/Zed.app" ]; then
    echo "✓ Zed is already installed"
    if command -v zed &> /dev/null; then
        zed --version 2>/dev/null || echo "⚠️  Version check failed, but Zed is installed"
    elif [ -d "/Applications/Zed.app" ]; then
        echo "  Found at /Applications/Zed.app"
    fi
    INSTALLED=true
fi

# Install via Homebrew if available and not installed
if [ "$INSTALLED" = false ] && command -v brew &> /dev/null; then
    echo "Installing Zed via Homebrew..."
    
    # Reinstall if already installed via brew
    if brew list --cask zed &> /dev/null; then
        echo "Reinstalling Zed..."
        brew reinstall --cask zed
    else
        brew install --cask zed
    fi
    
    if [ -d "/Applications/Zed.app" ] || brew list --cask zed &> /dev/null; then
        INSTALLED=true
        echo "✓ Zed installed successfully via Homebrew"
        
        # Wait a moment for the app to be fully available
        sleep 2
        
        # Check for command-line tool
        if command -v zed &> /dev/null; then
            echo "✓ Zed command-line tool is available"
            zed --version 2>/dev/null || echo "⚠️  Version check failed, but Zed is installed"
        else
            echo "⚠️  Zed command-line tool not found in PATH"
            echo "   The app is installed, but CLI may need manual setup"
        fi
    fi
fi

# Fallback to installation script if Homebrew not available or failed
if [ "$INSTALLED" = false ]; then
    echo "Installing Zed via installation script..."
    
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
        elif [ -d "/Applications/Zed.app" ]; then
            INSTALLED=true
            echo "✓ Zed.app found in Applications"
        fi
    fi
fi

if [ "$INSTALLED" = false ]; then
    echo "⚠️  Automatic installation failed"
    echo ""
    echo "Please install Zed manually:"
    echo "  1. Visit: https://zed.dev"
    echo "  2. Click 'Download' and select macOS"
    echo "  3. Drag Zed.app to Applications folder"
    echo ""
    echo "Or install via Homebrew:"
    echo "  brew install --cask zed"
    exit 1
fi

echo "=============================================="
echo "============== [21] DONE ===================="
echo "=============================================="
echo ""
echo "📝 Note: Zed supports integration with:"
echo "   • Claude Code (built-in support)"
echo "   • Gemini CLI (external agent)"
echo "   • Cursor CLI (external agent)"
echo ""
echo "▶ Installation complete!"

