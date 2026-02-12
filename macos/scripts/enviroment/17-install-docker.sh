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

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

echo "Installing Docker Desktop via Homebrew..."
# Reinstall if already installed
if brew list --cask docker &> /dev/null; then
  echo "Reinstalling Docker Desktop..."
  brew reinstall --cask docker
else
  brew install --cask docker
fi
echo "✓ Docker Desktop installed"

echo "Starting Docker Desktop..."
# Use full path to ensure Docker.app is found after installation
if [ -d "/Applications/Docker.app" ]; then
  open /Applications/Docker.app
else
  echo "⚠️  Docker.app not found at /Applications/Docker.app"
  echo "   Attempting to launch with 'open -a Docker'..."
  open -a Docker || echo "⚠️  Could not launch Docker. Please start it manually."
fi

echo "Waiting for Docker to start..."
sleep 5

echo "Testing Docker..."
if docker ps &> /dev/null; then
  echo "✓ Docker is running"
  docker run hello-world || true
else
  echo "⚠️  Docker Desktop is starting. Please wait for it to fully start."
  echo "   You can check the status in the Docker Desktop app."
fi

echo "=============================================="
echo "============== [16] DONE ===================="
echo "=============================================="
echo "⚠️  Make sure Docker Desktop is running"
echo ""
echo "▶ Next, run: bash 19-install-tableplus.sh"
