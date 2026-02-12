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
echo "========= [15] CONFIGURING VS CODE ==========="
echo "=============================================="

# Check if font is installed
echo "Checking if CaskaydiaCove Nerd Font is installed..."
FONT_INSTALLED=false
FONT_LOCATION=""

# Check various possible font locations
for check_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    if ls "$check_dir/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null; then
        FONT_INSTALLED=true
        FONT_LOCATION="$check_dir"
        echo "✓ Found CaskaydiaCove font files in $check_dir"
        break
    elif ls "$check_dir/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
        FONT_INSTALLED=true
        FONT_LOCATION="$check_dir"
        echo "✓ Found CascadiaCode font files in $check_dir"
        break
    fi
done

# Also check Homebrew cask
if [ "$FONT_INSTALLED" = false ] && brew list --cask font-caskaydia-cove-nerd-font &> /dev/null 2>&1; then
    # Verify fonts actually exist even if Homebrew says it's installed
    if ls "$HOME/Library/Fonts/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null || \
       ls "$HOME/Library/Fonts/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
        FONT_INSTALLED=true
        FONT_LOCATION="Homebrew Cask"
        echo "✓ Font installed via Homebrew Cask"
    else
        echo "⚠️  Homebrew reports font installed, but files not found"
        echo "   This may be installed for another user"
    fi
fi

if [ "$FONT_INSTALLED" = false ]; then
    echo ""
    echo "⚠️  WARNING: CaskaydiaCove Nerd Font is not installed!"
    echo ""
    echo "VS Code will be configured, but the font may not work until you install it."
    echo ""
    echo "To install the font, run:"
    echo "  bash macos/scripts/enviroment/08-install-font-caskaydia.sh"
    echo ""
    echo "Or install manually:"
    echo "  brew install --cask font-caskaydia-cove-nerd-font"
    echo ""
    read -p "Continue with VS Code configuration anyway? [Y/n]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Configuration cancelled. Please install the font first."
        exit 1
    fi
    echo ""
fi

# Determine VS Code user directory based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  VSCODE_USER_DIR="$HOME/.config/Code/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
else
  echo "❌ Operating system not automatically supported."
  exit 1
fi

mkdir -p "$VSCODE_USER_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYBINDINGS_PATH="$VSCODE_USER_DIR/keybindings.json"
SETTINGS_PATH="$VSCODE_USER_DIR/settings.json"

echo "Detected VS Code directory: $VSCODE_USER_DIR"
echo ""

echo "Copying keybindings.json..."
cp "$SCRIPT_DIR/../../config/vscode-keybindings.json" "$KEYBINDINGS_PATH"
echo "→ keybindings.json updated successfully!"

echo ""
echo "Copying settings.json..."
cp "$SCRIPT_DIR/../../config/user-settings.json" "$SETTINGS_PATH"
echo "→ settings.json updated successfully!"

echo ""
if [ "$FONT_INSTALLED" = true ]; then
    echo "📝 Font Configuration:"
    echo "   ✓ Font is installed and VS Code is configured to use it"
    echo "   Font location: $FONT_LOCATION"
    echo ""
    echo "   To verify in VS Code:"
    echo "   1. Restart VS Code completely (⌘Q, then reopen)"
    echo "   2. Check Settings → Font Family"
    echo "   3. The font should appear as: 'CaskaydiaCove Nerd Font Mono'"
    echo ""
else
    echo "📝 Font Configuration:"
    echo "   ⚠️  Font is NOT installed, but VS Code is configured"
    echo ""
    echo "   IMPORTANT: Install the font for it to work:"
    echo "   → Run: bash macos/scripts/enviroment/08-install-font-caskaydia.sh"
    echo "   → Or: brew install --cask font-caskaydia-cove-nerd-font"
    echo ""
    echo "   After installing, restart VS Code (⌘Q, then reopen)"
    echo ""
fi

echo "=============================================="
echo "============== [15] DONE ===================="
echo "=============================================="
echo "🎉 VS Code configured successfully!"
echo "   Open VS Code again to apply settings and keybindings."
echo ""
echo "▶ Next, run: bash 16-configure-cursor.sh"
