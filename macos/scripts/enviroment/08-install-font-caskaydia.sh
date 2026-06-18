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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

if [ -f "$PROJECT_ROOT/lib/sudo_helper.sh" ]; then
    # shellcheck source=lib/sudo_helper.sh
    source "$PROJECT_ROOT/lib/sudo_helper.sh"
fi

echo "=============================================="
echo "========= [08] INSTALLING NERD FONTS ========="
echo "=============================================="

# Install required packages via Homebrew
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

# Optional system-wide copy (off by default — ~/Library/Fonts is enough for dev tools)
copy_fonts_to_system_if_requested() {
    local label="$1"
    shift
    local copied=false

    if [ "${FONT_INSTALL_GLOBAL:-false}" != "true" ]; then
        echo ""
        echo "✓ $label disponível em ~/Library/Fonts"
        echo "  (cópia para /Library/Fonts/ omitida — suficiente para iTerm2, Cursor, etc.)"
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌍 Copiando $label para /Library/Fonts/ (FONT_INSTALL_GLOBAL=true)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for pattern in "$@"; do
        # shellcheck disable=SC2086
        if ! ls $FONT_DIR/$pattern 2>/dev/null | head -1 | grep -q .; then
            continue
        fi
        if type sudo_run &>/dev/null; then
            # shellcheck disable=SC2086
            if sudo_run cp $FONT_DIR/$pattern /Library/Fonts/; then
                copied=true
                break
            fi
        # shellcheck disable=SC2086
        elif sudo -n cp $FONT_DIR/$pattern /Library/Fonts/ 2>/dev/null; then
            copied=true
            break
        fi
    done

    if [ "$copied" = true ]; then
        echo "✅ $label disponível em ~/Library/Fonts e /Library/Fonts/"
    else
        echo "⚠️  Não foi possível copiar para /Library/Fonts/"
        echo "   A fonte já está em ~/Library/Fonts — suficiente para uso normal."
    fi
}

# Function to install a font via Homebrew
install_font_via_brew() {
    local font_cask="$1"
    local font_name="$2"
    
    echo ""
    echo "Installing $font_name..."
    if brew list --cask "$font_cask" &> /dev/null 2>&1; then
        echo "✓ $font_name is already installed via Homebrew"
        return 0
    else
        if brew install --cask "$font_cask" 2>&1; then
            if brew list --cask "$font_cask" &> /dev/null 2>&1; then
                echo "✓ $font_name installed successfully via Homebrew"
                return 0
            fi
        fi
        echo "⚠️  Failed to install $font_name via Homebrew"
        return 1
    fi
}

# Function to verify font installation
verify_font_installation() {
    local font_pattern="$1"
    local font_name="$2"
    local found=false
    local count=0
    
    for check_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
        if ls "$check_dir/$font_pattern"*.ttf 2>/dev/null | head -1 > /dev/null; then
            count=$(ls "$check_dir/$font_pattern"*.ttf 2>/dev/null | wc -l | tr -d ' ')
            found=true
            echo "✓ Found $count $font_name file(s) in $check_dir"
            break
        fi
    done
    
    if [ "$found" = false ] && brew list --cask "$font_cask" &> /dev/null 2>&1; then
        found=true
        echo "✓ $font_name installed via Homebrew Cask"
    fi
    
    echo "$found"
}

# Install CaskaydiaCove Nerd Font (primary)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Font 1/2: CaskaydiaCove Nerd Font (Primary)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BREW_INSTALLED=false

# Step 1: Remove broken registry (if exists)
if brew list --cask font-caskaydia-cove-nerd-font &> /dev/null 2>&1; then
    echo "Removing existing installation (may be broken)..."
    brew uninstall --cask font-caskaydia-cove-nerd-font 2>&1 || \
    brew uninstall --cask --force font-caskaydia-cove-nerd-font 2>&1 || true
    echo "✓ Removed existing installation"
fi

# Step 2: Clean install
echo "Installing CaskaydiaCove Nerd Font via Homebrew..."
if brew install --cask font-caskaydia-cove-nerd-font 2>&1; then
    # Step 3: Verify installation
    echo "Verifying installation..."
    if brew list --cask font-caskaydia-cove-nerd-font &> /dev/null 2>&1; then
        # Check if fonts actually exist
        if ls "$FONT_DIR/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null || \
           ls "$FONT_DIR/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
            echo "✓ Font installed successfully via Homebrew"
            BREW_INSTALLED=true
            copy_fonts_to_system_if_requested "CaskaydiaCove Nerd Font" "CaskaydiaCove*.ttf" "CascadiaCode*.ttf"
        else
            echo "⚠️  Homebrew reported success but font files not found"
            BREW_INSTALLED=false
        fi
    else
        echo "⚠️  Installation failed"
        BREW_INSTALLED=false
    fi
else
    echo "⚠️  Homebrew installation failed, trying manual download..."
    BREW_INSTALLED=false
fi

