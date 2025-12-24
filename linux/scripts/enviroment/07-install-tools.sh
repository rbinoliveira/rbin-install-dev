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
echo "========= [07] INSTALLING TOOLS ============"
echo "=============================================="

echo "Installing productivity tools..."

# Update package list
sudo apt update -y

# Install tools available in apt repositories
sudo apt install -y \
  zoxide \
  fzf \
  fd-find \
  bat \
  lsd

# Install lazygit (not available in default repos, use alternative methods)
echo ""
echo "Installing lazygit (git TUI)..."
if command -v lazygit &> /dev/null; then
    echo "✓ lazygit is already installed: $(lazygit --version 2>&1 | head -1)"
else
    LAZYGIT_INSTALLED=false
    
    # Method 1: Try snap (easiest but may have permission issues)
    if command -v snap &> /dev/null; then
        echo "→ Trying to install via snap..."
        if sudo snap install lazygit 2>/dev/null; then
            LAZYGIT_INSTALLED=true
            echo "✓ lazygit installed via snap"
            # Snap installs to /snap/bin, make sure it's in PATH
            if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
                export PATH="/snap/bin:$PATH"
            fi
        fi
    fi
    
    # Method 2: Direct download from GitHub releases
    if [ "$LAZYGIT_INSTALLED" = false ]; then
        echo "→ Trying direct download from GitHub..."
        
        # Detect architecture
        ARCH="$(uname -m)"
        if [ "$ARCH" = "x86_64" ]; then
            ARCH="x86_64"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            ARCH="arm64"
        else
            echo "⚠️  Unsupported architecture: $ARCH, defaulting to x86_64"
            ARCH="x86_64"
        fi
        
        # Get latest version
        LATEST_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
        
        if [ -n "$LATEST_VERSION" ]; then
            DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LATEST_VERSION}/lazygit_${LATEST_VERSION}_Linux_${ARCH}.tar.gz"
            TEMP_DIR=$(mktemp -d)
            
            echo "→ Downloading lazygit v${LATEST_VERSION} from GitHub..."
            if curl -sL "$DOWNLOAD_URL" -o "$TEMP_DIR/lazygit.tar.gz"; then
                echo "→ Extracting..."
                if tar -xzf "$TEMP_DIR/lazygit.tar.gz" -C "$TEMP_DIR" lazygit 2>/dev/null; then
                    # Install to ~/.local/bin (user directory, no sudo needed)
                    mkdir -p ~/.local/bin
                    if mv "$TEMP_DIR/lazygit" ~/.local/bin/lazygit 2>/dev/null; then
                        chmod +x ~/.local/bin/lazygit
                        # Add ~/.local/bin to PATH if not already there
                        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                            export PATH="$HOME/.local/bin:$PATH"
                            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null || true
                            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
                        fi
                        LAZYGIT_INSTALLED=true
                        echo "✓ lazygit installed to ~/.local/bin/lazygit"
                    fi
                fi
            fi
            rm -rf "$TEMP_DIR"
        fi
    fi
    
    # Method 3: Try go install if Go is available
    if [ "$LAZYGIT_INSTALLED" = false ] && command -v go &> /dev/null; then
        echo "→ Trying go install..."
        if go install github.com/jesseduffield/lazygit@latest 2>/dev/null; then
            # Ensure Go bin directory is in PATH
            GO_BIN="$(go env GOPATH)/bin"
            if [[ ":$PATH:" != *":$GO_BIN:"* ]]; then
                export PATH="$GO_BIN:$PATH"
                echo "export PATH=\"\$PATH:$GO_BIN\"" >> ~/.bashrc 2>/dev/null || true
                echo "export PATH=\"\$PATH:$GO_BIN\"" >> ~/.zshrc 2>/dev/null || true
            fi
            LAZYGIT_INSTALLED=true
            echo "✓ lazygit installed via go install"
        fi
    fi
    
    # Verify installation
    if [ "$LAZYGIT_INSTALLED" = false ]; then
        # Check if it's now available in PATH
        if ! command -v lazygit &> /dev/null; then
            echo "⚠️  Failed to install lazygit automatically"
            echo "   You can install it manually later with:"
            echo "   - sudo snap install lazygit"
            echo "   - Or download from: https://github.com/jesseduffield/lazygit/releases"
        else
            LAZYGIT_INSTALLED=true
            echo "✓ lazygit is now available"
        fi
    fi
fi

# Create symlinks for fd (apt installs as fdfind)
if [ ! -L /usr/local/bin/fd ] && [ -f /usr/bin/fdfind ]; then
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
fi

# Install FZF keybindings
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  echo "✓ FZF keybindings available"
else
  echo "⚠️  FZF keybindings not found, they may be in a different location"
fi

echo ""
echo "Installed tools:"
echo "  ✓ zoxide - smart cd"
echo "  ✓ fzf - fuzzy finder"
echo "  ✓ fd - fast find"
echo "  ✓ bat - better cat"
echo "  ✓ lsd - better ls"
echo "  ✓ lazygit - git TUI"

echo "=============================================="
echo "============== [07] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 08-install-font-jetbrains.sh"

