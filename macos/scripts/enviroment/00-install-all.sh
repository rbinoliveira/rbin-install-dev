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
echo "   - After Docker installation, you may need to"
echo "     restart Docker Desktop (macOS)."
echo ""

# Fix Homebrew permissions once before any brew-based installs
if [ -f "$PROJECT_ROOT/lib/brew_helper.sh" ]; then
    # shellcheck source=lib/brew_helper.sh
    source "$PROJECT_ROOT/lib/brew_helper.sh"
    if command -v brew &> /dev/null; then
        echo "Checking Homebrew permissions..."
        ensure_homebrew_writable || exit 1
    fi
fi

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

    # Always use reinstall mode - always install/reinstall everything, no prompts
    echo "→ $tool_name will be installed/reinstalled (reinstall mode)"
    log_info "$tool_name will be installed/reinstalled (reinstall mode)"
    return 0
}

# Wrapper function to run script with installation check
run_script_with_check() {
    local script_name="$1"
    local tool_name="$2"
    local check_command="$3"
    local version_command="${4:-}"
    local skip_if_installed="${5:-false}"

    # If SELECTED_SCRIPTS is set (option 3: Select What to Run), check if this script is in the list
    if [ -n "${SELECTED_SCRIPTS:-}" ]; then
        local script_found=false
        # Convert SELECTED_SCRIPTS to array
        local selected_array=($SELECTED_SCRIPTS)
        for selected_script in "${selected_array[@]}"; do
            if [ "$selected_script" = "$script_name" ]; then
                script_found=true
                break
            fi
        done
        
        if [ "$script_found" = false ]; then
            # Silently skip scripts that are not selected
            return 0
        fi
    fi

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

# iTerm2 installation check (macOS only)
run_script_with_check "02.5-install-iterm2.sh" "iTerm2" "[ -d \"/Applications/iTerm.app\" ] || (command -v brew &>/dev/null && brew list --cask iterm2 &>/dev/null)" "[ -d \"/Applications/iTerm.app\" ] && defaults read /Applications/iTerm.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo 'unknown'"

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
run_script_with_check "08-install-font-caskaydia.sh" "CaskaydiaCove Nerd Font" "ls \"$HOME/Library/Fonts/CaskaydiaCove\"*.ttf 2>/dev/null | head -1" "" "false"

echo ""
echo "=============================================="
echo "PHASE 4: Application Setup"
echo "=============================================="

# Part 4: Applications and configuration
# Cursor check
run_script_with_check "10-install-cursor.sh" "Cursor" "[ -d \"/Applications/Cursor.app\" ] || command -v cursor" "[ -d \"/Applications/Cursor.app\" ] && defaults read /Applications/Cursor.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo 'unknown'"

# Claude Code CLI check (requires Node.js)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "11-install-claude.sh" "Claude Code CLI" "command -v claude || npm list -g @anthropic-ai/claude-code &>/dev/null" "claude --version 2>&1 | head -1 || npm list -g @anthropic-ai/claude-code 2>&1 | grep claude-code | head -1"

# OpenAI Codex CLI (terminal agent: codex)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "11.2-install-codex.sh" "Codex CLI" "command -v codex || npm list -g @openai/codex &>/dev/null" "codex --version 2>&1 | head -1 || npm list -g @openai/codex 2>&1 | grep @openai/codex | head -1"

# Code-Notify (desktop notifications for Claude, Codex, Gemini)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
run_script_with_check "11.5-install-code-notify.sh" "Code-Notify" "command -v cn || npm list -g code-notify &>/dev/null || [ -x \"$HOME/.local/bin/cn\" ]" "cn version 2>&1 | head -1 || npm list -g code-notify 2>&1 | grep code-notify | head -1"

# Configuration scripts
run_script_with_check "12-configure-terminal.sh" "Terminal Configuration" "true" "" "false"

run_script_with_check "13-configure-ssh.sh" "SSH Configuration" "true" "" "false"

# Cursor configuration
run_script_with_check "16-configure-cursor.sh" "Cursor Configuration" "true" "" "false"

# Docker check
run_script_with_check "17-install-docker.sh" "Docker" "command -v docker" "docker --version 2>&1 | head -1"

# TablePlus check (macOS only)
run_script_with_check "19-install-tableplus.sh" "TablePlus" "command -v tableplus || [ -d \"/Applications/TablePlus.app\" ]" "[ -d \"/Applications/TablePlus.app\" ] && defaults read /Applications/TablePlus.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo 'unknown'"

# Cursor CLI check
run_script_with_check "20-install-cursor-cli.sh" "Cursor CLI" "command -v cursor-agent" "cursor-agent --version 2>&1 | head -1"

# RTK (token optimizer — requires Claude, Codex, Cursor installed above)
run_script_with_check "20.5-install-rtk.sh" "RTK" "command -v rtk || [ -x \"$HOME/.local/bin/rtk\" ]" "rtk --version 2>&1 | head -1"

# Graphify (knowledge graph — requires Claude, Codex, Cursor installed above)
run_script_with_check "20.6-install-graphify.sh" "Graphify" "command -v graphify || command -v uv" "graphify --version 2>&1 | head -1 || uv tool list 2>&1 | grep graphifyy | head -1"

# Modo empresa: AWS, Java, .NET, GitHub token
if [ "${RBIN_MODE:-}" = "enterprise" ]; then
    echo ""
    echo "=============================================="
    echo "PHASE 5: Enterprise (AWS, Java, .NET)"
    echo "=============================================="
    run_script_with_check "22-install-aws-vpn-client.sh" "AWS VPN Client" "true" "" "false"
    run_script_with_check "23-install-aws-cli.sh" "AWS CLI" "command -v aws" "aws --version 2>&1 | head -1"
    run_script_with_check "24-configure-aws-sso.sh" "AWS SSO Configuration" "true" "" "false"
    run_script_with_check "25-install-dotnet.sh" ".NET SDK" "command -v dotnet" "dotnet --version 2>&1 | head -1"
    run_script_with_check "26-install-java.sh" "Java" "command -v java" "java -version 2>&1 | head -1"
    run_script_with_check "27-configure-github-token.sh" "GitHub Token" "true" "" "false"
fi

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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "      cat ~/.ssh/id_ed25519.pub | pbcopy"
    else
        echo "      cat ~/.ssh/id_ed25519.pub | xclip -sel clip"
    fi
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
echo "   → cursor --version"
echo "   → cursor-agent --version"
echo "   → codex --version"
echo "   → cn version"
echo "   → rtk --version"
echo "   → rtk init --show"
echo "   → graphify --version"
echo ""
echo "4️⃣  DOCKER SETUP (if Docker was installed)"
echo "   → Start Docker Desktop application"
echo "   → Wait for it to fully start"
echo "   → Verify with: docker ps"
echo ""
echo "5️⃣  CURSOR IDE CONFIGURATION"
echo "   → Open Cursor IDE"
echo "   → Settings should be automatically applied"
echo "   → If needed, restart Cursor to load all configurations"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Your development environment is ready!"
echo "   Happy coding! 🚀"
echo ""