# If Homebrew installation didn't work, try manual download
if [ "$BREW_INSTALLED" = false ]; then
    # Method 2: Manual download as fallback
    if ! command -v wget &> /dev/null; then
        echo "Installing wget..."
        brew install wget || echo "⚠️  Failed to install wget"
    fi
    
    # Check if font files already exist in common locations
    FONT_EXISTS=false
    for check_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
        if ls "$check_dir/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null || \
           ls "$check_dir/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
            echo "✓ CaskaydiaCove Nerd Font files found in $check_dir"
            FONT_EXISTS=true
            break
        fi
    done
    
    if [ "$FONT_EXISTS" = false ]; then
        echo "Downloading CaskaydiaCove Nerd Font from GitHub..."
        cd /tmp
        if wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip 2>&1; then
            echo "Extracting font..."
            unzip -q -o CascadiaCode.zip -d "$FONT_DIR" 2>/dev/null || unzip -o CascadiaCode.zip -d "$FONT_DIR"
            rm -f CascadiaCode.zip
            
            # Verify installation
            if ls "$FONT_DIR/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null || \
               ls "$FONT_DIR/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
                echo "✓ Font installed successfully"
                FONT_EXISTS=true
                copy_fonts_to_system_if_requested "CaskaydiaCove Nerd Font" "CaskaydiaCove*.ttf" "CascadiaCode*.ttf"
            else
                echo "⚠️  Font files extracted but not found. Checking extracted files..."
                find "$FONT_DIR" -name "*Cascadia*" -o -name "*Caskaydia*" 2>/dev/null | head -5
            fi
        else
            echo "❌ Failed to download font"
            echo "   You may need to install manually:"
            echo "   brew install --cask font-caskaydia-cove-nerd-font"
        fi
    fi
fi

# Install JetBrains Mono Nerd Font (alternative/similar font)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Font 2/2: JetBrains Mono Nerd Font (Alternative)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Remove broken registry (if exists)
if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null 2>&1; then
    echo "Removing existing installation (may be broken)..."
    brew uninstall --cask font-jetbrains-mono-nerd-font 2>&1 || \
    brew uninstall --cask --force font-jetbrains-mono-nerd-font 2>&1 || true
    echo "✓ Removed existing installation"
fi

# Step 2: Clean install
echo "Installing JetBrains Mono Nerd Font via Homebrew..."
if brew install --cask font-jetbrains-mono-nerd-font 2>&1; then
    # Step 3: Verify installation
    if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null 2>&1; then
        # Check if fonts actually exist
        if ls "$FONT_DIR/JetBrainsMono"*.ttf 2>/dev/null | head -1 > /dev/null; then
            echo "✓ JetBrains Mono installed successfully via Homebrew"
            copy_fonts_to_system_if_requested "JetBrains Mono Nerd Font" "JetBrainsMono*.ttf"
        else
            echo "⚠️  Homebrew reported success but font files not found"
        fi
    fi
else
    echo "⚠️  Failed to install JetBrains Mono Nerd Font"
fi

# Update font cache on macOS
echo ""
echo "Updating macOS font cache..."
if command -v atsutil &> /dev/null; then
    # Force font cache update
    atsutil databases -removeUser 2>/dev/null || true
    echo "✓ Font cache update initiated"
else
    echo "⚠️  atsutil not found, font cache will update automatically"
fi

# Verify font installations
echo ""
echo "=============================================="
echo "Verifying font installations..."
echo "=============================================="

# Verify CaskaydiaCove Nerd Font
CASKAYDIA_FOUND=false
CASKAYDIA_LOCATION=""
CASKAYDIA_COUNT=0

# Check both user and global locations
for check_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    if ls "$check_dir/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null; then
        CASKAYDIA_COUNT=$(ls "$check_dir/CaskaydiaCove"*.ttf 2>/dev/null | wc -l | tr -d ' ')
        CASKAYDIA_FOUND=true
        CASKAYDIA_LOCATION="$check_dir"
        echo "✓ CaskaydiaCove: Found $CASKAYDIA_COUNT file(s) in $check_dir"
        break
    elif ls "$check_dir/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
        CASKAYDIA_COUNT=$(ls "$check_dir/CascadiaCode"*.ttf 2>/dev/null | wc -l | tr -d ' ')
        CASKAYDIA_FOUND=true
        CASKAYDIA_LOCATION="$check_dir"
        echo "✓ CaskaydiaCove: Found $CASKAYDIA_COUNT CascadiaCode file(s) in $check_dir"
        break
    fi
done

# Verify Homebrew registry
if brew list --cask font-caskaydia-cove-nerd-font &> /dev/null 2>&1; then
    echo "✓ CaskaydiaCove: Registered in Homebrew"
    # Check if no "Missing Font" errors
    if brew list --cask font-caskaydia-cove-nerd-font 2>&1 | grep -qi "Missing Font"; then
        echo "⚠️  WARNING: Homebrew reports 'Missing Font' errors"
        echo "   This indicates a broken installation"
    fi
else
    echo "✗ CaskaydiaCove: Not registered in Homebrew"
fi

# Verify JetBrains Mono Nerd Font
JETBRAINS_FOUND=false
JETBRAINS_LOCATION=""
JETBRAINS_COUNT=0

