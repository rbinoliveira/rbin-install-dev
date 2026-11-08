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
echo "========== [15] CONFIGURING ZED =============="
echo "=============================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../../config/zed"
ZED_DIR="$HOME/.config/zed"

mkdir -p "$ZED_DIR/themes"

# Back up existing settings before overwriting
if [ -f "$ZED_DIR/settings.json" ] && ! cmp -s "$SRC_DIR/settings.json" "$ZED_DIR/settings.json"; then
    backup="$ZED_DIR/settings.json.bak.$(date +%Y%m%d%H%M%S)"
    cp "$ZED_DIR/settings.json" "$backup"
    echo "→ Previous settings saved to $backup"
fi

cp "$SRC_DIR/settings.json" "$ZED_DIR/settings.json"
echo "✓ settings.json applied (Houston theme, CaskaydiaCove font, panels on the left)"

cp "$SRC_DIR/themes/houston.json" "$ZED_DIR/themes/houston.json"
echo "✓ Houston theme installed"
echo "  Material Icon Theme is auto-installed by Zed on the next launch"

if ! fc-list 2>/dev/null | grep -qi 'CaskaydiaCove'; then
    echo "⚠️  CaskaydiaCove Nerd Font not found. Run: bash linux/scripts/enviroment/08-install-font-cascadia.sh"
fi

echo "=============================================="
echo "============== [15] DONE ===================="
echo "=============================================="
echo "🎉 Zed configured! Restart Zed to apply everything."
echo ""
echo "▶ Next, run: bash 16-install-docker.sh"
