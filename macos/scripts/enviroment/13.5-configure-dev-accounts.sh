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

echo "=============================================="
echo "===== [13.5] CONFIGURE DEV ACCOUNTS =========="
echo "=============================================="
echo ""
echo "Sets up personal Git/GitHub accounts side by side under ~/dev."
echo "Each account gets its own folder, SSH key, and git identity via includeIf."
echo ""

# ────────────────────────────────────────────────────────────────
# Load env helper (prompt + save to .env, same pattern as git setup)
# ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        eval "export $line" 2>/dev/null || true
    done < "$ENV_FILE"
    set +a
fi

if [ -f "$PROJECT_ROOT/lib/env_helper.sh" ]; then
    # shellcheck source=lib/env_helper.sh
    source "$PROJECT_ROOT/lib/env_helper.sh"
fi

if ! command -v get_env_var &>/dev/null; then
    echo "❌ lib/env_helper.sh not found — cannot prompt for account values."
    exit 1
fi

DEV_ROOT="$HOME/dev"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"

mkdir -p "$DEV_ROOT" "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Track public keys to show at the end
PUBKEYS=()

configure_account() {
    local n="$1"
    local dir_var="DEV_ACCOUNT_${n}_DIR"
    local gh_var="DEV_ACCOUNT_${n}_GITHUB"
    local email_var="DEV_ACCOUNT_${n}_EMAIL"

    echo ""
    echo "──────────────────────────────────────────────"
    echo "  Account ${n}"
    echo "──────────────────────────────────────────────"

    # Prompt (and persist to .env) only when missing — same behavior as 01-configure-git
    get_env_var "$dir_var"   "folder name under ~/dev for account ${n} (e.g. rubinho)"        true >/dev/null
    get_env_var "$gh_var"    "GitHub username for account ${n} (e.g. rubensjuniordev)"         true >/dev/null
    get_env_var "$email_var" "git email for account ${n} (used in commits + SSH key)"          true >/dev/null

    local dir="${!dir_var}"
    local github="${!gh_var}"
    local email="${!email_var}"

    local folder="$DEV_ROOT/$dir"
    local key="$SSH_DIR/id_ed25519_${dir}"
    local host="github-${dir}"
    local acc_gitconfig="$HOME/.gitconfig-${dir}"

    echo ""
    echo "  Folder : $folder"
    echo "  GitHub : $github"
    echo "  Email  : $email"
    echo "  SSH key: $key"
    echo "  Host   : $host"
    echo ""

    mkdir -p "$folder"

    # 1) Dedicated SSH key for this account
    if [ ! -f "$key" ]; then
        echo "Generating SSH key for account ${n}..."
        ssh-keygen -t ed25519 -C "$email" -f "$key" -N ""
    else
        echo "SSH key already exists, reusing: $key"
    fi
    chmod 600 "$key"
    chmod 644 "$key.pub"

    # Add to ssh-agent / macOS keychain
    ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null || true

    # 2) ~/.ssh/config host entry (idempotent)
    if ! grep -qE "^Host[[:space:]]+${host}([[:space:]]|$)" "$SSH_CONFIG" 2>/dev/null; then
        {
            echo ""
            echo "# rbin dev account: $dir ($github)"
            echo "Host $host"
            echo "    HostName github.com"
            echo "    User git"
            echo "    IdentityFile $key"
            echo "    IdentitiesOnly yes"
            echo "    AddKeysToAgent yes"
            echo "    UseKeychain yes"
        } >> "$SSH_CONFIG"
        echo "✓ Added SSH host '$host' to $SSH_CONFIG"
    else
        echo "✓ SSH host '$host' already present in $SSH_CONFIG"
    fi

    # 3) Per-account gitconfig (regenerated each run so .env stays the source of truth)
    cat > "$acc_gitconfig" <<EOF
# Managed by rbin — Git identity for ~/dev/$dir
# Loaded automatically by ~/.gitconfig via includeIf for this folder.
[user]
	name = $github
	email = $email
[github]
	user = $github
[core]
	sshCommand = ssh -i $key -o IdentitiesOnly=yes
# Route github.com remotes through this account's SSH host inside this folder
[url "git@${host}:"]
	insteadOf = git@github.com:
	insteadOf = https://github.com/
EOF
    echo "✓ Wrote $acc_gitconfig"

    # 4) includeIf in the global ~/.gitconfig (idempotent — single value per folder)
    local gitdir="~/dev/${dir}/"
    git config --global "includeif.gitdir:${gitdir}.path" "$acc_gitconfig"
    echo "✓ Linked includeIf gitdir:${gitdir} → $acc_gitconfig"

    PUBKEYS+=("${n}|${dir}|${github}|${key}.pub")
}

configure_account 1
configure_account 2

if [ -n "${DEV_ACCOUNT_3_DIR:-}" ]; then
    configure_account 3
fi

echo ""
echo "=============================================="
echo "=========== [13.5] DONE ====================="
echo "=============================================="
echo ""
echo "Dev accounts are configured. Inside each folder, Git automatically"
echo "uses the matching name/email and SSH key — no manual switching:"
echo ""
echo "  ~/dev/${DEV_ACCOUNT_1_DIR}/...  → ${DEV_ACCOUNT_1_GITHUB} <${DEV_ACCOUNT_1_EMAIL}>"
echo "  ~/dev/${DEV_ACCOUNT_2_DIR}/...  → ${DEV_ACCOUNT_2_GITHUB} <${DEV_ACCOUNT_2_EMAIL}>"
if [ -n "${DEV_ACCOUNT_3_DIR:-}" ]; then
    echo "  ~/dev/${DEV_ACCOUNT_3_DIR}/...  → ${DEV_ACCOUNT_3_GITHUB} <${DEV_ACCOUNT_3_EMAIL}>"
fi
echo ""
echo "Verify inside a repo with:  git config user.name && git config user.email"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 ADD EACH PUBLIC KEY TO ITS OWN GITHUB ACCOUNT"
echo "   https://github.com/settings/keys  → 'New SSH key'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for entry in "${PUBKEYS[@]}"; do
    IFS='|' read -r n dir github pub <<< "$entry"
    echo ""
    echo "Account ${n} — login on GitHub as '${github}', then paste this key:"
    echo "  ($pub)"
    echo "------------------------------------------------------------"
    cat "$pub"
    echo "------------------------------------------------------------"
done
echo ""
echo "Tip: clone normally (git clone git@github.com:org/repo.git) inside the"
echo "matching ~/dev folder — the right key/identity is applied automatically."
echo ""
