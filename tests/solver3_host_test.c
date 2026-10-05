#include <assert.h>
#include <stdio.h>
#define SOLVER3_HOST_TEST
#include "../solver3.c"

static char output[256];
static unsigned output_length;
void solver3_host_putc(int c) {
    assert(output_length + 1 < sizeof(output));
    output[output_length++] = (char)c;
    output[output_length] = 0;
}
static void check(const char *input, int expected) {
    state_t state;
    int path[MAX_DEPTH];
    assert(parse_state(input, &state));
    int n = solve(state, path);
    assert(n == expected);
    for (int i = 0; i < n; ++i) {
        assert(path[i] >= 1 && path[i] <= MOVES);
        state = apply_move(state, (uint8_t)(path[i] - 1));
    }
    assert(is_solved(&state));
    output_length = 0;
    assert(solver3_run(input) == 0);
    assert(output_length && output[output_length - 1] == '\n');
}
int main(void) {
    check("12345671111111", 0);
    state_t solved = abstract_state(0, 0);
    state_t short_state = apply_move(solved, 0);
    char input[15];
    for (int i = 0; i < CUBIES; ++i) {
        input[i] = (char)('1' + short_state.p[i]);
        input[i + CUBIES] = (char)('1' + short_state.o[i]);
    }
    input[14] = 0;
    check(input, 1);
    check("21345671111111", 11);
    state_t state;
    assert(!parse_state("", &state));
    assert(!parse_state("1234567111111", &state));
    assert(!parse_state("123456711111111", &state));
    assert(!parse_state("11345671111111", &state));
    assert(!parse_state("12345672111111", &state));
    for (int kind = 0; kind < 2; ++kind) {
        int count = kind ? ORIENTATIONS : PERMUTATIONS;
        for (int r = 0; r < count; ++r) {
            state_t s = abstract_state(r, kind);
            assert((kind ? orientation_index(&s) : permutation_index(&s)) == r);
            assert((kind ? orient_dist[r] : perm_dist[r]) != UINT8_MAX);
        }
    }
    puts("PASS: solved, one-move, distance-11, replay, invalid inputs, all abstract indices and table completeness");
}
