#include <assert.h>
#include <stdio.h>
#define SOLVER6_HOST_TEST
#include "../solver6.c"

/* Adapter only for tests; production passes face and turns explicitly. */
static state_t test_move(state_t state, uint8_t move) {
    state_t out;
    uint8_t face = move_face(move);
    apply_move(&state, &out, face, move_turns(move, face));
    return out;
}
static char output[256];
static unsigned output_length;
void solver6_host_putc(int c) {
    assert(output_length + 1 < sizeof(output));
    output[output_length++] = (char)c;
    output[output_length] = 0;
}
static void check(const char *input, int expected) {
    state_t state;
    int path[MAX_DEPTH];
    assert(parse_state(input, &state));
    int n = solve(&state, path);
    assert(n == expected);
    for (int i = 0; i < n; ++i) {
        assert(path[i] >= 1 && path[i] <= MOVES);
        state = test_move(state, (uint8_t)(path[i] - 1));
    }
    assert(is_solved(&state));
    output_length = 0;
    assert(solver6_run(input) == 0);
    assert(output_length && output[output_length - 1] == '\n');
}
static int reference_p[PERMUTATIONS], reference_o[ORIENTATIONS];
static void check_tables(void) {
    for (int kind = 0; kind < 2; ++kind) {
        int count = kind ? ORIENTATIONS : PERMUTATIONS;

        int distance[PERMUTATIONS], queue[PERMUTATIONS];
        for (int r = 0; r < count; ++r) {
            distance[r] = -1;
        }
        int head = 0, tail = 1;
        queue[0] = 0;
        distance[0] = 0;
        while (head < tail) {
            int r = queue[head++];
            state_t state = abstract_state(r, kind);
            for (int m = 0; m < MOVES; ++m) {
                state_t next = test_move(state, (uint8_t)m);
                int n = kind ? orientation_index(&next) : permutation_index(&next);
                if (distance[n] < 0) {
                    distance[n] = distance[r] + 1;
                    queue[tail++] = n;
                }
            }
        }
        assert(tail == count);
        for (int r = 0; r < count; ++r) {
            state_t s = abstract_state(r, kind);
            int actual = kind ? orient_dist[s.o[0]][s.o[1]][s.o[2]][s.o[3]][s.o[4]][s.o[5]]
                              : perm_dist[s.p[0]][s.p[1]][s.p[2]][s.p[3]][s.p[4]][s.p[5]];
            assert(distance[r] == actual);
            (kind ? reference_o : reference_p)[r] = distance[r];
        }
    }
    int valid_slots = 0;
    const unsigned char *bytes = (const unsigned char *)perm_dist;
    for (unsigned i = 0; i < sizeof(perm_dist); ++i)
        valid_slots += bytes[i] != UINT8_MAX;
    assert(valid_slots == PERMUTATIONS);
    for (int p = 0; p < PERMUTATIONS; ++p) {
        state_t s = abstract_state(p, 0);
        for (int o = 0; o < ORIENTATIONS; ++o) {
            state_t orientation = abstract_state(o, 1);
            int incorrect = 0;
            for (int i = 0; i < CUBIES; ++i) {
                s.o[i] = orientation.o[i];
                incorrect += s.p[i] != i || s.o[i] != 0;
            }
            int expected = (incorrect + 3) / 4;
            if (reference_p[p] > expected) expected = reference_p[p];
            if (reference_o[o] > expected) expected = reference_o[o];
            assert(heuristic(&s) == expected);
        }
    }
    puts("PASS: 5,769 BFS distances, sparse slots, all 3,674,160 heuristic values");
}
int main(void) {
    check("12345671111111", 0);
    state_t solved = abstract_state(0, 0);
    state_t short_state = test_move(solved, 0);
    char input[15];
    for (int i = 0; i < CUBIES; ++i) {
        input[i] = (char)('1' + short_state.p[i]);
        input[i + CUBIES] = (char)('1' + short_state.o[i]);
    }
    input[14] = 0;
    check(input, 1);
    check("21345671111111", 11);
    check_tables();
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

        }
    }
    puts("PASS: solved, one-move, distance-11, replay, invalid inputs, all abstract indices and table completeness");
}
