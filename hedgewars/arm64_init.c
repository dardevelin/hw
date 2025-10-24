/*
 * ARM64 FP Register Initialization for macOS
 * 
 * Forces the OS to initialize the floating-point register state by 
 * performing a dummy FP operation. This must be called BEFORE any 
 * code that might trigger AppKit to read FP registers.
 */

#include <math.h>

// Force FP registers to be initialized by the OS
void hw_init_fp_state(void) {
    // This dummy computation forces the OS to properly initialize
    // the floating-point register file, including d8-d15
    volatile double dummy = 1.0;
    dummy = sqrt(dummy) * 2.0 + sin(dummy) * cos(dummy);
    dummy = dummy + 1.0;  // Prevent optimization
}
