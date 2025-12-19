# 🌐 Rubinho Install Dev

<div align="center">

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**Complete development environment configurations for Linux and macOS**

[🇺🇸](#) • [🇧🇷](#-brasil)

</div>

---

## 🇺🇸

> Complete development environment configurations for **Linux** and **macOS**

This repository contains **all development environment configurations**, including:

- 📝 Configuration files (dotfiles)
- 🎨 Themes and fonts
- ⚙️ Automated installation scripts
- 🔧 Cursor/VS Code configurations
- 🛠️ Auxiliary tools
- 🏢 Separate personal and work environments
- 🔐 Environment variables for sensitive data

---

### 🚀 Quick Start

#### 1. Clone the repository

```bash
git clone https://github.com/devrubinho/rubinho-install-dev.git
cd rubinho-install-dev
```

#### 2. Run the Installation Script (Recommended)

The easiest way to get started is using the main `run.sh` script:

```bash
bash run.sh
```

This will start the installation process for your development environment.

#### 3. Manual Installation (Alternative)

If you prefer to run scripts manually:

**🐧 Linux:**
```bash
cd linux/scripts/enviroment
bash 00-install-all.sh
```

**🍎 macOS:**
```bash
cd macos/scripts/enviroment
bash 00-install-all.sh
```

**🏢 Work Environment (Optional):**
```bash
cd work
cp .env.example .env  # Configure first
# Configure your work-specific environment variables
```

---

### 📚 Documentation

- [🐧 Linux Installation Guide](#-linux-installation)
- [🍎 macOS Installation Guide](#-macos-installation)
- [📖 Using run.sh](#-using-runsh)
- [📋 Complete Script Listing](#-complete-script-listing)
- [🐛 Troubleshooting](#-troubleshooting)
- [❓ FAQ](#-faq)

---

### 🐧 Linux Installation

#### Automatic Installation (Recommended)

```bash
cd linux/scripts/enviroment
bash 00-install-all.sh
```

**Note:** The script will automatically handle environment loading. After completion, simply close and reopen your terminal to ensure all configurations are applied.

#### Manual Installation

Run scripts in numerical order:

```bash
cd linux/scripts/enviroment

bash 01-configure-git.sh
bash 02-install-zsh.sh          # ⚠️ Close terminal after this
bash 03-install-zinit.sh
bash 04-install-starship.sh
bash 05-install-node-nvm.sh
bash 06-install-yarn.sh
bash 07-install-tools.sh
bash 08-install-font-jetbrains.sh
bash 09-install-cursor.sh
bash 10-install-claude.sh
bash 10-configure-terminal.sh
bash 11-configure-ssh.sh
bash 12-configure-inotify.sh
bash 13-configure-cursor.sh
bash 14-install-docker.sh       # ⚠️ Logout/login after this
bash 16-install-insomnia.sh
bash 17-install-tableplus.sh
```

---

### 🍎 macOS Installation

#### Automatic Installation (Recommended)

```bash
cd macos/scripts/enviroment
bash 00-install-all.sh
```

**Note:** The script will automatically handle environment loading. After completion, simply close and reopen your terminal to ensure all configurations are applied.

#### Manual Installation

Run scripts in numerical order:

```bash
cd macos/scripts/enviroment

bash 01-configure-git.sh
bash 02-install-zsh.sh          # ⚠️ Close terminal after this
bash 03-install-zinit.sh
bash 04-install-starship.sh
bash 05-install-node-nvm.sh
bash 06-install-yarn.sh
bash 07-install-tools.sh
bash 08-install-font-jetbrains.sh
bash 09-install-cursor.sh
bash 10-install-claude.sh
bash 10-configure-file-watchers.sh
bash 11-configure-ssh.sh
bash 12-configure-cursor.sh
bash 13-install-docker.sh
bash 14-configure-terminal.sh
bash 15-install-insomnia.sh
bash 16-install-tableplus.sh
```

---

### 📖 Using run.sh

The `run.sh` script is the main entry point for installing your development environment. It automatically detects your platform and runs the appropriate installation script.

#### Features

- **Platform Detection**: Automatically detects Linux or macOS
- **Environment Configuration**: Sets up required environment variables (Git name/email)
- **Automated Installation**: Installs and configures all development tools in sequence

#### Usage

```bash
# Basic usage
bash run.sh

# Skip all confirmation prompts
bash run.sh --force

# Enable verbose logging
bash run.sh --verbose
```

---

### 📋 Complete Script Listing

#### **00-install-all.sh** (Master Script)

Runs all installation scripts in sequence automatically.
- Prompts for Git user name and email at the start
- Executes scripts 01-17 (Linux) or 01-16 (macOS) in the correct order
- Automatically loads NVM and environment configurations during installation
- Handles all setup phases: Initial Setup, Environment Configuration, Development Tools, and Application Setup
- **Note:** After completion, close and reopen your terminal to ensure all configurations are applied

#### Individual Scripts

| Script | Description |
|--------|-------------|
| **01-configure-git.sh** | Configures Git with identity and preferences |
| **02-install-zsh.sh** | Installs and configures Zsh as the default shell ⚠️ Close terminal after |
| **03-install-zinit.sh** | Installs Zinit (fast Zsh plugin manager) |
| **04-install-starship.sh** | Installs and configures the Starship prompt |
| **05-install-node-nvm.sh** | Installs NVM (Node Version Manager) and Node.js v22 |
| **06-install-yarn.sh** | Installs Yarn via Corepack |
| **07-install-tools.sh** | Installs various development tools and utilities |
| **08-install-font-jetbrains.sh** | Installs JetBrains Mono Nerd Font |
| **09-install-cursor.sh** | Installs Cursor Editor |
| **10-install-claude.sh** | Installs Claude Code CLI |
| **10-configure-terminal.sh** (Linux) | Configures GNOME Terminal with Dracula theme |
| **10-configure-file-watchers.sh** (macOS) | Configures file watcher limits |
| **11-configure-ssh.sh** (Linux) | Configures SSH for Git |
| **12-configure-inotify.sh** (Linux) | Configures inotify limits for file watching |
| **12-configure-cursor.sh** (macOS) | Applies Cursor configurations |
| **13-configure-cursor.sh** (Linux) | Applies Cursor configurations |
| **13-install-docker.sh** (macOS) | Installs Docker Desktop |
| **14-configure-terminal.sh** (macOS) | Configures iTerm2 with Dracula theme |
| **15-install-docker.sh** (Linux) | Installs Docker Engine ⚠️ Logout/login after |
| **15-install-insomnia.sh** (macOS) | Installs Insomnia REST Client |
| **16-install-insomnia.sh** (Linux) | Installs Insomnia REST Client |
| **16-install-tableplus.sh** (macOS) | Installs TablePlus database client |
| **17-install-tableplus.sh** (Linux) | Installs TablePlus database client |

---

### 🔐 Environment Variables

#### Optional `.env` for Personal Preferences

```bash
cp .env.example .env  # Optional
```

#### Work Environment

Required `.env` for company-specific configuration:

```bash
cd work
cp .env.example .env  # Required
nano .env  # Fill in your company details
```

**Work environment variables:**
- `GITHUB_TOKEN` - For private repositories
- `AWS_SSO_START_URL` - AWS SSO configuration
- Multiple AWS accounts support

See [work/.env.example](work/.env.example) for complete list.

---

### 📁 Repository Structure

```
rubinho-install-dev/
├── .gitignore               # Protects sensitive files
├── LICENSE                  # MIT License
├── readme.md                # This file
├── .env.example             # Environment variables template (optional)
│
├── linux/                   # 🐧 Linux setup
│   ├── config/              # Dotfiles & themes
│   │   ├── starship.toml
│   │   ├── user-settings.json
│   │   ├── cursor-keyboard.json
│   │   └── zsh-config
│   └── scripts/
│       └── enviroment/      # Setup scripts (01-17)
│
├── macos/                   # 🍎 macOS setup
│   ├── config/              # Dotfiles & themes
│   └── scripts/
│       └── enviroment/      # Setup scripts (01-16)
│
└── work/                    # 🏢 Work environment (optional)
    ├── .env                 # Your config (gitignored)
    ├── .env.example         # Company config template
    └── [linux|macos]/       # Work-specific scripts
```

---

### 🐛 Troubleshooting

#### Scripts won't run
**Problem:** `Permission denied` when running scripts

**Solution:**
```bash
chmod +x run.sh
chmod +x linux/scripts/enviroment/*.sh
chmod +x macos/scripts/enviroment/*.sh
```

#### Git configuration not working
**Problem:** Git prompts for name/email every time

**Solution:**
1. Check if `.env` file exists in project root
2. Add your Git credentials:
```bash
   GIT_USER_NAME="Your Name"
   GIT_USER_EMAIL="your.email@example.com"
   ```
3. Or run `01-configure-git.sh` again

#### Docker requires sudo (Linux)
**Problem:** `docker` command requires `sudo`

**Solution:**
1. Logout and login again (after running `15-install-docker.sh`)
2. Or run: `newgrp docker`

#### Zsh not working after installation
**Problem:** Terminal still uses bash

**Solution:**
1. Close and reopen the terminal
2. Or run: `chsh -s $(which zsh)`
3. Logout and login again

---

### ❓ FAQ

#### General

**Q: Do I need to run all scripts?**
A: No, you can run individual scripts as needed. However, some scripts depend on others (e.g., Yarn needs Node.js).

**Q: Can I run scripts multiple times?**
A: Yes! Scripts check if tools are already installed and ask if you want to reinstall.

**Q: Will this affect my existing setup?**
A: Scripts are designed to be safe and non-destructive. They will ask before overwriting existing configurations and check for existing installations.

**Q: What if I'm on a different Linux distribution?**
A: Scripts are tested on Ubuntu/Debian. For other distributions, you may need to adjust package manager commands.

#### Installation

**Q: How long does installation take?**
A: Depends on your internet speed and system. Typically 15-30 minutes for a full installation.

**Q: Can I install tools selectively?**
A: Yes! You can run individual installation scripts manually from `linux/scripts/enviroment/` or `macos/scripts/enviroment/` directories.

**Q: What if a tool installation fails?**
A: The script will show an error message. Fix the issue and re-run. The script will skip already-installed tools.

---

### 📚 Additional Resources

---

### 🤝 Contributing

Found a bug or want to improve something? Feel free to:
1. Open an issue
2. Submit a pull request
3. Share feedback

---

### 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🇧🇷 {#brasil}

> Configurações completas de ambiente de desenvolvimento para **Linux** e **macOS**

Este repositório contém **todas as configurações de ambiente de desenvolvimento**, incluindo:

- 📝 Arquivos de configuração (dotfiles)
- 🎨 Temas e fontes
- ⚙️ Scripts de instalação automatizados
- 🔧 Configurações do Cursor/VS Code
- 🛠️ Ferramentas auxiliares
- 🏢 Ambientes separados para pessoal e trabalho
- 🔐 Variáveis de ambiente para dados sensíveis

---

### 🚀 Início Rápido

#### 1. Clonar o repositório

```bash
git clone https://github.com/devrubinho/rubinho-install-dev.git
cd rubinho-install-dev
```

#### 2. Executar o Script de Instalação (Recomendado)

A forma mais fácil de começar é usar o script principal `run.sh`:

```bash
bash run.sh
```

Isso iniciará o processo de instalação do seu ambiente de desenvolvimento.

#### 3. Instalação Manual (Alternativa)

Se preferir executar os scripts manualmente:

**🐧 Linux:**
```bash
cd linux/scripts/enviroment
bash 00-install-all.sh
```

**🍎 macOS:**
```bash
cd macos/scripts/enviroment
bash 00-install-all.sh
```

**🏢 Ambiente de Trabalho (Opcional):**
```bash
cd work
cp .env.example .env  # Configure primeiro
# Configure suas variáveis de ambiente específicas do trabalho
```

---

### 📚 Documentação

- [🐧 Guia de Instalação Linux](#-instalação-linux)
- [🍎 Guia de Instalação macOS](#-instalação-macos)
- [📖 Usando run.sh](#-usando-runsh)
- [📋 Lista Completa de Scripts](#-lista-completa-de-scripts)
- [🐛 Solução de Problemas](#-solução-de-problemas)
- [❓ Perguntas Frequentes](#-perguntas-frequentes)

---

### 🐧 Instalação Linux

#### Instalação Automática (Recomendado)

```bash
cd linux/scripts/enviroment
bash 00-install-all.sh
```

**Nota:** O script carregará automaticamente as variáveis de ambiente. Após a conclusão, simplesmente feche e reabra o terminal para garantir que todas as configurações sejam aplicadas.

#### Instalação Manual

Execute os scripts em ordem numérica:

```bash
cd linux/scripts/enviroment

bash 01-configure-git.sh
bash 02-install-zsh.sh          # ⚠️ Feche o terminal após isso
bash 03-install-zinit.sh
bash 04-install-starship.sh
bash 05-install-node-nvm.sh
bash 06-install-yarn.sh
bash 07-install-tools.sh
bash 08-install-font-jetbrains.sh
bash 09-install-cursor.sh
bash 10-install-claude.sh
bash 10-configure-terminal.sh
bash 11-configure-ssh.sh
bash 12-configure-inotify.sh
bash 13-configure-cursor.sh
bash 14-install-docker.sh       # ⚠️ Faça logout/login após isso
bash 16-install-insomnia.sh
bash 17-install-tableplus.sh
```

---

### 🍎 Instalação macOS

#### Instalação Automática (Recomendado)

```bash
cd macos/scripts/enviroment
bash 00-install-all.sh
```

**Nota:** O script carregará automaticamente as variáveis de ambiente. Após a conclusão, simplesmente feche e reabra o terminal para garantir que todas as configurações sejam aplicadas.

#### Instalação Manual

Execute os scripts em ordem numérica:

```bash
cd macos/scripts/enviroment

bash 01-configure-git.sh
bash 02-install-zsh.sh          # ⚠️ Feche o terminal após isso
bash 03-install-zinit.sh
bash 04-install-starship.sh
bash 05-install-node-nvm.sh
bash 06-install-yarn.sh
bash 07-install-tools.sh
bash 08-install-font-jetbrains.sh
bash 09-install-cursor.sh
bash 10-install-claude.sh
bash 10-configure-file-watchers.sh
bash 11-configure-ssh.sh
bash 12-configure-cursor.sh
bash 13-install-docker.sh
bash 14-configure-terminal.sh
bash 15-install-insomnia.sh
bash 16-install-tableplus.sh
```

---

### 📖 Usando run.sh

O script `run.sh` é o ponto de entrada principal para instalar seu ambiente de desenvolvimento. Ele detecta automaticamente sua plataforma e executa o script de instalação apropriado.

#### Funcionalidades

- **Detecção de Plataforma**: Detecta automaticamente Linux ou macOS
- **Configuração de Ambiente**: Configura variáveis de ambiente necessárias (nome/email do Git)
- **Instalação Automatizada**: Instala e configura todas as ferramentas de desenvolvimento em sequência

#### Uso

```bash
# Uso básico
bash run.sh

# Pular todos os prompts de confirmação
bash run.sh --force

# Habilitar registro verboso
bash run.sh --verbose
```

---

### 📋 Lista Completa de Scripts

#### **00-install-all.sh** (Script Mestre)

Executa todos os scripts de instalação em sequência automaticamente.
- Solicita nome e email do Git no início
- Executa scripts 01-17 (Linux) ou 01-16 (macOS) na ordem correta
- Carrega automaticamente NVM e configurações de ambiente durante a instalação
- Gerencia todas as fases de configuração: Configuração Inicial, Configuração de Ambiente, Ferramentas de Desenvolvimento e Configuração de Aplicativos
- **Nota:** Após a conclusão, feche e reabra o terminal para garantir que todas as configurações sejam aplicadas

#### Scripts Individuais

| Script | Descrição |
|--------|-----------|
| **01-configure-git.sh** | Configura Git com identidade e preferências |
| **02-install-zsh.sh** | Instala e configura Zsh como shell padrão ⚠️ Feche o terminal após |
| **03-install-zinit.sh** | Instala Zinit (gerenciador de plugins Zsh rápido) |
| **04-install-starship.sh** | Instala e configura o prompt Starship |
| **05-install-node-nvm.sh** | Instala NVM (Node Version Manager) e Node.js v22 |
| **06-install-yarn.sh** | Instala Yarn via Corepack |
| **07-install-tools.sh** | Instala várias ferramentas de desenvolvimento e utilitários |
| **08-install-font-jetbrains.sh** | Instala JetBrains Mono Nerd Font |
| **09-install-cursor.sh** | Instala Cursor Editor |
| **10-install-claude.sh** | Instala Claude Code CLI |
| **10-configure-terminal.sh** (Linux) | Configura GNOME Terminal com tema Dracula |
| **10-configure-file-watchers.sh** (macOS) | Configura limites de file watchers |
| **11-configure-ssh.sh** (Linux) | Configura SSH para Git |
| **12-configure-inotify.sh** (Linux) | Configura limites inotify para file watching |
| **12-configure-cursor.sh** (macOS) | Aplica configurações do Cursor |
| **13-configure-cursor.sh** (Linux) | Aplica configurações do Cursor |
| **13-install-docker.sh** (macOS) | Instala Docker Desktop |
| **14-configure-terminal.sh** (macOS) | Configura iTerm2 com tema Dracula |
| **15-install-docker.sh** (Linux) | Instala Docker Engine ⚠️ Faça logout/login após |
| **15-install-insomnia.sh** (macOS) | Instala Insomnia REST Client |
| **16-install-insomnia.sh** (Linux) | Instala Insomnia REST Client |
| **16-install-tableplus.sh** (macOS) | Instala cliente de banco de dados TablePlus |
| **17-install-tableplus.sh** (Linux) | Instala cliente de banco de dados TablePlus |

---

### 🔐 Variáveis de Ambiente

#### `.env` Opcional para Preferências Pessoais

```bash
cp .env.example .env  # Opcional
```

#### Ambiente de Trabalho

`.env` obrigatório para configuração específica da empresa:

```bash
cd work
cp .env.example .env  # Obrigatório
nano .env  # Preencha os detalhes da sua empresa
```

**Variáveis de ambiente de trabalho:**
- `GITHUB_TOKEN` - Para repositórios privados
- `AWS_SSO_START_URL` - Configuração AWS SSO
- Suporte para múltiplas contas AWS

Veja [work/.env.example](work/.env.example) para a lista completa.

---

### 📁 Estrutura do Repositório

```
rubinho-install-dev/
├── .gitignore               # Protege arquivos sensíveis
├── LICENSE                  # Licença MIT
├── readme.md                # Este arquivo
├── .env.example             # Template de variáveis de ambiente (opcional)
│
├── linux/                   # 🐧 Configuração Linux
│   ├── config/              # Dotfiles e temas
│   │   ├── starship.toml
│   │   ├── user-settings.json
│   │   ├── cursor-keyboard.json
│   │   └── zsh-config
│   └── scripts/
│       └── enviroment/      # Scripts de configuração (01-17)
│
├── macos/                   # 🍎 Configuração macOS
│   ├── config/              # Dotfiles e temas
│   └── scripts/
│       └── enviroment/      # Scripts de configuração (01-16)
│
└── work/                    # 🏢 Ambiente de trabalho (opcional)
    ├── .env                 # Sua configuração (gitignored)
    ├── .env.example         # Template de configuração da empresa
    └── [linux|macos]/       # Scripts específicos de trabalho
```

---

### 🐛 Solução de Problemas

#### Scripts não executam
**Problema:** `Permission denied` ao executar scripts

**Solução:**
```bash
chmod +x run.sh
chmod +x linux/scripts/enviroment/*.sh
chmod +x macos/scripts/enviroment/*.sh
```

#### Configuração do Git não funciona
**Problema:** Git solicita nome/email toda vez

**Solução:**
1. Verifique se o arquivo `.env` existe na raiz do projeto
2. Adicione suas credenciais do Git:
   ```bash
   GIT_USER_NAME="Seu Nome"
   GIT_USER_EMAIL="seu.email@exemplo.com"
   ```
3. Ou execute `01-configure-git.sh` novamente

#### Docker requer sudo (Linux)
**Problema:** Comando `docker` requer `sudo`

**Solução:**
1. Faça logout e login novamente (após executar `15-install-docker.sh`)
2. Ou execute: `newgrp docker`

#### Zsh não funciona após instalação
**Problema:** Terminal ainda usa bash

**Solução:**
1. Feche e reabra o terminal
2. Ou execute: `chsh -s $(which zsh)`
3. Faça logout e login novamente

---

### ❓ Perguntas Frequentes

#### Geral

**P: Preciso executar todos os scripts?**
R: Não, você pode executar scripts individuais conforme necessário. No entanto, alguns scripts dependem de outros (por exemplo, Yarn precisa do Node.js).

**P: Posso executar os scripts várias vezes?**
R: Sim! Os scripts verificam se as ferramentas já estão instaladas e perguntam se você deseja reinstalar.

**P: Isso afetará minha configuração existente?**
R: Os scripts são projetados para serem seguros e não destrutivos. Eles perguntarão antes de sobrescrever configurações existentes e verificarão instalações existentes.

**P: E se eu estiver em uma distribuição Linux diferente?**
R: Os scripts são testados no Ubuntu/Debian. Para outras distribuições, você pode precisar ajustar os comandos do gerenciador de pacotes.

#### Instalação

**P: Quanto tempo leva a instalação?**
R: Depende da velocidade da sua internet e do sistema. Normalmente 15-30 minutos para uma instalação completa.

**P: Posso instalar ferramentas seletivamente?**
R: Sim! Você pode executar scripts de instalação individuais manualmente dos diretórios `linux/scripts/enviroment/` ou `macos/scripts/enviroment/`.

**P: E se a instalação de uma ferramenta falhar?**
R: O script mostrará uma mensagem de erro. Corrija o problema e execute novamente. O script pulará ferramentas já instaladas.

---

### 📚 Recursos Adicionais

---

### 🤝 Contribuindo

Encontrou um bug ou quer melhorar algo? Sinta-se à vontade para:
1. Abrir uma issue
2. Enviar um pull request
3. Compartilhar feedback

---

### 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
