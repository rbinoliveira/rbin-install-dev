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
echo "========= [08] INSTALLING CASCADIA FONT ====="
echo "=============================================="

# Install required packages
echo "Installing required packages (wget, unzip, fontconfig)..."
sudo apt update -y
sudo apt install -y wget unzip fontconfig

FONT_DIR="$HOME/.local/share/fonts/CascadiaCode"
FONTS_BASE="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Check if font is already installed (in our dir or in fc-list)
if fc-list 2>/dev/null | grep -qi 'CaskaydiaCove'; then
    echo "✓ CaskaydiaCove Nerd Font is already installed"
    echo "  Skipping download and installation"
else
    echo "Downloading CaskaydiaCove Nerd Font..."
    if ! wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip -O /tmp/CascadiaCode.zip; then
        echo "❌ Download failed. Try manually: https://github.com/ryanoasis/nerd-fonts/releases"
        exit 1
    fi

    echo "Extracting font..."
    mkdir -p /tmp/CascadiaCode_extract
    unzip -o /tmp/CascadiaCode.zip -d /tmp/CascadiaCode_extract -x "*.md" 2>/dev/null || true
    # Nerd-fonts zip may put .ttf in root or in a subfolder; move all .ttf into FONT_DIR
    find /tmp/CascadiaCode_extract -name "*.ttf" -exec mv -f {} "$FONT_DIR/" \; 2>/dev/null || true
    TTF_COUNT=$(find "$FONT_DIR" -name "*.ttf" 2>/dev/null | wc -l)
    if [ "$TTF_COUNT" -eq 0 ]; then
        echo "→ Trying direct extract to font dir..."
        unzip -o /tmp/CascadiaCode.zip -d "$FONT_DIR" -x "*.md" 2>/dev/null || true
        TTF_COUNT=$(find "$FONT_DIR" -name "*.ttf" 2>/dev/null | wc -l)
    fi
    rm -rf /tmp/CascadiaCode_extract /tmp/CascadiaCode.zip

    echo "Updating font cache (this may take a few seconds)..."
    fc-cache -f -v "$FONTS_BASE" 2>/dev/null || fc-cache -fv

    if fc-list 2>/dev/null | grep -qi 'CaskaydiaCove'; then
        echo "✓ CaskaydiaCove Nerd Font installed successfully."
    else
        echo "⚠️  Font files placed in $FONT_DIR"
        echo "   If the font still does not appear: close all apps, run: fc-cache -fv"
        echo "   Then reopen the terminal or app."
    fi
fi

echo "=============================================="
echo "============== [08] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 09-install-cursor.sh"
