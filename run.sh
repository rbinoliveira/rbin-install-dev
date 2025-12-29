#!/usr/bin/env bash

#
# Rbin Scripts - Main Entry Point
#
# Simplified interface for installing development environment.
# Automatically detects platform and runs the installation script.
#

set -eo pipefail

# ────────────────────────────────────────────────────────────────
# Script Directory and Initialization
# ────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command-line arguments
FORCE_MODE=false
VERBOSE_MODE=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE_MODE=true
            export LOG_LEVEL="DEBUG"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --force       Skip all confirmation prompts"
            echo "  --verbose, -v Enable verbose logging (DEBUG level)"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Export modes for use in other scripts
export FORCE_MODE
export VERBOSE_MODE

# ────────────────────────────────────────────────────────────────
# Platform Detection
# ────────────────────────────────────────────────────────────────

# Source platform detection module
if [ ! -f "$SCRIPT_DIR/lib/platform.sh" ]; then
    echo "ERROR: Platform detection module not found at $SCRIPT_DIR/lib/platform.sh"
    exit 1
fi

# shellcheck source=lib/platform.sh
source "$SCRIPT_DIR/lib/platform.sh"

# ────────────────────────────────────────────────────────────────
# Logging Initialization
# ────────────────────────────────────────────────────────────────

# Source logging module
if [ ! -f "$SCRIPT_DIR/lib/logging.sh" ]; then
    echo "WARNING: Logging module not found at $SCRIPT_DIR/lib/logging.sh" >&2
else
    # shellcheck source=lib/logging.sh
    source "$SCRIPT_DIR/lib/logging.sh"
    init_logging
    log_info "Rbin Scripts started"
    log_info "Platform: $PLATFORM_NAME"
    log_info "Force mode: $FORCE_MODE"
    log_info "Verbose mode: $VERBOSE_MODE"
fi

# Source environment helper module
if [ ! -f "$SCRIPT_DIR/lib/env_helper.sh" ]; then
    echo "WARNING: Environment helper module not found at $SCRIPT_DIR/lib/env_helper.sh" >&2
else
    # shellcheck source=lib/env_helper.sh
    source "$SCRIPT_DIR/lib/env_helper.sh"
    # Set PROJECT_ROOT for env_helper
    export PROJECT_ROOT="$SCRIPT_DIR"
fi

# ────────────────────────────────────────────────────────────────
# Welcome Banner
# ────────────────────────────────────────────────────────────────

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         🚀 Rbin Scripts - Installation Manager 🚀           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
print_platform_info
echo ""

# ────────────────────────────────────────────────────────────────
# Environment Variables Setup
# ────────────────────────────────────────────────────────────────

