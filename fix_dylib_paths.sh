#!/bin/bash

# Script to fix all dylib paths in the Hedgewars.app bundle
set -e

APP_DIR="$1"
if [ -z "$APP_DIR" ]; then
    echo "Usage: $0 <path_to_Hedgewars.app>"
    exit 1
fi

FRAMEWORKS_DIR="$APP_DIR/Contents/Frameworks"
MACOS_DIR="$APP_DIR/Contents/MacOS"

echo "Fixing dylib paths in $APP_DIR"

# Function to recursively copy and fix dependencies
fix_dependencies() {
    local binary="$1"
    echo "Processing: $binary"
    
    # Get all dependencies
    otool -L "$binary" | grep -E "/opt/homebrew|/usr/local" | awk '{print $1}' | while read -r dep; do
        local libname=$(basename "$dep")
        local target="$FRAMEWORKS_DIR/$libname"
        
        # Skip if already in Frameworks
        if [ -f "$target" ]; then
            # Just fix the path reference
            install_name_tool -change "$dep" "@executable_path/../Frameworks/$libname" "$binary" 2>/dev/null || true
        else
            # Copy the library if it exists
            if [ -f "$dep" ]; then
                echo "  Copying: $libname"
                cp "$dep" "$target"
                chmod +w "$target"
                
                # Fix the library's install name
                install_name_tool -id "@executable_path/../Frameworks/$libname" "$target" 2>/dev/null || true
                
                # Fix the reference in the binary
                install_name_tool -change "$dep" "@executable_path/../Frameworks/$libname" "$binary" 2>/dev/null || true
                
                # Recursively fix this library's dependencies
                fix_dependencies "$target"
            fi
        fi
    done
}

# Fix hwengine first
echo "=== Fixing hwengine ==="
fix_dependencies "$MACOS_DIR/hwengine"

# Fix hedgewars frontend
echo "=== Fixing hedgewars ==="
fix_dependencies "$MACOS_DIR/hedgewars"

# Fix all frameworks
echo "=== Fixing all frameworks ==="
for lib in "$FRAMEWORKS_DIR"/*.dylib; do
    if [ -f "$lib" ]; then
        fix_dependencies "$lib"
    fi
done

echo "=== Done! ==="
echo "Verifying hwengine dependencies:"
otool -L "$MACOS_DIR/hwengine" | grep -E "^\s" | grep -v "/System" | grep -v "/usr/lib"
