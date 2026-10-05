#include <assert.h>
#include <setjmp.h>
#include <stdio.h>
#include <string.h>
#undef memset
#define SOLVER7_HOST_TEST
#define SOLVER7_LED
#define SOLVER7_LED_LOOP
#include "../solver7.c"
static jmp_buf finished;
static state_t first[12];
static int moves[12], frames, newlines;
void solver7_host_putc(int c) { if(c=='\n')newlines++; }
void solver7_led_frame(const state_t *s,int step,int move) {
    int i=frames%12;
    assert(step==i);
    if(frames<12){first[i]=*s;moves[i]=move;}
    else {assert(!memcmp(s,&first[i],sizeof *s));assert(move==moves[i]);}
    if(i==11)assert(is_solved(s));
    if(++frames==36)longjmp(finished,1);
}
int main(void) {
    if(setjmp(finished)==0){solver7_run("21345671111111");assert(!"Replay returned instead of looping");}
    assert(frames==36 && newlines==1);
    puts("PASS: three identical 12-frame replays; solution printed once.");
}
