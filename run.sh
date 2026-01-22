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

# Source environment validator module
if [ -f "$SCRIPT_DIR/lib/env_validator.sh" ]; then
    # shellcheck source=lib/env_validator.sh
    source "$SCRIPT_DIR/lib/env_validator.sh"
fi

# Source check_installed module
if [ -f "$SCRIPT_DIR/lib/check_installed.sh" ]; then
    # shellcheck source=lib/check_installed.sh
    source "$SCRIPT_DIR/lib/check_installed.sh"
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
    local env_file="$SCRIPT_DIR/.env"
    local env_example="$SCRIPT_DIR/.env.example"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚙️  Environment Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Use the shared validation library if available
    if type validate_required_env_variables >/dev/null 2>&1; then
        if ! validate_required_env_variables "$env_file" "$env_example"; then
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "❌ Environment validation failed!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Installation cannot proceed without required variables."
            echo "Please check your .env file: $env_file"
            echo ""
            return 1
        fi

        # Load environment variables
        if type load_env_file >/dev/null 2>&1; then
            load_env_file "$env_file"
        fi
    else
        # Fallback to basic validation if library not available
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

        # Basic check for required variables
        if [ -z "$GIT_USER_NAME" ] || [ "$GIT_USER_NAME" = "Your Name" ]; then
            echo "❌ GIT_USER_NAME is required in .env file"
            echo "   Please set GIT_USER_NAME in: $env_file"
            return 1
        fi

        if [ -z "$GIT_USER_EMAIL" ] || [ "$GIT_USER_EMAIL" = "your.email@example.com" ]; then
            echo "❌ GIT_USER_EMAIL is required in .env file"
            echo "   Please set GIT_USER_EMAIL in: $env_file"
            return 1
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Environment configuration complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ────────────────────────────────────────────────────────────────
# Get All Available Scripts
# ────────────────────────────────────────────────────────────────

get_all_scripts() {
    local platform_dir="$SCRIPT_DIR/$PLATFORM/scripts/enviroment"
    local scripts=()

    # Get all scripts from the platform directory
    if [ -d "$platform_dir" ]; then
        # List all numbered scripts (excluding 00-install-all.sh)
        for script in "$platform_dir"/*.sh; do
            if [ -f "$script" ]; then
                local basename_script=$(basename "$script")
                # Only include numbered scripts, but not 00-install-all.sh
                if [[ "$basename_script" =~ ^[0-9]+-.*\.sh$ ]] && [[ "$basename_script" != "00-install-all.sh" ]]; then
                    scripts+=("$basename_script")
                fi
            fi
        done
    fi

    # Sort scripts
    local sorted_scripts=($(printf '%s\n' "${scripts[@]}" | sort -V))

    # Output as space-separated string
    echo "${sorted_scripts[@]}"
}

# ────────────────────────────────────────────────────────────────
# Select Scripts to Run
# ────────────────────────────────────────────────────────────────

select_scripts_to_run() {
    local all_scripts=($(get_all_scripts))
    local selected_scripts=()

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Available Scripts for $PLATFORM_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local index=1
    for script in "${all_scripts[@]}"; do
        # Format script name for display
        local script_name=$(echo "$script" | sed 's/^[0-9]*-//;s/\.sh$//' | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
        printf "  %2d) %s\n" "$index" "$script"
        ((index++))
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Enter the numbers of scripts you want to run, separated by commas."
    echo "Example: 1,2,3 or 1,5,10"
    echo ""

    while true; do
        read -p "Select scripts: " user_input
        echo ""

        if [ -z "$user_input" ]; then
            echo "❌ Please enter at least one script number."
            echo ""
            continue
        fi

        # Parse comma-separated numbers
        local valid_selection=true
        IFS=',' read -ra numbers <<< "$user_input"

        for num in "${numbers[@]}"; do
            # Remove whitespace
            num=$(echo "$num" | tr -d '[:space:]')

            # Check if it's a valid number
            if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                echo "❌ Invalid number: $num"
                valid_selection=false
                continue
            fi

            # Check if number is in range
            if [ "$num" -lt 1 ] || [ "$num" -gt ${#all_scripts[@]} ]; then
                echo "❌ Number $num is out of range (1-${#all_scripts[@]})"
                valid_selection=false
                continue
            fi

            # Add to selected scripts (convert to 0-based index)
            local script_index=$((num - 1))
            selected_scripts+=("${all_scripts[$script_index]}")
        done

        if [ "$valid_selection" = true ] && [ ${#selected_scripts[@]} -gt 0 ]; then
            break
        else
            echo "Please try again."
            echo ""
            selected_scripts=()
        fi
    done

    # Export selected scripts as space-separated string
    export SELECTED_SCRIPTS="${selected_scripts[*]}"

    echo "✓ Selected scripts:"
    for script in "${selected_scripts[@]}"; do
        echo "   - $script"
    done
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
        echo "🚀 Installation Action Selection"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Choose what you want to do:"
        echo ""
        echo "  1) 🧠 Smart Install"
        echo "     Installs only what's missing"
        echo "     Automatically skips tools that are already installed"
        echo ""
        echo "  2) 🔄 Reinstall All"
        echo "     Reinstalls everything from scratch"
        echo "     Useful for updating or fixing issues"
        echo ""
        echo "  3) 🎯 Select What to Run"
        echo "     Choose specific scripts to run"
        echo "     You'll see a list and select by number (e.g., 1,2,3)"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        read -p "Select action [1/2/3] (default: 1): " -n 1 -r
        echo ""
        echo ""

        if [[ -z "$REPLY" ]] || [[ "$REPLY" == "1" ]]; then
            export INSTALL_ACTION="smart"
            export INSTALL_MODE="smart"
            echo "✓ Selected: Smart Install"
            log_info "Installation action: Smart Install"
        elif [[ "$REPLY" == "2" ]]; then
            export INSTALL_ACTION="reinstall"
            export INSTALL_MODE="interactive"
            export FORCE_REINSTALL=true
            echo "✓ Selected: Reinstall All"
            log_info "Installation action: Reinstall All"
        elif [[ "$REPLY" == "3" ]]; then
            export INSTALL_ACTION="select"
            export INSTALL_MODE="interactive"
            echo "✓ Selected: Select What to Run"
            log_info "Installation action: Select What to Run"
        else
            echo "❌ Invalid option. Using Smart Install by default."
            export INSTALL_ACTION="smart"
            export INSTALL_MODE="smart"
            log_info "Installation action: Smart Install (default)"
        fi
    else
        # Force mode defaults to smart mode
        export INSTALL_ACTION="smart"
        export INSTALL_MODE="smart"
        log_info "Installation action: Smart (force mode)"
    fi

    # Handle select action - let user choose specific scripts
    if [ "$INSTALL_ACTION" = "select" ]; then
        select_scripts_to_run
        export SELECTED_SCRIPTS
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
