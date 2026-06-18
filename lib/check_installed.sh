#!/usr/bin/env bash

# Function to check if a tool/application is installed
# Usage: check_installed "tool_name" [additional_check_command]
check_installed() {
    local tool="$1"
    local additional_check="${2:-}"

    # Check if command exists
    if command -v "$tool" &> /dev/null; then
        return 0
    fi

    # Check common installation paths (Linux)
    if [ -f "/usr/bin/$tool" ] || [ -f "/usr/local/bin/$tool" ] || [ -f "$HOME/.local/bin/$tool" ]; then
        return 0
    fi

    # Check macOS Applications directory
    # Capitalize first letter (bash 3.2 compatible)
    tool_capitalized=$(echo "$tool" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    if [ -d "/Applications/${tool}.app" ] || [ -d "/Applications/${tool_capitalized}.app" ]; then
        return 0
    fi

    # Check Homebrew installations (macOS)
    if command -v brew &> /dev/null; then
        if brew list "$tool" &> /dev/null 2>&1 || brew list --cask "$tool" &> /dev/null 2>&1; then
            return 0
        fi
    fi

    # Run additional check if provided
    if [ -n "$additional_check" ]; then
        if eval "$additional_check" &> /dev/null; then
            return 0
        fi
    fi

    return 1
}

# Function to check if a specific script's tool is installed
# Maps script names to their tool checks
check_script_installed() {
    local script_name="$1"

    case "$script_name" in
        "02-install-zsh.sh")
            check_installed "zsh" || return 1
            ;;
        "02.5-install-iterm2.sh")
            [ -d "/Applications/iTerm.app" ] || \
                (command -v brew &>/dev/null && brew list --cask iterm2 &>/dev/null) || return 1
            ;;
        "03-install-zinit.sh")
            [ -d "$HOME/.zinit/bin" ] || return 1
            ;;
        "04-install-starship.sh")
            check_installed "starship" || return 1
            ;;
        "05-install-node-nvm.sh")
            [ -d "$HOME/.nvm" ] && [ -s "$HOME/.nvm/nvm.sh" ] && check_installed "node" || return 1
            ;;
        "06-install-yarn.sh")
            check_installed "yarn" || return 1
            ;;
        "07-install-tools.sh")
            check_installed "zoxide" && \
            check_installed "fzf" && \
            (check_installed "fd" || check_installed "fdfind") && \
            (check_installed "bat" || check_installed "batcat") && \
            check_installed "lsd" && \
            check_installed "lazygit" || return 1
            ;;
        "08-install-font-cascadia.sh")
            if [ -d "$HOME/.local/share/fonts/CascadiaCode" ]; then
                return 0
            fi
            fc-list 2>/dev/null | grep -qi 'CaskaydiaCove' && return 0
            return 1
            ;;
        "08-install-font-caskaydia.sh")
            if brew list --cask font-caskaydia-cove-nerd-font &>/dev/null 2>&1; then
                return 0
            fi
            ls "$HOME/Library/Fonts/CaskaydiaCove"*.ttf 2>/dev/null | head -1 | grep -q . && return 0
            ls "$HOME/Library/Fonts/CascadiaCode"*.ttf 2>/dev/null | head -1 | grep -q . && return 0
            return 1
            ;;
        "09-install-cursor.sh"|"10-install-cursor.sh")
            check_installed "cursor" || [ -d "/Applications/Cursor.app" ] || return 1
            ;;
        "10-install-claude.sh"|"11-install-claude.sh")
            check_installed "claude" || npm list -g @anthropic-ai/claude-code &>/dev/null || return 1
            ;;
        "10.2-install-codex.sh"|"11.2-install-codex.sh")
            check_installed "codex" || npm list -g @openai/codex &>/dev/null || return 1
            ;;
        "10.5-install-code-notify.sh"|"11.5-install-code-notify.sh")
            check_installed "cn" || npm list -g code-notify &>/dev/null || [ -x "$HOME/.local/bin/cn" ] || return 1
            ;;
        "16-install-docker.sh"|"17-install-docker.sh")
            check_installed "docker" || [ -d "/Applications/Docker.app" ] || return 1
            ;;
        "18-install-tableplus.sh"|"19-install-tableplus.sh")
            check_installed "tableplus" || [ -d "/Applications/TablePlus.app" ] || \
                [ -f "$HOME/.local/bin/tableplus" ] || return 1
            ;;
        "19-install-cursor-cli.sh"|"20-install-cursor-cli.sh")
            check_installed "cursor-agent" || return 1
            ;;
        "19.5-install-rtk.sh"|"20.5-install-rtk.sh")
            check_installed "rtk" || [ -x "$HOME/.local/bin/rtk" ] || return 1
            ;;
        "19.6-install-graphify.sh"|"20.6-install-graphify.sh")
            check_installed "graphify" || command -v uv &>/dev/null || return 1
            ;;
        "22-install-aws-vpn-client.sh")
            check_installed "awsvpnclient" || [ -d "/Applications/AWS VPN Client/AWS VPN Client.app" ] || return 1
            ;;
        "23-install-aws-cli.sh")
            check_installed "aws" || return 1
            ;;
        "25-install-dotnet.sh")
            check_installed "dotnet" || return 1
            ;;
        "26-install-java.sh")
            check_installed "java" || return 1
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}
