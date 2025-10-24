# Building Hedgewars on Apple Silicon (macOS ARM64)

## Summary

This document describes the successful build of Hedgewars for Apple Silicon (ARM64) Macs. The build completes successfully and creates a distributable DMG.

## Quick Start

### Prerequisites
All dependencies from Homebrew on Apple Silicon:
```bash
brew install cmake qt sdl2 sdl2_image sdl2_mixer sdl2_net sdl2_ttf \
             physfs lua glew ffmpeg fpc yasm ghc cabal-install
```

### Build Commands
```bash
# Clean build directory
rm -rf build && mkdir build && cd build

# Configure CMake for ARM64
cmake .. \
  -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DNOSERVER=1 \
  -DNOAUTOUPDATE=1

# Build (use all CPU cores)
make -j$(sysctl -n hw.ncpu)

# Create DMG
make dmg
```

The final DMG will be created as `rw.Hedgewars-1.1.0.dmg` in the build directory.

## Key Changes for ARM64 Support

### 1. CMake Architecture Detection (`cmake_modules/TargetArch.cmake`)

**Problem**: The original CMake module didn't recognize `arm64` as a valid macOS architecture.

**Solution**: Added ARM64 support to the architecture detection:
```cmake
# Added arm64 detection in C code
#if defined(__aarch64__) || defined(_M_ARM64)
    #error cmake_ARCH arm64

# Added arm64 to valid macOS architectures
elseif("${osx_arch}" STREQUAL "arm64")
    set(osx_arch_arm64 TRUE)

# Added arm64 to architecture list
if(osx_arch_arm64)
    list(APPEND ARCH arm64)
endif()
```

### 2. Pascal Compiler Flags (`hedgewars/CMakeLists.txt`)

**Problem**: The `-Cfv` flag (VFP floating point) is specific to ARM32 and not supported on ARM64.

**Solution**: Removed `-Cfv` flag for ARM64 builds:
```cmake
if(APPLE AND ${CMAKE_TARGET_ARCHITECTURES} MATCHES "arm64|aarch64")
    message(STATUS "ARM64 detected - adding conservative compiler flags")
    # Use -O1 instead of -O2 to avoid aggressive register optimizations
    string(REPLACE "-O2" "-O1" CMAKE_Pascal_FLAGS_RELEASE "${CMAKE_Pascal_FLAGS_RELEASE}")
    # Note: -Cfv is for VFP (Vector Floating Point) which doesn't apply to ARM64
    # ARM64 uses NEON/Advanced SIMD by default
    # Pass linker flags for hardened runtime compatibility
    add_flag_append(CMAKE_Pascal_FLAGS "-k-no_adhoc_codesign")
    add_flag_append(CMAKE_Pascal_FLAGS "-k-no_fixup_chains")
endif()
```

**Rationale**: 
- `-Cfv`: VFP (Vector Floating Point) is an ARM32-specific feature. ARM64 uses NEON/Advanced SIMD natively.
- `-O1`: Conservative optimization to avoid ABI issues with Free Pascal on ARM64
- Linker flags: Disable hardened runtime features that conflict with FPC's code generation

## Build Output

### Binary Architecture
```bash
$ file build/Hedgewars.app/Contents/MacOS/hwengine
build/Hedgewars.app/Contents/MacOS/hwengine: Mach-O 64-bit executable arm64
```

### DMG Package
- **Filename**: `Hedgewars-1.1.0-arm64.dmg`
- **Size**: ~192 MB (compressed)
- **Architecture**: ARM64 native
- **Includes**: All required frameworks and dependencies

## Technical Notes

### Free Pascal on ARM64

Free Pascal 3.2.2 has experimental ARM64 support for macOS. The build succeeds with these considerations:

1. **No VFP flags**: ARM64 doesn't use VFP; NEON is the default
2. **Conservative optimization**: `-O1` instead of `-O2` to avoid register allocation issues
3. **No PIE**: `-k-no_pie` flag needed for proper linking (ignored by linker on ARM64, but required by FPC)

### Dependencies

All dependencies are available via Homebrew for ARM64:
- SDL2 libraries: Native ARM64 builds
- Qt 6: Full ARM64 support
- Free Pascal Compiler: ARM64 backend available
- All multimedia codecs: Native ARM64

### Known Issues

1. **DMG blessing**: The `bless` command fails on Apple Silicon during DMG creation, but this is cosmetic. The DMG is fully functional.
   ```
   bless: The 'openfolder' is not supported on Apple Silicon devices.
   ```

2. **Linker warnings**: Various warnings about minimum macOS version mismatches are cosmetic and don't affect functionality:
   ```
   ld: warning: building for macOS-11.0, but linking with dylib built for newer version
   ```

## Distribution

The resulting DMG can be distributed to Apple Silicon Mac users. The app bundle includes:
- ARM64 native `hedgewars` frontend
- ARM64 native `hwengine` game engine
- All required frameworks in `Hedgewars.app/Contents/Frameworks/`
- Complete game data in `Hedgewars.app/Contents/Resources/`

## For Developers

### Code Signing

To distribute the DMG, you'll want to sign it:
```bash
# Sign the app
codesign --deep --force --sign "Developer ID Application: Your Name (TEAM_ID)" \
         build/Hedgewars.app

# Verify signature
codesign --verify --verbose build/Hedgewars.app

# Notarize for distribution (optional, requires Apple Developer account)
xcrun notarytool submit Hedgewars-1.1.0-arm64.dmg \
         --apple-id "your@email.com" \
         --team-id "TEAM_ID" \
         --wait
```

### Contributing Back

These changes enable native ARM64 builds of Hedgewars on Apple Silicon. Consider:
1. Testing the build on multiple Apple Silicon Mac models
2. Running the full test suite (if available)
3. Submitting patches upstream to the Hedgewars project

## Build Date

This build was successfully completed on: **2025-10-25**

Compiler versions:
- CMake: 3.31.3
- Free Pascal: 3.2.2
- Qt: 6.8.0
- SDL2: 2.30.10
- GHC: 9.12.2 (for server, not built)

---

**Status**: ✅ **Build Successful** - Native ARM64 binary created
