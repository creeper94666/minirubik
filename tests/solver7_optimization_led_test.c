#include <assert.h>
#include <stdio.h>
#include <string.h>
#undef memset
#define SOLVER7_HOST_TEST
#include "../solver7.c"
#include "../cube_led.h"
static unsigned int framebuffer[LED_PIXELS];
static void capture(volatile unsigned int *,const unsigned char *);
#define LED_MATRIX_0_BASE framebuffer
#define LED_FRAME_DELAY 0
#define LED_REPLAY_CYCLES 2
#define cube_led_write capture
#include "../solver7_led_replay.c"
#undef cube_led_write
static state_t expected[12];
static unsigned frames;
void solver7_host_putc(int c){(void)c;}
static void capture(volatile unsigned int *base,const unsigned char *pixels){
 unsigned char f[6][4],reference[LED_PIXELS];
 const state_t *s=&expected[frames%12];
 cube_to_facelets(s->p,s->o,f);cube_to_pixels(f,reference);
 assert(!memcmp(reference,pixels,LED_PIXELS));
 cube_led_write(base,pixels);
 for(int i=0;i<LED_PIXELS;i++)assert(base[i]==cube_led_palette[reference[i]]);
 frames++;
}
int main(void){
 state_t start;int solution[11];assert(parse_state("21345671111111",&start));
 int n=solve(&start,solution);assert(n==11);expected[0]=start;
 for(int i=0;i<n;i++){int m=solution[i]-1;unsigned char f=move_face(m);apply_move(&expected[i],&expected[i+1],f,move_turns(m,f));}
 assert(is_solved(&expected[11]));
 replay_state initial;for(int i=0;i<7;i++){initial.p[i]=start.p[i];initial.o[i]=start.o[i];}
 led_replay(&initial,solution,n);
 assert(frames==24 && led_replay_round==2 && led_replay_step==11);
 puts("PASS: 24 replay frames and RGB writes match original apply_move reference.");
}
