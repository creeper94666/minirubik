/* LED replay linked to the original optimized search assembly.
 * Called only after the optimized solver validates its computed solution. */
#include "cube_led.h"
#ifndef LED_MATRIX_0_BASE
#error "Supply LED_MATRIX_0_BASE at build time"
#endif
#ifndef LED_FRAME_DELAY
#define LED_FRAME_DELAY 10000u
#endif
#ifndef LED_REPLAY_CYCLES
#define LED_REPLAY_CYCLES 0 /* zero = loop forever */
#endif
typedef struct { unsigned char p[7],o[7]; } replay_state;
static const unsigned char replay_source[3][7]={
 {1,4,2,0,3,5,6},{0,1,2,4,5,6,3},{0,2,5,3,1,4,6}};
static const unsigned char replay_twist[3][7]={
 {1,2,0,2,1,0,0},{0,0,0,1,2,1,2},{0,0,0,0,0,0,0}};
static unsigned char replay_pixels[LED_PIXELS];
volatile unsigned int led_replay_step,led_replay_round;
static void draw(const replay_state *s) {
 unsigned char f[6][4];
 cube_to_facelets(s->p,s->o,f);cube_to_pixels(f,replay_pixels);
 cube_led_write((volatile unsigned int *)(__UINTPTR_TYPE__)LED_MATRIX_0_BASE,replay_pixels);
#if LED_FRAME_DELAY > 0
 for(volatile unsigned int wait=0;wait<LED_FRAME_DELAY;wait++){}
#endif
}
void led_replay(const replay_state *start,const int *solution,int length) {
 led_replay_round=0;
 do {
  replay_state current,next;
  for(int i=0;i<7;i++){current.p[i]=start->p[i];current.o[i]=start->o[i];}
  led_replay_step=0;draw(&current);
  for(int step=0;step<length;step++) {
   int m=solution[step]-1,face=m<3?0:m<6?1:2,turns=m-face*3+1;
   for(int t=0;t<turns;t++) {
    for(int i=0;i<7;i++) {
     int j=replay_source[face][i],o=current.o[j]+replay_twist[face][i];
     next.p[i]=current.p[j];next.o[i]=(unsigned char)(o>=3?o-3:o);
    }
    for(int i=0;i<7;i++){current.p[i]=next.p[i];current.o[i]=next.o[i];}
   }
   led_replay_step=(unsigned int)(step+1);draw(&current);
  }
  led_replay_round++;
#if LED_REPLAY_CYCLES == 0
 } while(1);
#else
 } while(led_replay_round<LED_REPLAY_CYCLES);
#endif
}
