#!/usr/bin/env bash
set -e
echo "=============================================="
echo "========= [25] INSTALLING DOTNET ============"
echo "=============================================="
# .NET version to install (try 10.0 first, fallback to 8.0 LTS)
DOTNET_VERSION="10"
FALLBACK_VERSION="8"
# Check if .NET is already installed
if command -v dotnet &> /dev/null; then
    CURRENT_VERSION=$(dotnet --version 2>/dev/null | head -n 1)
    MAJOR_VERSION=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    if [ "$MAJOR_VERSION" = "$DOTNET_VERSION" ]; then
        echo "✓ .NET ${DOTNET_VERSION} is already installed (version: $CURRENT_VERSION)"
        echo "Skipping installation..."
        exit 0
    else
        echo ":atenção:  .NET $MAJOR_VERSION is installed, but .NET ${DOTNET_VERSION} is required"
        echo "Installing .NET ${DOTNET_VERSION}..."
    fi
else
    echo "Installing .NET SDK ${DOTNET_VERSION}..."
fi
# Detect distro and Microsoft repo URL (ubuntu/22.04 or debian/12)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    LSB_VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
    
    case "$ID" in
        zorin)
            # Zorin reports its own version (17); map to Ubuntu base
            ZORIN_MAJOR=$(echo "${VERSION_ID:-0}" | cut -d. -f1)
            if [ "$ZORIN_MAJOR" -ge 16 ] 2>/dev/null; then
                MS_REPO_VERSION="22.04"
            elif [ "$ZORIN_MAJOR" -ge 15 ] 2>/dev/null; then
                MS_REPO_VERSION="20.04"
            else
                MS_REPO_VERSION="22.04"
            fi
            MS_REPO_URL="https://packages.microsoft.com/config/ubuntu/${MS_REPO_VERSION}/packages-microsoft-prod.deb"
            echo "Detected Zorin $VERSION_ID (Ubuntu-based) → using Ubuntu $MS_REPO_VERSION repository"
            ;;
        ubuntu)
            MS_REPO_VERSION="$LSB_VERSION"
            MS_REPO_URL="https://packages.microsoft.com/config/ubuntu/${MS_REPO_VERSION}/packages-microsoft-prod.deb"
            echo "Detected Ubuntu $MS_REPO_VERSION"
            ;;
        debian)
            DEBIAN_MAJOR=$(echo "${VERSION_ID:-$LSB_VERSION}" | cut -d. -f1)
            MS_REPO_URL="https://packages.microsoft.com/config/debian/${DEBIAN_MAJOR}/packages-microsoft-prod.deb"
            echo "Detected Debian $DEBIAN_MAJOR"
            ;;
        *)
            # Pop, Mint, etc.: use Ubuntu 22.04 if lsb looks like Ubuntu version
            if [[ "$LSB_VERSION" =~ ^[0-9]{2}\.[0-9]{2}$ ]]; then
                MS_REPO_VERSION="$LSB_VERSION"
            else
                MS_REPO_VERSION="22.04"
                echo "Detected $ID: using Ubuntu $MS_REPO_VERSION repository (fallback)"
            fi
            MS_REPO_URL="https://packages.microsoft.com/config/ubuntu/${MS_REPO_VERSION}/packages-microsoft-prod.deb"
            ;;
    esac
else
    echo ":atenção:  Cannot detect Linux distribution"
    exit 1
fi
echo ""
# Add Microsoft repository
echo "Adding Microsoft repository..."
wget "$MS_REPO_URL" -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
# Update package list
echo "Updating package list..."
sudo apt-get update -y
# Install .NET SDK (try preferred version, fallback to LTS)
echo "Installing .NET SDK ${DOTNET_VERSION}.0..."
if ! sudo apt-get install -y dotnet-sdk-${DOTNET_VERSION}.0 2>&1; then
    echo ":atenção:  .NET SDK ${DOTNET_VERSION}.0 not available, trying LTS version ${FALLBACK_VERSION}.0..."
    if ! sudo apt-get install -y dotnet-sdk-${FALLBACK_VERSION}.0 2>&1; then
        echo ":x_vermelho: Failed to install .NET SDK ${DOTNET_VERSION}.0 or ${FALLBACK_VERSION}.0"
        echo ""
        echo "Available .NET SDK versions:"
        apt-cache search dotnet-sdk | grep -E "^dotnet-sdk-[0-9]" | head -5
        echo ""
        echo "Please install manually or check available versions:"
        echo "  apt-cache search dotnet-sdk"
        exit 1
    else
        DOTNET_VERSION="$FALLBACK_VERSION"
        echo "✓ Installed .NET SDK ${FALLBACK_VERSION}.0 (LTS)"
    fi
else
    echo "✓ Installed .NET SDK ${DOTNET_VERSION}.0"
fi
# Verify installation
if command -v dotnet &> /dev/null; then
    INSTALLED_VERSION=$(dotnet --version)
    echo "✓ .NET SDK installed successfully (version: $INSTALLED_VERSION)"
    # Show installed SDKs
    echo ""
    echo "Installed SDKs:"
    dotnet --list-sdks
else
    echo ":x_vermelho: .NET SDK installation failed"
    exit 1
fi
echo "=============================================="
        echo "============== [25] DONE ===================="
        echo "=============================================="
        echo ":seta_para_frente: Next, run: bash 20-install-java.sh"