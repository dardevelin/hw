Hedgewars - a turn-based strategy game
======================================
[![Build Status](https://travis-ci.org/hedgewars/hw.svg)](https://travis-ci.org/hedgewars/hw)

Description
-----------
This is the funniest and most addictive game you'll ever play—hilarious fun
that you can enjoy anywhere, anytime. **Hedgewars** is a **turn-based strategy
game** but the real buzz is from watching the **devastation caused by those
pesky hedgehogs** with those fantastic weapons—sneaky little blighters with
a bad attitude!

Each player controls a **team of up to 8 hedgehogs**. During the course of
the game, players take turns with one of their hedgehogs. They then use
whatever tools and weapons are available to **attack and kill the opponents'
hedgehogs**, thereby winning the game.

To destroy your foes you can use one out of **over 40 weapons**!
Launch bazookas or homing bees, drop mines, dynamite or explosive rubber ducks,
throw grenades or watermelon bombs, poison them with stinky cheese, send them
flying with a baseball bat, and much more!

Most weapons cause **explosions that deform the terrain**, removing
circular chunks. Hedgehogs can die by drowning, being thrown off
either side of the arena, or when their health is reduced to zero.

Hedgehogs may move around the terrain in a variety of ways, normally by
walking and jumping but also by using particular tools such as the rope
or parachute, to move to otherwise inaccessible areas. Each **turn is
time-limited** to ensure that players do not hold up the game with
excessive thinking or moving.

Getting started
---------------
For complete beginners we recommend to play in singleplayer mode first.
Start with the Basic Movement Training found in the training menu.
Proceed with the other training missions.
After completing the training, try to play some quick matches against the
computer (also found in the singleplayer menu).
Hedgewars has many weapons, so play a few matches to get a better feeling
for them.

In-depth information about the game can be found online:

* <https://hedgewars.org/start>: Getting Started
* <https://hedgewars.org/wiki.html>: Hedgewars Wiki

Default controls (excerpt)
--------------------------
The most important default controls are:

* Cursor keys: Walk and aim
* Mouse: Move camera
* Right mouse button: Open ammo menu
* Left mouse button: Select target or weapon
* Space bar: Shoot
* Left shift: Precise (this is a modifier key)
* Precise + Up/Down: Precise aiming
* Precise + Left/Right: Turn around without walking
* Hold down Precise: Prevent slipping on ice
* Enter: Jump
* Backspace: High jump
* Backspace ×2: Backjump
* Tab: Switch hedgehog (after activating the utility)
* 1-5: Set weapon timer
* F1-F10: Weapon shortcuts
* M: Mission panel / game mode information. Hold pressed to display, release to hide
* P: Pause, when playing offline, toggle automatic turn skipping when online
* Esc: Quit with prompt
* T: Chat
* U: Clan chat

For the full list, go to the Hedgewars settings. Also read the weapon tooltips
for weapon-specific controls.

### Special controls

These are lesser-known controls of Hedgewars, they are based on your
configured controls:

* Precise + Toggle hedgehog tags: Change visible hedgehog tags (team name/hog name/health)
* Switch  + Toggle hedgehog tags: Toggle hedgehog tag translucency
* Precise + Toggle team bars + Switch: Toggle HUD
* Precise + Capture (screenshot key): Save current map + mask into Screenshot directory
* Precise + zoom in/out: Change zoom in smaller steps
* Precise + volume up/down: Change volume in smaller steps
* Precise + Reset zoom: Set zoom to 100% (instead of the zoom level in the settings)

System requirements
-------------------
For PC or Mac:

* Mouse and keyboard
* Monitor, minimal resolution 1024×768
* 200 MiB storage space
* Processor: 1 GHz (1 core is enough), 64bit recommended
* Video card: 250 MHz or so
              (any decent card from the year 2004 or later should do fine)
* 1 GiB RAM minimum
* Operating system: Windows Vista/7/8/10, GNU/Linux, macOS, FreeBSD, others

Hedgewars has been ported to other operating systems in the past.
Check out <https://hedgewars.org/download.html> for the latest information.

Gamepads are supported partially (only in-game, not in the main menu).

Installation instructions
-------------------------
See the `INSTALL.md` file.

Or see our wiki at <https://hedgewars.org/kb/BuildingHedgewars>.

### Building on Apple Silicon (macOS ARM64)

Special instructions for building Hedgewars on Apple Silicon Macs:

#### Quick Start

1. **Install dependencies**:
   ```bash
   ./install_dependencies.sh
   ```

2. **Build the game**:
   ```bash
   ./build_hedgewars.sh
   ```

The built `Hedgewars.app` will be located in the `build/` directory.

#### Manual Build Process

If you prefer to build manually:

1. **Install Homebrew dependencies**:
   ```bash
   brew install cmake qt sdl2 sdl2_image sdl2_mixer sdl2_net sdl2_ttf \
                freetype glew lua physfs libpng fpc
   ```

2. **Configure and build**:
   ```bash
   mkdir build && cd build
   cmake .. \
     -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
     -DCMAKE_BUILD_TYPE=Release \
     -DNOSERVER=1 \
     -DNOAUTOUPDATE=1 \
     -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13
   make -j$(sysctl -n hw.ncpu)
   ```

3. **Note**: Due to compatibility issues with SDL2 headers and the macOS SDK, a temporary patch to SDL headers may be required. The build scripts handle this automatically.

#### Apple Silicon Changes

This fork includes extensive modifications for Apple Silicon (ARM64) support. While the build system and most components work, **the game engine currently crashes at runtime** due to a deep compatibility issue between Free Pascal 3.2.2 and ARM64 macOS.

**Status**: ⚠️ **Work In Progress** - Frontend works, game engine crashes

##### Modified Files and Rationale

**Build System (CMake)**
- `cmake_modules/platform.cmake`: Added ARM64/aarch64 architecture detection for Free Pascal compiler
- `CMakeLists.txt`: Added prefix header for macOS deployment target handling
- `hedgewars/CMakeLists.txt`: Fixed SDL2 library detection for Homebrew ARM64 installations
- `QTfrontend/CMakeLists.txt`: Added Cocoa and Foundation framework linking (required on macOS)

**Pascal Source Code**
- `hedgewars/uConsts.pas`: Fixed constant expressions using `round(HDPIScaleFactor)` - FPC 3.2.2 on ARM64 requires compile-time constants, cannot evaluate `round()` at compile time
- `hedgewars/uVariables.pas`: Replaced font height calculations from `round(N*HDPIScaleFactor)` to literal values (HDPIScaleFactor=1 on desktop)
- `hedgewars/uRenderUtils.pas`: Fixed text rendering width calculations, removed `round(HDPIScaleFactor)` calls

**Rust FFI (Critical for ARM64 Compatibility)**
- `rust/lib-hwengine-future/src/lib.rs`: **Changed ALL FFI function signatures from Rust references (`&T`, `&mut T`) to raw pointers (`*const T`, `*mut T`)**

  **Why this matters**: On x86_64, Rust references and C pointers happen to be ABI-compatible by luck - both pass a single pointer value in a register. However, on ARM64, the calling convention is stricter:
  
  - **Rust references** (`&T`): The compiler may pass additional metadata or use different registers
  - **Raw pointers** (`*const T`): Guaranteed to match C's calling convention (single pointer value)
  
  When Pascal calls Rust functions with `pointer` parameters, it uses the C calling convention. On x86_64, this accidentally works even with Rust references. On ARM64, it causes mismatched parameter passing, leading to crashes.

  Changed functions:
  - `create_ai`, `land_get`, `land_set`, `land_row`, `land_fill`
  - `land_pixel_get`, `land_pixel_set`, `land_pixel_row`
  - `ai_clear_team`, `ai_think`, `ai_have_plan`, `apply_theme`

**Build Scripts**
- `install_dependencies.sh`: Automated Homebrew dependency installation for ARM64
- `build_hedgewars.sh`: Automated build with correct CMake flags
- `patch_sdl_build.sh`: SDL2 header compatibility workaround for macOS SDK
- `prefix.h`: Prefix header for deployment target configuration

##### Current Issue: Runtime Crash (Exit Code 217)

**Symptom**: Game crashes immediately when starting gameplay with:
```
EAccessViolation: Access violation at $00000001FBC02EF0
Exit code: 217
```

**What Works**:
- ✅ Full build compiles successfully
- ✅ Frontend (Qt GUI) runs perfectly
- ✅ Map preview generation works
- ✅ All menus and settings functional

**What Doesn't Work**:
- ❌ Starting actual gameplay (single or multiplayer)
- ❌ Game engine (`hwengine`) initialization

**Root Cause**: Still under investigation. The crash happens at a consistent memory address very early in the engine initialization. Possible causes:

1. **Free Pascal ARM64 runtime issue**: FPC 3.2.2's ARM64 support may have bugs with certain operations
2. **Position-Independent Code (PIC)**: ARM64 requires stricter PIC compliance
3. **Function pointer initialization**: The crash address suggests dereferencing an uninitialized function pointer
4. **Rust library loading**: Despite fixing FFI signatures, there may be additional initialization issues

**For Community Contributors**: This is a challenging problem requiring deep knowledge of Free Pascal internals on ARM64. The same code works fine on x86_64 (Intel) Macs. We need ARM64-specific debugging to identify why the Pascal runtime or game initialization fails.

See `KNOWN_ISSUES.md` for detailed troubleshooting information.

Source code
-----------
Our main repository is located at <https://hg.hedgewars.org/hedgewars/> using
Mercurial as DVCS. A Git repository is also available (mirrored daily)
at <https://github.com/hedgewars/hw>.

Contribute
----------
If you see a bug or have any suggestion please use the official bug tracker at
<https://hedgewars.org/bugs> or the integrated feedback button.

If you want to help or get to know the sources better you can do that with some
easy tasks from <https://hedgewars.org/kb/TODO>. We also have an extensive API
in Lua to customize your adventures. See our wiki at
<https://hedgewars.org/kb/LuaAPI>.

If you know your way through the code feel free to send a patch or open a pull
request. The best Lua scripts get released in the official DLC page and later
integrated in the next version.

Licence and credits
-------------------
This game is free software (“free” as in “freedom”). Source code is
distributed under the terms of the GNU General Public Licence version 2;
images and sounds are distributed under the terms of the GNU Free Documentation
Licence version 1.2. See the `COPYING` file for the full text of the licenses.

Copyright 2004-2018 Andrey Korotaev <unC0Rr@gmail.com> and others.
Click on the Hedgewars logo in the main menu and read the `CREDITS` text file
for a more complete list of authors.

Contact
-------
* Homepage        - https://hedgewars.org/
* IRC channel     - irc://irc.libera.chat/hedgewars
* Community forum - https://hedgewars.org/forum