setup_environment_variables() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚙️  Environment Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Checking required environment variables..."
    echo ""

    # Check if .env exists
    local env_file="$SCRIPT_DIR/.env"
    local env_example="$SCRIPT_DIR/.env.example"

    if [ ! -f "$env_file" ]; then
        echo "⚠️  .env file not found"
        echo ""
        if [ -f "$env_example" ]; then
            echo "📝 Please create a .env file manually:"
            echo "   cp $env_example $env_file"
            echo "   Then edit $env_file with your information"
        else
            echo "📝 Please create a .env file manually in: $SCRIPT_DIR"
        fi
        echo ""
        return 1
    fi

    # Variables that might be needed for installation
    local required_vars=(
        "GIT_USER_NAME:Your Git user name (for Git commits):true"
        "GIT_USER_EMAIL:Your Git user email (for Git commits):true"
    )

    local optional_vars=(
    )

    # Check required variables
    for var_info in "${required_vars[@]}"; do
        IFS=':' read -r var_name prompt_text is_required <<< "$var_info"

        # Check if variable exists in .env
        local value
        if [ -f "$env_file" ]; then
            # Try to read from .env
            while IFS= read -r line || [ -n "$line" ]; do
                # Skip comments and empty lines
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${line// }" ]] && continue

                # Check if this line matches our variable
                if [[ "$line" =~ ^[[:space:]]*${var_name}[[:space:]]*=[[:space:]]*(.+)$ ]]; then
                    value="${BASH_REMATCH[1]}"
                    # Remove quotes if present
                    value="${value#\"}"
                    value="${value%\"}"
                    value="${value#\'}"
                    value="${value%\'}"
                    # Remove leading/trailing whitespace
                    value="${value#"${value%%[![:space:]]*}"}"
                    value="${value%"${value##*[![:space:]]}"}"
                    break
                fi
            done < "$env_file"
        fi

        # If not found or empty (after removing quotes and spaces), prompt user
        if [ -z "${value// }" ] || [ -z "$value" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📝 Missing Required Variable: $var_name"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "$prompt_text"
            echo ""

            while true; do
                read -p "Enter value for $var_name: " user_input

                if [ -z "$user_input" ]; then
                    if [ "$is_required" = "true" ]; then
                        echo "❌ Error: $var_name is required and cannot be empty."
                        echo "   Please enter a value."
                        echo ""
                        continue
                    else
                        echo "⚠️  No value provided. Skipping..."
                        echo ""
                        break
                    fi
                else
                    # Save to .env
                    if grep -q "^[[:space:]]*${var_name}[[:space:]]*=" "$env_file" 2>/dev/null; then
                        # Update existing line
                        if [[ "$OSTYPE" == "darwin"* ]]; then
                            sed -i '' "s|^[[:space:]]*${var_name}[[:space:]]*=.*|${var_name}=\"${user_input}\"|" "$env_file"
                        else
                            sed -i "s|^[[:space:]]*${var_name}[[:space:]]*=.*|${var_name}=\"${user_input}\"|" "$env_file"
                        fi
                    else
                        # Append new line
                        echo "${var_name}=\"${user_input}\"" >> "$env_file"
                    fi

                    echo "✓ Saved $var_name to .env file"
                    echo ""
                    break
                fi
            done
        else
            echo "✓ Found $var_name in .env file (using existing value)"
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Environment configuration complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ────────────────────────────────────────────────────────────────
# Installation Function
# ────────────────────────────────────────────────────────────────

install_development_environment() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Install Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This will install and configure your complete development environment:"
    echo "  • Git configuration"
    echo "  • Zsh shell with Zinit and Starship prompt"
    echo "  • Node.js (via NVM) and Yarn"
    echo "  • Development tools and utilities"
    echo "  • Cursor IDE and extensions"
    echo "  • Docker"
    echo "  • And more..."
    echo ""
    echo "Platform: $PLATFORM_NAME"
    echo ""

    # Setup environment variables before installation
    if ! setup_environment_variables; then
        echo "❌ Environment configuration failed. Please fix the issues above and try again."
        log_error "Environment configuration failed"
        return 1
    fi

    # Choose installation mode
    if [ "$FORCE_MODE" = false ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔧 Installation Mode Selection"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Choose installation mode:"
        echo ""
        echo "  1) 🚀 Smart Mode (Auto-detect)"
        echo "     → Installs only missing tools automatically"
        echo "     → Skips already installed components"
        echo "     → No prompts, faster installation"
        echo ""
        echo "  2) 🎯 Interactive Mode (Manual)"
        echo "     → Prompts for each component"
        echo "     → Full control over what to install"
        echo "     → Can reinstall existing tools"
        echo ""
        echo "  3) 🔄 Reinstall All (Force)"
        echo "     → Installs/reinstalls everything automatically"
        echo "     → No prompts, installs all components"
        echo "     → Perfect when you know you'll accept all"
        echo ""
        read -p "Select mode [1/2/3]: " -n 1 -r
        echo ""
        echo ""

        if [[ $REPLY =~ ^[1]$ ]]; then
            export INSTALL_MODE="smart"
            echo "✓ Smart Mode selected"
            log_info "Installation mode: Smart (auto-detect)"
        elif [[ $REPLY =~ ^[2]$ ]]; then
            export INSTALL_MODE="interactive"
            echo "✓ Interactive Mode selected"
            log_info "Installation mode: Interactive (manual)"
        elif [[ $REPLY =~ ^[3]$ ]]; then
            export INSTALL_MODE="reinstall"
            export FORCE_MODE="true"
            echo "✓ Reinstall All Mode selected"
            log_info "Installation mode: Reinstall All (force)"
        else
            echo "⚠️  Invalid selection. Using Interactive Mode by default."
            export INSTALL_MODE="interactive"
            log_info "Installation mode: Interactive (default)"
        fi
    else
        # Force mode defaults to smart mode
        export INSTALL_MODE="smart"
        log_info "Installation mode: Smart (force mode)"
    fi

    # Determine platform-specific script path
    local install_script
    if is_macos; then
        install_script="$SCRIPT_DIR/macos/scripts/enviroment/00-install-all.sh"
    elif is_linux; then
        install_script="$SCRIPT_DIR/linux/scripts/enviroment/00-install-all.sh"
    else
        echo "❌ Error: Unsupported platform: $PLATFORM_NAME"
        log_error "Unsupported platform: $PLATFORM_NAME"
        return 1
    fi

    # Validate script exists
    if [ ! -f "$install_script" ]; then
        echo "❌ Error: Installation script not found at: $install_script"
        log_error "Installation script not found: $install_script"
        return 1
    fi

    # Make script executable
    chmod +x "$install_script" 2>/dev/null || true

    echo ""
    echo "🚀 Starting installation..."
    echo ""
    log_info "Starting installation: $install_script"

    # Execute installation script
    if bash "$install_script"; then
        echo ""
        echo "✅ Installation completed successfully!"
        log_info "Installation completed successfully"
        return 0
    else
        echo ""
        echo "❌ Installation failed. Check the logs for details."
        log_error "Installation failed"
        return 1
    fi
}

# ────────────────────────────────────────────────────────────────
# Cleanup Handler
# ────────────────────────────────────────────────────────────────

cleanup_and_exit() {
    local exit_code=$?
    echo ""
    log_info "Script exiting with code: $exit_code"
    finalize_logging
    exit "$exit_code"
}

# ────────────────────────────────────────────────────────────────
# Entry Point
# ────────────────────────────────────────────────────────────────

# Trap signals for graceful exit
trap 'echo ""; echo "Interrupted by user. Exiting..."; log_warning "Script interrupted by user (Ctrl+C)"; cleanup_and_exit' INT
trap cleanup_and_exit EXIT

# Start installation
install_development_environment

# Finalize logging
finalize_logging
