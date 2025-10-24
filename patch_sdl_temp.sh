#!/bin/bash
# Temporary workaround: Comment out SDL's macOS version check
SDL_PLATFORM="/opt/homebrew/include/SDL2/SDL_platform.h"

if [ ! -f "${SDL_PLATFORM}.bak" ]; then
    echo "Backing up SDL_platform.h..."
    sudo cp "$SDL_PLATFORM" "${SDL_PLATFORM}.bak"
fi

echo "Patching SDL_platform.h..."
sudo sed -i '' '/#if MAC_OS_X_VERSION_MIN_REQUIRED < 1070/,/#endif \/\* MAC_OS_X_VERSION_MIN_REQUIRED < 1070 \*\//s/^# error/\/\/ # error/' "$SDL_PLATFORM"

echo "Patch applied. To restore original:"
echo "  sudo cp ${SDL_PLATFORM}.bak $SDL_PLATFORM"
