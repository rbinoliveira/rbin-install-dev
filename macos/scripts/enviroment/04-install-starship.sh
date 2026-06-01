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

if [ -f "$PROJECT_ROOT/lib/brew_helper.sh" ]; then
    # shellcheck source=lib/brew_helper.sh
    source "$PROJECT_ROOT/lib/brew_helper.sh"
    ensure_homebrew_in_path
    command -v brew &> /dev/null && ensure_homebrew_writable
fi

install_starship_from_github() {
    local arch target version download_url temp_dir install_dir

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="x86_64" ;;
        arm64|aarch64) arch="aarch64" ;;
        *)
            echo "⚠️  Unsupported architecture: $arch"
            return 1
            ;;
    esac

    target="${arch}-apple-darwin"
    version="$(curl -fsSL https://api.github.com/repos/starship/starship/releases/latest \
        | grep -o '"tag_name": "v[^"]*"' | head -1 | cut -d'"' -f4)"
    if [ -z "$version" ]; then
        echo "⚠️  Could not determine latest Starship release"
        return 1
    fi

    download_url="https://github.com/starship/starship/releases/download/${version}/starship-${target}.tar.gz"
    temp_dir="$(mktemp -d)"
    install_dir="${HOME}/.local/bin"

    echo "→ Downloading Starship ${version} (${target})..."
    if ! curl -fsSL "$download_url" -o "$temp_dir/starship.tar.gz"; then
        rm -rf "$temp_dir"
        return 1
    fi

    tar -xzf "$temp_dir/starship.tar.gz" -C "$temp_dir"
    mkdir -p "$install_dir"
    mv "$temp_dir/starship" "$install_dir/starship"
    chmod +x "$install_dir/starship"
    rm -rf "$temp_dir"

    if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
        export PATH="${install_dir}:$PATH"
    fi

    echo "✓ Starship installed to ${install_dir}/starship"
    return 0
}

run_starship_official_installer() {
    # run.sh exports PLATFORM=macos; Starship's installer treats PLATFORM as
    # its own target OS name and skips auto-detection (expects apple-darwin).
    local saved_platform="${PLATFORM-}"
    unset PLATFORM
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    local rc=$?
    if [ -n "$saved_platform" ]; then
        export PLATFORM="$saved_platform"
    fi
    return $rc
}

echo "=============================================="
echo "========= [04] INSTALLING STARSHIP ==========="
echo "=============================================="

echo "Installing Starship prompt..."

STARSHIP_INSTALLED=false

# Check if Homebrew is available (preferred method for macOS)
if command -v brew &> /dev/null; then
    echo "→ Installing Starship via Homebrew..."
    if brew list starship &> /dev/null; then
        if brew upgrade starship 2>/dev/null || brew reinstall starship 2>/dev/null; then
            STARSHIP_INSTALLED=true
        fi
    elif brew install starship; then
        STARSHIP_INSTALLED=true
    else
        echo "⚠️  Homebrew install failed"
    fi
fi

if [ "$STARSHIP_INSTALLED" = false ] && ! command -v starship &> /dev/null; then
    echo "→ Homebrew unavailable or failed, trying GitHub release download..."
    if install_starship_from_github; then
        STARSHIP_INSTALLED=true
    fi
fi

if [ "$STARSHIP_INSTALLED" = false ] && ! command -v starship &> /dev/null; then
    echo "→ GitHub download failed, trying official install script..."
    if run_starship_official_installer; then
        STARSHIP_INSTALLED=true
    fi
fi

if ! command -v starship &> /dev/null; then
    echo "❌ Failed to install Starship"
    exit 1
fi

echo "✓ Starship: $(starship --version 2>&1 | head -1)"

echo "Copying starship.toml..."
mkdir -p ~/.config
cp "$SCRIPT_DIR/../../config/starship.toml" ~/.config/starship.toml

echo "Updating .zshrc with Zinit + Starship + custom config..."
# Copy the complete zsh-config which includes Zinit and Starship
if [ -f "$SCRIPT_DIR/../../config/zsh-config" ]; then
  cat "$SCRIPT_DIR/../../config/zsh-config" > ~/.zshrc
  echo "✓ zsh-config applied successfully"
else
  echo "⚠️  zsh-config not found, using fallback configuration"
  # Fallback if file doesn't exist
  cat >> ~/.zshrc << 'EOF'
# Load Starship prompt
eval "$(starship init zsh)"
EOF
fi

echo "=============================================="
echo "============== [04] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 05-install-node-nvm.sh"
