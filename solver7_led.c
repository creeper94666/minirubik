    /* Standalone C LED-enabled solver7 variant. Build with build_solver7_led.sh.
 * This uses the C solver; it does not include the hand-specialized assembly. */
#define SOLVER7_LED
#define SOLVER7_LED_LOOP
#include "solver7.c"
#include "cube_led.h"
#ifndef LED_MATRIX_0_BASE
#error "Define LED_MATRIX_0_BASE to the address shown by your Ripes LED Matrix."
#endif
#ifndef LED_FRAME_DELAY
#define LED_FRAME_DELAY 1000000u
#endif
static unsigned char led_pixels[LED_PIXELS];
void solver7_led_frame(const state_t *state, int step, int move) {
    unsigned char facelets[6][4];
    (void)step; (void)move;
    cube_to_facelets(state->p,state->o,facelets);
    cube_to_pixels(facelets,led_pixels);
    cube_led_write((volatile unsigned int *)(__UINTPTR_TYPE__)LED_MATRIX_0_BASE,led_pixels);
    /* Iteration count, not a wall-clock duration. Tune for GUI run speed. */
#if LED_FRAME_DELAY > 0
    for(volatile unsigned int wait=0;wait<LED_FRAME_DELAY;++wait) {}
#endif
}
