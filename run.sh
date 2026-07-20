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
FORCE_INSTALL=false
VERBOSE_MODE=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --force-install)
            FORCE_INSTALL=true
            shift
            ;;
        --verbose|-v)
            VERBOSE_MODE=true
            export LOG_LEVEL="DEBUG"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force-install] [--force] [--verbose]"
            echo ""
            echo "Options:"
            echo "  --force-install  Reinstall everything, even if already installed"
            echo "  --force          Skip interactive confirmation prompts"
            echo "  --verbose, -v    Enable verbose logging (DEBUG level)"
            echo "  --help           Show this help message"
            echo ""
            echo "Default: install missing tools only; configuration scripts always run."
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
export FORCE_INSTALL
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
    log_info "Force install: $FORCE_INSTALL"
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

# Source sudo helper (one password for the whole install)
if [ -f "$SCRIPT_DIR/lib/sudo_helper.sh" ]; then
    # shellcheck source=lib/sudo_helper.sh
    source "$SCRIPT_DIR/lib/sudo_helper.sh"
fi

# ────────────────────────────────────────────────────────────────
# Mode: always personal (dev environment without AWS, Java or .NET)
# ────────────────────────────────────────────────────────────────

export RBIN_MODE="personal"
log_info "RBIN_MODE=personal"

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

    # Use the shared validation library if available (required vars depend on mode)
    if type validate_required_env_variables >/dev/null 2>&1; then
        if ! validate_required_env_variables "$env_file" "$env_example" "personal"; then
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

    return 0
}

# ────────────────────────────────────────────────────────────────
# Get All Available Scripts
# ────────────────────────────────────────────────────────────────

