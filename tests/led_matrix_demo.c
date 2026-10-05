/* Host-only visual smoke test: render solved, R x4, B x4, D x4.
 * No search is executed. Uses the real solver move rules and C renderer.
 * Build: cc -O2 -fno-builtin tests/led_matrix_demo.c cube_led.c -o /tmp/led_matrix_demo
 * Run: /tmp/led_matrix_demo > measurements/solver7_led/demo_frames.json
 */
#include <stdio.h>
#include <assert.h>
#define SOLVER7_HOST_TEST
#include "../solver7.c"
#include "../cube_led.h"
void solver7_host_putc(int c) { (void)c; }
static void frame(const state_t *s, int step, int move) {
    unsigned char facelets[6][4],pixels[LED_PIXELS];
    cube_to_facelets(s->p,s->o,facelets);
    cube_to_pixels(facelets,pixels);
    printf("%s{\"step\":%d,\"move\":%d,\"pixels\":[",step?",\n":"",step,move);
    for(int i=0;i<LED_PIXELS;i++)printf("%s%u",i?",":"",pixels[i]);
    printf("]}");
}
int main(void) {
    state_t s={{0,1,2,3,4,5,6},{0,0,0,0,0,0,0}};
    puts("[");frame(&s,0,0);
    for(int face=0;face<3;face++) {
        for(int turn=0;turn<4;turn++) {
            state_t next;apply_move(&s,&next,(uint8_t)face,1);s=next;
            frame(&s,face*4+turn+1,face*3+1);
        }
        assert(is_solved(&s));
    }
    puts("\n]");return 0;
}
