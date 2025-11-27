#!/usr/bin/env bash

set -e

echo "=============================================="
echo "========= [03] INSTALLING STARSHIP ==========="
echo "=============================================="

echo "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh

echo "Downloading starship.toml..."
mkdir -p ~/.config
curl -fsSL https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/linux/config/starship.toml -o ~/.config/starship.toml

echo "Updating .zshrc with Prezto + Starship + custom config..."
# Download the complete zsh-config which already includes Prezto and Starship
if ! curl -fsSL https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/linux/config/zsh-config -o ~/.zshrc; then
  # Fallback if download fails
  cat > ~/.zshrc << 'EOF'
#
# Final ZSH configuration (Prezto + Starship)
#

# Load Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Disable Prezto default prompt to use Starship
zstyle ':prezto:module:prompt' theme 'off'

# Load Starship prompt
eval "$(starship init zsh)"
EOF
fi

echo "=============================================="
echo "============== [03] DONE ===================="
echo "=============================================="
echo "👉 Run: source ~/.zshrc"
echo "▶ Next, run: bash <(curl -fsSL https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/linux/scripts/04-configure-git.sh)"

