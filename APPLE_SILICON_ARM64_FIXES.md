# Hedgewars Apple Silicon (ARM64) Build Fixes

## Overview
This document explains the critical fixes required to build and run Hedgewars natively on Apple Silicon (ARM64) Macs running macOS 11.0+ (Big Sur and later).

## The Problem

When building Hedgewars for ARM64, the game engine (`hwengine`) was crashing immediately on launch with:
- **Exit code 217** (displayed by the frontend)
- **System error**: `EXC_BAD_ACCESS (SIGKILL - Code Signature Invalid)`
- **Termination reason**: `CODESIGNING, Code 2, Invalid Page`

The application would launch, but clicking "Play" would fail with the engine crash.

## Root Cause

The build system was applying three incompatible linker flags specifically for ARM64:

1. **`-k-no_adhoc_codesign`** - Disabled automatic ad-hoc code signing
2. **`-k-no_fixup_chains`** - Disabled fixup chains (required for ARM64)
3. **`-k-no_pie`** - Disabled Position Independent Executable

These flags were originally added to work around issues with Free Pascal's ARM64 backend, but they made the binaries incompatible with modern macOS security requirements.

### Why These Flags Broke ARM64

**Modern macOS on Apple Silicon requires:**

1. **Fixup Chains**: ARM64 binaries must use chained fixups instead of classic relocations. This is a fundamental requirement of the ARM64 ABI on macOS.

2. **Code Signing**: All executable code pages must be signed. The linker automatically applies ad-hoc signatures. Disabling this causes "Invalid Page" crashes.

3. **PIE (Position Independent Executable)**: Modern macOS requires PIE for security (ASLR - Address Space Layout Randomization).

### The x86_64 vs ARM64 Difference

On x86_64, these flags were tolerated because:
- Classic relocations were still supported
- Security enforcement was less strict
- The flags "worked by luck"

On ARM64, macOS strictly enforces:
- W^X (Write XOR Execute) - no page can be both writable and executable
- Mandatory code signing of all executable pages
- Proper use of fixup chains for relocations

## The Fix

**Files Modified:**
1. `hedgewars/CMakeLists.txt` - Lines 33-34
2. `cmake_modules/platform.cmake` - Lines 55-56, 73-74

**Changes Made:**
- Removed `-k-no_adhoc_codesign` flag
- Removed `-k-no_fixup_chains` flag  
- Removed `-k-no_pie` flag

**Result:**
The Free Pascal linker now uses proper ARM64 conventions:
- Generates fixup chains automatically
- Creates ad-hoc signed binaries
- Produces PIE executables

## Technical Details

### Code Signing on ARM64

When the linker processes an ARM64 binary on macOS:
1. It generates a code signature directory (`LC_CODE_SIGNATURE` load command)
2. Each code page gets a cryptographic hash
3. The kernel verifies these hashes when loading pages
4. Any page that doesn't match its hash triggers `SIGKILL` with "Invalid Page"

The `-no_adhoc_codesign` flag prevented step 1, causing all pages to fail verification.

### Fixup Chains

ARM64 uses a compact format for relocations:
- **Classic relocations**: Separate data structure listing all fixup locations
- **Chained fixups**: Each fixup contains a pointer to the next fixup

The `-no_fixup_chains` flag forced classic relocations, which the ARM64 loader doesn't support properly, leading to corruption of function pointers and code.

### Position Independent Executable

PIE allows the binary to load at any address:
- Required for ASLR security
- Standard on all modern macOS binaries
- The `-no_pie` flag created a fixed-address binary, incompatible with ARM64 ABI

## Building for ARM64

### Prerequisites
```bash
brew install cmake physfs sdl2 sdl2_image sdl2_mixer sdl2_ttf sdl2_net qt
```

### Build Steps
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt -DCMAKE_BUILD_TYPE=Release
make -j$(sysctl -n hw.ncpu)
make install
```

### Create DMG
```bash
make dmg
# If unmount fails, manually:
hdiutil detach "/Volumes/Hedgewars 1.1.0"
hdiutil convert rw.Hedgewars-1.1.0.dmg -format UDZO -o Hedgewars-1.1.0-arm64.dmg
codesign --force --sign - Hedgewars-1.1.0-arm64.dmg
```

## Verification

### Check Binary Architecture
```bash
file build/bin/hwengine
# Should output: Mach-O 64-bit executable arm64
```

### Verify Code Signature
```bash
codesign -vvv --strict build/Hedgewars.app/Contents/MacOS/hwengine
# Should output: satisfies its Designated Requirement
```

### Check for Fixup Chains
```bash
otool -l build/bin/hwengine | grep -A 5 "LC_CODE_SIGNATURE"
# Should show non-zero dataoff and datasize
```

## Free Pascal Compatibility

**FPC Version**: 3.2.2 for AArch64
- The FPC ARM64 backend now generates compatible code
- No special flags needed
- Standard macOS conventions work correctly

## Testing

After building:
1. Launch Hedgewars.app
2. Click "Play" → "Training" or "Quick Game"
3. Engine should start without error
4. No exit code 217 or SIGKILL crashes

## References

- [Apple Mach-O File Format](https://developer.apple.com/documentation/kernel/mach-o_file_format)
- [Apple Code Signing Guide](https://developer.apple.com/library/archive/technotes/tn2206/)
- [Free Pascal ARM64 Port](https://wiki.freepascal.org/ARM64)
- [ld64 Linker Options](https://opensource.apple.com/source/ld64/)

## Credits

Fix identified and implemented by analyzing crash reports showing:
- `Termination Reason: Namespace CODESIGNING, Code 2, Invalid Page`
- `Exception Type: EXC_BAD_ACCESS (SIGKILL)`

The solution removes the flags that disabled modern macOS security features, allowing Hedgewars to run natively on Apple Silicon.
