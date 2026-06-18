#!/usr/bin/env bash

#
# Sudo session helper — authenticate once, keep credentials alive during install.
#
# Usage:
#   source lib/sudo_helper.sh
#   start_sudo_keepalive
#   sudo_run cp file /Library/Fonts/    # uses cached creds when possible
#   stop_sudo_keepalive
#

SUDO_KEEPALIVE_PID=""

refresh_sudo_if_needed() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    if [ -e /dev/tty ]; then
        sudo -v < /dev/tty
    else
        sudo -v
    fi
}

# Run a command with sudo, reusing cached credentials (no extra password prompt).
sudo_run() {
    if sudo -n "$@" 2>/dev/null; then
        return 0
    fi

    refresh_sudo_if_needed || return 1
    sudo "$@"
}

start_sudo_keepalive() {
    if [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
        return 0
    fi

    if ! command -v sudo &>/dev/null; then
        return 0
    fi

    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi

    if [ ! -t 0 ]; then
        if ! sudo -n true 2>/dev/null; then
            return 0
        fi
    else
        echo ""
        echo "🔐 Alguns passos precisam de senha de administrador (sudo)."
        echo "   Você digita uma vez; a sessão fica ativa durante a instalação."
        echo ""

        if ! refresh_sudo_if_needed; then
            echo "❌ Autenticação sudo falhou."
            return 1
        fi
    fi

    (
        while true; do
            sleep 60
            if [ -e /dev/tty ]; then
                sudo -v 2>/dev/null < /dev/tty || exit 0
            else
                sudo -v 2>/dev/null || exit 0
            fi
        done
    ) &
    SUDO_KEEPALIVE_PID=$!
    export SUDO_KEEPALIVE_PID
}

stop_sudo_keepalive() {
    if [ -n "${SUDO_KEEPALIVE_PID:-}" ]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
        wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
        SUDO_KEEPALIVE_PID=""
    fi
}
