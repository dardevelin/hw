#!/bin/bash

# Hedgewars Build Script for macOS (Apple Silicon)
# This script builds Hedgewars with the correct configuration for ARM64 Macs

set -e

echo "=============================================="
echo "  Hedgewars Build Script for macOS"
echo "=============================================="
echo ""

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo "Error: cmake not found. Please install it with: brew install cmake"
    exit 1
fi

if ! command -v fpc &> /dev/null; then
    echo "Error: Free Pascal Compiler (fpc) not found. Please install it with: brew install fpc"
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo "Error: make not found. Please install Xcode Command Line Tools."
    exit 1
fi

# Create build directory
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning existing build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo ""
echo "Configuring Hedgewars..."
echo ""

# Configure with CMake
# -DNOSERVER=1: Don't build the Haskell server (optional, can be removed if Haskell packages are installed)
# -DNOAUTOUPDATE=1: Don't build autoupdate feature (Sparkle framework not installed)
# -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13: Set minimum macOS version
cmake .. \
    -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
    -DCMAKE_BUILD_TYPE=Release \
    -DNOSERVER=1 \
    -DNOAUTOUPDATE=1 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13

echo ""
echo "Building Hedgewars..."
echo ""

# Build with all available cores
NUM_CORES=$(sysctl -n hw.ncpu)
make -j"$NUM_CORES"

echo ""
echo "Installing..."
echo ""

make install

echo ""
echo "=============================================="
echo "  Build Complete!"
echo "==============================================  "
echo ""
echo "The Hedgewars.app has been created in:"
echo "  $PWD/Hedgewars.app"
echo ""
echo "To create a DMG:"
echo "  cd $PWD"
echo "  make dmg"
echo ""
