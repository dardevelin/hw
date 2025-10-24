// SDL Compatibility fix for macOS deployment target
// This file is force-included via -include compiler flag
#ifdef __APPLE__
#include <Availability.h>
// Ensure MAC_OS_X_VERSION_MIN_REQUIRED is at least 10.7 to satisfy SDL
#if defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_7
#undef MAC_OS_X_VERSION_MIN_REQUIRED
#define MAC_OS_X_VERSION_MIN_REQUIRED MAC_OS_X_VERSION_10_13
#endif
#endif