get_all_scripts() {
    local platform_dir="$SCRIPT_DIR/$PLATFORM/scripts/enviroment"
    local scripts=()

    # Enterprise-only scripts (never offered — install is always personal mode)
    local enterprise_scripts=(
        "22-install-aws-vpn-client.sh"
        "23-install-aws-cli.sh"
        "24-configure-aws-sso.sh"
        "25-install-dotnet.sh"
        "26-install-java.sh"
        "27-configure-github-token.sh"
    )

    # Get all scripts from the platform directory
    if [ -d "$platform_dir" ]; then
        for script in "$platform_dir"/*.sh; do
            if [ -f "$script" ]; then
                local basename_script=$(basename "$script")
                # Only include numbered scripts, but not 00-install-all.sh
                if [[ "$basename_script" =~ ^[0-9]+\.?[0-9]*-.*\.sh$ ]] && [[ "$basename_script" != "00-install-all.sh" ]]; then
                    # Skip inotify (removed step)
                    [[ "$basename_script" == "13-configure-inotify.sh" ]] && continue
                    # Skip enterprise-only scripts
                    local is_enterprise=false
                    for es in "${enterprise_scripts[@]}"; do
                        if [[ "$basename_script" == "$es" ]]; then
                            is_enterprise=true
                            break
                        fi
                    done
                    [[ "$is_enterprise" == true ]] && continue
                    scripts+=("$basename_script")
                fi
            fi
        done
    fi

    # Sort scripts using version sort (handles 02.5 correctly)
    local sorted_scripts=($(printf '%s\n' "${scripts[@]}" | sort -V))

    echo "${sorted_scripts[@]}"
}

# ────────────────────────────────────────────────────────────────
# Select Scripts to Run (deprecated - now integrated in main flow)
# ────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────
# Installation Function
# ────────────────────────────────────────────────────────────────

install_development_environment() {
    # Setup environment variables before installation
    if ! setup_environment_variables; then
        echo "❌ Environment configuration failed. Please fix the issues above and try again."
        log_error "Environment configuration failed"
        return 1
    fi

    if [ "${FORCE_INSTALL:-false}" = true ]; then
        export INSTALL_MODE="reinstall"
    else
        export INSTALL_MODE="install-missing"
    fi

    # Show numbered list of scripts and allow selection
    local all_scripts=($(get_all_scripts))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Available Installation Scripts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [ "${FORCE_INSTALL:-false}" = true ]; then
        echo "Mode: reinstall everything (--force-install)"
    else
        echo "Mode: install missing only · configs always updated"
        echo "      (use --force-install to reinstall all tools)"
    fi
    echo ""
    echo "Select scripts to run:"
    echo "  (Use the numbers shown below — they match the [NN] shown when each script runs)"
    echo ""
    
    # Helper: resolve script filename by number (Bash 3.x compatible; no associative arrays)
    get_script_by_num() {
        local want="$1"
        for s in "${all_scripts[@]}"; do
            local np
            np=$(echo "$s" | sed -E 's/^([0-9]+(\.[0-9]+)?)-.*/\1/')
            if [ "$np" = "$want" ]; then
                echo "$s"
                return
            fi
        done
    }

    for script in "${all_scripts[@]}"; do
        local num_prefix
        num_prefix=$(echo "$script" | sed -E 's/^([0-9]+(\.[0-9]+)?)-.*/\1/')
        local script_basename=$(echo "$script" | sed 's/\.sh$//')
        local script_name
        script_name=$(echo "$script_basename" | sed -E 's/^[0-9]+(\.[0-9]+)?-//' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
        printf "  %5s) %s\n" "$num_prefix" "$script_name"
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Enter script numbers separated by commas (e.g., 15,16 or 01,02,15)"
    echo "Or type 'all' to install everything"
    echo ""
    
    while true; do
        read -p "Select scripts: " user_input
        echo ""
        
        if [ -z "$user_input" ]; then
            echo "❌ Please enter at least one script number or 'all'."
            echo ""
            continue
        fi
        
        user_input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        if [ "$user_input_lower" = "all" ]; then
            export SELECTED_SCRIPTS="${all_scripts[*]}"
            echo "✓ Selected: All scripts (${#all_scripts[@]} scripts)"
            log_info "Installation action: All scripts selected"
            break
        fi
        
        local valid_selection=true
        local selected_scripts=()
        IFS=',' read -ra numbers <<< "$user_input"
        
        for num in "${numbers[@]}"; do
            num=$(echo "$num" | tr -d '[:space:]')
            # Accept digits with optional decimal (e.g. 15, 02.5, 1, 16)
            if [[ ! "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "❌ Invalid number: $num"
                valid_selection=false
                continue
            fi
            
            # Match by script number (exact, then try zero-padded: 1->01, 2.5->02.5)
            local script_file
            script_file=$(get_script_by_num "$num")
            if [ -z "$script_file" ]; then
                local padded
                if [[ "$num" =~ ^[0-9]+$ ]]; then
                    padded=$(printf "%02d" "$num" 2>/dev/null || echo "$num")
                else
                    # e.g. 2.5 -> 02.5
                    padded=$(echo "$num" | sed -E 's/^([0-9]+)\./\1./; s/^([0-9])\./0\1./')
                fi
                script_file=$(get_script_by_num "$padded")
            fi
            if [ -z "$script_file" ]; then
                echo "❌ No script with number: $num (use one of the numbers listed above)"
                valid_selection=false
                continue
            fi
            selected_scripts+=("$script_file")
        done
        
        if [ "$valid_selection" = true ] && [ ${#selected_scripts[@]} -gt 0 ]; then
            # Remove duplicates (user might type 15,15)
            local unique_scripts=()
            for s in "${selected_scripts[@]}"; do
                [[ " ${unique_scripts[*]} " =~ " $s " ]] || unique_scripts+=("$s")
            done
            export SELECTED_SCRIPTS="${unique_scripts[*]}"
            echo "✓ Selected scripts:"
            for script in "${unique_scripts[@]}"; do
                echo "   - $script"
            done
            log_info "Installation action: Selected scripts: ${SELECTED_SCRIPTS}"
            break
        else
            echo "Please try again."
            echo ""
        fi
    done
    
    echo ""

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

    # Execute installation script (RBIN_MODE is exported for 00-install-all.sh)
    # Sudo keepalive runs inside 00-install-all.sh (same process as brew/sudo)
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
