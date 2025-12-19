#!/usr/bin/env bash

set -e

# ────────────────────────────────────────────────────────────────
# Load Logging Module
# ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

# Source logging module if available
if [ -f "$PROJECT_ROOT/lib/logging.sh" ]; then
    # shellcheck source=lib/logging.sh
    source "$PROJECT_ROOT/lib/logging.sh"
    init_logging
else
    # Fallback logging functions if module not available
    log_info() {
        echo "[INFO] $*" >&2 || true
    }
    log_error() {
        echo "[ERROR] $*" >&2 || true
    }
    log_warning() {
        echo "[WARNING] $*" >&2 || true
    }
fi

echo "=============================================="
echo "========= COMPLETE INSTALLATION =============="
echo "=============================================="
echo ""
echo "This script will install and configure your development environment."
echo ""

ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

# Mark that install-all is running (prevents direct execution of module scripts)
export INSTALL_ALL_RUNNING=true

# Load environment variables from .env file if it exists
if [ -f "$ENV_FILE" ]; then
    echo "📝 Loading configuration from .env file..."
    # Source the .env file, ignoring comments and empty lines
    set -a
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        # Export the variable
        eval "export $line" 2>/dev/null || true
    done < "$ENV_FILE"
    set +a
    echo "✓ Configuration loaded from .env"
else
    echo "❌ .env file not found"
    echo ""
    if [ -f "$ENV_EXAMPLE" ]; then
        echo "📝 Please create a .env file manually:"
        echo "   1. Copy .env.example to .env:"
        echo "      cp $ENV_EXAMPLE $ENV_FILE"
        echo ""
        echo "   2. Edit .env with your information:"
        echo "      nano $ENV_FILE"
        echo ""
        echo "   3. Run this script again"
    else
        echo "   Please create a .env file in the project root: $PROJECT_ROOT"
        echo "   You can use .env.example as a template if available"
    fi
    exit 1
fi

# Validate required configuration from .env
echo "📝 Validating configuration from .env file..."
echo ""

# Check Git user name
if [ -z "$GIT_USER_NAME" ] || [ "$GIT_USER_NAME" = "Your Name" ]; then
    echo "❌ GIT_USER_NAME is required in .env file"
    echo "   Please set GIT_USER_NAME in: $ENV_FILE"
    exit 1
fi

# Check Git email
if [ -z "$GIT_USER_EMAIL" ] || [ "$GIT_USER_EMAIL" = "your.email@example.com" ]; then
    echo "❌ GIT_USER_EMAIL is required in .env file"
    echo "   Please set GIT_USER_EMAIL in: $ENV_FILE"
    exit 1
fi

# Export variables for child scripts
export GIT_USER_NAME
export GIT_USER_EMAIL

echo ""
echo "=============================================="
echo "Configuration summary:"
echo "  Git Name: $GIT_USER_NAME"
echo "  Git Email: $GIT_USER_EMAIL"
echo "=============================================="
echo ""
echo "⚠️  ATTENTION:"
echo "   - After Docker installation (final step), you may need to"
echo "     logout/login to use Docker without sudo (Linux only)."
echo ""

# ────────────────────────────────────────────────────────────────
# Helper Function: Check and Confirm Installation
# ────────────────────────────────────────────────────────────────

