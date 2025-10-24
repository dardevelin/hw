# Hedgewars macOS Build Progress Report

## Summary
Successfully installed all required dependencies and made significant progress building Hedgewars on macOS (Apple Silicon). The build process is working except for one remaining issue with SDL2 deployment target detection.

## Dependencies Installed

### Core Dependencies (via Homebrew)
- ✅ physfs - File system abstraction library
- ✅ fpc (Free Pascal Compiler) - Required for building the game engine
- ✅ cmake, qt, sdl2, sdl2_image, sdl2_mixer, sdl2_net, sdl2_ttf, freetype, glew, lua, libpng (already installed)

### Optional Dependencies
- ✅ yasm - Assembler for video encoding
- ✅ ghc, cabal-install - Haskell compiler and package manager
- ✅ Haskell packages - Installed all required Cabal packages (vector, bytestring, network, etc.)

## Code Fixes Made

### 1. ARM64/Apple Silicon Support (`cmake_modules/platform.cmake`)
- **Problem**: Build system was hardcoded to use x86_64 architecture
- **Fix**: Added detection for ARM64/aarch64 architecture and set correct Pascal compiler flags (-Paarch64)
- **Status**: ✅ FIXED

### 2. Pascal Constant Expressions (`hedgewars/uConsts.pas`, `hedgewars/uVariables.pas`)
- **Problem**: Free Pascal on ARM64 doesn't support `round()` function in constant expressions
- **Fix**: Replaced `round(N * HDPIScaleFactor)` with literal values (since HDPIScaleFactor=1)
- **Status**: ✅ FIXED

### 3. SDL2 Library vs Framework Detection (`hedgewars/CMakeLists.txt`)
- **Problem**: CMake was checking wrong variable for SDL2 library type
- **Fix**: Changed from `SDL2_LIBRARIES` to `SDL2_IMAGE_LIBRARY` for dylib detection
- **Status**: ✅ FIXED

### 4. macOS Deployment Target (`QTfrontend/CMakeLists.txt`)
- **Problem**: SDL2 requires macOS 10.7+ but build was defaulting to 10.6
- **Attempted Fix**: Added explicit MAC_OS_X_VERSION_MIN_REQUIRED define
- **Status**: ⚠️ PARTIAL - Define is added but SDL still sees wrong version

## Remaining Issue

###SDL2 Deployment Target Detection
**Error**: `/opt/homebrew/include/SDL2/SDL_platform.h:118:3: error: SDL for Mac OS X only supports deploying on 10.7 and above.`

**Root Cause**: The AvailabilityMacros.h is setting `MAC_OS_X_VERSION_MIN_REQUIRED` to `MAC_OS_X_VERSION_10_6` (10.6) instead of respecting the `-mmacosx-version-min=10.13` compiler flag and `CMAKE_OSX_DEPLOYMENT_TARGET=10.13` CMake variable.

**Possible Solutions**:
1. Use older Xcode/SDK that doesn't have this issue
2. Patch SDL2 headers locally to remove the check
3. Find why AvailabilityMacros isn't respecting the deployment target flag
4. Use Qt5 from a different source that has compatible headers

## Build Scripts Created

1. **install_dependencies.sh** - Installs all missing Homebrew and Haskell dependencies
2. **build_hedgewars.sh** - Automated build script with correct CMake flags

## How to Complete the Build

The build can be completed with one of these approaches:

### Option 1: Build without Server (Current Configuration)
```bash
cd /Users/dbrasdasilva/dev/vcs-codebases/github.com/hedgewars/hw/build
cmake .. \
  -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
  -DCMAKE_BUILD_TYPE=Release \
  -DNOSERVER=1 \
  -DNOAUTOUPDATE=1 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13
make -j32
make install
```

### Option 2: Temporarily Patch SDL2 (Workaround)
Comment out the version check in `/opt/homebrew/include/SDL2/SDL_platform.h` line 118.

### Option 3: Install Non-Beta Xcode
The issue may be related to using Xcode-beta. Installing stable Xcode might resolve the AvailabilityMacros issue.

## Next Steps

1. Investigate why AvailabilityMacros.h in the SDK isn't respecting -mmacosx-version-min
2. Consider temporarily patching SDL headers as workaround
3. Test with stable Xcode instead of beta version
4. Potentially report issue to Hedgewars developers about ARM64 macOS support

## Files Modified

- `cmake_modules/platform.cmake` - ARM64 architecture support
- `hedgewars/uConsts.pas` - Fixed constant expressions  
- `hedgewars/uVariables.pas` - Fixed constant expressions
- `hedgewars/CMakeLists.txt` - SDL library detection
- `QTfrontend/CMakeLists.txt` - Deployment target handling
- `install_dependencies.sh` - Created (dependency installer)
- `build_hedgewars.sh` - Created (build automation)
