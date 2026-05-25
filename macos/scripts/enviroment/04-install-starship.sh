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
    command -v brew &> /dev/null && ensure_homebrew_writable
fi

echo "=============================================="
echo "========= [04] INSTALLING STARSHIP ==========="
echo "=============================================="

echo "Installing Starship prompt..."

STARSHIP_INSTALLED=false

# Check if Homebrew is available (preferred method for macOS)
if command -v brew &> /dev/null; then
    echo "→ Installing Starship via Homebrew..."
    if brew list starship &> /dev/null; then
        brew upgrade starship 2>/dev/null || brew reinstall starship 2>/dev/null || true
        STARSHIP_INSTALLED=true
    elif brew install starship; then
        STARSHIP_INSTALLED=true
    fi
fi

if [ "$STARSHIP_INSTALLED" = false ] && ! command -v starship &> /dev/null; then
    echo "→ Homebrew install failed or unavailable, trying direct installation..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if ! command -v starship &> /dev/null; then
    echo "❌ Failed to install Starship"
    exit 1
fi

echo "✓ Starship: $(starship --version 2>&1 | head -1)"

echo "Copying starship.toml..."
mkdir -p ~/.config
cp "$SCRIPT_DIR/../../config/starship.toml" ~/.config/starship.toml

echo "Updating .zshrc with Zinit + Starship + custom config..."
# Copy the complete zsh-config which includes Zinit and Starship
if [ -f "$SCRIPT_DIR/../../config/zsh-config" ]; then
  cat "$SCRIPT_DIR/../../config/zsh-config" > ~/.zshrc
  echo "✓ zsh-config applied successfully"
else
  echo "⚠️  zsh-config not found, using fallback configuration"
  # Fallback if file doesn't exist
  cat >> ~/.zshrc << 'EOF'
# Load Starship prompt
eval "$(starship init zsh)"
EOF
fi

echo "=============================================="
echo "============== [04] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 05-install-node-nvm.sh"
