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
echo "========= [11] CONFIGURING TERMINAL ========="
echo "=============================================="

# Check if running in GNOME
if ! command -v gsettings &> /dev/null; then
  echo "⚠️  gsettings not found. This script requires GNOME desktop environment."
  echo "   Skipping terminal configuration."
  exit 0
fi

echo "Installing required packages (dconf-cli, uuid-runtime)..."
sudo apt-get update -y
sudo apt-get install -y dconf-cli uuid-runtime

echo "Checking if Dracula theme is installed..."
# Check if Dracula colors are already applied (check for Dracula background color)
DRACULA_INSTALLED=false
if dconf read /org/gnome/terminal/legacy/profiles:/:*/background-color 2>/dev/null | grep -q "#282a36"; then
  DRACULA_INSTALLED=true
  echo "✓ Dracula colors found in existing profiles"
else
  # Check if dracula theme directory exists
  if [ -d "$HOME/.local/share/gnome-terminal/colors/dracula" ] || [ -d "/usr/share/gnome-terminal/colors/dracula" ]; then
    DRACULA_INSTALLED=true
    echo "✓ Dracula theme files found"
  else
    echo "⚠️  Dracula theme not found"
    echo "   Will apply Dracula colors manually to the new profile"
  fi
fi

echo ""
echo "Creating new GNOME Terminal profile: rbin..."
NEW_PROFILE_ID=$(uuidgen)

# Add to GNOME Terminal list
OLD_LIST=$(gsettings get org.gnome.Terminal.ProfilesList list)
NEW_LIST=$(echo "$OLD_LIST" | sed "s/]/, '$NEW_PROFILE_ID']/")
gsettings set org.gnome.Terminal.ProfilesList list "$NEW_LIST"

PROFILE_KEY="/org/gnome/terminal/legacy/profiles:/:$NEW_PROFILE_ID/"

dconf write "${PROFILE_KEY}visible-name" "'rbin'"
dconf write "${PROFILE_KEY}use-system-font" "false"
dconf write "${PROFILE_KEY}font" "'CaskaydiaCove Nerd Font 13'"
dconf write "${PROFILE_KEY}use-theme-colors" "false"
dconf write "${PROFILE_KEY}foreground-color" "'#f8f8f2'"
dconf write "${PROFILE_KEY}background-color" "'#282a36'"
dconf write "${PROFILE_KEY}palette" "['#000000', '#ff5555', '#50fa7b', '#f1fa8c', '#bd93f9', '#ff79c6', '#8be9fd', '#bbbbbb', '#44475a', '#ff6e6e', '#69ff94', '#ffffa5', '#d6caff', '#ff92df', '#a6f0ff', '#ffffff']"

echo "Setting rbin as default profile..."
gsettings set org.gnome.Terminal.ProfilesList default "'$NEW_PROFILE_ID'"

echo "Cleaning up old profiles..."
ALL_PROFILES=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[],'")

for PID in $ALL_PROFILES; do
  if [ "$PID" != "$NEW_PROFILE_ID" ]; then
    echo "Removing old profile: $PID"
    dconf reset -f "/org/gnome/terminal/legacy/profiles:/:$PID/"
  fi
done

gsettings set org.gnome.Terminal.ProfilesList list "['$NEW_PROFILE_ID']"

echo "Profile successfully applied."

echo "=============================================="
echo "============== [11] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 12-configure-ssh.sh"
