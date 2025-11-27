#!/usr/bin/env bash

set -e

echo "========================================"
echo "===== STARTING PREZTO + STARSHIP ======="
echo "========================================"

ZSH_BIN=$(which zsh)

echo "===== Creating temporary ZSH script ====="
TMP_ZSH_SCRIPT=$(mktemp /tmp/zsh_script.XXXXXX)

cat > "$TMP_ZSH_SCRIPT" << 'EOF'
set -e

echo "----------------------------------------"
echo "  Installing Prezto"
echo "----------------------------------------"
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
  echo "Prezto already installed."
fi

echo "----------------------------------------"
echo "  Creating Prezto runcom symlinks"
echo "----------------------------------------"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo "----------------------------------------"
echo "  Writing .zpreztorc (module config)"
echo "----------------------------------------"
cat > ~/.zpreztorc << 'ZPREZTOEOF'
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'autosuggestions' \
  'syntax-highlighting'
ZPREZTOEOF


echo "----------------------------------------"
echo "  Installing Starship prompt"
echo "----------------------------------------"
curl -sS https://starship.rs/install.sh | sh

echo "----------------------------------------"
echo "  Downloading starship.toml"
echo "----------------------------------------"
mkdir -p ~/.config
curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/step-2-aux-1 -o ~/.config/starship.toml

echo "----------------------------------------"
echo "  Creating final .zshrc"
echo "----------------------------------------"
cat > ~/.zshrc << 'ENDZSH'
#
# Final ZSH configuration (Prezto + Starship)
#

# Load Prezto
if [[ -s "\${ZDOTDIR:-\$HOME}/.zprezto/init.zsh" ]]; then
  source "\${ZDOTDIR:-\$HOME}/.zprezto/init.zsh"
fi

# Load Starship prompt
eval "\$(starship init zsh)"
ENDZSH

echo "----------------------------------------"
echo "  Finished Prezto + Starship Setup"
echo "----------------------------------------"

EOF

echo "===== Running temporary ZSH script ====="
$ZSH_BIN "$TMP_ZSH_SCRIPT"

echo "===== Removing temporary script ====="
rm "$TMP_ZSH_SCRIPT"

echo ""
echo "========================================"
echo "          INSTALLATION COMPLETE         "
echo "========================================"
echo "👉 Run: source ~/.zshrc"
echo "👉 Logout/Login to finish activation"
echo "👉 Next script: "
echo "    bash <(curl -fsSL https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/step-3-dev-stack.sh)"
