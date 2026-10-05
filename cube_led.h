#ifndef CUBE_LED_H
#define CUBE_LED_H
/* No library headers required by the freestanding target. */
enum { LED_WIDTH=35, LED_HEIGHT=25, LED_PIXELS=875 };
/* Face enums must start at zero, independently of dimensions. */
enum { CUBE_U=0, CUBE_L, CUBE_F, CUBE_R, CUBE_B, CUBE_D };
enum { COLOR_OFF=0, COLOR_WHITE, COLOR_ORANGE, COLOR_GREEN,
       COLOR_RED, COLOR_BLUE, COLOR_YELLOW };
extern const unsigned int cube_led_palette[7];
extern const unsigned char cube_led_origins[6][2];
void cube_to_facelets(const unsigned char p[7], const unsigned char o[7],
                      unsigned char out[6][4]);
void cube_to_pixels(const unsigned char facelets[6][4], unsigned char pixels[LED_PIXELS]);
unsigned int cube_led_byte_offset(unsigned int face, unsigned int cell,
                                  unsigned int dx, unsigned int dy);
void cube_led_write(volatile unsigned int *base, const unsigned char pixels[LED_PIXELS]);
#endif
