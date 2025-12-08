#!/usr/bin/env bash

# ────────────────────────────────────────────────────────────────
# Module Guard - Prevent Direct Execution
# ────────────────────────────────────────────────────────────────
# This script should only be executed by 00-install-all.sh
if [ -z "$INSTALL_ALL_RUNNING" ]; then
    SCRIPT_NAME=$(basename "$0")
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    INSTALL_SCRIPT="$SCRIPT_DIR/00-install-all.sh"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  This script should not be executed directly"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The script '$SCRIPT_NAME' is a module and should only be"
    echo "executed as part of the complete installation process."
    echo ""
    echo "To run the complete installation, use:"
    echo "  bash $INSTALL_SCRIPT"
    echo ""
    echo "Or from the project root:"
    echo "  bash run.sh"
    echo ""
    exit 1
fi

set -e

# Source environment helper if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
if [ -f "$PROJECT_ROOT/lib/env_helper.sh" ]; then
    source "$PROJECT_ROOT/lib/env_helper.sh"
fi

echo "=============================================="
echo "========= [01] CONFIGURING GIT ==============="
echo "=============================================="

# Get Git user name (from .env or prompt)
if [ -z "$GIT_USER_NAME" ]; then
    if command -v get_env_var &> /dev/null; then
        GIT_USER_NAME=$(get_env_var "GIT_USER_NAME" "Your Git name" true true)
    else
        echo "⚠️  GIT_USER_NAME not found in .env file"
        read -p "Enter your Git name: " GIT_USER_NAME
        if [ -z "$GIT_USER_NAME" ]; then
            echo "❌ Error: GIT_USER_NAME cannot be empty"
            exit 1
        fi
    fi
fi

# Get Git user email (from .env or prompt)
if [ -z "$GIT_USER_EMAIL" ]; then
    if command -v get_env_var &> /dev/null; then
        GIT_USER_EMAIL=$(get_env_var "GIT_USER_EMAIL" "Your Git email" true true)
    else
        echo "⚠️  GIT_USER_EMAIL not found in .env file"
        read -p "Enter your Git email: " GIT_USER_EMAIL
        if [ -z "$GIT_USER_EMAIL" ]; then
            echo "❌ Error: GIT_USER_EMAIL cannot be empty"
            exit 1
        fi
    fi
fi

echo "Setting up Git identity..."
echo "  Name: $GIT_USER_NAME"
echo "  Email: $GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global color.ui auto

echo "=============================================="
echo "============== [01] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 02-install-zsh.sh"

