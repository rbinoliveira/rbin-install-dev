#!/usr/bin/env bash

# ────────────────────────────────────────────────────────────────────────────────
# Environment Variables Validator Library
# ────────────────────────────────────────────────────────────────────────────────
# This library provides functions to validate and collect required environment
# variables from the .env file before any installation begins.
# ────────────────────────────────────────────────────────────────────────────────

# Function to get variable value from .env
get_var_from_env() {
    local var_name="$1"
    local env_file="$2"
    local value=""

    if [ -f "$env_file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue

            if [[ "$line" =~ ^[[:space:]]*${var_name}[[:space:]]*=[[:space:]]*(.+)$ ]]; then
                value="${BASH_REMATCH[1]}"
                value="${value#\"}"
                value="${value%\"}"
                value="${value#\'}"
                value="${value%\'}"
                value="${value#"${value%%[![:space:]]*}"}"
                value="${value%"${value##*[![:space:]]}"}"
                break
            fi
        done < "$env_file"
    fi

    echo "$value"
}

# Function to save variable to .env
save_var_to_env() {
    local var_name="$1"
    local var_value="$2"
    local env_file="$3"

    if grep -q "^[[:space:]]*${var_name}[[:space:]]*=" "$env_file" 2>/dev/null; then
        # Update existing line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^[[:space:]]*${var_name}[[:space:]]*=.*|${var_name}=\"${var_value}\"|" "$env_file"
        else
            sed -i "s|^[[:space:]]*${var_name}[[:space:]]*=.*|${var_name}=\"${var_value}\"|" "$env_file"
        fi
    else
        # Append new line
        echo "${var_name}=\"${var_value}\"" >> "$env_file"
    fi
}

# Function to validate if a value is acceptable (not empty, not placeholder)
# Optional second arg: if "allow_empty" then empty is valid (for optional vars)
is_valid_value() {
    local value="$1"
    local allow_empty="${2:-}"

    # Check if empty (unless allow_empty for optional vars)
    if [ -z "$value" ]; then
        [ "$allow_empty" = "allow_empty" ] && return 0
        return 1
    fi

    # Check if it's a placeholder value
    case "$value" in
        "Your Name"|"your.email@example.com"|"required"|"optional"|"https://your-org.awsapps.com/start"|"https://sua-org.awsapps.com/start")
            return 1
            ;;
    esac

    return 0
}

# Function to prompt user for a variable value
# Arg 5: "optional" = empty value is allowed
prompt_for_variable() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="$3"
    local env_file="$4"
    local allow_empty="${5:-}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 Required Variable: $var_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "$prompt_text"
    echo ""

    while true; do
        if [ -n "$default_value" ]; then
            read -p "Enter value for $var_name [$default_value]: " user_input
            user_input="${user_input:-$default_value}"
        else
            [ "$allow_empty" = "optional" ] && echo "(press Enter to leave empty)"
            read -p "Enter value for $var_name: " user_input
        fi

        if [ "$allow_empty" = "optional" ] && [ -z "$user_input" ]; then
            echo "✓ $var_name left empty (optional)"
            echo ""
            break
        fi

        if ! is_valid_value "$user_input"; then
            echo "❌ Error: $var_name cannot be a placeholder value."
            echo "   Please enter a valid value or leave empty (if optional)."
            echo ""
            continue
        fi

        save_var_to_env "$var_name" "$user_input" "$env_file"
        echo "✓ Saved $var_name to .env file"
        echo ""
        break
    done
}

