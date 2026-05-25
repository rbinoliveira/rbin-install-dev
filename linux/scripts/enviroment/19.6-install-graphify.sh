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
echo "======= [19.6] INSTALLING GRAPHIFY =========="
echo "=============================================="

ensure_local_bin_in_path() {
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

python3_ok() {
    local py candidates=()

    for py in python3.12 python3.11 python3.10 python3; do
        if command -v "$py" &> /dev/null; then
            candidates+=("$(command -v "$py")")
        fi
    done

    for py in "${candidates[@]}"; do
        if "$py" -c 'import sys; exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
            export GRAPHIFY_PYTHON="$py"
            return 0
        fi
    done

    return 1
}

ensure_python() {
    if python3_ok; then
        echo "✓ Python $($GRAPHIFY_PYTHON --version 2>&1 | awk '{print $2}') ($GRAPHIFY_PYTHON)"
        return 0
    fi

    echo "Installing Python 3 via apt..."
    sudo apt update -y 2>/dev/null || true
    for pkg in python3 python3-pip python3-venv python3.12 python3.11; do
        sudo apt install -y "$pkg" 2>/dev/null || true
    done
    python3_ok
}

install_uv() {
    if command -v uv &> /dev/null; then
        echo "✓ uv already installed: $(uv --version 2>&1 | head -1)"
        return 0
    fi

    echo "Installing uv..."
    if command -v brew &> /dev/null; then
        brew install uv
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    ensure_local_bin_in_path
    command -v uv &> /dev/null
}

install_graphify_package() {
    ensure_local_bin_in_path

    if command -v graphify &> /dev/null; then
        echo "→ Upgrading graphifyy via uv..."
        uv tool upgrade graphifyy 2>/dev/null || uv tool install graphifyy --force
    else
        echo "→ Installing graphifyy via uv..."
        uv tool install graphifyy
    fi

    ensure_local_bin_in_path
    if ! command -v graphify &> /dev/null; then
        echo "→ Fallback: pipx install graphifyy..."
        if command -v pipx &> /dev/null; then
            pipx install graphifyy 2>/dev/null || pipx upgrade graphifyy 2>/dev/null || true
        fi
        ensure_local_bin_in_path
    fi

    command -v graphify &> /dev/null
}

configure_graphify_agents() {
    echo ""
    echo "Registering Graphify with Claude Code, Codex, and Cursor..."

    echo "→ Claude Code..."
    if graphify claude install 2>/dev/null; then
        echo "  ✓ graphify claude install"
    elif graphify install 2>/dev/null; then
        echo "  ✓ graphify install (Claude default)"
    else
        echo "⚠️  graphify Claude integration had issues"
    fi

    echo "→ Codex..."
    if graphify codex install 2>/dev/null; then
        echo "  ✓ graphify codex install"
        if [ -f "$HOME/.codex/config.toml" ] && ! grep -q 'multi_agent' "$HOME/.codex/config.toml" 2>/dev/null; then
            echo "  ℹ️  Consider adding multi_agent = true under [features] in ~/.codex/config.toml"
        fi
    else
        echo "⚠️  graphify codex install had issues"
    fi

    echo "→ Cursor..."
    graphify cursor install 2>/dev/null && echo "  ✓ graphify cursor install" \
        || echo "⚠️  graphify cursor install had issues"
}

if ! ensure_python; then
    echo "❌ Python 3.10+ is required for Graphify"
    exit 1
fi

if ! install_uv; then
    echo "❌ Failed to install uv"
    exit 1
fi

if ! install_graphify_package; then
    echo "❌ Failed to install graphifyy"
    exit 1
fi

echo "✓ Graphify CLI: $(graphify --version 2>/dev/null || graphify --help 2>&1 | head -1 || echo 'installed')"

configure_graphify_agents

echo ""
echo "✓ Graphify installed and registered globally"
echo ""
echo "  Per project (run inside each repo):"
echo "    cd /path/to/your-project"
echo "    graphify extract    # or: graphify ."
echo ""
echo "  Then in Claude/Codex use: /graphify .  (Codex: \$graphify .)"
echo "  Re-run graphify extract when the codebase structure changes a lot."

echo "=============================================="
echo "============ [19.6] DONE ====================="
echo "=============================================="
