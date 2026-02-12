#!/usr/bin/env bash

# Script to fix CaskaydiaCove Nerd Font installation

echo "=============================================="
echo "Fixing CaskaydiaCove Nerd Font Installation"
echo "=============================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

FONT_DIR="$HOME/Library/Fonts"

echo "Method 1: Installing via Homebrew (recommended)..."
if brew install --cask font-caskaydia-cove-nerd-font 2>&1; then
    echo "✓ Font installed via Homebrew"
    echo ""
    echo "Font should now be available in iTerm2 as:"
    echo "  - 'CaskaydiaCove Nerd Font'"
    echo "  - 'CaskaydiaCove NF'"
    echo ""
    echo "Please restart iTerm2 and check Preferences → Profiles → Text → Font"
    exit 0
else
    echo "⚠️  Homebrew installation failed or font already installed"
fi

echo ""
echo "Method 2: Checking manual installation..."
echo ""

# Check if font files exist
FONT_FILES=$(find "$FONT_DIR" -name "*Caskaydia*" -o -name "*Cascadia*" 2>/dev/null | head -5)

if [ -n "$FONT_FILES" ]; then
    echo "✓ Found font files:"
    echo "$FONT_FILES" | while read -r file; do
        echo "  - $file"
    done
    echo ""
    echo "Font files are installed. The issue might be:"
    echo "  1. Font name in iTerm2 is different"
    echo "  2. iTerm2 needs to be restarted"
    echo "  3. Font cache needs to be refreshed"
    echo ""
    echo "Try these font names in iTerm2 Preferences:"
    echo "  - CaskaydiaCove Nerd Font"
    echo "  - Cascadia Code"
    echo "  - CaskaydiaCove NF"
    echo "  - CascadiaCode"
else
    echo "❌ No font files found"
    echo ""
    echo "Downloading font manually..."
    
    if ! command -v wget &> /dev/null; then
        echo "Installing wget..."
        brew install wget
    fi
    
    cd /tmp
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip; then
        echo "Extracting font..."
        unzip -q -o CascadiaCode.zip -d "$FONT_DIR" 2>/dev/null
        rm -f CascadiaCode.zip
        
        echo "✓ Font extracted to $FONT_DIR"
        echo ""
        echo "Please restart iTerm2 and check Preferences → Profiles → Text → Font"
    else
        echo "❌ Failed to download font"
        echo ""
        echo "Please install manually:"
        echo "  1. Visit: https://www.nerdfonts.com/font-downloads"
        echo "  2. Download 'Cascadia Code'"
        echo "  3. Extract and install the font files"
    fi
fi

echo ""
echo "=============================================="
echo "To verify font installation in iTerm2:"
echo "=============================================="
echo "1. Open iTerm2 → Preferences (⌘,)"
echo "2. Go to Profiles → Text"
echo "3. Click 'Change Font'"
echo "4. Search for 'Caskaydia' or 'Cascadia'"
echo "5. Select the font and set size to 16"
echo ""