# Main validation function
# Args: env_file, env_example, [mode]
#   mode = "personal" (default) → only Git vars required
#   mode = "enterprise"        → Git + GITHUB_TOKEN + AWS_SSO_* required
validate_required_env_variables() {
    local env_file="$1"
    local env_example="$2"
    local mode="${3:-personal}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚙️  Environment Variables Validation (modo: $mode)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Checking required environment variables..."
    echo "   Installation will NOT proceed until all required variables are set."
    echo ""

    # Create .env file if it doesn't exist
    if [ ! -f "$env_file" ]; then
        echo "📝 Creating new .env file..."
        if [ -f "$env_example" ]; then
            cp "$env_example" "$env_file"
            echo "✓ Created .env file from .env.example"
        else
            touch "$env_file"
            echo "✓ Created empty .env file"
        fi
        echo ""
    fi

    # Required variables depend on mode
    # Format: "VAR_NAME:Prompt Text:default_value"
    local required_vars=(
        "GIT_USER_NAME:Your Git user name (for Git commits):"
        "GIT_USER_EMAIL:Your Git user email (for Git commits):"
    )

    if [ "$mode" = "enterprise" ]; then
        required_vars+=(
            "GITHUB_TOKEN:GitHub Personal Access Token (private repos; leave empty to skip):optional"
            "AWS_SSO_START_URL:AWS SSO Start URL (e.g. https://your-org.awsapps.com/start):"
            "AWS_SSO_REGION:AWS SSO Region (e.g. us-east-1):"
        )
    fi

    # First pass: check what's missing in required variables
    local missing_required=()

    for var_info in "${required_vars[@]}"; do
        IFS=':' read -r var_name prompt_text default_value <<< "$var_info"
        local current_value=$(get_var_from_env "$var_name" "$env_file")

        # Optional vars (default_value=optional): empty is valid
        if [ "$default_value" = "optional" ]; then
            is_valid_value "$current_value" "allow_empty" && continue
        else
            if [ -z "$current_value" ] && [ -n "$default_value" ]; then
                current_value="$default_value"
            fi
            is_valid_value "$current_value" && continue
        fi
        missing_required+=("$var_info")
    done

    # If there are missing required variables, prompt for them
    if [ ${#missing_required[@]} -gt 0 ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 Missing Required Variables"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "The following required variables need to be configured:"
        echo ""

        for var_info in "${missing_required[@]}"; do
            IFS=':' read -r var_name prompt_text default_value <<< "$var_info"
            local opt_arg=""
            [ "$default_value" = "optional" ] && { default_value=""; opt_arg="optional"; }
            prompt_for_variable "$var_name" "$prompt_text" "$default_value" "$env_file" "$opt_arg"
        done
    fi

    # Final validation: ensure all REQUIRED variables are set
    # Loop until all are valid
    while true; do
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔍 Final Validation"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        local validation_failed=false
        local still_missing=()

        # Validate required variables
        for var_info in "${required_vars[@]}"; do
            IFS=':' read -r var_name prompt_text default_value <<< "$var_info"
            local value=$(get_var_from_env "$var_name" "$env_file")

            if [ "$default_value" = "optional" ]; then
                is_valid_value "$value" "allow_empty" && { echo "✓ $var_name is set (or optional)"; continue; }
            else
                if [ -z "$value" ] && [ -n "$default_value" ]; then
                    value="$default_value"
                fi
                is_valid_value "$value" && { echo "✓ $var_name is set"; continue; }
            fi
            echo "❌ Missing or invalid: $var_name"
            validation_failed=true
            still_missing+=("$var_info")
        done

        echo ""

        if [ "$validation_failed" = false ]; then
            break
        fi

        # Otherwise, prompt for missing ones
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 Missing Required Variables"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Please provide the following required variables:"
        echo ""

        for var_info in "${still_missing[@]}"; do
            IFS=':' read -r var_name prompt_text default_value <<< "$var_info"
            local opt_arg=""
            [ "$default_value" = "optional" ] && { default_value=""; opt_arg="optional"; }
            prompt_for_variable "$var_name" "$prompt_text" "$default_value" "$env_file" "$opt_arg"
        done
    done

    # Show summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 Environment Variables Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show required variables
    for var_info in "${required_vars[@]}"; do
        IFS=':' read -r var_name prompt_text default_value <<< "$var_info"
        local current_value=$(get_var_from_env "$var_name" "$env_file")

        if [ -z "$current_value" ] && [ "$default_value" = "optional" ]; then
            echo "✓ $var_name = (optional, not set)"
        elif [[ "$var_name" =~ (TOKEN|SECRET|PASSWORD|KEY) ]]; then
            echo "✓ $var_name = $(echo "$current_value" | sed 's/\(.\{10\}\).*/\1.../' 2>/dev/null || echo "***HIDDEN***")"
        else
            echo "✓ $var_name = $(echo "$current_value" | sed 's/\(.\{50\}\).*/\1.../' 2>/dev/null || echo "$current_value")"
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All Required Variables Are Set!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    return 0
}

# Function to load environment variables from .env file
load_env_file() {
    local env_file="$1"

    if [ -f "$env_file" ]; then
        echo "📝 Loading environment variables from .env file..."
        set -a
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            # Export the variable
            eval "export $line" 2>/dev/null || true
        done < "$env_file"
        set +a
        echo "✓ Environment variables loaded"
        echo ""
    fi
}

# Function to populate AWS account variables from ~/.aws/config (modo empresa)
populate_aws_accounts() {
    local env_file="$1"

    if ! declare -f get_aws_env_variables > /dev/null 2>&1; then
        return 0
    fi

    if [ ! -f "$HOME/.aws/config" ]; then
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Discovering AWS Accounts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local aws_vars_output
    aws_vars_output=$(get_aws_env_variables)

    if [ -z "$aws_vars_output" ]; then
        echo "⏭️  No AWS accounts found in ~/.aws/config"
        echo ""
        return 0
    fi

    local existing_accounts=$(grep -c "^AWS_ACCOUNT_.*_ID=" "$env_file" 2>/dev/null || echo "0")

    if [ "$existing_accounts" -gt 0 ]; then
        echo "ℹ️  Found $existing_accounts AWS account(s) already in .env file."
        echo ""
        read -p "Do you want to update AWS accounts from ~/.aws/config? [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "⏭️  Keeping existing AWS accounts in .env"
            echo ""
            return 0
        fi
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/^AWS_ACCOUNT_/d' "$env_file"
        else
            sed -i '/^AWS_ACCOUNT_/d' "$env_file"
        fi
        echo "✓ Removed existing AWS account variables"
    fi

    local account_count=0
    echo ""
    echo "Adding AWS accounts to .env file:"
    echo ""

    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        if [[ "$line" =~ ^AWS_ACCOUNT_[0-9]+_(ID|ROLE|PROFILE)= ]]; then
            echo "$line" >> "$env_file"
            if [[ "$line" =~ ^AWS_ACCOUNT_[0-9]+_ID= ]]; then
                account_count=$((account_count + 1))
                local account_id=$(echo "$line" | sed 's/^AWS_ACCOUNT_[0-9]*_ID=//')
                echo "  ✓ Account $account_count: $account_id"
            fi
        elif [[ "$line" =~ ^AWS_SSO_ ]]; then
            local var_name=$(echo "$line" | sed 's/=.*//')
            if grep -q "^${var_name}=" "$env_file" 2>/dev/null; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "s|^${var_name}=.*|${line}|" "$env_file"
                else
                    sed -i "s|^${var_name}=.*|${line}|" "$env_file"
                fi
            else
                echo "$line" >> "$env_file"
            fi
        fi
    done <<< "$aws_vars_output"

    echo ""
    if [ $account_count -gt 0 ]; then
        echo "✓ Added $account_count AWS account(s) to .env file"
    else
        echo "⏭️  No AWS accounts found to add"
    fi
    echo ""
}

