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


# Don't exit on error - we want to continue even if some tools fail to install
set +e

echo "=============================================="
echo "========= [07] INSTALLING TOOLS ============"
echo "=============================================="

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is required. Please install it first."
  exit 1
fi

# Check and fix Homebrew permissions
echo "Checking Homebrew permissions..."
HOMEBREW_PREFIX=$(brew --prefix)
if [ ! -w "$HOMEBREW_PREFIX" ]; then
  echo "⚠️  Homebrew directory is not writable. Fixing permissions..."
  echo ""
  echo "This requires sudo access. You'll be prompted for your password."
  echo ""
  
  # Fix ownership of Homebrew directory
  echo "Fixing ownership of Homebrew directories..."
  sudo chown -R "$(whoami)" "$HOMEBREW_PREFIX" 2>/dev/null || true
  
  # Fix write permissions on specific directories
  echo "Fixing write permissions..."
  for dir in \
    "$HOMEBREW_PREFIX" \
    "$HOMEBREW_PREFIX/etc/bash_completion.d" \
    "$HOMEBREW_PREFIX/lib/pkgconfig" \
    "$HOMEBREW_PREFIX/share/aclocal" \
    "$HOMEBREW_PREFIX/share/doc" \
    "$HOMEBREW_PREFIX/share/info" \
    "$HOMEBREW_PREFIX/share/locale" \
    "$HOMEBREW_PREFIX/share/man" \
    "$HOMEBREW_PREFIX/share/man/man1" \
    "$HOMEBREW_PREFIX/share/man/man3" \
    "$HOMEBREW_PREFIX/share/man/man5" \
    "$HOMEBREW_PREFIX/share/man/man7" \
    "$HOMEBREW_PREFIX/share/pwsh" \
    "$HOMEBREW_PREFIX/share/pwsh/completions" \
    "$HOMEBREW_PREFIX/share/zsh" \
    "$HOMEBREW_PREFIX/share/zsh/site-functions" \
    "$HOMEBREW_PREFIX/var/homebrew/locks"; do
    if [ -d "$dir" ]; then
      chmod u+w "$dir" 2>/dev/null || true
    fi
  done
  
  echo "✓ Homebrew permissions fixed"
  echo ""
fi

echo "Installing productivity tools..."

# Install tools via Homebrew
# Use --force-bottle to avoid building from source if possible
# Continue even if a package is already installed
echo "Installing zoxide..."
brew install zoxide || echo "⚠️  zoxide installation had issues (may already be installed)"

echo "Installing fzf..."
brew install fzf || echo "⚠️  fzf installation had issues (may already be installed)"

echo "Installing fd..."
brew install fd || echo "⚠️  fd installation had issues (may already be installed)"

echo "Installing bat..."
brew install bat || echo "⚠️  bat installation had issues (may already be installed)"

echo "Installing lsd..."
brew install lsd || echo "⚠️  lsd installation had issues (may already be installed)"

echo "Installing lazygit..."
brew install lazygit || echo "⚠️  lazygit installation had issues (may already be installed)"

# Install FZF keybindings
echo ""
echo "Installing FZF keybindings..."
$(brew --prefix)/opt/fzf/install --all

# Verify installations
echo ""
echo "Verifying installations..."
INSTALLED_COUNT=0
if command -v zoxide &> /dev/null; then
  echo "  ✓ zoxide - smart cd"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi
if command -v fzf &> /dev/null; then
  echo "  ✓ fzf - fuzzy finder"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi
if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
  echo "  ✓ fd - fast find"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi
if command -v bat &> /dev/null; then
  echo "  ✓ bat - better cat"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi
if command -v lsd &> /dev/null; then
  echo "  ✓ lsd - better ls"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi
if command -v lazygit &> /dev/null; then
  echo "  ✓ lazygit - git TUI"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
fi

if [ $INSTALLED_COUNT -eq 0 ]; then
  echo "⚠️  Warning: No tools were successfully installed."
  echo "   This may be due to permission issues. Please check the errors above."
  echo "   You may need to run: sudo chown -R $(whoami) $(brew --prefix)"
else
  echo ""
  echo "✓ Successfully verified $INSTALLED_COUNT out of 6 tools"
fi

echo "=============================================="
echo "============== [07] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 08-install-cursor.sh"

