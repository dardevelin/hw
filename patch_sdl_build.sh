#!/bin/bash
# Temporarily patch SDL_platform.h to bypass version check for build

SDL_FILE="/opt/homebrew/include/SDL2/SDL_platform.h"
BACKUP_FILE="${SDL_FILE}.hedgewars_backup"

if [ ! -f "$SDL_FILE" ]; then
    echo "Error: SDL_platform.h not found at $SDL_FILE"
    exit 1
fi

# Backup if not already backed up
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Creating backup of SDL_platform.h..."
    cp "$SDL_FILE" "$BACKUP_FILE"
fi

# Patch the file - comment out the error line
echo "Patching SDL_platform.h..."
sed -i.tmp 's/^# error SDL for Mac OS X only supports deploying on 10.7 and above./\/\/ PATCHED: & /' "$SDL_FILE"
rm -f "${SDL_FILE}.tmp"

echo "SDL_platform.h patched successfully!"
echo "To restore: cp $BACKUP_FILE $SDL_FILE"
