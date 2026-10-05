#include <assert.h>
#include <stdio.h>
#include <string.h>
#define SOLVER7_HOST_TEST
#define SOLVER7_LED
#include "../solver7.c"
#include "../cube_led.h"
static int frames;
static FILE *output;
void solver7_host_putc(int c) { (void)c; }
void solver7_led_frame(const state_t *s, int step, int move) {
    unsigned char f[6][4], pixels[LED_PIXELS];
    cube_to_facelets(s->p,s->o,f); cube_to_pixels(f,pixels);
    if(output) {
        fprintf(output,"%s{\"step\":%d,\"move\":%d,\"pixels\":[",frames?",\n":"",step,move);
        for(int i=0;i<LED_PIXELS;i++) fprintf(output,"%s%d",i?",":"",pixels[i]);
        fputs("]}",output);
    }
    if(step==11) {
        assert(is_solved(s));
        for(int face=0;face<6;face++)for(int c=0;c<4;c++)assert(f[face][c]==face+1);
    }
    frames++;
}
/* Independent geometry: xyz axes point right, up, front. Each face's
 * screen-right/screen-down basis defines its four viewed-from-outside cells. */
static const int normals[6][3]={{0,1,0},{-1,0,0},{0,0,1},{1,0,0},{0,0,-1},{0,-1,0}};
static const int right[6][3]={{1,0,0},{0,0,1},{1,0,0},{0,0,-1},{-1,0,0},{1,0,0}};
static const int down[6][3]={{0,0,1},{0,-1,0},{0,-1,0},{0,-1,0},{0,-1,0},{0,0,-1}};
static void rotate(int v[3], int axis, int sign) {
    int a=(axis+1)%3,b=(axis+2)%3,x=v[a],y=v[b];
    v[a]=-sign*y; v[b]=sign*x;
}
static void reference(const unsigned char in[6][4], unsigned char out[6][4], int move) {
    int kind=move/3, turns=move%3+1;
    int axis=kind==0?0:kind==1?2:1, side=kind==0?1:-1;
    for(int f=0;f<6;f++) for(int c=0;c<4;c++) {
        int pos[3],n[3];
        for(int k=0;k<3;k++) {
            pos[k]=normals[f][k]+(c%2?1:-1)*right[f][k]+(c/2?1:-1)*down[f][k];
            n[k]=normals[f][k];
        }
        if(pos[axis]==side) for(int t=0;t<turns;t++) {rotate(pos,axis,-side);rotate(n,axis,-side);}
        int nf=0; while(memcmp(n,normals[nf],sizeof n)) {nf++; assert(nf<6);}
        int x=0,y=0;for(int k=0;k<3;k++){x+=pos[k]*right[nf][k];y+=pos[k]*down[nf][k];}
        out[nf][(y>0?2:0)+(x>0)]=in[f][c];
    }
}
int main(int argc,char **argv) {
    state_t s={{0,1,2,3,4,5,6},{0,0,0,0,0,0,0}};
    unsigned char f[6][4], expected[6][4],actual[6][4],pixels[LED_PIXELS];
    cube_to_facelets(s.p,s.o,f);
    for(int face=0;face<6;face++)for(int c=0;c<4;c++)assert(f[face][c]==face+1);
    unsigned seed=19;
    for(int trial=0;trial<1000;trial++) {
        cube_to_facelets(s.p,s.o,f);
        for(int m=0;m<9;m++) {
            state_t next;apply_move(&s,&next,m/3,m%3+1);
            reference(f,expected,m);cube_to_facelets(next.p,next.o,actual);
            assert(!memcmp(actual,expected,24));
        }
        seed=seed*1664525u+1013904223u;int m=(int)(seed%9);
        state_t next;apply_move(&s,&next,m/3,m%3+1);s=next;
    }
    cube_to_pixels(f,pixels);
    int count[7]={0}; for(int i=0;i<LED_PIXELS;i++){assert(pixels[i]<7);count[pixels[i]]++;}
    assert(count[0]==587);for(int c=1;c<7;c++)assert(count[c]==48);
    unsigned char used[LED_PIXELS]={0};
    for(int face=0;face<6;face++)for(int c=0;c<4;c++)for(int dy=0;dy<3;dy++)for(int dx=0;dx<4;dx++) {
        unsigned a=cube_led_byte_offset(face,c,dx,dy);assert(a%4==0 && a<3500);assert(!used[a/4]++);
        assert(pixels[a/4]==f[face][c]);
    }
    unsigned int memory[LED_PIXELS+2];memory[0]=123;memory[LED_PIXELS+1]=456;
    cube_led_write(memory+1,pixels);assert(memory[0]==123 && memory[LED_PIXELS+1]==456);
    for(int i=0;i<LED_PIXELS;i++)assert(memory[i+1]==cube_led_palette[pixels[i]]);
    frames=0;assert(solver7_run("12345671111111")==0);assert(frames==1);
    frames=0;assert(solver7_run("invalid")==2);assert(frames==0);
    if(argc>1){output=fopen(argv[1],"w");assert(output);fputs("[\n",output);}
    frames=0;assert(solver7_run("21345671111111")==0);assert(frames==12);
    if(output){fputs("\n]\n",output);fclose(output);}
    puts("PASS: 9000 geometric move comparisons, 288 pixel offsets, RGB writes, solved/invalid/11-move replay.");
}