# Check both user and global locations
for check_dir in "$HOME/Library/Fonts" "/Library/Fonts"; do
    if ls "$check_dir/JetBrainsMono"*.ttf 2>/dev/null | head -1 > /dev/null; then
        JETBRAINS_COUNT=$(ls "$check_dir/JetBrainsMono"*.ttf 2>/dev/null | wc -l | tr -d ' ')
        JETBRAINS_FOUND=true
        JETBRAINS_LOCATION="$check_dir"
        echo "✓ JetBrains Mono: Found $JETBRAINS_COUNT file(s) in $check_dir"
        break
    fi
done

# Verify Homebrew registry
if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null 2>&1; then
    echo "✓ JetBrains Mono: Registered in Homebrew"
    # Check if no "Missing Font" errors
    if brew list --cask font-jetbrains-mono-nerd-font 2>&1 | grep -qi "Missing Font"; then
        echo "⚠️  WARNING: Homebrew reports 'Missing Font' errors"
        echo "   This indicates a broken installation"
    fi
else
    echo "✗ JetBrains Mono: Not registered in Homebrew"
fi

# Determine overall status
FONT_FOUND=false
if [ "$CASKAYDIA_FOUND" = true ] || [ "$JETBRAINS_FOUND" = true ]; then
    FONT_FOUND=true
fi

if [ "$CASKAYDIA_FOUND" = false ] && [ "$JETBRAINS_FOUND" = false ]; then
    echo ""
    echo "⚠️  Neither font was found in expected locations"
fi

echo ""
if [ "$FONT_FOUND" = true ]; then
    echo "✅ Font installation verified successfully!"
    echo ""
    echo "📊 Installation Summary:"
    if [ "$CASKAYDIA_FOUND" = true ]; then
        echo "   • CaskaydiaCove Nerd Font: ✓ Installed"
        echo "     Location: $CASKAYDIA_LOCATION"
        if [ "$CASKAYDIA_COUNT" -gt 0 ]; then
            echo "     Files: $CASKAYDIA_COUNT"
        fi
    else
        echo "   • CaskaydiaCove Nerd Font: ✗ Not found"
    fi
    
    if [ "$JETBRAINS_FOUND" = true ]; then
        echo "   • JetBrains Mono Nerd Font: ✓ Installed"
        echo "     Location: $JETBRAINS_LOCATION"
        if [ "$JETBRAINS_COUNT" -gt 0 ]; then
            echo "     Files: $JETBRAINS_COUNT"
        fi
    else
        echo "   • JetBrains Mono Nerd Font: ✗ Not found"
    fi
    echo ""
    echo "📝 IMPORTANT: To use the fonts in applications:"
    echo ""
    echo "   🖥️  iTerm2:"
    echo "   1. Restart iTerm2 completely (⌘Q, then reopen)"
    echo "   2. Go to Preferences (⌘,) → Profiles → Text"
    echo "   3. Click 'Change Font'"
    echo "   4. Search for one of these names:"
    if [ "$CASKAYDIA_FOUND" = true ]; then
        echo "      - 'CaskaydiaCove Nerd Font' (preferred)"
        echo "      - 'Cascadia Code'"
        echo "      - 'CaskaydiaCove NF'"
    fi
    if [ "$JETBRAINS_FOUND" = true ]; then
        echo "      - 'JetBrainsMono Nerd Font' (alternative)"
        echo "      - 'JetBrains Mono'"
    fi
    echo "   5. Set size to 16"
    echo ""
    echo "   ⚠️  If font doesn't appear, try the alternative font or wait a few seconds and restart"
else
    echo "❌ Font installation verification FAILED"
    echo ""
    echo "Font not found in any expected location:"
    echo "   • $HOME/Library/Fonts"
    echo "   • /Library/Fonts"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo ""
    echo "1. Try reinstalling via Homebrew:"
    echo "   brew uninstall --cask font-caskaydia-cove-nerd-font"
    echo "   brew install --cask font-caskaydia-cove-nerd-font"
    echo ""
    echo "2. Or download manually from:"
    echo "   https://www.nerdfonts.com/font-downloads"
    echo "   Extract to: $HOME/Library/Fonts"
    echo ""
    echo "3. After installation, run this script again to verify"
    echo ""
    echo "4. If still not working, run the fix script:"
    echo "   bash macos/scripts/helpers/fix-font-installation.sh"
    echo ""
    exit 1
fi

echo "=============================================="
echo "============== [08] DONE ===================="
echo "=============================================="

# Final verification summary
echo ""
if [ "$FONT_FOUND" = true ]; then
    echo "✅ Installation Status: SUCCESS"
    echo "   Font is properly installed and ready to use"
else
    echo "❌ Installation Status: FAILED"
    echo "   Font installation could not be verified"
    echo ""
    echo "   Run the fix script to troubleshoot:"
    echo "   bash macos/scripts/helpers/fix-font-installation.sh"
fi
echo ""
echo "▶ Next, run: bash 10-install-cursor.sh"
