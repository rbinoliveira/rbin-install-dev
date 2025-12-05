#!/bin/bash

# clean_space.sh
# Safely removes temporary files, caches, and old logs on macOS
# Usage: 
#   ./clean_space.sh          - Cleans only current user
#   sudo ./clean_space.sh     - Cleans all users

# ────────────────────────────────
# System Check
# ────────────────────────────────

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script only works on macOS"
    exit 1
fi

# Don't use set -e to allow controlled failures

# ────────────────────────────────
# User Detection
# ────────────────────────────────

# Check if running with sudo
ORIGINAL_USER=${SUDO_USER:-$USER}
ORIGINAL_HOME=$(eval echo ~$ORIGINAL_USER)

if [ "$EUID" -eq 0 ]; then
    SUDO_MODE=true
    echo "⚠️  Running with administrator privileges"
    echo "    Cleaning ALL users"
else
    SUDO_MODE=false
    ORIGINAL_USER=$USER
    ORIGINAL_HOME=$HOME
fi

# ────────────────────────────────
# Color Definitions
# ────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ────────────────────────────────
# Space Calculation Functions
# ────────────────────────────────

SPACE_FREED=0

calculate_space() {
    local dir=$1
    if [ -d "$dir" ]; then
        local size=$(du -sk "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ]; then
            SPACE_FREED=$((SPACE_FREED + size))
        fi
    fi
}

# ────────────────────────────────
# Directory Cleaning Function
# ────────────────────────────────

clean_dir() {
    local dir=$1
    local name=$2
    local use_sudo=${3:-false}
    
    if [ -d "$dir" ]; then
        local size_before
        if [ "$use_sudo" = "true" ]; then
            size_before=$(sudo du -sk "$dir" 2>/dev/null | cut -f1)
        else
            size_before=$(du -sk "$dir" 2>/dev/null | cut -f1)
        fi
        
        if [ -n "$size_before" ] && [ "$size_before" -gt 0 ]; then
            echo -e "${BLUE}  🧹 Cleaning: ${BOLD}$name${NC}"
            if [ "$use_sudo" = "true" ]; then
                sudo rm -rf "$dir"/* 2>/dev/null || true
            else
                rm -rf "$dir"/* 2>/dev/null || true
            fi
            
            local size_after
            if [ "$use_sudo" = "true" ]; then
                size_after=$(sudo du -sk "$dir" 2>/dev/null | cut -f1)
            else
                size_after=$(du -sk "$dir" 2>/dev/null | cut -f1)
            fi
            local size_after=${size_after:-0}
            local freed=$((size_before - size_after))
            if [ $freed -gt 0 ]; then
                local freed_mb=$((freed / 1024))
                local freed_kb=$(((freed % 1024) * 100 / 1024))
                echo -e "${GREEN}     ✓ Freed: ${freed_mb}.${freed_kb} MB${NC}"
            fi
        fi
    fi
}

# ────────────────────────────────
# Old Files Cleaning Function
# ────────────────────────────────

clean_old_files() {
    local dir=$1
    local days=$2
    local name=$3
    local use_sudo=${4:-false}
    
    if [ -d "$dir" ]; then
        echo -e "${BLUE}  🗑️  Removing files >${days} days: ${BOLD}$name${NC}"
        local count
        if [ "$use_sudo" = "true" ]; then
            count=$(sudo find "$dir" -type f -mtime +$days -delete -print 2>/dev/null | wc -l | tr -d ' ')
        else
            count=$(find "$dir" -type f -mtime +$days -delete -print 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$count" -gt 0 ]; then
            echo -e "${GREEN}     ✓ Removed $count old files${NC}"
        fi
    fi
}

# ────────────────────────────────
# Welcome Banner
# ────────────────────────────────

echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                                                ║${NC}"
echo -e "${BOLD}${CYAN}║            🧹  DISK SPACE CLEANUP - macOS  🧹                 ║${NC}"
echo -e "${BOLD}${CYAN}║                                                                ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
if [ "$SUDO_MODE" = "true" ]; then
    echo -e "${BOLD}${MAGENTA}👥 Mode: Cleaning ALL users${NC}"
else
    echo -e "${BOLD}${BLUE}👤 Mode: Cleaning current user only ($ORIGINAL_USER)${NC}"
    echo -e "${YELLOW}   💡 Run with sudo to clean all users${NC}"
fi
echo ""
echo -e "${BOLD}${YELLOW}⚡ AGGRESSIVE CLEANUP - What will be removed:${NC}"
echo ""
echo -e "${CYAN}  🐳 Docker:${NC}"
echo "     • Containers, images, volumes, and networks"
echo ""
echo -e "${CYAN}  📦 Development Artifacts:${NC}"
echo "     • JavaScript/TypeScript: node_modules, dist, build, .next, .turbo"
echo "     • Python: __pycache__, .venv, venv, .pytest_cache, *.pyc"
echo "     • Go: vendor, pkg folders"
echo "     • Build caches (.vite, .parcel, .webpack, .angular, etc.)"
echo "     • Test outputs (coverage, playwright, cypress, etc.)"
echo "     • Temp files and IDE artifacts"
echo ""
echo -e "${CYAN}  🍎 Xcode:${NC}"
echo "     • DerivedData"
echo "     • Old archives (>30 days)"
echo "     • Caches and old logs"
echo ""
echo -e "${CYAN}  🗑️  System:${NC}"
echo "     • All trash (users + external volumes)"
echo "     • Application caches"
echo "     • Old logs (>30 days)"
echo "     • Temporary files"
if [ "$SUDO_MODE" = "true" ]; then
    echo ""
    echo -e "${CYAN}  🔒 Homebrew, pip, and others:${NC}"
    echo "     • Development tool caches"
fi
echo ""
echo -e "${BOLD}${RED}⚠️  WARNING: Development data will be removed!${NC}"
echo -e "${YELLOW}   Projects will need to reinstall dependencies (npm install, etc.)${NC}"
echo ""

# ────────────────────────────────
# User Confirmation
# ────────────────────────────────

echo -e "${BOLD}${GREEN}Do you want to continue with the cleanup? (y/N): ${NC}"
read -n 1 -r
echo
if [[ ! $REPLY =~ ^[YySs]$ ]]; then
    echo -e "${RED}❌ Operation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${GREEN}🚀 Starting cleanup...${NC}"
echo ""

# ────────────────────────────────
# Development Artifacts Cleaning
# ────────────────────────────────

clean_dev_artifacts() {
    local user_home=$1
    local user_name=$2
    local use_sudo=$3
    
    echo -e "${BLUE}  🗂️  Removing ALL development build artifacts...${NC}"
    echo -e "${CYAN}     Searching in: $user_home${NC}"
    echo ""
    
    # Define all patterns to clean (folders)
    local folder_patterns=(
        # JavaScript/TypeScript/Node.js
        "node_modules"
        "dist"
        "build"
        "out"
        ".next"
        ".turbo"
        "nx-out"
        ".vite"
        ".rspack-cache"
        ".rollup.cache"
        ".webpack"
        ".parcel-cache"
        ".sass-cache"
        ".pnpm-store"
        "storybook-static"
        ".expo"
        ".expo-shared"
        "solid-start-build"
        
        # Python
        "__pycache__"
        ".pytest_cache"
        ".tox"
        ".venv"
        "venv"
        ".eggs"
        "*.egg-info"
        ".mypy_cache"
        ".ruff_cache"
        ".hypothesis"
        ".pytype"
        "pip-wheel-metadata"
        "htmlcov"
        ".coverage"
        
        # Go
        "vendor"
        
        
        # General
        "coverage"
        "playwright-report"
        ".vitest"
        ".idea"
    )
    
    local total_items=0
    local total_freed=0
    
    # Clean folders - use direct find with -delete for reliability
    for pattern in "${folder_patterns[@]}"; do
        echo -e "${BLUE}  → Searching for '$pattern' folders...${NC}"
        local pattern_count=0
        local pattern_size=0
        
        if [ "$use_sudo" = "true" ]; then
            # First, count and calculate size (skip folders < 100KB to ignore test fixtures)
            while IFS= read -r path; do
                if [ -d "$path" ]; then
                    local size_kb=$(sudo du -sk "$path" 2>/dev/null | cut -f1)
                    if [ -n "$size_kb" ] && [ "$size_kb" -gt 100 ]; then
                        pattern_count=$((pattern_count + 1))
                        pattern_size=$((pattern_size + size_kb))
                        echo -e "${CYAN}     Removing: $path${NC}"
                        # Remove immediately
                        sudo rm -rf "$path" 2>/dev/null || echo -e "${RED}     Failed to remove: $path${NC}"
                    fi
                fi
            done < <(sudo find "$user_home" -type d -name "$pattern" 2>/dev/null)
        else
            # First, count and calculate size (skip folders < 100KB to ignore test fixtures)
            while IFS= read -r path; do
                if [ -d "$path" ]; then
                    local size_kb=$(du -sk "$path" 2>/dev/null | cut -f1)
                    if [ -n "$size_kb" ] && [ "$size_kb" -gt 100 ]; then
                        pattern_count=$((pattern_count + 1))
                        pattern_size=$((pattern_size + size_kb))
                        echo -e "${CYAN}     Removing: $path${NC}"
                        # Remove immediately
                        rm -rf "$path" 2>/dev/null || echo -e "${RED}     Failed to remove: $path${NC}"
                    fi
                fi
            done < <(find "$user_home" -type d -name "$pattern" 2>/dev/null)
        fi
        
        if [ $pattern_count -gt 0 ]; then
            total_items=$((total_items + pattern_count))
            total_freed=$((total_freed + pattern_size))
            local size_mb=$((pattern_size / 1024))
            echo -e "${GREEN}     ✓ Removed $pattern_count '$pattern' folder(s) - ${size_mb} MB${NC}"
        fi
        echo ""
    done
    
    # Clean files
    echo -e "${BLUE}  → Cleaning cache files...${NC}"
    local file_patterns=(
        # JavaScript/TypeScript
        ".eslintcache"
        ".prettier-cache"
        ".tsbuildinfo"
        
        # Python
        "*.pyc"
        "*.pyo"
        "*.pyd"
        ".coverage"
        "coverage.xml"
        "nosetests.xml"
        