check_and_confirm_installation() {
    local tool_name="$1"
    local check_command="$2"
    local version_command="${3:-}"
    local skip_if_installed="${4:-false}"

    # If skip_if_installed is true, skip without asking
    if [ "$skip_if_installed" = true ]; then
        echo "Skipping $tool_name installation..."
        log_info "$tool_name installation skipped"
        return 1
    fi

    # Determine installation mode (default to interactive if not set)
    local install_mode="${INSTALL_MODE:-interactive}"

    # Reinstall Mode: Always install/reinstall everything, no prompts
    if [ "$install_mode" = "reinstall" ] || [ "${FORCE_MODE:-false}" = "true" ]; then
        echo "→ $tool_name will be installed/reinstalled (reinstall mode)"
        log_info "$tool_name will be installed/reinstalled (reinstall mode)"
        return 0
    fi

    # Smart Mode: Check if already installed and skip if it is
    if [ "$install_mode" = "smart" ]; then
        # Configuration scripts (check_command = "true") always run
        if [ "$check_command" = "true" ]; then
            echo "→ $tool_name (configuration), will apply"
            log_info "$tool_name is a configuration script, will proceed"
            return 0
        fi

    local is_installed=false
    local version="unknown"

    # Check if tool is installed
    if eval "$check_command" &>/dev/null; then
        is_installed=true

        # Try to get version if version command provided
        if [ -n "$version_command" ]; then
            version=$(eval "$version_command" 2>/dev/null | head -1 | tr -d '\n' || echo "unknown")
        fi
    fi

        if [ "$is_installed" = true ]; then
            echo "✓ $tool_name is already installed"
            if [ "$version" != "unknown" ]; then
                echo "  Version: $version"
            fi
            echo "  → Skipping installation"
        log_info "$tool_name already installed (version: $version), skipped"
        return 1
        else
            echo "→ $tool_name not found, will install"
            log_info "$tool_name not installed, will proceed with installation"
            return 0
        fi
    fi

    # Interactive Mode: Always prompt user
    # Prompt user for installation
    echo ""
    read -p "Do you want to install $tool_name? [Y/n]: " -n 1 -r
    echo ""

    # Check response (default to yes)
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "  Skipping $tool_name installation..."
        log_info "$tool_name installation skipped by user"
        return 1
    fi

    echo "  Installing $tool_name..."
    log_info "$tool_name installation confirmed by user"
    return 0
}

# Wrapper function to run script with installation check
run_script_with_check() {
    local script_name="$1"
    local tool_name="$2"
    local check_command="$3"
    local version_command="${4:-}"
    local skip_if_installed="${5:-false}"

    echo ""
    echo "Running script: $script_name"
    echo "=============================================="

    # Check and confirm installation
    if check_and_confirm_installation "$tool_name" "$check_command" "$version_command" "$skip_if_installed"; then
        # Execute script
        bash "$SCRIPT_DIR/$script_name"
    else
        echo "Script $script_name skipped."
    fi
}

# Part 1: Initial setup (01-02)
echo ""
echo "=============================================="
echo "PHASE 1: Initial Setup"
echo "=============================================="

# Git configuration
run_script_with_check "01-configure-git.sh" "Git Configuration" "true" "" "false"

# Zsh installation check
run_script_with_check "02-install-zsh.sh" "Zsh" "command -v zsh" "zsh --version 2>&1 | head -1"

echo ""
echo "=============================================="
echo "PHASE 2: Environment Configuration"
echo "=============================================="

# Part 2: Environment setup (03-04)
# Zinit check (check if directory exists)
run_script_with_check "03-install-zinit.sh" "Zinit" "[ -d \"\$HOME/.zinit/bin\" ]" "" "false"

# Starship check
run_script_with_check "04-install-starship.sh" "Starship" "command -v starship" "starship --version 2>&1 | head -1"

# Load NVM (it will be available in .zshrc after restart)
echo ""
echo "Loading NVM configuration..."
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
  echo "✓ NVM loaded"
else
  echo "⚠️  NVM not found yet, will be available after restart"
fi

echo ""
echo "=============================================="
echo "PHASE 3: Development Tools"
echo "=============================================="

# Part 3: Development tools (05-08)
# Node/NVM check
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "05-install-node-nvm.sh" "Node.js" "command -v node" "node --version 2>&1 | head -1"

# Yarn check
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "06-install-yarn.sh" "Yarn" "command -v yarn" "yarn --version 2>&1 | head -1"

# Tools installation
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "07-install-tools.sh" "Development Tools" "true" "" "false"

# Font installation
run_script_with_check "08-install-font-jetbrains.sh" "JetBrains Font" "ls \"$HOME/.local/share/fonts/JetBrainsMono\"/*.ttf 2>/dev/null | head -1 || fc-list | grep -i 'JetBrains Mono' | head -1" "" "false"

echo ""
echo "=============================================="
echo "PHASE 4: Application Setup"
echo "=============================================="

# Part 4: Applications and configuration
# Cursor check
run_script_with_check "09-install-cursor.sh" "Cursor" "command -v cursor" "cursor --version 2>&1 | head -1"

# Claude Code CLI check (requires Node.js)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "10-install-claude.sh" "Claude Code CLI" "command -v claude || npm list -g @anthropic-ai/claude-code &>/dev/null" "claude --version 2>&1 | head -1 || npm list -g @anthropic-ai/claude-code 2>&1 | grep claude-code | head -1"

# Configuration scripts
run_script_with_check "11-configure-terminal.sh" "Terminal Configuration" "true" "" "false"

