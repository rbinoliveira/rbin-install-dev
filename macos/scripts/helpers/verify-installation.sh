#!/usr/bin/env bash

# Script to verify installation after reinstall mode

echo "=============================================="
echo "Verifying Installation Status"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check_item() {
    local name="$1"
    local check_cmd="$2"
    
    if eval "$check_cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        return 1
    fi
}

# Check fonts
echo "📝 Fonts:"
echo "--------"
FONT_FOUND=false

# Check Homebrew font
if brew list --cask font-caskaydia-cove-nerd-font &>/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} CaskaydiaCove Nerd Font (via Homebrew)"
    FONT_FOUND=true
fi

# Check font files
if ls ~/Library/Fonts/CaskaydiaCove*.ttf 2>/dev/null | head -1 > /dev/null; then
    echo -e "${GREEN}✓${NC} CaskaydiaCove font files found"
    FONT_FOUND=true
elif ls ~/Library/Fonts/CascadiaCode*.ttf 2>/dev/null | head -1 > /dev/null; then
    echo -e "${GREEN}✓${NC} CascadiaCode font files found"
    FONT_FOUND=true
fi

if [ "$FONT_FOUND" = false ]; then
    echo -e "${RED}✗${NC} CaskaydiaCove Nerd Font not found"
    echo "   Run: bash macos/scripts/helpers/fix-font-installation.sh"
fi

echo ""

# Check iTerm2
echo "🖥️  iTerm2:"
echo "--------"
check_item "iTerm2 installed" "[ -d '/Applications/iTerm.app' ]"
check_item "iTerm2 theme downloaded" "[ -f '$HOME/.iterm2-themes/catppuccin-mocha.itermcolors' ]"

echo ""

# Check development tools
echo "🛠️  Development Tools:"
echo "--------"
check_item "Homebrew" "command -v brew"
check_item "Zsh" "command -v zsh"
check_item "Node.js" "command -v node"
check_item "Yarn" "command -v yarn"
check_item "Docker" "command -v docker"
check_item "Git" "command -v git"

echo ""

# Check editors
echo "📝 Editors:"
echo "--------"
check_item "Zed" "[ -d '/Applications/Zed.app' ]"

echo ""

# Check CLI tools
echo "🔧 CLI Tools:"
echo "--------"
check_item "Claude CLI" "command -v claude"
check_item "Starship" "command -v starship"
check_item "Zoxide" "command -v zoxide"
check_item "FZF" "command -v fzf"
check_item "LazyGit" "command -v lazygit"

echo ""
echo "=============================================="
echo "📋 Next Steps:"
echo "=============================================="
echo ""

if [ "$FONT_FOUND" = false ]; then
    echo -e "${YELLOW}⚠️  Font not installed. Run:${NC}"
    echo "   bash macos/scripts/helpers/fix-font-installation.sh"
    echo ""
fi

echo "1. Configure iTerm2 font:"
echo "   • Open iTerm2 → Preferences (⌘,)"
echo "   • Profiles → Text → Change Font"
echo "   • Search for 'CaskaydiaCove Nerd Font'"
echo "   • Set size to 16"
echo ""
echo "2. Configure iTerm2 working directory:"
echo "   • Profiles → General → Working Directory"
echo "   • Select 'Reuse previous session's directory'"
echo ""
echo "3. Restart iTerm2 to apply all changes"
echo ""
