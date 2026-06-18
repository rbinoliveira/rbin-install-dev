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
    echo "To run only this step, use:"
    echo "  bash run.sh"
    echo "  (select script 11.4)"
    echo ""
    echo "Or from the project root:"
    echo "  INSTALL_ALL_RUNNING=1 bash $0"
    echo ""
    exit 1
fi

set -e

echo "=============================================="
echo "==== [11.4] CONFIGURE CLAUDE ACCOUNTS ========"
echo "=============================================="
echo ""
echo "Sets up isolated Claude Code configs via CLAUDE_CONFIG_DIR."
echo "Use claude1 / claude2 to run two accounts side by side."
echo ""

expand_path() {
    local p="$1"
    p="${p/#\~/$HOME}"
    echo "$p"
}

CLAUDE_DIR_1="$(expand_path "${CLAUDE_CONFIG_DIR_1:-$HOME/.claude}")"
CLAUDE_DIR_2="$(expand_path "${CLAUDE_CONFIG_DIR_2:-$HOME/.claude-work}")"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
mkdir -p "$CLAUDE_DIR_2"

if ! command -v claude &>/dev/null; then
    echo "⚠️  Claude Code CLI not found. Install it first (script 11-install-claude.sh)."
    echo "   Wrappers will still be created for when Claude is available."
fi

install_wrapper() {
    local name="$1"
    local config_dir="$2"
    local extra_args="$3"
    local target="$BIN_DIR/$name"

    if [ -z "$config_dir" ]; then
        # Account 1: same as plain `claude` (default ~/.claude, no override)
        cat > "$target" << EOF
#!/usr/bin/env bash
# $name: Claude Code — default account (same as \`claude\`)
exec claude $extra_args "\$@"
EOF
    else
        cat > "$target" << EOF
#!/usr/bin/env bash
# $name: Claude Code with isolated config at $config_dir
export CLAUDE_CONFIG_DIR="$config_dir"
exec claude $extra_args "\$@"
EOF
    fi
    chmod +x "$target"
    if [ -n "$config_dir" ]; then
        echo "✓ $name → $config_dir"
    else
        echo "✓ $name → default (~/.claude, same as claude)"
    fi
}

install_wrapper "claude1" "" ""
install_wrapper "claude2" "$CLAUDE_DIR_2" ""
install_wrapper "claude1-danger" "" "--dangerously-skip-permissions"
install_wrapper "claude2-danger" "$CLAUDE_DIR_2" "--dangerously-skip-permissions"

# Ensure ~/.local/bin is in PATH
add_to_path_if_missing() {
    local rc_file="$1"
    local path_line='export PATH="$HOME/.local/bin:$PATH"'

    if [ -f "$rc_file" ] && ! grep -qF '.local/bin' "$rc_file"; then
        echo "" >> "$rc_file"
        echo "# Added by rbin claude-accounts installer" >> "$rc_file"
        echo "$path_line" >> "$rc_file"
        echo "✓ Added ~/.local/bin to PATH in $rc_file"
    fi
}

add_to_path_if_missing "$HOME/.zshrc"
add_to_path_if_missing "$HOME/.bashrc"
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "=============================================="
echo "=========== [11.4] DONE ====================="
echo "=============================================="
echo ""
echo "Account 1 (default): ~/.claude (same as \`claude\` / \`claude1\`)"
echo "Account 2 (second):  $CLAUDE_DIR_2"
echo ""
echo "First-time setup for account 2:"
echo "  claude2 auth login"
echo ""
echo "Daily use (two terminals, no logout):"
echo "  claude  or  claude1    # your existing account (unchanged)"
echo "  claude2                # second account"
echo "  claude1-danger         # account 1, danger mode"
echo "  claude2-danger         # account 2, danger mode"
echo "  claudes                # open claude + claude2 in two tabs"
echo "  claudes-danger         # open both in danger mode"
echo ""
echo "Optional: set CLAUDE_CONFIG_DIR_2 in .env to customize the second path."
echo "Re-run script 11.4 after changing .env to refresh wrappers."
echo ""
