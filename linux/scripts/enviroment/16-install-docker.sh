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
echo "========= [16] INSTALLING DOCKER ============="
echo "=============================================="

echo "Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "Removing old Docker installations..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

echo "Installing required dependencies..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "Adding Docker GPG Key..."
sudo install -m 0755 -d /etc/apt/keyrings
DOCKER_GPG="/etc/apt/keyrings/docker.gpg"
# Valid dearmored Docker key is typically > 1KB
need_key=1
if [ -s "$DOCKER_GPG" ] && [ "$(stat -c%s "$DOCKER_GPG" 2>/dev/null || echo 0)" -gt 500 ]; then
  echo "→ Using existing Docker GPG key (already installed)"
  need_key=0
fi
if [ "$need_key" -eq 1 ]; then
  tmp_gpg="$(mktemp)"
  if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$tmp_gpg" 2>/dev/null && [ -s "$tmp_gpg" ]; then
    sudo mv "$tmp_gpg" "$DOCKER_GPG"
  else
    rm -f "$tmp_gpg"
    if [ -s "$DOCKER_GPG" ] && [ "$(stat -c%s "$DOCKER_GPG" 2>/dev/null || echo 0)" -gt 500 ]; then
      echo "→ Download failed (network/DNS); using existing Docker GPG key"
    else
      echo "❌ Could not download Docker GPG key. Check network/DNS (e.g. ping download.docker.com)"
      echo "   If a previous run failed, remove the corrupted key and retry: sudo rm -f $DOCKER_GPG"
      exit 1
    fi
  fi
fi
sudo chmod a+r "$DOCKER_GPG"

echo "Adding Docker Repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

echo "Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Testing Docker..."
sudo docker run hello-world || true

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "=============================================="
echo "============== [16] DONE ===================="
echo "=============================================="
echo "⚠️  Logout/Login required to use Docker without sudo"
echo ""
echo "🎉 INSTALLATION COMPLETE!"
echo "=============================================="
echo "All scripts have been executed successfully!"
echo "Restart the terminal to apply all changes."
