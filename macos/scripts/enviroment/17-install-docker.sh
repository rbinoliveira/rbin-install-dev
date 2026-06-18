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
fi

echo "=============================================="
echo "========= [16] INSTALLING DOCKER ============="
echo "=============================================="

if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

echo "Installing Docker Desktop via Homebrew..."

# Homebrew cask name varies; prefer docker-desktop (current name)
DOCKER_CASK=""
for candidate in docker-desktop docker; do
    if brew info --cask "$candidate" &>/dev/null; then
        DOCKER_CASK="$candidate"
        break
    fi
done
DOCKER_CASK="${DOCKER_CASK:-docker-desktop}"

# Upgrade-only when already installed — reinstall removes launchctl services and asks sudo again
brew_cask_install_smart "$DOCKER_CASK" "Docker"
echo "✓ Docker Desktop ready"

echo "Starting Docker Desktop..."
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
