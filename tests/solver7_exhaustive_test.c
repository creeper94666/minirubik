#include <errno.h>
#include <time.h>

/* Prefix the reference symbols so both implementations can coexist. */
#define CUBIES ref_CUBIES
#define PERMUTATIONS ref_PERMUTATIONS
#define ORIENTATIONS ref_ORIENTATIONS
#define STATES ref_STATES
#define MOVES ref_MOVES
#define state_t ref_state_t
#define move_names ref_move_names
#define inverse_move ref_inverse_move
#define source ref_source
#define twist ref_twist
#define quarter_turn ref_quarter_turn
#define apply_move ref_apply_move
#define rank_state ref_rank_state
#define unrank_state ref_unrank_state
#define valid ref_valid
#define build_table ref_build_table
#define parse_state ref_parse_state
#define output_failed ref_output_failed
#define self_test ref_self_test
#define main ref_main
#include "../solver.c"
#undef CUBIES
#undef PERMUTATIONS
#undef ORIENTATIONS
#undef STATES
#undef MOVES
#undef state_t
#undef move_names
#undef inverse_move
#undef source
#undef twist
#undef quarter_turn
#undef apply_move
#undef rank_state
#undef unrank_state
#undef valid
#undef build_table
#undef parse_state
#undef output_failed
#undef self_test
#undef main

#include <assert.h>
#include <limits.h>
#include <sys/stat.h>
#undef UINT8_MAX
#define SOLVER7_HOST_TEST
#undef memset
#define memset solver7_private_memset
#ifndef SOLVER7_VALIDATION_SOURCE
#define SOLVER7_VALIDATION_SOURCE "../solver7.c"
#endif
#include SOLVER7_VALIDATION_SOURCE
#ifndef SOLVER7_VALIDATION_HEURISTIC
#define SOLVER7_VALIDATION_HEURISTIC(state) heuristic(state)
#endif
#undef memset
void solver7_host_putc(int c) { (void)c; }

static double now_seconds(void) {
    struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}
