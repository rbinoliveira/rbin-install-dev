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
echo "========= [02] INSTALLING ZSH ================"
echo "=============================================="

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon Macs
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed."
fi

# Install zsh (usually comes with macOS, but we'll install via Homebrew if needed)
echo "Installing ZSH..."
brew install zsh

# Install git and curl if not available
if ! command -v git &> /dev/null; then
  brew install git
fi

if ! command -v curl &> /dev/null; then
  brew install curl
fi

ZSH_BIN=$(which zsh)

echo "=============================================="
echo "===== [02] SETTING DEFAULT SHELL ============"
echo "=============================================="

if [ "$SHELL" != "$ZSH_BIN" ]; then
  # Add zsh to /etc/shells if not already there
  if ! grep -q "$ZSH_BIN" /etc/shells; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_BIN"
  echo "✔ Default shell changed to ZSH"
else
  echo "✔ ZSH is already the default shell"
fi

echo "=============================================="
echo "===== [02] CREATING MINIMAL .zshrc ==========="
echo "=============================================="

cat > ~/.zshrc << 'EOF'
# ==========================================
#  Minimal ZSH bootstrap configuration file
# ==========================================

# Fix permissions for completion directories first
# This prevents the "insecure directories" warning on terminal startup
if [[ -d "$HOME/.zsh" ]]; then
  chmod 755 "$HOME/.zsh" 2>/dev/null || true
fi
if [[ -d "$HOME/.cache/zsh" ]]; then
  chmod 755 "$HOME/.cache/zsh" 2>/dev/null || true
fi
# Fix permissions for zcompdump files
if [[ -f "$HOME/.zcompdump" ]]; then
  chmod 600 "$HOME/.zcompdump" 2>/dev/null || true
fi
if [[ -f "$HOME/.zcompdump-"* ]]; then
  chmod 600 "$HOME/.zcompdump-"* 2>/dev/null || true
fi

# Initialize completion system
autoload -Uz compinit
# Use -C flag to skip security check (safe since we fixed permissions above)
compinit -C

# Additional helper configurations will be appended below
# --------------------------------------------
EOF

echo "=============================================="
echo "===== [02] MINIMAL CONFIG CREATED ============"
echo "=============================================="
echo "Full ZSH configuration will be added by script 04"

echo "=============================================="
echo "============== [02] DONE ===================="
echo "=============================================="
echo "⚠️  Please close the terminal and open it again."
echo "▶ Next, run: bash 03-install-zinit.sh"
