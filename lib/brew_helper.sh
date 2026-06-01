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

    sudo chown -R "$(whoami)" "$hombrew_prefix" 2>/dev/null || {
        echo "❌ Could not fix Homebrew ownership. Run manually:"
        echo "   sudo chown -R $(whoami) $hombrew_prefix"
        return 1
    }

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
