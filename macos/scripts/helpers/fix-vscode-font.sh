#!/usr/bin/env bash

# Script to fix CaskaydiaCove Nerd Font in VS Code

echo "=============================================="
echo "Fixing Font in VS Code"
echo "=============================================="
echo ""

# Determine VS Code user directory
if [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
else
  VSCODE_USER_DIR="$HOME/.config/Code/User"
fi

SETTINGS_PATH="$VSCODE_USER_DIR/settings.json"

echo "VS Code settings location: $SETTINGS_PATH"
echo ""

# Check if VS Code settings file exists
if [ ! -f "$SETTINGS_PATH" ]; then
    echo "⚠️  VS Code settings file not found"
    echo "   Please open VS Code at least once to create the settings file"
    exit 1
fi

# Check if font is installed
FONT_INSTALLED=false
if ls ~/Library/Fonts/CaskaydiaCove*.ttf 2>/dev/null | head -1 > /dev/null || \
   ls ~/Library/Fonts/CascadiaCode*.ttf 2>/dev/null | head -1 > /dev/null || \
   brew list --cask font-caskaydia-cove-nerd-font &>/dev/null 2>&1; then
    FONT_INSTALLED=true
    echo "✓ Font is installed"
else
    echo "❌ Font not found. Installing..."
    brew install --cask font-caskaydia-cove-nerd-font || {
        echo "❌ Failed to install font"
        exit 1
    }
    FONT_INSTALLED=true
fi

echo ""
echo "Updating VS Code settings..."

# Backup current settings
cp "$SETTINGS_PATH" "$SETTINGS_PATH.backup.$(date +%Y%m%d_%H%M%S)"
echo "✓ Backup created"

    # Update font family in settings.json
    # Use Python or sed to update JSON properly
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
import sys

settings_file = "$SETTINGS_PATH"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
    
    # Update font family to exact name
    font_family = "CaskaydiaCove Nerd Font Mono"
    settings['editor.fontFamily'] = font_family
    settings['terminal.integrated.fontFamily'] = font_family
    
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
    
    print("✓ VS Code settings updated successfully")
    sys.exit(0)
except Exception as e:
    print(f"❌ Error updating settings: {e}")
    sys.exit(1)
EOF
else
    echo "⚠️  Python3 not found. Please update VS Code settings manually:"
    echo ""
    echo "1. Open VS Code"
    echo "2. Go to Settings (⌘,)"
    echo "3. Search for 'font family'"
    echo "4. Set Editor: Font Family to:"
    echo "   CaskaydiaCove Nerd Font Mono"
    echo "5. Set Terminal: Font Family to the same value"
    echo ""
    exit 1
fi

echo ""
echo "=============================================="
echo "Next Steps:"
echo "=============================================="
echo "1. Restart VS Code completely (⌘Q, then reopen)"
echo "2. Check if the font is working"
echo "3. If not, try manually selecting the font in Settings"
echo ""
