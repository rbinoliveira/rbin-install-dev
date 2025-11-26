# bash <(curl -Ls URL_DO_BOOTSTRAP)

#!/usr/bin/env bash

set -e

echo "===== [BOOTSTRAP] Instalando ZSH ====="
sudo apt update -y
sudo apt install -y zsh curl git

ZSH_BIN=$(which zsh)

echo "===== [BOOTSTRAP] Alterando shell padrão ====="
if [ "$SHELL" != "$ZSH_BIN" ]; then
  chsh -s "$ZSH_BIN"
fi

echo "===== [BOOTSTRAP] Criando .zshrc mínimo ====="
cat > ~/.zshrc << 'EOF'
# ZSH mínimo para preparar ambiente
autoload -Uz compinit
compinit
EOF

echo "===== [BOOTSTRAP] Concluído ====="
echo "⚠️ Agora feche o terminal e abra novamente."
echo "✔ Depois rode o SCRIPT 2 em ZSH:"
echo "    zsh <(curl -Ls URL_DO_SCRIPT_2)"
