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
    echo "The script \"$SCRIPT_NAME\" is a module and should only be"
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

echo "=============================================="
echo "========= [01] CONFIGURING GIT ==============="
echo "=============================================="

# Validate required values from .env
if [ -z "$GIT_USER_NAME" ]; then
    echo "❌ GIT_USER_NAME is required in .env file"
    exit 1
fi

if [ -z "$GIT_USER_EMAIL" ]; then
    echo "❌ GIT_USER_EMAIL is required in .env file"
    exit 1
fi

echo "Setting up Git identity..."
echo "  Name: $GIT_USER_NAME"
echo "  Email: $GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global color.ui auto
# Evitar nano ao abrir editor (git commit, merge message, etc)
git config --global core.editor "code --wait"

echo "=============================================="
echo "============== [01] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 02-install-zsh.sh"

