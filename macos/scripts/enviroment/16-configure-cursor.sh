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
echo "========= [16] CONFIGURING CURSOR ============"
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
    echo "Cursor will be configured, but the font may not work until you install it."
    echo ""
    echo "To install the font, run:"
    echo "  bash macos/scripts/enviroment/08-install-font-caskaydia.sh"
    echo ""
    echo "Or install manually:"
    echo "  brew install --cask font-caskaydia-cove-nerd-font"
    echo ""
    read -p "Continue with Cursor configuration anyway? [Y/n]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Configuration cancelled. Please install the font first."
        exit 1
    fi
    echo ""
fi

# Determine Cursor user directory based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  CURSOR_USER_DIR="$HOME/.config/Cursor/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
else
  echo "❌ Operating system not automatically supported."
  exit 1
fi

mkdir -p "$CURSOR_USER_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_PATH="$CURSOR_USER_DIR/settings.json"
KEYBINDINGS_PATH="$CURSOR_USER_DIR/keybindings.json"
TASKS_PATH="$CURSOR_USER_DIR/tasks.json"

echo "Detected Cursor directory: $CURSOR_USER_DIR"
echo ""

echo "Copying settings.json..."
cp "$SCRIPT_DIR/../../config/user-settings.json" "$SETTINGS_PATH"
echo "→ settings.json updated successfully!"

echo "Copying keybindings.json..."
cp "$SCRIPT_DIR/../../config/cursor-keyboard.json" "$KEYBINDINGS_PATH"
echo "→ keybindings.json updated successfully!"

echo "Copying tasks.json..."
if cp "$SCRIPT_DIR/../../config/tasks.json" "$TASKS_PATH" 2>/dev/null; then
    echo "→ tasks.json updated successfully!"
else
    echo "⚠️  tasks.json not found (optional file, skipping)"
fi

echo ""
if [ "$FONT_INSTALLED" = true ]; then
    echo "📝 Font Configuration:"
    echo "   ✓ Font is installed and Cursor is configured to use it"
    echo "   Font location: $FONT_LOCATION"
    echo "   Configured font: 'CaskaydiaCove Nerd Font Mono'"
    echo ""
    echo "   To verify in Cursor:"
    echo "   1. Restart Cursor completely (⌘Q, then reopen)"
    echo "   2. Check Settings → Font Family"
    echo "   3. The font should appear as: 'CaskaydiaCove Nerd Font Mono'"
    echo ""
else
    echo "📝 Font Configuration:"
    echo "   ⚠️  Font is NOT installed, but Cursor is configured"
    echo ""
    echo "   IMPORTANT: Install the font for it to work:"
    echo "   → Run: bash macos/scripts/enviroment/08-install-font-caskaydia.sh"
    echo "   → Or: brew install --cask font-caskaydia-cove-nerd-font"
    echo ""
    echo "   After installing, restart Cursor (⌘Q, then reopen)"
    echo ""
fi

echo "=============================================="
echo "============== [16] DONE ===================="
echo "=============================================="
echo "🎉 Cursor configured successfully!"
echo "   Open Cursor again to apply settings and keybindings."
echo ""
echo "▶ Next, run: bash 17-install-docker.sh"
