# Quick Build Guide - Apple Silicon

## Prerequisites
- Homebrew installed
- Xcode Command Line Tools

## One-Command Build

```bash
./install_dependencies.sh && ./build_hedgewars.sh
```

## Manual Build

```bash
# 1. Install dependencies
brew install cmake qt sdl2 sdl2_image sdl2_mixer sdl2_net sdl2_ttf \
             freetype glew lua physfs libpng fpc

# 2. Build
mkdir -p build && cd build
cmake .. \
  -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
  -DCMAKE_BUILD_TYPE=Release \
  -DNOSERVER=1 \
  -DNOAUTOUPDATE=1 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13
make -j$(sysctl -n hw.ncpu)

# 3. Run
open Hedgewars.app
```

## Troubleshooting

If you encounter SDL errors during build:
```bash
./patch_sdl_build.sh
```

Then rebuild.

## Clean Build

```bash
rm -rf build && mkdir build && cd build
# ... run cmake and make commands above
```

See `BUILD_PROGRESS.md` for detailed information.
