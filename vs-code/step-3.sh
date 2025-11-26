#!/usr/bin/env bash
set -e

echo "======================================="
echo "===== INSTALAÇÃO DO AMBIENTE DEV ====="
echo "======================================="

###########################################################################
# 1. DOCKER
###########################################################################

echo "===== [DOCKER] Atualizando sistema ====="
sudo apt update -y && sudo apt upgrade -y

echo "===== [DOCKER] Removendo instalações antigas ====="
sudo apt remove -y docker docker-engine docker.io containerd runc || true

echo "===== [DOCKER] Instalando dependências ====="
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "===== [DOCKER] Adicionando chave GPG ====="
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "===== [DOCKER] Adicionando repositório ====="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

echo "===== [DOCKER] Instalando Docker ====="
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "===== [DOCKER] Testando Docker ====="
sudo docker run hello-world || true

echo "===== [DOCKER] Adicionando usuário ao grupo docker ====="
sudo usermod -aG docker $USER
echo "⚠ Deslogue e logue novamente para usar Docker sem sudo!"

###########################################################################
# 2. NODE + NVM + YARN
###########################################################################

echo "===== [NODE] Instalando NVM ====="
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
  echo "NVM já instalado"
fi

# Carregar NVM na sessão atual
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

echo "===== [NODE] Instalando Node 22 ====="
nvm install 22
nvm alias default 22

echo "Node -> $(node -v)"
echo "NPM  -> $(npm -v)"

echo "===== [YARN] Habilitando Corepack ====="
corepack enable
corepack prepare yarn@1 --activate

echo "Yarn -> $(yarn -v)"

###########################################################################
# 3. JETBRAINS MONO NERD FONT
###########################################################################

echo "===== [FONTS] Instalando JetBrainsMono Nerd Font ====="

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
mkdir -p "$FONT_DIR"

wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$FONT_DIR" > /dev/null
rm JetBrainsMono.zip

fc-cache -fv

echo "===== [FONTS] JetBrainsMono Nerd Font instalada ====="

###########################################################################
# 4. CURSOR 
###########################################################################

echo "===== [CURSOR] Instalando Cursor Editor ====="

curl -L "https://downloads.cursor.com/linux/appImage/x64" -o cursor.AppImage
chmod +x cursor.AppImage
sudo mv cursor.AppImage /usr/local/bin/cursor

echo "Cursor -> instalado com sucesso!"
cursor --version || echo "Cursor instalado, mas versão não pôde ser exibida."

###########################################################################
# 5. TECLADO EUA INTERNACIONAL + cedilha
###########################################################################

echo "===== [KEYBOARD] Configurando teclado EUA internacional ====="
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"

echo "===== [KEYBOARD] Fix cedilha (ç) ====="
gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']"

###########################################################################
# 6. TEMA DRACULA + CRIAÇÃO DE NOVO PERFIL
###########################################################################

echo "===== [DRACULA] Criando novo profile GNOME Terminal ====="

NEW_ID=$(uuidgen)
PROFILE_DIR="/org/gnome/terminal/legacy/profiles:/:$NEW_ID/"

echo "Novo perfil: $NEW_ID"

# ---- Inserir novo perfil na lista ----
LIST=$(dconf read /org/gnome/terminal/legacy/profiles:/list)

if [[ "$LIST" == "@"* ]]; then
  dconf write /org/gnome/terminal/legacy/profiles:/list "['$NEW_ID']"
else
  NEW_LIST=$(echo "$LIST" | sed "s/]$/, '$NEW_ID']/")
  dconf write /org/gnome/terminal/legacy/profiles:/list "$NEW_LIST"
fi

# ---- Tornar o novo perfil o padrão ----
dconf write /org/gnome/terminal/legacy/profiles:/default "'$NEW_ID'"

# ---- Aplicar Dracula ----
echo "Aplicando esquema de cores Dracula..."

dconf write $PROFILE_DIR"palette" "[
 '#000000',
 '#ff5555',
 '#50fa7b',
 '#f1fa8c',
 '#bd93f9',
 '#ff79c6',
 '#8be9fd',
 '#bbbbbb',
 '#44475a',
 '#ff6e6e',
 '#69ff94',
 '#ffffa5',
 '#d6caff',
 '#ff92df',
 '#a6f0ff',
 '#ffffff'
]"

dconf write $PROFILE_DIR"use-theme-colors" "false"
dconf write $PROFILE_DIR"foreground-color" "'#f8f8f2'"
dconf write $PROFILE_DIR"background-color" "'#282a36'"

# Cursor
dconf write $PROFILE_DIR"cursor-colors-set" "true"
dconf write $PROFILE_DIR"cursor-background-color" "'#f8f8f2'"
dconf write $PROFILE_DIR"cursor-foreground-color" "'#282a36'"

# Fonte
dconf write $PROFILE_DIR"use-system-font" "false"
dconf write $PROFILE_DIR"font" "'JetBrainsMono Nerd Font 13'"

# Nome visível
dconf write $PROFILE_DIR"visible-name" "'Dracula (auto)'"

echo "===== [DRACULA] Tema aplicado com sucesso no novo perfil ====="

###########################################################################
# 6.5. Remover perfis antigos e deixar apenas o "rubinho"
###########################################################################

echo "===== [TERMINAL] Limpando perfis antigos ====="

# Lista de perfis atuais
PROFILE_LIST=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[]'," )

# Loop removendo todos menos o atual
for PROFILE in $PROFILE_LIST; do
  if [ "$PROFILE" != "$NEW_PROFILE_ID" ]; then
    echo "Removendo perfil antigo: $PROFILE"
    gsettings set org.gnome.Terminal.ProfilesList list \
      "$(gsettings get org.gnome.Terminal.ProfilesList list | sed "s/'$PROFILE', //; s/, '$PROFILE'//; s/'$PROFILE'//")"
  fi
done

# Garantir que só o perfil novo existe na lista
gsettings set org.gnome.Terminal.ProfilesList list "['$NEW_PROFILE_ID']"

# Renomear perfil
echo "===== [TERMINAL] Renomeando perfil para rubinho ====="
gsettings set \
  org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$NEW_PROFILE_ID/ \
  visible-name "rubinho"

echo "===== Perfis antigos removidos. Apenas 'rubinho' permanece. ====="

###########################################################################
# FINAL
###########################################################################

echo ""
echo "======================================="
echo " AMBIENTE DEV CONFIGURADO COM SUCESSO! "
echo "======================================="
echo "Reabra seu terminal para aplicar fontes e tema Dracula."
