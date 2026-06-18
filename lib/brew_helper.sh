#!/usr/bin/env bash

# Homebrew permission helpers for macOS installation scripts.
#
# Usage:
#   source lib/brew_helper.sh
#   ensure_homebrew_in_path
#   ensure_homebrew_writable

ensure_homebrew_in_path() {
    if command -v brew &> /dev/null; then
        if [ -x "$(brew --prefix 2>/dev/null)/bin/brew" ]; then
            eval "$(brew shellenv)" 2>/dev/null || \
                export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
        fi
        return 0
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

ensure_homebrew_writable() {
    ensure_homebrew_in_path
    if ! command -v brew &> /dev/null; then
        return 0
    fi

    local hombrew_prefix
    hombrew_prefix=$(brew --prefix 2>/dev/null || echo "")
    if [ -z "$hombrew_prefix" ] || [ -w "$hombrew_prefix" ]; then
        return 0
    fi

    echo "⚠️  Homebrew directory is not writable: $hombrew_prefix"
    echo "   Fixing ownership and permissions (sudo required)..."
    echo ""

    if type sudo_run &>/dev/null; then
        sudo_run chown -R "$(whoami)" "$hombrew_prefix" 2>/dev/null || {
            echo "❌ Could not fix Homebrew ownership. Run manually:"
            echo "   sudo chown -R $(whoami) $hombrew_prefix"
            return 1
        }
    elif ! sudo chown -R "$(whoami)" "$hombrew_prefix" 2>/dev/null; then
        echo "❌ Could not fix Homebrew ownership. Run manually:"
        echo "   sudo chown -R $(whoami) $hombrew_prefix"
        return 1
    fi

    local dir
    for dir in \
        "$hombrew_prefix" \
        "$hombrew_prefix/etc/bash_completion.d" \
        "$hombrew_prefix/lib/pkgconfig" \
        "$hombrew_prefix/share/aclocal" \
        "$hombrew_prefix/share/doc" \
        "$hombrew_prefix/share/info" \
        "$hombrew_prefix/share/locale" \
        "$hombrew_prefix/share/man" \
        "$hombrew_prefix/share/man/man1" \
        "$hombrew_prefix/share/man/man3" \
        "$hombrew_prefix/share/man/man5" \
        "$hombrew_prefix/share/man/man7" \
        "$hombrew_prefix/share/pwsh" \
        "$hombrew_prefix/share/pwsh/completions" \
        "$hombrew_prefix/share/zsh" \
        "$hombrew_prefix/share/zsh/site-functions" \
        "$hombrew_prefix/var/homebrew/locks"; do
        if [ -d "$dir" ]; then
            chmod u+w "$dir" 2>/dev/null || true
        fi
    done

    if [ -w "$hombrew_prefix" ]; then
        echo "✓ Homebrew permissions fixed"
        echo ""
        return 0
    fi

    echo "❌ Homebrew is still not writable after permission fix."
    return 1
}

_brew_helper_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$_brew_helper_dir/sudo_helper.sh" ]; then
    # shellcheck source=lib/sudo_helper.sh
    source "$_brew_helper_dir/sudo_helper.sh"
fi

# Install or upgrade a cask without destructive reinstall (avoids extra sudo prompts).
brew_cask_install_smart() {
    local cask="$1"
    local app_name="${2:-}"

    ensure_homebrew_in_path

    if type refresh_sudo_if_needed &>/dev/null; then
        refresh_sudo_if_needed 2>/dev/null || true
    fi

    if brew list --cask "$cask" &>/dev/null 2>&1; then
        if [ -n "$app_name" ] && [ -d "/Applications/${app_name}.app" ]; then
            echo "✓ $cask already installed (/Applications/${app_name}.app)"
            echo "→ Checking for updates (upgrade only — no reinstall)..."
            if brew upgrade --cask "$cask" 2>/dev/null; then
                echo "✓ $cask upgraded (or already latest)"
            else
                echo "✓ $cask is up to date"
            fi
            return 0
        fi
        echo "→ $cask is registered but ${app_name:-app} is missing — installing..."
        brew install --cask "$cask"
        return $?
    fi

    echo "Installing $cask..."
    brew install --cask "$cask"
}
