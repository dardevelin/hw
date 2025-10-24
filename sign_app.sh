#!/bin/bash
set -e

APP_PATH="$1"
SIGNING_IDENTITY="Apple Development: Darcy Bras da Silva (5DR6X39U87)"
ENTITLEMENTS="entitlements.plist"

if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <path-to-app-bundle>"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH is not a directory"
    exit 1
fi

echo "========================================"
echo "  Signing Hedgewars App Bundle"
echo "========================================"
echo "App: $APP_PATH"
echo "Identity: $SIGNING_IDENTITY"
echo ""

# Remove existing signatures
echo "Removing existing signatures..."
find "$APP_PATH" -type f \( -name "*.dylib" -o -name "*.so" -o -perm +111 \) -exec codesign --remove-signature {} \; 2>/dev/null || true

# Sign all dylibs and frameworks first (deepest first)
echo "Signing dynamic libraries..."
find "$APP_PATH/Contents/Frameworks" -name "*.dylib" -type f 2>/dev/null | while read lib; do
    echo "  Signing: $(basename "$lib")"
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        "$lib" || echo "    Warning: Could not sign $lib"
done

# Sign plugins
echo "Signing plugins..."
find "$APP_PATH/Contents/PlugIns" -name "*.dylib" -type f 2>/dev/null | while read lib; do
    echo "  Signing: $(basename "$lib")"
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        "$lib" || echo "    Warning: Could not sign $lib"
done

# Sign the hwengine binary (critical!)
echo "Signing hwengine..."
if [ -f "$APP_PATH/Contents/MacOS/hwengine" ]; then
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        --entitlements "$ENTITLEMENTS" \
        "$APP_PATH/Contents/MacOS/hwengine"
    echo "  ✓ hwengine signed"
else
    echo "  Warning: hwengine not found"
fi

# Sign any other executables in MacOS
echo "Signing other executables..."
find "$APP_PATH/Contents/MacOS" -type f -perm +111 ! -name "hedgewars" ! -name "hwengine" 2>/dev/null | while read exe; do
    echo "  Signing: $(basename "$exe")"
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        "$exe" || echo "    Warning: Could not sign $exe"
done

# Sign the main executable
echo "Signing main executable..."
codesign --force --sign "$SIGNING_IDENTITY" \
    --options runtime \
    --timestamp \
    --entitlements "$ENTITLEMENTS" \
    "$APP_PATH/Contents/MacOS/hedgewars"
echo "  ✓ hedgewars signed"

# Finally, sign the app bundle itself
echo "Signing app bundle..."
codesign --force --sign "$SIGNING_IDENTITY" \
    --options runtime \
    --timestamp \
    --entitlements "$ENTITLEMENTS" \
    --deep \
    "$APP_PATH"

echo ""
echo "========================================"
echo "  Verifying signatures..."
echo "========================================"

# Verify the signature
codesign --verify --deep --strict --verbose=2 "$APP_PATH" && echo "✓ Verification successful" || echo "✗ Verification failed"

# Check if it will run with Gatekeeper
spctl --assess --type execute --verbose=4 "$APP_PATH" && echo "✓ Gatekeeper will allow" || echo "✗ Gatekeeper will block"

echo ""
echo "Done!"
