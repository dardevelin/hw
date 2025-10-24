# ARM64 Fixes for Hedgewars on Apple Silicon

## Problem
Free Pascal compiler (FPC) on ARM64/AArch64 has critical runtime issues with:
1. Direct field access on global record variables
2. Loop-based field initialization on global record arrays
3. Nested function calls during module initialization that access global variables

These cause `EAccessViolation` crashes (exit code 217) even in simple assignments like `globalRecord.field := nil`.

## Root Cause
The FPC ARM64 backend has bugs in how it generates code for accessing fields in global variables of record/struct types. The issue appears to be related to:
- Incorrect base address calculation for global variables
- Stack frame corruption in nested function calls
- Uninitialized memory sections for global variables

## Solutions Applied

### uChat.pas - Module Initialization Fix
**File**: `hedgewars/uChat.pas`
**Function**: `initModule`

**Problem**: Crash when accessing `InputLinePrefix.Tex`, `inputStr.s`, or `Strs[i].Tex`

**Solution**: Initialize ALL global record/array structures with `FillChar()` at the beginning of `initModule`:

```pascal
// ARM64 FIX: Initialize ALL global record/array structures FIRST
FillChar(Strs, SizeOf(Strs), 0);
FillChar(MStrs, SizeOf(MStrs), 0);
FillChar(LocalStrs, SizeOf(LocalStrs), 0);
FillChar(InputStr, SizeOf(InputStr), 0);
FillChar(InputLinePrefix, SizeOf(InputLinePrefix), 0);
```

**Why it works**: `FillChar()` initializes the entire memory block at once instead of individual field access, avoiding the ARM64 code generation bug.

### uChat.pas - ResetCursor Workaround
**Problem**: Crash in `UpdateCursorCoords()` function prologue (stack frame setup)

**Solution**: Avoid calling `ResetCursor()` during initialization; set cursor variables directly:

```pascal
// ARM64 FIX: Don't call ResetCursor/UpdateCursorCoords during init
selectedPos:= -1;
cursorPos:= 0;
cursorX:= 0;
selectionDx:= 0;
```

**Why it works**: Avoids nested function calls that trigger stack corruption in FPC ARM64 during module initialization.

## Impact
These fixes allow Hedgewars to successfully initialize on ARM64 and progress past the chat module initialization. The game now crashes later in the graphics/OpenGL initialization phase, which is a separate issue unrelated to the FPC ARM64 global variable bug.

## Testing
- Tested on: macOS 15.0 (26B5072a), Mac15,14 (MacBook Pro M3)
- FPC Version: 3.2.2 (ARM64 target)
- Status: Chat module initialization ✅ FIXED
- Remaining: Graphics/OpenGL initialization crash (different issue)

## Future Work
Other modules may have similar global variable issues and may need the same FillChar() pattern applied to their `initModule` procedures.