static void require(int good, const char *message) {
    if (!good) { fprintf(stderr, "FAIL: %s\n", message); exit(1); }
}
static void input_string(const ref_state_t *s, char out[15]) {
    for (int i=0;i<7;i++) { out[i]='1'+s->p[i];out[i+7]='1'+s->o[i]; } out[14]=0;
}
static state_t convert(const ref_state_t *s) {
    state_t v; for(int i=0;i<7;i++){v.p[i]=s->p[i];v.o[i]=s->o[i];} return v;
}
static uint16_t pt[5040][9], ot[729][9];
static void transitions(void) {
    for(int kind=0;kind<2;kind++) {
        int n=kind?729:5040;
        for(int r=0;r<n;r++) {
            ref_state_t s;ref_unrank_state(kind?r:r*729,&s);
            for(int m=0;m<9;m++) {
                ref_state_t v=ref_apply_move(s,m);
                unsigned rank=ref_rank_state(&v);
                if(kind)ot[r][m]=rank%729;else pt[r][m]=rank/729;
                state_t a=convert(&s),b;apply_move(&a,&b,m/3,m%3+1);
                require(memcmp(b.p,v.p,7)==0 && memcmp(b.o,v.o,7)==0,"H2 move composition differs from upstream");
            }
        }
    }
}
static uint8_t *oracle(const char *dir) {
    double t=now_seconds(); transitions();
    uint8_t *d=malloc(ref_STATES); uint32_t *q=malloc(sizeof(*q)*ref_STATES);
    require(d && q,"oracle allocation");memset(d,255,ref_STATES);d[0]=0;q[0]=0;
    unsigned head=0,tail=1,hist[12]={0};
    while(head<tail){unsigned r=q[head++],p=r/729,o=r%729;
        require(d[r]<=11,"oracle diameter exceeds 11");hist[d[r]]++;
        for(int m=0;m<9;m++){unsigned n=pt[p][m]*729U+ot[o][m];
            if(d[n]==255){d[n]=d[r]+1;q[tail++]=n;}}
    }
    require(tail==ref_STATES && hist[11]==2644,"oracle coverage or distance-11 count");
    free(q); double bfs_time=now_seconds()-t;
    uint8_t pd[5040],od[729];memset(pd,255,sizeof pd);memset(od,255,sizeof od);
    char path[1024];snprintf(path,sizeof path,"%s/distance11.csv",dir);FILE *csv=fopen(path,"w");require(csv!=NULL,"open distance11");
    fprintf(csv,"rank,input,exact_distance\n");
    t=now_seconds(); unsigned hmax=0;
    for(unsigned r=0;r<ref_STATES;r++){
        ref_state_t s;ref_unrank_state(r,&s);require(ref_valid(&s)&&ref_rank_state(&s)==r,"oracle rank roundtrip");
        state_t a=convert(&s);int h=SOLVER7_VALIDATION_HEURISTIC(&a);
#ifdef VALIDATION_INJECT_BAD_HEURISTIC
        if(r==0)h=1;
#endif
        if(h<0 || h>d[r]){char in[15];input_string(&s,in);fprintf(stderr,"FAIL H1 rank=%u input=%s h=%d exact=%u\n",r,in,h,d[r]);exit(1);}
        if((unsigned)h>hmax)hmax=h;
        if(d[r]<pd[r/729])pd[r/729]=d[r];if(d[r]<od[r%729])od[r%729]=d[r];
        if(d[r]==11){char in[15];input_string(&s,in);fprintf(csv,"%u,%s,11\n",r,in);}
    }
    require(fclose(csv)==0,"write distance11");double h1_time=now_seconds()-t;
    t=now_seconds();unsigned pmax=0,omax=0,occupied=0;uint8_t used[117649]={0};
    for(unsigned p=0;p<5040;p++){
        ref_state_t s;ref_unrank_state(p*729,&s);unsigned i=0;for(int j=0;j<6;j++)i=i*7+s.p[j];
        require(!used[i],"H2 duplicate permutation slot");used[i]=1;
        unsigned v=((const uint8_t*)perm_dist)[i];
#ifdef VALIDATION_INJECT_BAD_TABLE
        if(p==0)v=1;
#endif
        require(v==pd[p],"H2 permutation value differs from projected BFS");if(v>pmax)pmax=v;
    }
    for(unsigned i=0;i<sizeof perm_dist;i++){
        unsigned v=((const uint8_t*)perm_dist)[i];
        require(used[i] ? v!=255 : v==255,"H2 invalid sparse slot");occupied+=v!=255;
    }
    for(unsigned o=0;o<729;o++){
        require(((const uint8_t*)orient_dist)[o]==od[o],"H2 orientation differs from projected BFS");if(od[o]>omax)omax=od[o];
    }
    require(pd[0]==0 && od[0]==0 && occupied==5040,"H2 solved entries and occupancy");
    double h2_time=now_seconds()-t;
    snprintf(path,sizeof path,"%s/oracle.bin",dir);FILE *out=fopen(path,"wb");require(out!=NULL,"oracle file");require(fwrite(d,1,ref_STATES,out)==ref_STATES,"write oracle");require(fclose(out)==0,"close oracle");
    snprintf(path,sizeof path,"%s/oracle-summary.json",dir);out=fopen(path,"w");require(out!=NULL,"summary file");
    fprintf(out,"{\"states\":%u,\"diameter\":11,\"distance11_count\":2644,\"H1\":\"PASS\",\"H2\":\"PASS\",\"heuristic_max\":%u,\"permutation_max\":%u,\"orientation_max\":%u,\"permutation_legal_slots\":5040,\"permutation_unused_slots\":112609,\"move_comparisons\":51921,\"bfs_seconds\":%.9f,\"h1_seconds\":%.9f,\"h2_seconds\":%.9f,\"histogram\":[",ref_STATES,hmax,pmax,omax,bfs_time,h1_time,h2_time);
    for(int i=0;i<12;i++)fprintf(out,"%s%u",i?",":"",hist[i]);fprintf(out,"]}\n");require(fclose(out)==0,"summary close");
    printf("PASS H1 all %u states; H2 maxima p=%u o=%u; BFS %.6fs H1 %.6fs H2 %.6fs\n",ref_STATES,pmax,omax,bfs_time,h1_time,h2_time);fflush(stdout);return d;
}
static unsigned number(const char *s){char *end;errno=0;unsigned long n=strtoul(s,&end,10);require(*s && !*end && !errno && n<=ref_STATES,"bad number");return n;}
int main(int argc,char **argv){
    if(argc==3 && !strcmp(argv[1],"oracle")){free(oracle(argv[2]));return 0;}
    if(argc!=6 || strcmp(argv[1],"search")){fprintf(stderr,"usage: %s oracle DIR | search ORACLE START COUNT CSV\n",argv[0]);return 2;}
    unsigned start=number(argv[3]),count=number(argv[4]);require(count && start<ref_STATES && count<=ref_STATES-start,"invalid search range");
    uint8_t *d=malloc(ref_STATES);require(d!=NULL,"distance allocation");FILE *in=fopen(argv[2],"rb");require(in!=NULL,"open oracle");require(fread(d,1,ref_STATES,in)==ref_STATES && fgetc(in)==EOF,"oracle length");fclose(in);
    FILE *out=fopen(argv[5],"w");require(out!=NULL,"open result CSV");fprintf(out,"rank,exact_distance,returned_length,path\n");
    double t=now_seconds();
    for(unsigned r=start;r<start+count;r++){
        ref_state_t s;ref_unrank_state(r,&s);state_t a=convert(&s);int path[11];for(int k=0;k<11;k++)path[k]=-1;
        int n=solve(&a,path);
#ifdef VALIDATION_INJECT_BAD_LENGTH
        if(r==start)n=12;
#endif
        if(n!=d[r]){char text[15];input_string(&s,text);fprintf(stderr,"FAIL H3 rank=%u input=%s expected=%u got=%d\n",r,text,d[r],n);return 1;}
        ref_state_t replay=s;
        fprintf(out,"%u,%u,%d,",r,d[r],n);
        for(int k=0;k<n;k++){require(path[k]>=1 && path[k]<=9,"H3 invalid move");replay=ref_apply_move(replay,path[k]-1);fprintf(out,"%d",path[k]);}
        require(ref_rank_state(&replay)==0,"H3 independent replay");fputc('\n',out);
        unsigned done=r-start+1;
        if(done%10000==0 || done==count){printf("PASS through rank %u; %u/%u; elapsed %.6f seconds\n",r,done,count,now_seconds()-t);fflush(stdout);require(fflush(out)==0,"flush results");}
    }
    double elapsed=now_seconds()-t;require(fclose(out)==0,"close results");free(d);
    printf("RESULT {\"H3\":\"PASS\",\"replay\":\"PASS\",\"start\":%u,\"count\":%u,\"wall_seconds\":%.9f}\n",start,count,elapsed);return 0;
}
