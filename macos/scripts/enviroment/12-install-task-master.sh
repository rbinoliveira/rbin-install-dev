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
echo "===== [12] INSTALLING TASK MASTER (MCP) ====="
echo "=============================================="

# ────────────────────────────────
# Check Cursor Installation
# ────────────────────────────────

CURSOR_MCP_DIR="$HOME/.cursor"
MCP_CONFIG_FILE="$CURSOR_MCP_DIR/mcp.json"

if [ ! -d "$CURSOR_MCP_DIR" ]; then
    echo "Creating Cursor MCP directory..."
    mkdir -p "$CURSOR_MCP_DIR"
fi

# ────────────────────────────────
# Install Task Master via One-Click
# ────────────────────────────────

echo ""
echo "📦 Installing Task Master MCP Server..."
echo ""
echo "⚠️  IMPORTANT: This will open Task Master installation page"
echo "   Follow the one-click installation in Cursor"
echo ""
echo "Opening: https://www.task-master.dev/"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
    open "https://www.task-master.dev/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "https://www.task-master.dev/" 2>/dev/null || \
    sensible-browser "https://www.task-master.dev/" 2>/dev/null || \
    echo "Please open: https://www.task-master.dev/"
fi

echo ""
read -p "Press Enter after completing the one-click installation in Cursor..."

# ────────────────────────────────
# Create/Update MCP Configuration
# ────────────────────────────────

echo ""
echo "📝 Configuring MCP settings..."

if [ -f "$MCP_CONFIG_FILE" ]; then
    echo "→ Found existing mcp.json, backing up..."
    cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup"
fi

# ────────────────────────────────
# Load API Keys from .env if available
# ────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

ANTHROPIC_KEY=""
PERPLEXITY_KEY=""
OPENAI_KEY=""
GOOGLE_KEY=""

if [ -f "$ENV_FILE" ]; then
    echo "→ Loading API keys from .env file..."
    
    # Read API keys from .env (ignoring comments and empty lines)
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Extract key-value pairs
        if [[ "$line" =~ ^[[:space:]]*ANTHROPIC_API_KEY[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            ANTHROPIC_KEY="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*PERPLEXITY_API_KEY[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            PERPLEXITY_KEY="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*OPENAI_API_KEY[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            OPENAI_KEY="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^[[:space:]]*GOOGLE_API_KEY[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            GOOGLE_KEY="${BASH_REMATCH[1]}"
        fi
    done < "$ENV_FILE"
    
    if [ -n "$ANTHROPIC_KEY" ] || [ -n "$PERPLEXITY_KEY" ] || [ -n "$OPENAI_KEY" ] || [ -n "$GOOGLE_KEY" ]; then
        echo "✓ Found API keys in .env file"
    else
        echo "⚠️  No API keys found in .env file"
    fi
else
    echo "⚠️  .env file not found at: $ENV_FILE"
    echo "   API keys will need to be added manually to mcp.json"
fi

# ────────────────────────────────
# Create MCP Config with API Keys
# ────────────────────────────────

# Use jq if available, otherwise use sed/awk
if command -v jq &> /dev/null; then
    # Create JSON with jq
    cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "taskmaster-ai": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "$ANTHROPIC_KEY",
        "PERPLEXITY_API_KEY": "$PERPLEXITY_KEY",
        "OPENAI_API_KEY": "$OPENAI_KEY",
        "GOOGLE_API_KEY": "$GOOGLE_KEY"
      }
    }
  }
}
EOF
else
    # Fallback: create JSON manually
    cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "taskmaster-ai": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "$ANTHROPIC_KEY",
        "PERPLEXITY_API_KEY": "$PERPLEXITY_KEY",
        "OPENAI_API_KEY": "$OPENAI_KEY",
        "GOOGLE_API_KEY": "$GOOGLE_KEY"
      }
    }
  }
}
EOF
fi

echo "→ Created/updated mcp.json at: $MCP_CONFIG_FILE"

if [ -n "$ANTHROPIC_KEY" ]; then
    echo "  ✓ ANTHROPIC_API_KEY: configured"
else
    echo "  ⚠️  ANTHROPIC_API_KEY: not set (required for Claude)"
fi

if [ -n "$PERPLEXITY_KEY" ]; then
    echo "  ✓ PERPLEXITY_API_KEY: configured"
else
    echo "  ⚠️  PERPLEXITY_API_KEY: not set (optional, for research)"
fi

if [ -n "$OPENAI_KEY" ]; then
    echo "  ✓ OPENAI_API_KEY: configured"
else
    echo "  ⚠️  OPENAI_API_KEY: not set (optional)"
fi

if [ -n "$GOOGLE_KEY" ]; then
    echo "  ✓ GOOGLE_API_KEY: configured"
else
    echo "  ⚠️  GOOGLE_API_KEY: not set (optional)"
fi

echo ""

# ────────────────────────────────
# Instructions
# ────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. ✅ Complete one-click installation in Cursor (if not done)"
echo ""
echo "2. 🔑 Add your API keys to: $MCP_CONFIG_FILE"
echo "   Edit the file and add your keys:"
echo "   - ANTHROPIC_API_KEY (required for Claude)"
echo "   - PERPLEXITY_API_KEY (optional, for search)"
echo "   - OPENAI_API_KEY (optional)"
echo "   - GOOGLE_API_KEY (optional)"
echo ""
echo "3. ⚙️  Enable Task Master in Cursor:"
echo "   - Open Cursor Settings (Cmd+,)"
echo "   - Go to 'MCP' tab"
echo "   - Enable 'taskmaster-ai' toggle"
echo ""
echo "4. 🚀 Initialize Task Master in your project:"
echo "   - Open Cursor AI chat"
echo "   - Type: 'Inicializar taskmaster-ai no meu projeto'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Documentation: https://docs.task-master.dev/"
echo "🌐 Website: https://www.task-master.dev/"
echo ""

echo "=============================================="
echo "============== [12] DONE ===================="
echo "=============================================="
echo "▶ Next, run: bash 13-configure-cursor.sh"


