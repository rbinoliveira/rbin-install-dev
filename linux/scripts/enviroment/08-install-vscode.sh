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
echo "========= [08] INSTALLING VS CODE ==========="
echo "=============================================="

echo "Installing Visual Studio Code..."

# Check if snap is available (Ubuntu/Debian)
if command -v snap &> /dev/null; then
    echo "Installing VS Code via snap..."
    sudo snap install --classic code
    echo "✓ Visual Studio Code installed successfully via snap"
# Check if apt is available (Debian/Ubuntu without snap)
elif command -v apt &> /dev/null; then
    echo "Installing VS Code via apt..."

    # Import Microsoft GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    rm -f packages.microsoft.gpg

    # Add VS Code repository
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

    # Update and install
    sudo apt update
    sudo apt install -y code

    echo "✓ Visual Studio Code installed successfully via apt"
# Check if yum/dnf is available (Fedora/RHEL/CentOS)
elif command -v dnf &> /dev/null; then
    echo "Installing VS Code via dnf..."

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    sudo dnf check-update
    sudo dnf install -y code

    echo "✓ Visual Studio Code installed successfully via dnf"
else
    echo "⚠️  Package manager not found"
    echo ""
    echo "Please install Visual Studio Code manually:"
    echo "  1. Visit: https://code.visualstudio.com/docs/setup/linux"
    echo "  2. Follow instructions for your distribution"
    echo ""
    exit 1
fi

# Wait a moment for the installation to complete
sleep 2

# Check for command-line tool
if command -v code &> /dev/null; then
    echo "✓ VS Code command-line tool is available"
    code --version 2>/dev/null || echo "⚠️  Version check failed, but VS Code is installed"
else
    echo "⚠️  VS Code command-line tool not found in PATH"
    echo "   You may need to restart your terminal"
fi

echo "=============================================="
echo "============== [08] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 09-install-cursor.sh"
