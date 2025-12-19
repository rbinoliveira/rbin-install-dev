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
echo "========= [13] CONFIGURING FILE WATCHERS ====="
echo "=============================================="

echo "Configuring file watcher limits for macOS..."
echo ""
echo "⚠️  macOS uses different file watching mechanisms than Linux"
echo "   (kqueue instead of inotify)"
echo ""

# Increase file descriptor limits
echo "Setting file descriptor limits..."
ulimit -n 65536

# Make it persistent by adding to .zshrc
if ! grep -q "ulimit -n 65536" ~/.zshrc; then
  echo "" >> ~/.zshrc
  echo "# Increase file descriptor limit for file watchers" >> ~/.zshrc
  echo "ulimit -n 65536" >> ~/.zshrc
  echo "✓ Added ulimit to .zshrc"
fi

# For Node.js projects, you might want to set CHOKIDAR_USEPOLLING
echo ""
echo "Note: For some Node.js projects, you may need to set:"
echo "  export CHOKIDAR_USEPOLLING=true"
echo ""
echo "Or add it to your .zshrc if you experience file watching issues"

echo "=============================================="
echo "============== [13] DONE ===================="
echo "=============================================="
