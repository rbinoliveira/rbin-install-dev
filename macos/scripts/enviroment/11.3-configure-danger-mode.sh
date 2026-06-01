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
echo "====== [11.3] CONFIGURE DANGER MODE ========="
echo "=============================================="
echo ""
echo "⚠️  DANGER MODE: All AI agent permissions are auto-approved."
echo "   Use these commands only in trusted environments."
echo ""

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# ────────────────────────────────────────────────────────────────
# claude-danger: Claude Code with --dangerously-skip-permissions
# ────────────────────────────────────────────────────────────────

CLAUDE_DANGER="$BIN_DIR/claude-danger"

cat > "$CLAUDE_DANGER" << 'EOF'
#!/usr/bin/env bash
# claude-danger: Claude Code CLI with all permission prompts bypassed.
# Equivalent to: claude --dangerously-skip-permissions
exec claude --dangerously-skip-permissions "$@"
EOF

chmod +x "$CLAUDE_DANGER"
echo "✓ claude-danger installed at $CLAUDE_DANGER"

# ────────────────────────────────────────────────────────────────
# codex-danger: OpenAI Codex with --dangerously-auto-approve-everything
# ────────────────────────────────────────────────────────────────

CODEX_DANGER="$BIN_DIR/codex-danger"

cat > "$CODEX_DANGER" << 'EOF'
#!/usr/bin/env bash
# codex-danger: OpenAI Codex CLI with all actions auto-approved.
# Equivalent to: codex --dangerously-auto-approve-everything
exec codex --dangerously-auto-approve-everything "$@"
EOF

chmod +x "$CODEX_DANGER"
echo "✓ codex-danger installed at $CODEX_DANGER"

# ────────────────────────────────────────────────────────────────
# Ensure ~/.local/bin is in PATH
# ────────────────────────────────────────────────────────────────

add_to_path_if_missing() {
    local rc_file="$1"
    local path_line='export PATH="$HOME/.local/bin:$PATH"'

    if [ -f "$rc_file" ] && ! grep -qF '.local/bin' "$rc_file"; then
        echo "" >> "$rc_file"
        echo "# Added by rbin danger-mode installer" >> "$rc_file"
        echo "$path_line" >> "$rc_file"
        echo "✓ Added ~/.local/bin to PATH in $rc_file"
    fi
}

add_to_path_if_missing "$HOME/.zshrc"
add_to_path_if_missing "$HOME/.bashrc"

# Also export for the current session
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "=============================================="
echo "=========== [11.3] DONE ====================="
echo "=============================================="
echo ""
echo "Usage after restarting terminal:"
echo "  claude-danger          → Claude with --dangerously-skip-permissions"
echo "  codex-danger           → Codex with --dangerously-auto-approve-everything"
echo ""
echo "  claude-danger .        → Run on current directory"
echo "  codex-danger 'task'    → Run Codex task auto-approved"
echo ""
