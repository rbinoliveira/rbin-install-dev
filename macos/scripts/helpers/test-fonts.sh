#!/usr/bin/env bash

# Script to test if fonts are installed

echo "=============================================="
echo "Testing Font Installation"
echo "=============================================="
echo ""

FONT_DIR="$HOME/Library/Fonts"

# Test CaskaydiaCove Nerd Font
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  CaskaydiaCove Nerd Font"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CASKAYDIA_FOUND=false
CASKAYDIA_COUNT=0

# Check files
if ls "$FONT_DIR/CaskaydiaCove"*.ttf 2>/dev/null | head -1 > /dev/null; then
    CASKAYDIA_COUNT=$(ls "$FONT_DIR/CaskaydiaCove"*.ttf 2>/dev/null | wc -l | tr -d ' ')
    CASKAYDIA_FOUND=true
    echo "✓ Found $CASKAYDIA_COUNT CaskaydiaCove font file(s)"
    echo "  Location: $FONT_DIR"
    ls "$FONT_DIR/CaskaydiaCove"*.ttf 2>/dev/null | head -3 | sed 's/^/    - /'
elif ls "$FONT_DIR/CascadiaCode"*.ttf 2>/dev/null | head -1 > /dev/null; then
    CASKAYDIA_COUNT=$(ls "$FONT_DIR/CascadiaCode"*.ttf 2>/dev/null | wc -l | tr -d ' ')
    CASKAYDIA_FOUND=true
    echo "✓ Found $CASKAYDIA_COUNT CascadiaCode font file(s)"
    echo "  Location: $FONT_DIR"
    ls "$FONT_DIR/CascadiaCode"*.ttf 2>/dev/null | head -3 | sed 's/^/    - /'
else
    echo "✗ CaskaydiaCove font files not found"
fi

# Check Homebrew
if brew list --cask font-caskaydia-cove-nerd-font &> /dev/null 2>&1; then
    echo "✓ Installed via Homebrew Cask"
else
    echo "✗ Not installed via Homebrew Cask"
fi

echo ""

# Test JetBrains Mono Nerd Font
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  JetBrains Mono Nerd Font"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

JETBRAINS_FOUND=false
JETBRAINS_COUNT=0

# Check files
if ls "$FONT_DIR/JetBrainsMono"*.ttf 2>/dev/null | head -1 > /dev/null; then
    JETBRAINS_COUNT=$(ls "$FONT_DIR/JetBrainsMono"*.ttf 2>/dev/null | wc -l | tr -d ' ')
    JETBRAINS_FOUND=true
    echo "✓ Found $JETBRAINS_COUNT JetBrainsMono font file(s)"
    echo "  Location: $FONT_DIR"
    ls "$FONT_DIR/JetBrainsMono"*.ttf 2>/dev/null | head -3 | sed 's/^/    - /'
else
    echo "✗ JetBrainsMono font files not found"
fi

# Check Homebrew
if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null 2>&1; then
    echo "✓ Installed via Homebrew Cask"
else
    echo "✗ Not installed via Homebrew Cask"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$CASKAYDIA_FOUND" = true ]; then
    echo "✅ CaskaydiaCove Nerd Font: INSTALLED ($CASKAYDIA_COUNT files)"
else
    echo "❌ CaskaydiaCove Nerd Font: NOT FOUND"
fi

if [ "$JETBRAINS_FOUND" = true ]; then
    echo "✅ JetBrains Mono Nerd Font: INSTALLED ($JETBRAINS_COUNT files)"
else
    echo "❌ JetBrains Mono Nerd Font: NOT FOUND"
fi

echo ""

# Test in system
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 System Font Check (macOS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v system_profiler &> /dev/null; then
    echo "Checking system font list..."
    if system_profiler SPFontsDataType 2>/dev/null | grep -qi "CaskaydiaCove\|CascadiaCode"; then
        echo "✓ CaskaydiaCove/CascadiaCode found in system fonts"
    else
        echo "⚠️  CaskaydiaCove/CascadiaCode not found in system font list"
        echo "   (This is normal if fonts were just installed - restart may be needed)"
    fi
    
    if system_profiler SPFontsDataType 2>/dev/null | grep -qi "JetBrainsMono\|JetBrains Mono"; then
        echo "✓ JetBrains Mono found in system fonts"
    else
        echo "⚠️  JetBrains Mono not found in system font list"
        echo "   (This is normal if fonts were just installed - restart may be needed)"
    fi
else
    echo "⚠️  system_profiler not available"
fi

echo ""
echo "=============================================="
echo "💡 Tips:"
echo "=============================================="
echo ""
echo "To test fonts in applications:"
echo ""
echo "1. iTerm2:"
echo "   • Restart iTerm2 (⌘Q)"
echo "   • Preferences → Profiles → Text → Change Font"
echo "   • Search for 'JetBrainsMono' or 'CaskaydiaCove'"
echo ""
echo "2. If fonts don't appear:"
echo "   • Wait a few seconds (macOS needs to index fonts)"
echo "   • Restart the application"
echo "   • Run: bash macos/scripts/helpers/fix-font-installation.sh"
echo ""
