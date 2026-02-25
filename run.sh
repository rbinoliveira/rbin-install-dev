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
# Mode Selection: Personal vs Enterprise (first question)
# ────────────────────────────────────────────────────────────────
# Modo pessoal: ambiente dev sem AWS, Java ou .NET.
# Modo empresa: inclui configurações AWS, Java e .NET.

select_rbin_mode() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Rbin Scripts - Escolha o modo"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1) Modo pessoal"
    echo "     Ambiente de desenvolvimento básico (sem AWS, Java ou .NET)"
    echo ""
    echo "  2) Modo empresa"
    echo "     Inclui configurações de AWS, Java e .NET"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    while true; do
        read -p "Selecione o modo [1/2]: " -n 1 -r
        echo ""

        if [[ "$REPLY" == "1" ]]; then
            export RBIN_MODE="personal"
            echo ""
            echo "✓ Modo selecionado: Pessoal"
            log_info "RBIN_MODE=personal"
            break
        elif [[ "$REPLY" == "2" ]]; then
            export RBIN_MODE="enterprise"
            echo ""
            echo "✓ Modo selecionado: Empresa (AWS, Java, .NET)"
            log_info "RBIN_MODE=enterprise"
            break
        else
            echo "❌ Opção inválida. Digite 1 ou 2."
            echo ""
        fi
    done
    echo ""
}

# Ask mode first (before environment setup); default to personal if non-interactive
if [ -t 0 ]; then
    select_rbin_mode
else
    export RBIN_MODE="${RBIN_MODE:-personal}"
    log_info "RBIN_MODE=$RBIN_MODE (non-interactive)"
fi

# Load AWS helper only in enterprise mode
if [ "${RBIN_MODE:-}" = "enterprise" ] && [ -f "$SCRIPT_DIR/lib/aws_helper.sh" ]; then
    # shellcheck source=lib/aws_helper.sh
    source "$SCRIPT_DIR/lib/aws_helper.sh"
fi

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
        if ! validate_required_env_variables "$env_file" "$env_example" "${RBIN_MODE:-personal}"; then
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

    # Enterprise-only scripts (only shown when RBIN_MODE=enterprise)
    local enterprise_scripts=(
        "22-install-aws-vpn-client.sh"
        "23-install-aws-cli.sh"
        "24-configure-aws-sso.sh"
        "25-install-dotnet.sh"
        "26-install-java.sh"
        "27-configure-github-token.sh"
        "28-install-insomnia.sh"
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
                    # In personal mode, skip enterprise-only scripts
                    if [ "${RBIN_MODE:-personal}" = "personal" ]; then
                        local is_enterprise=false
                        for es in "${enterprise_scripts[@]}"; do
                            if [[ "$basename_script" == "$es" ]]; then
                                is_enterprise=true
                                break
                            fi
                        done
                        [[ "$is_enterprise" == true ]] && continue
                    fi
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

    # Always use reinstall mode
    export INSTALL_MODE="reinstall"
    export FORCE_REINSTALL=true
    
    # Show numbered list of scripts and allow selection
    local all_scripts=($(get_all_scripts))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Available Installation Scripts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Select scripts to install (will always reinstall):"
    echo ""
    
    local index=1
    for script in "${all_scripts[@]}"; do
        # Format script name for display (remove numbers and .sh, capitalize)
        # Remove .sh extension first
        local script_basename=$(echo "$script" | sed 's/\.sh$//')
        # Remove leading numbers (including decimals like 02.5) and dash
        # Pattern: one or more digits, optionally followed by . and more digits, then a dash
        local script_name=$(echo "$script_basename" | sed -E 's/^[0-9]+(\.[0-9]+)?-//' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
        printf "  %2d) %s\n" "$index" "$script_name"
        ((index++))
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Enter script numbers separated by commas (e.g., 1,2,3)"
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
        
        # Convert to lowercase for comparison
        user_input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        
        # Handle "all" option
        if [ "$user_input_lower" = "all" ]; then
            export SELECTED_SCRIPTS="${all_scripts[*]}"
            echo "✓ Selected: All scripts (${#all_scripts[@]} scripts)"
            log_info "Installation action: All scripts selected"
            break
        fi
        
        # Parse comma-separated numbers
        local valid_selection=true
        local selected_scripts=()
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
            export SELECTED_SCRIPTS="${selected_scripts[*]}"
            echo "✓ Selected scripts:"
            for script in "${selected_scripts[@]}"; do
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
    if bash "$install_script"; then
        echo ""
        echo "✅ Installation completed successfully!"
        log_info "Installation completed successfully"
        # Modo empresa: popular contas AWS no .env se disponível
        if [ "${RBIN_MODE:-}" = "enterprise" ] && type populate_aws_accounts &>/dev/null 2>&1; then
            if [ -f "$SCRIPT_DIR/.env" ]; then
                populate_aws_accounts "$SCRIPT_DIR/.env"
            fi
        fi
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
