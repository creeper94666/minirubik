#include "cube_led.h"
const unsigned int cube_led_palette[7]={0x000000,0xffffff,0xff8000,0x00ff00,0xff0000,0x0000ff,0xffff00};
const unsigned char cube_led_origins[6][2]={{9,2},{0,9},{9,9},{18,9},{27,9},{9,16}};
/* Slots 0..6: UFR, DFR, DFL, UBR, DBR, DBL, UBL; slot 7: fixed UFL.
 * Sticker order is handed consistently. Slot k receives cubie sticker
 * (k + orientation) mod 3, matching solver7's R/B twist convention. */
static const unsigned char corner_faces[8][3]={
    {CUBE_U,CUBE_R,CUBE_F},{CUBE_D,CUBE_F,CUBE_R},
    {CUBE_D,CUBE_L,CUBE_F},{CUBE_U,CUBE_B,CUBE_R},
    {CUBE_D,CUBE_R,CUBE_B},{CUBE_D,CUBE_B,CUBE_L},
    {CUBE_U,CUBE_L,CUBE_B},{CUBE_U,CUBE_F,CUBE_L}
};
static const unsigned char corner_cells[8][3]={
    {3,0,1},{1,3,2},{0,3,2},{1,0,1},
    {3,3,2},{2,3,2},{0,0,1},{2,0,1}
};
void cube_to_facelets(const unsigned char p[7],const unsigned char o[7],unsigned char out[6][4]) {
    for(unsigned slot=0;slot<8;slot++) {
        unsigned cubie=slot==7?7:p[slot], twist=slot==7?0:o[slot];
        for(unsigned k=0;k<3;k++) {
            unsigned sticker=k+twist;if(sticker>=3)sticker-=3;
            out[corner_faces[slot][k]][corner_cells[slot][k]]=corner_faces[cubie][sticker]+1;
        }
    }
}
unsigned int cube_led_byte_offset(unsigned face,unsigned cell,unsigned dx,unsigned dy) {
    unsigned x=cube_led_origins[face][0]+(cell&1)*4+dx;
    unsigned y=cube_led_origins[face][1]+(cell>>1)*3+dy;
    return 4*(y*LED_WIDTH+x);
}
void cube_to_pixels(const unsigned char f[6][4],unsigned char pixels[LED_PIXELS]) {
    for(unsigned i=0;i<LED_PIXELS;i++)pixels[i]=COLOR_OFF;
    for(unsigned face=0;face<6;face++)for(unsigned cell=0;cell<4;cell++)
        for(unsigned dy=0;dy<3;dy++)for(unsigned dx=0;dx<4;dx++)
            pixels[cube_led_byte_offset(face,cell,dx,dy)>>2]=f[face][cell];
}
void cube_led_write(volatile unsigned int *base,const unsigned char pixels[LED_PIXELS]) {
    for(unsigned i=0;i<LED_PIXELS;i++)base[i]=cube_led_palette[pixels[i]];
}
