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
echo "========= [09] INSTALLING CURSOR ============"
echo "=============================================="

echo "Installing Cursor Editor..."

INSTALLED=false

# Check if already installed
if command -v cursor &> /dev/null; then
    echo "✓ Cursor is already installed: $(cursor --version 2>&1 | head -1)"
    INSTALLED=true
else
    # Method 1: Try snap (most reliable method)
    if command -v snap &> /dev/null; then
        echo "→ Trying to install via snap..."
        if sudo snap install cursor 2>&1; then
            # Verify installation succeeded
            if command -v cursor &> /dev/null || [ -f /snap/bin/cursor ]; then
                INSTALLED=true
                echo "✓ Cursor installed via snap"
                # Snap installs to /snap/bin, make sure it's in PATH
                if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
                    export PATH="/snap/bin:$PATH"
                fi
            fi
        fi
    fi
    
    # Method 2: Try direct download from downloader endpoint
    if [ "$INSTALLED" = false ]; then
        echo "→ Trying direct download from Cursor downloader..."
        
        # Install wget or curl if not available
        DOWNLOAD_CMD=""
        if command -v wget &> /dev/null; then
            DOWNLOAD_CMD="wget"
        elif command -v curl &> /dev/null; then
            DOWNLOAD_CMD="curl"
        else
            echo "→ Installing wget/curl..."
            sudo apt update -y
            sudo apt install -y wget curl 2>/dev/null || sudo apt install -y wget 2>/dev/null || sudo apt install -y curl 2>/dev/null
            if command -v wget &> /dev/null; then
                DOWNLOAD_CMD="wget"
            elif command -v curl &> /dev/null; then
                DOWNLOAD_CMD="curl"
            fi
        fi
        
        if [ -n "$DOWNLOAD_CMD" ]; then
            # Try different possible URLs
            DEB_URLS=(
                "https://downloader.cursor.sh/linux/deb/x64"
                "https://download.todesktop.com/230313mzl4w4u92/cursor_amd64.deb"
            )
            
            for DEB_URL in "${DEB_URLS[@]}"; do
                echo "→ Trying: $DEB_URL"
                
                if [ "$DOWNLOAD_CMD" = "wget" ]; then
                    if wget "$DEB_URL" -O cursor.deb 2>/dev/null; then
                        DOWNLOAD_SUCCESS=true
                    else
                        DOWNLOAD_SUCCESS=false
                    fi
                else
                    if curl -sL "$DEB_URL" -o cursor.deb 2>/dev/null; then
                        DOWNLOAD_SUCCESS=true
                    else
                        DOWNLOAD_SUCCESS=false
                    fi
                fi
                
                if [ "$DOWNLOAD_SUCCESS" = true ] && [ -f cursor.deb ]; then
                    # Verify it's actually a .deb file
                    if file cursor.deb 2>/dev/null | grep -q "Debian binary package"; then
                        echo "✓ Valid .deb file downloaded"
                        echo "→ Installing Cursor..."
                        if sudo dpkg -i cursor.deb 2>&1; then
                            INSTALLED=true
                            rm -f cursor.deb
                            break
                        else
                            echo "→ Fixing dependencies..."
                            sudo apt --fix-broken install -y 2>/dev/null
                            if sudo dpkg -i cursor.deb 2>&1; then
                                INSTALLED=true
                                rm -f cursor.deb
                                break
                            fi
                        fi
                    fi
                    rm -f cursor.deb
                fi
            done
        fi
    fi
    
    # If installation failed, provide helpful error message
    if [ "$INSTALLED" = false ]; then
        echo "⚠️  Automatic installation failed."
        echo ""
        echo "Please install Cursor manually using one of these methods:"
        echo ""
        echo "Method 1 (Recommended):"
        echo "  sudo snap install cursor"
        echo ""
        echo "Method 2:"
        echo "  1. Visit: https://cursor.sh"
        echo "  2. Click 'Download' and select Linux (.deb)"
        echo "  3. Install with: sudo dpkg -i ~/Downloads/cursor*.deb"
        echo ""
        echo "Method 3:"
        echo "  Visit: https://download.todesktop.com/230313mzl4w4u92/"
        echo ""
        exit 1
    fi
fi

if [ "$INSTALLED" = true ]; then
  echo "Verifying installation..."

  # Find the correct cursor executable
  CURSOR_CMD=""
  if command -v cursor &> /dev/null; then
    CURSOR_CMD="cursor"
  elif [ -f "/snap/bin/cursor" ]; then
    CURSOR_CMD="/snap/bin/cursor"
  elif [ -f "/usr/share/cursor/bin/cursor" ]; then
    CURSOR_CMD="/usr/share/cursor/bin/cursor"
  elif [ -f "/usr/share/cursor/cursor" ]; then
    CURSOR_CMD="/usr/share/cursor/cursor"
  elif [ -f "/opt/cursor/cursor" ]; then
    CURSOR_CMD="/opt/cursor/cursor"
  fi

  # Remove incorrect /usr/local/bin/cursor if it exists and is not executable
  if [ -f "/usr/local/bin/cursor" ] && ! /usr/local/bin/cursor --version &> /dev/null; then
    echo "Removing incorrect cursor symlink..."
    sudo rm -f /usr/local/bin/cursor
  fi

  # Create correct symlink if cursor is installed but not in PATH
  if [ -n "$CURSOR_CMD" ] && [ ! -f "/usr/local/bin/cursor" ]; then
    echo "Creating cursor symlink..."
    sudo ln -sf "$CURSOR_CMD" /usr/local/bin/cursor
  fi

  # Verify installation
  if [ -n "$CURSOR_CMD" ] && $CURSOR_CMD --version &> /dev/null; then
    echo "✓ Cursor installed successfully!"
    $CURSOR_CMD --version 2>/dev/null | head -1
  elif command -v cursor &> /dev/null && cursor --version &> /dev/null; then
    echo "✓ Cursor installed successfully!"
    cursor --version 2>/dev/null | head -1
  else
    echo "✓ Cursor installed (version check unavailable)"
  fi
else
  echo "❌ Cursor installation failed"
  exit 1
fi

echo "=============================================="
echo "============== [09] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 10-install-claude.sh"
