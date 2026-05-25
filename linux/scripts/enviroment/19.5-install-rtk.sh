#!/usr/bin/env bash

# ────────────────────────────────────────────────────────────────
# Module Guard - Prevent Direct Execution
# ────────────────────────────────────────────────────────────────
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
echo "========= [19.5] INSTALLING RTK =============="
echo "=============================================="

ensure_rtk_in_path() {
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_rtk_binary() {
    if command -v brew &> /dev/null; then
        echo "Installing RTK via Homebrew..."
        if brew list rtk &> /dev/null; then
            echo "→ Reinstalling rtk..."
            brew reinstall rtk || brew upgrade rtk || true
        else
            echo "→ Installing rtk..."
            brew install rtk
        fi
        ensure_rtk_in_path
        command -v rtk &> /dev/null && return 0
    fi

    echo "Installing RTK via official install script..."
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    ensure_rtk_in_path
    command -v rtk &> /dev/null
}

configure_rtk_agents() {
    local init_flags=(--auto-patch)

    echo ""
    echo "Configuring RTK for Claude Code, Codex, and Cursor..."

    echo "→ Claude Code (default)..."
    rtk init -g "${init_flags[@]}" || echo "⚠️  rtk init for Claude Code had issues"

    echo "→ Codex (OpenAI)..."
    rtk init -g --codex "${init_flags[@]}" || echo "⚠️  rtk init for Codex had issues"

    echo "→ Cursor..."
    rtk init -g --agent cursor "${init_flags[@]}" || echo "⚠️  rtk init for Cursor had issues"

    echo ""
    echo "Verifying RTK agent configuration..."
    rtk init --show 2>/dev/null || true
}

if ! install_rtk_binary; then
    echo "❌ Failed to install RTK"
    exit 1
fi

echo "✓ RTK installed: $(rtk --version 2>/dev/null || rtk version 2>/dev/null || echo 'unknown')"

configure_rtk_agents

echo ""
echo "✓ RTK configured for Claude Code, Codex, and Cursor"
echo "  Restart Claude Code, Codex, and Cursor after installation."
echo "  Test: rtk gain"

echo "=============================================="
echo "============ [19.5] DONE ====================="
echo "=============================================="
echo "▶ Next, run: bash 19.6-install-graphify.sh"
