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
echo "========= [13] CONFIGURING INOTIFY ==========="
echo "=============================================="

echo "Setting inotify max_user_watches..."
sudo sysctl fs.inotify.max_user_watches=524288

echo "Making inotify setting persistent..."
if ! grep -q "fs.inotify.max_user_watches=524288" /etc/sysctl.conf; then
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
fi

echo "Applying sysctl changes..."
sudo sysctl -p

echo "Verifying setting..."
cat /proc/sys/fs/inotify/max_user_watches

echo "=============================================="
echo "============== [13] DONE ===================="
echo "=============================================="
