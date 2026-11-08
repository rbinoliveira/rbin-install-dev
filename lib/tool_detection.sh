#!/usr/bin/env bash

#
# Tool Detection Module
#
# Detects whether Claude is already installed
# on the system and stores detection results for use by installation handlers.
#
# Usage:
#   source lib/tool_detection.sh
#   detect_all_tools
#

set -eo pipefail

# Ensure platform detection is available
if [ -z "$PLATFORM" ]; then
    echo "ERROR: Platform detection must be sourced before tool detection" >&2
    return 1 2>/dev/null || exit 1
fi

# ────────────────────────────────────────────────────────────────
# Claude Code Detection
# ────────────────────────────────────────────────────────────────

detect_claude() {
    export CLAUDE_INSTALLED="false"
    export CLAUDE_VERSION="unknown"
    export CLAUDE_PATH=""
    export CLAUDE_CONFIG_EXISTS="false"

    # Check if claude command is available
    if command -v claude &> /dev/null; then
        export CLAUDE_PATH="$(command -v claude)"

        # Try to get version
        if claude --version &> /dev/null; then
            local version_output
            version_output="$(claude --version 2>&1 | head -1)"
            export CLAUDE_VERSION="$version_output"
            export CLAUDE_INSTALLED="true"
        else
            # Command exists but version check failed
            export CLAUDE_VERSION="unknown (command found but version check failed)"
            export CLAUDE_INSTALLED="partial"
        fi
    fi

    # Check for Claude configuration directory
    if [ -d "$HOME/.claude" ]; then
        export CLAUDE_CONFIG_EXISTS="true"
    fi

    # Also check npm global packages if available
    if [ "$CLAUDE_INSTALLED" = "false" ] && command -v npm &> /dev/null; then
        if npm list -g @anthropic-ai/claude-code &> /dev/null; then
            local npm_version
            npm_version="$(npm list -g @anthropic-ai/claude-code 2>&1 | grep claude-code | head -1)"
            export CLAUDE_VERSION="$npm_version"
            export CLAUDE_INSTALLED="true"
            export CLAUDE_PATH="npm global"
        fi
    fi
}

# ────────────────────────────────────────────────────────────────
# Main Detection Function
# ────────────────────────────────────────────────────────────────

detect_all_tools() {
    detect_claude
}

# ────────────────────────────────────────────────────────────────
# Display Detection Results
# ────────────────────────────────────────────────────────────────

print_detection_summary() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Tool Detection Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Claude
    echo -n "Claude Code:    "
    if [ "$CLAUDE_INSTALLED" = "true" ]; then
        echo "✓ Installed ($CLAUDE_VERSION)"
        if [ "$CLAUDE_CONFIG_EXISTS" = "true" ]; then
            echo "                └─ Configuration found"
        fi
    elif [ "$CLAUDE_INSTALLED" = "partial" ]; then
        echo "⚠ Partially installed (needs repair)"
    else
        echo "✗ Not installed"
    fi

    echo ""
}

# ────────────────────────────────────────────────────────────────
# Reinstall Prompt Functions
# ────────────────────────────────────────────────────────────────

prompt_reinstall_if_needed() {
    local tool_name="$1"
    local installed_var="$2"
    local version_var="$3"

    # Get the value of the installed variable (using eval for compatibility)
    local is_installed
    local version
    eval "is_installed=\$$installed_var"
    eval "version=\$$version_var"

    # If not installed, no prompt needed
    if [ "$is_installed" = "false" ]; then
        return 0
    fi

    # In force mode, always reinstall
    if [ "$FORCE_MODE" = "true" ]; then
        echo "Force mode: $tool_name will be reinstalled"
        return 0
    fi

    # Prompt user for reinstall
    echo ""
    if [ "$is_installed" = "partial" ]; then
        echo "⚠️  $tool_name appears to be partially installed or misconfigured."
        echo "Version: $version"
        read -p "Repair/reinstall $tool_name? [Y/n]: " -n 1 -r
    else
        echo "✓ $tool_name is already installed."
        echo "Version: $version"
        read -p "Reinstall $tool_name anyway? [y/N]: " -n 1 -r
    fi
    echo ""

    # Check response
    if [ "$is_installed" = "partial" ]; then
        # For partial installs, default to yes (repair)
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Skipping $tool_name reinstall."
            return 1
        fi
    else
        # For complete installs, default to no (skip)
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping $tool_name reinstall."
            return 1
        fi
    fi

    echo "Will reinstall $tool_name..."
    return 0
}

# Export functions for use in other scripts
export -f detect_claude
export -f detect_all_tools
export -f print_detection_summary
export -f prompt_reinstall_if_needed