run_script_with_check "12-configure-ssh.sh" "SSH Configuration" "true" "" "false"

run_script_with_check "13-configure-inotify.sh" "Inotify Configuration" "true" "" "false"

# Cursor configuration
run_script_with_check "15-configure-cursor.sh" "Cursor Configuration" "true" "" "false"

# Docker check
run_script_with_check "16-install-docker.sh" "Docker" "command -v docker" "docker --version 2>&1 | head -1"

# Insomnia check
run_script_with_check "17-install-insomnia.sh" "Insomnia" "command -v insomnia" "insomnia --version 2>&1 | head -1"

# TablePlus check (Linux only)
run_script_with_check "18-install-tableplus.sh" "TablePlus" "command -v tableplus || [ -f $HOME/.local/bin/tableplus ]" "tableplus --version 2>&1 | head -1 || echo 'TablePlus AppImage'"

# Cursor CLI check
run_script_with_check "19-install-cursor-cli.sh" "Cursor CLI" "command -v cursor-agent" "cursor-agent --version 2>&1 | head -1"

# Gemini CLI check (requires Node.js)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "20-install-gemini-cli.sh" "Gemini CLI" "command -v gemini || npm list -g @google/gemini-cli &>/dev/null" "gemini --version 2>&1 | head -1 || npm list -g @google/gemini-cli 2>&1 | grep gemini-cli | head -1"

# Zed check
run_script_with_check "21-install-zed.sh" "Zed" "command -v zed" "zed --version 2>&1 | head -1"

echo ""
echo "=============================================="
echo "🎉 INSTALLATION COMPLETE!"
echo "=============================================="
echo "All scripts have been executed successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS - IMPORTANT ACTIONS REQUIRED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  RESTART YOUR TERMINAL"
echo "   → Close and reopen your terminal to load all configurations"
echo "   → This ensures Zsh, NVM, and other tools are available"
echo ""
echo "2️⃣  CONFIGURE SSH KEY ON GITHUB/GITLAB"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    echo "   → Your SSH public key is ready!"
    echo "   → Key location: ~/.ssh/id_ed25519.pub"
    echo ""
    echo "   📝 To view your public key:"
    echo "      cat ~/.ssh/id_ed25519.pub"
    echo ""
    echo "   📝 To copy to clipboard:"
    echo "      cat ~/.ssh/id_ed25519.pub | xclip -sel clip"
    echo ""
    echo "   🔗 GitHub: https://github.com/settings/keys"
    echo "      → Click 'New SSH key'"
    echo "      → Paste your public key"
    echo "      → Click 'Add SSH key'"
    echo ""
    echo "   🔗 GitLab: https://gitlab.com/-/profile/keys"
    echo "      → Click 'Add new key'"
    echo "      → Paste your public key"
    echo "      → Click 'Add key'"
else
    echo "   → SSH key was not generated. Run script 12-configure-ssh.sh manually"
fi
echo ""
echo "3️⃣  VERIFY INSTALLATIONS"
echo "   After restarting your terminal, run:"
echo "   → node -v"
echo "   → yarn -v"
echo "   → docker --version"
echo "   → zsh --version"
echo "   → starship --version"
echo "   → cursor-agent --version"
echo "   → gemini --version"
echo "   → zed --version"
echo ""
echo "4️⃣  DOCKER SETUP"
echo "   → You may need to logout/login to use Docker without sudo"
echo "   → Or add your user to docker group:"
echo "      sudo usermod -aG docker $USER"
echo "   → Then logout/login"
echo ""
echo "5️⃣  CURSOR IDE CONFIGURATION"
echo "   → Open Cursor IDE"
echo "   → Settings should be automatically applied"
echo "   → If needed, restart Cursor to load all configurations"
echo ""
echo "6️⃣  ZED EDITOR CONFIGURATION"
echo "   → Open Zed editor"
echo "   → Configure AI agents (Claude, Gemini CLI, Cursor CLI)"
echo "   → Press Ctrl-? to open agent panel"
echo "   → Click '+' and select your preferred agent"
echo ""
echo "7️⃣  GEMINI CLI - ENABLE GEMINI 3"
echo "   → Run: gemini"
echo "   → Type: /settings and enable 'Preview Features'"
echo "   → Type: /model and select 'Auto (Gemini 3)'"
echo "   → See: https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/gemini-3.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Your development environment is ready!"
echo "   Happy coding! 🚀"
echo ""
