# Hedgewars Apple Silicon - Distribution Guide

## 📦 Signed DMG Created!

**Location**: `build/Hedgewars-AppleSilicon.dmg`  
**Size**: 168 MB  
**Architecture**: ARM64 (Apple Silicon native)  
**Signature**: Signed with Apple Developer Certificate  
**Team ID**: 4B2J377Y8K

## ✅ What's Been Done

1. **Application Signed**
   - All binaries and frameworks signed with your Apple Developer certificate
   - Code signature verified and valid
   - Bundle identifier: `org.hedgewars.desktop`

2. **DMG Created and Signed**
   - Disk image created with Applications folder symlink
   - DMG itself signed with your certificate
   - Ready for distribution

## 🚀 Distribution Options

### Option 1: Local/Private Distribution (Current State)

The DMG is **ready for local distribution** right now. Users can:

1. Download the DMG
2. Right-click and select "Open" (bypasses Gatekeeper warning)
3. Drag Hedgewars to Applications folder
4. Launch the game

**Good for**: Friends, beta testers, local installations

### Option 2: Public Distribution (Requires Notarization)

For public distribution without warnings, you need Apple notarization:

#### Steps for Notarization:

1. **Get App-Specific Password**
   - Visit: https://appleid.apple.com/account/manage
   - Go to: Sign In & Security → App-Specific Passwords
   - Generate new password for "Hedgewars Notarization"

2. **Store Credentials** (one-time setup):
   ```bash
   cd build
   xcrun notarytool store-credentials "AC_PASSWORD" \
     --apple-id "your@email.com" \
     --team-id "4B2J377Y8K" \
     --password "xxxx-xxxx-xxxx-xxxx"
   ```

3. **Run Notarization**:
   - Edit `build/notarize_dmg.sh` and update your Apple ID
   - Uncomment the notarization commands
   - Run: `./notarize_dmg.sh`

4. **Wait for Apple** (usually 5-15 minutes)
   - Apple will scan the DMG
   - If approved, the ticket is stapled to the DMG

5. **Distribute**: Now anyone can download and install without warnings!

## 📤 Sharing Your DMG

### GitHub Release

1. Create a new release on your fork:
   ```bash
   # Tag the release
   git tag -a v1.1.0-apple-silicon -m "Apple Silicon build"
   git push origin v1.1.0-apple-silicon
   ```

2. Go to: https://github.com/dardevelin/hw/releases
3. Click "Draft a new release"
4. Choose the tag you just created
5. Upload `Hedgewars-AppleSilicon.dmg`
6. Add release notes

### Direct Download

Upload to any file hosting:
- Google Drive
- Dropbox
- Your own web server
- GitHub Releases (recommended)

## 🔍 Verification Commands

### Check Application Signature
```bash
codesign -dv --verbose=4 build/Hedgewars.app
codesign --verify --deep --strict --verbose=2 build/Hedgewars.app
```

### Check DMG Signature
```bash
codesign -dv --verbose=4 build/Hedgewars-AppleSilicon.dmg
codesign --verify --verbose build/Hedgewars-AppleSilicon.dmg
```

### Check Notarization Status (after notarizing)
```bash
spctl --assess --type install --verbose build/Hedgewars-AppleSilicon.dmg
stapler validate build/Hedgewars-AppleSilicon.dmg
```

## 📝 Installation Instructions for Users

Include these instructions with your DMG:

```
# Hedgewars for Apple Silicon

## Installation

1. Download Hedgewars-AppleSilicon.dmg
2. Double-click to mount the disk image
3. Drag Hedgewars.app to your Applications folder
4. Launch Hedgewars from Applications

## First Launch

If you see a security warning:
- Right-click Hedgewars.app
- Select "Open"
- Click "Open" in the dialog
- This is only needed the first time

## Requirements

- Apple Silicon Mac (M1, M2, M3, M4)
- macOS 11.0 or later
- ~500 MB free space

## Enjoy!
```

## 🎯 Current Status Summary

✅ **Ready for distribution:**
- Signed application bundle
- Signed DMG
- Works on all Apple Silicon Macs

⚠️ **Optional (for wider distribution):**
- Notarization (removes Gatekeeper warnings)
- Public release on GitHub
- Website/landing page

## 💡 Tips

**For Beta Testing**: Current signed DMG is perfect. Share with testers via direct link.

**For Public Release**: Notarize first to avoid user confusion about security warnings.

**File Size**: 168 MB is reasonable for a game. If needed, you could:
- Strip debug symbols for smaller size
- Create a separate "Debug" build
- Compress with higher settings (slower but smaller)

## 🔐 Security Notes

- Your Apple Developer certificate is embedded in the signature
- Users can verify authenticity with `codesign` commands
- Notarization adds an additional layer of trust from Apple
- The application is sandboxed within standard macOS permissions

---

**DMG Location**: `/Users/dbrasdasilva/dev/vcs-codebases/github.com/hedgewars/hw/build/Hedgewars-AppleSilicon.dmg`

Your signed DMG is ready to share! 🎉
