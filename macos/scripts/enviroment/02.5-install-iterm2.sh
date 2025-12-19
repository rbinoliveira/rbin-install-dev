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
echo "========= [02.5] INSTALLING iTERM2 =========="
echo "=============================================="

echo "Installing iTerm2 terminal..."

INSTALLED=false

# Check if iTerm2 is already installed
if [ -d "/Applications/iTerm.app" ]; then
    echo "✓ iTerm2 is already installed"
    INSTALLED=true
elif command -v brew &> /dev/null && brew list --cask iterm2 &> /dev/null 2>&1; then
    echo "✓ iTerm2 is installed via Homebrew"
    INSTALLED=true
fi

# Install via Homebrew if available and not installed
if [ "$INSTALLED" = false ] && command -v brew &> /dev/null; then
    echo "Installing iTerm2 via Homebrew..."
    
    # Reinstall if already installed via brew
    if brew list --cask iterm2 &> /dev/null 2>&1; then
        echo "Reinstalling iTerm2..."
        brew reinstall --cask iterm2
    else
        brew install --cask iterm2
    fi
    
    if [ -d "/Applications/iTerm.app" ] || brew list --cask iterm2 &> /dev/null 2>&1; then
        INSTALLED=true
        echo "✓ iTerm2 installed successfully via Homebrew"
        
        # Wait a moment for the app to be fully available
        sleep 2
    fi
fi

# Fallback to manual download instructions if Homebrew not available or failed
if [ "$INSTALLED" = false ]; then
    echo "⚠️  Homebrew not found or installation failed"
    echo ""
    echo "Please install iTerm2 manually:"
    echo "  1. Visit: https://iterm2.com"
    echo "  2. Click 'Download' to download the latest version"
    echo "  3. Open the downloaded .zip file"
    echo "  4. Drag iTerm.app to Applications folder"
    echo ""
    echo "Or install Homebrew first, then run this script again:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    echo "The installation will continue, but you may want to install iTerm2 manually."
    exit 0  # Don't fail the installation if iTerm2 can't be installed automatically
fi

echo "=============================================="
echo "============== [02.5] DONE =================="
echo "=============================================="
echo "▶ Next, run: bash 03-install-zinit.sh"
echo ""
echo "📝 Note: You can start using iTerm2 now!"
echo "   iTerm2 configuration (themes, fonts) will be set up in script 11-configure-terminal.sh"

