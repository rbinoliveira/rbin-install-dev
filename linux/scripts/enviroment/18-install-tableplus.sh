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

# Resolve the user's Downloads directory (handles localized names via XDG)
get_downloads_dir() {
    if command -v xdg-user-dir &> /dev/null; then
        xdg-user-dir DOWNLOAD
    else
        echo "$HOME/Downloads"
    fi
}

# Find the newest TablePlus AppImage or .deb in the Downloads directory
find_tableplus_download() {
    local downloads_dir="$1"
    ls -t "$downloads_dir"/[Tt]able[Pp]lus*.AppImage \
          "$downloads_dir"/[Tt]able[Pp]lus*.deb \
          "$downloads_dir"/tableplus*.AppImage \
          "$downloads_dir"/tableplus*.deb 2>/dev/null | head -1
}

# Install a found AppImage/.deb file
install_tableplus_file() {
    local file="$1"
    local tableplus_path="$HOME/.local/bin/tableplus"

    case "$file" in
        *.deb)
            echo "→ Installing .deb: $file"
            if ! sudo dpkg -i "$file"; then
                echo "→ Fixing dependencies..."
                sudo apt-get --fix-broken install -y
                sudo dpkg -i "$file"
            fi
            echo "✓ TablePlus installed successfully via .deb"
            return 0
            ;;
        *.AppImage)
            echo "→ Installing AppImage: $file"
            mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
            mv "$file" "$tableplus_path"
            chmod +x "$tableplus_path"

            # Create desktop entry
            cat > "$HOME/.local/share/applications/tableplus.desktop" <<EOF
[Desktop Entry]
Name=TablePlus
Comment=Modern database client
Exec=$tableplus_path
Icon=tableplus
Type=Application
Categories=Development;Database;
EOF

            echo "✓ TablePlus installed successfully"
            echo ""
            echo "📝 TablePlus is available at: $tableplus_path"
            echo "   You can run it with: tableplus"
            return 0
            ;;
    esac
    return 1
}

# Function to install TablePlus via AppImage (auto-detects file in Downloads)
install_tableplus_appimage() {
    local tableplus_path="$HOME/.local/bin/tableplus"
    local downloads_dir
    downloads_dir="$(get_downloads_dir)"

    echo "📥 Installing TablePlus via AppImage/.deb..."
    echo ""

    while true; do
        # Already placed manually at the final location?
        if [ -f "$tableplus_path" ]; then
            chmod +x "$tableplus_path"
            echo "✓ TablePlus found at $tableplus_path and made executable"
            return 0
        fi

        # Auto-detect a downloaded file in Downloads
        local found
        found="$(find_tableplus_download "$downloads_dir")"
        if [ -n "$found" ]; then
            echo "✓ Found downloaded file: $found"
            install_tableplus_file "$found"
            return $?
        fi

        echo "No TablePlus file found in $downloads_dir yet."
        echo ""
        echo "Please visit https://tableplus.com/download and download the"
        echo "Linux AppImage (or .deb) — save it to your Downloads folder."
        echo "I will detect and install it automatically."
        echo ""
        read -p "Press Enter after downloading (I'll check Downloads again), or type 'skip' to exit: " response

        if [ "$response" = "skip" ]; then
            echo "⚠️  Installation skipped"
            return 0
        fi
    done
}

echo "=============================================="
echo "========= [18] INSTALLING TABLEPLUS =========="
echo "=============================================="

echo "Installing TablePlus for Linux..."
echo ""

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    echo "Detected architecture: x86_64"
    echo ""

    # Try installing via snap first (easiest method)
    if command -v snap &> /dev/null; then
        echo "📥 Installing TablePlus via Snap..."
        echo ""
        # Remove if already installed, then reinstall
        if sudo snap list tableplus &> /dev/null; then
            echo "Reinstalling TablePlus..."
            sudo snap remove tableplus || true
        fi
        if sudo snap install tableplus; then
            echo "✓ TablePlus installed successfully via Snap"
            echo ""
            echo "📝 TablePlus is now available. Run it with: tableplus"
        else
            echo "⚠️  Snap installation failed, trying alternative method..."
            install_tableplus_appimage
        fi
    else
        echo "📥 Snap not available, installing TablePlus via AppImage..."
        echo ""
        install_tableplus_appimage
    fi
else
    echo "❌ Unsupported architecture: $ARCH"
    echo "   TablePlus Linux version is currently only available for x86_64"
    echo ""
    echo "You can try installing manually from:"
    echo "  https://tableplus.com/download"
    exit 1
fi

echo "=============================================="
echo "============== [18] DONE ===================="
echo "=============================================="
echo ""
echo "📝 TablePlus is a modern database management tool for:"
echo "   - MySQL, MariaDB, PostgreSQL, SQLite, Redis, and many more"
echo "   - Beautiful native interface"
echo "   - Cross-platform support"
echo ""
echo "🎉 All development tools installation complete!"
