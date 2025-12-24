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
echo "========= [04] INSTALLING STARSHIP ==========="
echo "=============================================="

echo "Installing Starship prompt..."

# Check if Starship is already installed
if command -v starship &> /dev/null; then
    echo "✓ Starship is already installed: $(starship --version)"
else
    INSTALLED=false
    
    # Method 1: Try package manager (preferred method)
    if command -v apt-get &> /dev/null; then
        echo "→ Trying to install via apt..."
        if sudo apt-get update -y && sudo apt-get install -y starship 2>/dev/null; then
            INSTALLED=true
            echo "✓ Starship installed via apt"
        fi
    elif command -v dnf &> /dev/null; then
        echo "→ Trying to install via dnf..."
        if sudo dnf install -y starship 2>/dev/null; then
            INSTALLED=true
            echo "✓ Starship installed via dnf"
        fi
    elif command -v yum &> /dev/null; then
        echo "→ Trying to install via yum..."
        if sudo yum install -y starship 2>/dev/null; then
            INSTALLED=true
            echo "✓ Starship installed via yum"
        fi
    fi
    
    # Method 2: Direct download from GitHub releases (fallback)
    if [ "$INSTALLED" = false ]; then
        echo "→ Package manager installation failed, trying direct download..."
        
        # Detect architecture
        ARCH="$(uname -m)"
        if [ "$ARCH" = "x86_64" ]; then
            ARCH="x86_64"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            ARCH="aarch64"
        else
            echo "⚠️  Unsupported architecture: $ARCH"
            ARCH="x86_64"  # Default fallback
        fi
        
        # Get latest version and download URL
        LATEST_VERSION=$(curl -s https://api.github.com/repos/starship/starship/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
        
        if [ -n "$LATEST_VERSION" ]; then
            DOWNLOAD_URL="https://github.com/starship/starship/releases/download/v${LATEST_VERSION}/starship-${ARCH}-unknown-linux-gnu.tar.gz"
            TEMP_DIR=$(mktemp -d)
            
            echo "→ Downloading Starship v${LATEST_VERSION} from GitHub..."
            if curl -sL "$DOWNLOAD_URL" -o "$TEMP_DIR/starship.tar.gz"; then
                echo "→ Extracting..."
                tar -xzf "$TEMP_DIR/starship.tar.gz" -C "$TEMP_DIR"
                
                # Install to ~/.local/bin (user directory, no sudo needed)
                mkdir -p ~/.local/bin
                if mv "$TEMP_DIR/starship" ~/.local/bin/starship; then
                    chmod +x ~/.local/bin/starship
                    # Add ~/.local/bin to PATH if not already there
                    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                        export PATH="$HOME/.local/bin:$PATH"
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null || true
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
                    fi
                    INSTALLED=true
                    echo "✓ Starship installed to ~/.local/bin/starship"
                fi
            fi
            
            rm -rf "$TEMP_DIR"
        fi
    fi
    
    # Method 3: Try official install script as last resort (might work in some cases)
    if [ "$INSTALLED" = false ]; then
        echo "→ Trying official install script as last resort..."
        if curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>&1; then
            INSTALLED=true
            echo "✓ Starship installed via official script"
        fi
    fi
    
    # Verify installation (check both PATH and common install locations)
    STARSHIP_CMD=""
    if command -v starship &> /dev/null; then
        STARSHIP_CMD="starship"
    elif [ -f ~/.local/bin/starship ]; then
        STARSHIP_CMD="$HOME/.local/bin/starship"
    elif [ -f /usr/local/bin/starship ]; then
        STARSHIP_CMD="/usr/local/bin/starship"
    elif [ -f /usr/bin/starship ]; then
        STARSHIP_CMD="/usr/bin/starship"
    fi
    
    if [ "$INSTALLED" = false ] || [ -z "$STARSHIP_CMD" ]; then
        echo "❌ Failed to install Starship"
        echo ""
        echo "Please install manually:"
        echo "  1. Visit: https://starship.rs/guide/#%F0%9F%9A%80-installation"
        echo "  2. Or use: cargo install starship (requires Rust)"
        exit 1
    fi
    
    echo "✓ Starship installed successfully: $($STARSHIP_CMD --version)"
fi

echo "Copying starship.toml..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ~/.config
cp "$SCRIPT_DIR/../../config/starship.toml" ~/.config/starship.toml

echo "Updating .zshrc with Zinit + Starship + custom config..."
# Copy the complete zsh-config which includes Zinit and Starship
if [ -f "$SCRIPT_DIR/../../config/zsh-config" ]; then
  cat "$SCRIPT_DIR/../../config/zsh-config" > ~/.zshrc
  echo "✓ zsh-config applied successfully"
else
  echo "⚠️  zsh-config not found, using fallback configuration"
  # Fallback if file doesn't exist
  cat >> ~/.zshrc << 'EOF'
# Load Starship prompt
eval "$(starship init zsh)"
EOF
fi

echo "=============================================="
echo "============== [04] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 05-install-node-nvm.sh"
