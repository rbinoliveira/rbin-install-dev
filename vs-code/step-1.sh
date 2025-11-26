# bash <(curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/step-1.sh)

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
# ==========================
#  ZSH - configuração mínima
# ==========================

autoload -Uz compinit
compinit

# --------------------------
#  Configurações auxiliares
# --------------------------
EOF

echo "===== [BOOTSTRAP] Inserindo conteúdo do step-1-aux-1 ====="
curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/step-1-aux-1 >> ~/.zshrc

echo "===== [BOOTSTRAP] Concluído ====="
echo "⚠️ Feche o terminal e abra novamente."
echo "✔ Depois rode o SCRIPT 2 em ZSH:"
echo "    curl -Ls https://raw.githubusercontent.com/rubensdeoliveira/rubinho-env/master/vs-code/prezto_starship_script.sh -o /tmp/prezto.sh && bash /tmp/prezto.sh"
