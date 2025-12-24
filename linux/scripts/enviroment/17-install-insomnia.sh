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


# Don't use set -e here because we need to handle installation failures gracefully
set +e

echo "=============================================="
echo "========= [17] INSTALLING INSOMNIA ==========="
echo "=============================================="

echo "Installing Insomnia..."

INSTALLED=false

# Clean up old Bintray repository if it exists (Bintray was shut down)
if [ -d /etc/apt/sources.list.d ]; then
    if [ -f /etc/apt/sources.list.d/insomnia.list ]; then
        echo "→ Removing old Insomnia repository (Bintray is shut down)..."
        sudo rm -f /etc/apt/sources.list.d/insomnia.list
    fi
    # Also check for any bintray entries in sources.list.d
    for file in /etc/apt/sources.list.d/*.list; do
        if [ -f "$file" ] && grep -q "bintray.com/getinsomnia" "$file" 2>/dev/null; then
            echo "→ Removing broken repository: $(basename "$file")"
            sudo rm -f "$file"
        fi
    done
fi
# Remove GPG keys
sudo rm -f /etc/apt/keyrings/insomnia.gpg 2>/dev/null || true
sudo rm -f /etc/apt/trusted.gpg.d/insomnia.gpg 2>/dev/null || true

# Check if already installed
if command -v insomnia &> /dev/null; then
    echo "✓ Insomnia is already installed: $(insomnia --version 2>&1 | head -1 || echo 'installed')"
    INSTALLED=true
else
    # Method 1: Try snap (easiest and most reliable)
    if command -v snap &> /dev/null; then
        echo "→ Trying to install via snap..."
        if sudo snap install insomnia 2>&1; then
            # Verify installation succeeded
            if command -v insomnia &> /dev/null || [ -f /snap/bin/insomnia ]; then
                INSTALLED=true
                echo "✓ Insomnia installed via snap"
                # Snap installs to /snap/bin, make sure it's in PATH
                if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
                    export PATH="/snap/bin:$PATH"
                fi
            fi
        fi
    fi
    
    # Method 2: Try official Kong repository (new location after Kong acquisition)
    if [ "$INSTALLED" = false ]; then
        echo "→ Trying official Kong repository..."
        
        # Install curl if not available
        if ! command -v curl &> /dev/null; then
            sudo apt-get update -y
            sudo apt-get install -y curl
        fi
        
        # Use the official setup script from Kong
        if curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' 2>/dev/null | sudo -E bash 2>&1; then
            echo "→ Repository added, updating package list..."
            if sudo apt-get update -y 2>&1; then
                echo "→ Installing Insomnia..."
                if sudo apt-get install -y insomnia 2>&1; then
                    INSTALLED=true
                    echo "✓ Insomnia installed via APT repository"
                fi
            fi
        fi
    fi
    
    # If installation failed, provide helpful error message
    if [ "$INSTALLED" = false ]; then
        echo "⚠️  Automatic installation failed."
        echo ""
        echo "Please install Insomnia manually using one of these methods:"
        echo ""
        echo "Method 1 (Recommended):"
        echo "  sudo snap install insomnia"
        echo ""
        echo "Method 2:"
        echo "  curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' | sudo -E bash"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install insomnia"
        echo ""
        echo "Method 3 (AppImage):"
        echo "  1. Visit: https://insomnia.rest/download"
        echo "  2. Download the AppImage"
        echo "  3. chmod +x Insomnia.AppImage && ./Insomnia.AppImage"
        echo ""
        exit 1
    fi
fi

# Verify installation
if [ "$INSTALLED" = true ]; then
    # Find the correct insomnia executable
    INSOMNIA_CMD=""
    if command -v insomnia &> /dev/null; then
        INSOMNIA_CMD="insomnia"
    elif [ -f "/snap/bin/insomnia" ]; then
        INSOMNIA_CMD="/snap/bin/insomnia"
    fi
    
    if [ -n "$INSOMNIA_CMD" ]; then
        echo "✓ Insomnia installed successfully"
        if $INSOMNIA_CMD --version &> /dev/null; then
            $INSOMNIA_CMD --version 2>&1 | head -1
        fi
    else
        echo "⚠️  Insomnia installed but command not found in PATH"
        echo "   Try restarting your terminal or launching from Applications menu"
    fi
fi

echo "=============================================="
echo "============== [17] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 18-install-tableplus.sh"
