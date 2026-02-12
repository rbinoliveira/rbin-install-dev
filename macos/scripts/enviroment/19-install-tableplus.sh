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
echo "========= [19] INSTALLING TABLEPLUS =========="
echo "=============================================="

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

echo "Installing TablePlus via Homebrew..."

# Check if already installed via Homebrew
if brew list --cask tableplus &> /dev/null 2>&1; then
    echo "✓ TablePlus is already installed via Homebrew"
    echo "  Skipping reinstallation"
else
    echo "Installing TablePlus..."
    brew install --cask tableplus
fi

# Verify installation
if [ -d "/Applications/TablePlus.app" ]; then
    echo "✓ TablePlus installed successfully"
else
    echo "⚠️  TablePlus installation may have failed"
fi

echo "=============================================="
echo "============== [19] DONE ===================="
echo "=============================================="
echo ""
echo "📝 TablePlus is a modern database management tool for:"
echo "   - MySQL, MariaDB, PostgreSQL, SQLite, Redis, and many more"
echo "   - Beautiful native interface"
echo "   - Cross-platform support"
echo ""
