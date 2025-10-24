# Known Issues - Apple Silicon Build

## Game Engine Crash (CRITICAL)

**Status**: UNRESOLVED  
**Severity**: Critical - Game is unplayable  
**Platform**: Apple Silicon (ARM64) macOS only

### Symptoms
- Frontend (hedgewars GUI) launches successfully
- Map preview generation works
- Starting an actual game causes immediate crash with:
  - Exit code: 217
  - Exception: EAccessViolation at address $00000001FBC02EF0
  - Error occurs in hwengine (Pascal game engine)

### Root Cause Analysis
The crash appears to be related to one or more of:

1. **Free Pascal ARM64 Compatibility**  
   - FPC 3.2.2 on ARM64 macOS may have issues with:
     - Position-independent code (PIC)
     - Function pointers
     - FFI with Rust library

2. **Rust FFI Integration**  
   - The `libhwengine_future.dylib` (Rust library) may not properly interface with Pascal on ARM64
   - Function pointer initialization might fail

3. **SDL2 Duplicate Loading** (FIXED)  
   - Was causing crashes due to duplicate SDL classes
   - Now fixed by proper library bundling

### What Works
✅ Application launches  
✅ Frontend GUI fully functional  
✅ Map preview generation  
✅ Menu navigation  
✅ Settings configuration  

### What Doesn't Work
❌ Starting a game (single or multiplayer)  
❌ Game engine initialization  
❌ Actual gameplay  

### Attempted Fixes

1. ✅ Fixed library bundling (79 libraries now properly bundled)
2. ✅ Fixed SDL duplicate loading issue  
3. ✅ Fixed symlinks for versioned libraries
4. ✅ Proper code signing with Apple Developer certificate
5. ✅ Fixed Pascal constant expressions (removed all `round(HDPIScaleFactor)` calls)
6. ✅ Fixed Rust FFI calling convention (changed from references to raw pointers)
7. ✅ Fixed hwengine library path to Rust library (from absolute to @executable_path)
8. ❌ Still crashes - issue is deeper than calling conventions

### The Calling Convention Issue (FIXED, but not the root cause)

**Discovery**: The Rust library used Rust references (`&T`, `&mut T`) for FFI functions, which is incorrect for C interop.

**Why it worked on x86_64 (Intel) by luck**:
- x86_64 System V ABI: Both pointers and references are passed as a single 64-bit value in register `%rdi`, `%rsi`, etc.
- The memory layout is identical: both are just addresses
- The compiler optimizations happen to align perfectly

**Why it fails on ARM64**:
- ARM64 AAPCS (Procedure Call Standard) is more strict
- References may carry additional semantics or metadata
- Different register usage patterns between Rust and C conventions
- Register `x0`, `x1`, etc. usage differs for references vs raw pointers

**The Fix**: Changed all Rust FFI functions to use raw pointers:
```rust
// Before (WRONG for FFI):
pub extern "C" fn land_get(game_field: &GameField, x: i32, y: i32) -> u16

// After (CORRECT for FFI):
pub extern "C" fn land_get(game_field: *const GameField, x: i32, y: i32) -> u16 {
    unsafe { (*game_field).collision.get(y, x) }
}
```

**Result**: The Rust library now compiles and loads correctly, but the game still crashes, indicating a different underlying issue.

### Possible Solutions

#### Option 1: Use x86_64 Build with Rosetta
Build for x86_64 architecture and run under Rosetta 2 translation:
```bash
cmake .. -DCMAKE_OSX_ARCHITECTURES=x86_64 ...
```

#### Option 2: Disable Rust Component
Investigate building without the Rust hwengine_future library (may require code changes)

#### Option 3: Update Free Pascal
Wait for or test with newer FPC versions that may have better ARM64 support

#### Option 4: Debug with GDB
Attach debugger to hwengine to get exact crash location:
```bash
lldb Hedgewars.app/Contents/MacOS/hwengine
```

### For Developers
If you want to help debug this issue:

1. **Get crash backtrace**:
   ```bash
   lldb ~/Library/Application\ Support/Hedgewars/hwengine
   ```

2. **Check Pascal ARM64 compilation**:
   ```bash
   fpc -Paarch64 -va test.pas
   ```

3. **Test Rust library separately**:
   ```bash
   nm -g build/bin/libhwengine_future.dylib | grep -i init
   ```

### Related Files
- `hedgewars/hwengine.pas` - Main engine entry point
- `rust/lib-hwengine-future/` - Rust library source
- `hedgewars/CMakeLists.txt` - Engine build configuration
- `~/Library/Application Support/Hedgewars/Logs/game0.log` - Crash logs

### Workaround for Users
Currently, there is no workaround. The game cannot be played on Apple Silicon until this is resolved.

**Recommendation**: Use the official x86_64 build with Rosetta 2 until native ARM64 support is fully working.

---

Last Updated: October 24, 2025  
FPC Version: 3.2.2  
macOS Version: 26.1 (16.0 beta)  
Architecture: arm64 (aarch64)
