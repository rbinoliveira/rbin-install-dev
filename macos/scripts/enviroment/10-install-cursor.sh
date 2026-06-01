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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

if [ -f "$PROJECT_ROOT/lib/brew_helper.sh" ]; then
    # shellcheck source=lib/brew_helper.sh
    source "$PROJECT_ROOT/lib/brew_helper.sh"
    ensure_homebrew_in_path
fi

echo "=============================================="
echo "========= [09] INSTALLING CURSOR ============"
echo "=============================================="

CURSOR_APP="/Applications/Cursor.app"
INSTALLED=false

if [ -d "$CURSOR_APP" ]; then
    echo "✓ Cursor.app is already in Applications"
    INSTALLED=true
fi

if command -v brew &> /dev/null; then
    echo "Installing Cursor via Homebrew..."

    if [ -d "$CURSOR_APP" ]; then
        if brew list --cask cursor &> /dev/null 2>&1; then
            echo "→ Upgrading Cursor via Homebrew..."
            brew upgrade --cask cursor 2>/dev/null || brew reinstall --cask cursor 2>/dev/null || true
        else
            echo "→ Registering existing Cursor.app with Homebrew (--adopt)..."
            if brew install --cask --adopt cursor; then
                echo "✓ Cursor registered with Homebrew"
            else
                echo "⚠️  Homebrew could not adopt Cursor.app (app is still usable)"
            fi
        fi
        INSTALLED=true
    elif brew list --cask cursor &> /dev/null 2>&1; then
        echo "→ Reinstalling Cursor via Homebrew..."
        brew reinstall --cask cursor
        INSTALLED=true
    else
        echo "→ Installing Cursor via Homebrew..."
        if brew install --cask cursor; then
            INSTALLED=true
        fi
    fi

    if [ "$INSTALLED" = true ]; then
        echo "✓ Cursor installed successfully via Homebrew"
        sleep 2
    fi
else
    echo "⚠️  Homebrew not found"
fi

if [ "$INSTALLED" = false ]; then
    echo ""
    echo "Please install Cursor manually:"
    echo "  1. Visit: https://cursor.sh"
    echo "  2. Click 'Download' and select macOS"
    echo "  3. Drag Cursor.app to Applications folder"
    echo ""
    echo "Or install Homebrew first, then run this script again"
    exit 1
fi

if [ -d "$CURSOR_APP" ]; then
    echo "✓ Cursor.app found in Applications"
    version="$(defaults read "$CURSOR_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")"
    echo "✓ Cursor version: $version"
fi

if command -v cursor &> /dev/null; then
    echo "✓ Cursor command-line tool is available"
    cursor --version 2>/dev/null || echo "⚠️  Version check failed, but Cursor is installed"
else
    echo "⚠️  Cursor command-line tool not found in PATH"
    echo "   This is normal — the app is installed; CLI setup runs in a later script"
fi

echo "=============================================="
echo "============== [09] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 10-install-claude.sh"
