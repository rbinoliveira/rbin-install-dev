#!/usr/bin/env bash

#
# Install mode helpers — skip installed tools by default; always refresh configs.
#
# Environment:
#   FORCE_INSTALL=true  → reinstall everything (--force-install)
#
# Usage:
#   source lib/install_mode.sh
#   is_config_script "04-install-starship.sh"
#   check_and_confirm_installation "$tool" "$check" "$version" "$skip" "$script"
#

# Scripts that apply project configs (always run unless explicitly skipped).
is_config_script() {
    local script_name="$1"

    case "$script_name" in
        01-configure-git.sh)
            return 0
            ;;
        04-install-starship.sh)
            # Installs starship if missing; always refreshes ~/.zshrc and starship.toml
            return 0
            ;;
        *configure*)
            return 0
            ;;
    esac

    return 1
}

check_and_confirm_installation() {
    local tool_name="$1"
    local check_command="$2"
    local version_command="${3:-}"
    local skip_if_installed="${4:-false}"
    local script_name="${5:-}"

    if [ "$skip_if_installed" = true ]; then
        echo "Skipping $tool_name..."
        log_info "$tool_name installation skipped (skip_if_installed)"
        return 1
    fi

    if [ "${FORCE_INSTALL:-false}" = true ]; then
        echo "→ $tool_name will be installed/reinstalled (--force-install)"
        log_info "$tool_name will be installed/reinstalled (force-install)"
        return 0
    fi

    if [ -n "$script_name" ] && is_config_script "$script_name"; then
        echo "→ $tool_name — updating configuration"
        log_info "$tool_name configuration will be applied"
        return 0
    fi

    if [ -n "$check_command" ] && [ "$check_command" != "true" ]; then
        if eval "$check_command" 2>/dev/null; then
            if [ -n "$version_command" ]; then
                local version_output
                version_output="$(eval "$version_command" 2>/dev/null | head -1)"
                if [ -n "$version_output" ]; then
                    echo "✓ $tool_name already installed ($version_output) — skipping"
                else
                    echo "✓ $tool_name already installed — skipping"
                fi
            else
                echo "✓ $tool_name already installed — skipping"
            fi
            log_info "$tool_name skipped (already installed)"
            return 1
        fi
    elif [ -n "$script_name" ] && type check_script_installed &>/dev/null 2>&1; then
        if check_script_installed "$script_name"; then
            echo "✓ $tool_name already installed — skipping"
            log_info "$tool_name skipped (already installed)"
            return 1
        fi
    fi

    echo "→ $tool_name will be installed"
    log_info "$tool_name will be installed"
    return 0
}
