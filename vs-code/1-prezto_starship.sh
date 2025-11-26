# RODE -> curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/prezto_starship_script.sh -o /tmp/rubinho-install.sh && bash /tmp/rubinho-install.sh
# RODE EM SEQUENCIA N-> bash /tmp/rubinho-install.sh

#!/usr/bin/env bash

set -e

echo "===== Instalando ZSH ====="
sudo apt update -y
sudo apt install -y zsh curl git

ZSH_BIN=$(which zsh)

echo "===== Alterando shell padrão para ZSH ====="
if [ "$SHELL" != "$ZSH_BIN" ]; then
  chsh -s "$ZSH_BIN"
fi

echo "===== Criando script temporário ZSH ====="
TMP_ZSH_SCRIPT=$(mktemp /tmp/zsh_script.XXXXXX)

cat > "$TMP_ZSH_SCRIPT" << 'EOF'
set -e

echo "===== Instalando Prezto ====="
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
  echo "Prezto já instalado."
fi

echo "===== Criando symlinks dos runcoms ====="
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo "===== Instalando Starship ====="
curl -sS https://starship.rs/install.sh | sh

echo "===== Baixando starship.toml ====="
mkdir -p ~/.config
curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/starship.toml -o ~/.config/starship.toml

echo "===== Criando .zshrc ====="
cat > ~/.zshrc << 'ENDZSH'
# Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Starship
eval "$(starship init zsh)"
ENDZSH

echo "===== CONFIGURAÇÃO VIA ZSH CONCLUÍDA ====="
EOF

echo "===== Executando script ZSH ====="
$ZSH_BIN "$TMP_ZSH_SCRIPT"

echo "===== Limpando arquivo temporário ====="
rm "$TMP_ZSH_SCRIPT"

echo "===== INSTALAÇÃO COMPLETA ====="
echo "👉 Rode: source ~/.zshrc"
echo "👉 Faça logout e login para ativar o ZSH totalmente"
