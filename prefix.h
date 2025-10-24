// Prefix header for macOS builds - included before all source files
#ifdef __APPLE__
// Override MAC_OS_X_VERSION_MIN_REQUIRED before any system headers process it
#define MAC_OS_X_VERSION_MIN_REQUIRED 101300
#endif
