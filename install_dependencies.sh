#!/bin/bash

# Hedgewars Build Dependencies Installer for macOS
# This script installs all missing dependencies for building Hedgewars

set -e

echo "=============================================="
echo "  Hedgewars Build Dependencies Installer"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Core dependencies (required)
CORE_DEPS=("physfs")

# Optional dependencies
OPTIONAL_VIDEO_DEPS=("yasm")
OPTIONAL_HASKELL_DEPS=("ghc" "cabal-install")

echo "This script will install the following packages:"
echo ""
echo -e "${GREEN}Core Dependencies (required):${NC}"
for dep in "${CORE_DEPS[@]}"; do
    echo "  - $dep"
done

echo ""
echo -e "${YELLOW}Optional Dependencies:${NC}"
echo "  Video Recording:"
for dep in "${OPTIONAL_VIDEO_DEPS[@]}"; do
    echo "    - $dep"
done
echo "  Hedgewars Server (Haskell):"
for dep in "${OPTIONAL_HASKELL_DEPS[@]}"; do
    echo "    - $dep"
done

echo ""
read -p "Install ALL dependencies (core + optional)? [Y/n] " -n 1 -r
echo ""

INSTALL_ALL=true
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    INSTALL_ALL=false
fi

# Install core dependencies
echo ""
echo -e "${GREEN}Installing core dependencies...${NC}"
for dep in "${CORE_DEPS[@]}"; do
    echo "Installing $dep..."
    brew install "$dep"
done

if [ "$INSTALL_ALL" = true ]; then
    # Install optional dependencies
    echo ""
    echo -e "${YELLOW}Installing optional dependencies for video recording...${NC}"
    for dep in "${OPTIONAL_VIDEO_DEPS[@]}"; do
        echo "Installing $dep..."
        brew install "$dep"
    done

    echo ""
    echo -e "${YELLOW}Installing optional dependencies for Haskell server...${NC}"
    for dep in "${OPTIONAL_HASKELL_DEPS[@]}"; do
        echo "Installing $dep..."
        brew install "$dep"
    done

    echo ""
    echo -e "${YELLOW}Setting up Haskell environment...${NC}"
    echo "After installation, you'll need to:"
    echo "  1. Load ghc environment: source ~/.ghcup/env"
    echo "  2. Install Haskell packages with the following command:"
    echo ""
    echo "     cabal install vector bytestring 'network < 2.7' time mtl sandi 'hslogger < 1.3' process utf8-string SHA entropy zlib random regex-tdfa deepseq"
    echo ""
else
    echo ""
    echo -e "${YELLOW}Skipping optional dependencies.${NC}"
    echo "You can install them later with:"
    echo "  brew install yasm ghc cabal-install"
fi

echo ""
echo -e "${GREEN}=============================================="
echo "  Installation Complete!"
echo "==============================================\${NC}"
echo ""
echo "Next steps to build Hedgewars:"
echo ""
echo "1. Set macOS deployment target (optional, for older macOS support):"
echo "   export MACOSX_DEPLOYMENT_TARGET=10.8"
echo ""
echo "2. Create build directory:"
echo "   mkdir -p build && cd build"
echo ""
echo "3. Configure with CMake (adjust Qt path as needed):"
echo "   cmake .. -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt -DCMAKE_BUILD_TYPE=Release"
echo ""
echo "   For minimal build (no server, no video recording):"
echo "   cmake .. -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt -DCMAKE_BUILD_TYPE=Release -DNOSERVER=1 -DNOVIDEOREC=1"
echo ""
echo "4. Build:"
echo "   make -j$(sysctl -n hw.ncpu)"
echo ""
echo "5. Install:"
echo "   make install"
echo ""
echo "6. Create DMG (optional):"
echo "   make dmg"
echo ""
