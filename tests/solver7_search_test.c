#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static struct { unsigned long long candidates, bounds, inverse, sequences; } counts;
#define SOLVER7_SEARCH_COUNT(kind) (++counts.kind)
#define SOLVER7_HOST_TEST
#undef memset
#define memset solver7_private_memset
#include "../solver7_search.c"
#undef memset
void solver7_host_putc(int c) { (void)c; }

static void check(const char *input, int exact, unsigned long long ceiling)
{
    state_t state;
    assert(parse_state(input, &state));
    counts.candidates=counts.bounds=counts.inverse=counts.sequences=0;
    int path[11], n=solve(&state,path);
    assert(n==exact);
    for(int i=0;i<n;i++) {
        state_t next;int m=path[i]-1;
        assert(m>=0 && m<9);
        apply_move(&state,&next,m/3,m%3+1);state=next;
    }
    assert(is_solved(&state));
    printf("%s length=%d candidates=%llu bounds=%llu inverse=%llu\n",
           input,n,counts.candidates,counts.bounds,counts.inverse);
    fflush(stdout);
    assert(counts.candidates < ceiling);
}
int main(void)
{
    check("12345671111111",0,1);
    state_t solved=abstract_state(0,0);
    assert(permutation_index(&solved)==0 && orientation_index(&solved)==0);
    for(int m=0;m<9;m++) {
        state_t next;char input[15];
        apply_move(&solved,&next,m/3,m%3+1);
        for(int i=0;i<7;i++){input[i]='1'+next.p[i];input[i+7]='1'+next.o[i];}
        input[14]=0;check(input,1,10);
    }
    /* Both hard cases must generate at least 20% fewer candidates. */
    check("21345671111111",11,233961ULL*80/100);
    check("54721631111111",11,639792ULL*80/100);
    puts("PASS: solved, all one-move states, hard cases, replay and candidate reduction.");
    return 0;
}
