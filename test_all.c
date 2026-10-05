/* Host-only exhaustive verification; NOT part of the RV32I solver.
 * Build: cc -std=c11 -O2 -Wall -Wextra -Werror test_all.c -o /tmp/test_all
 * Full run: /tmp/test_all
 * Range:    /tmp/test_all START COUNT
 * Ranks in [START, START + COUNT) are tested; default is every state.
 * A range PASS is NOT a full H1/H3 PASS. Retain logs for all ranges.
 * BFS allocations belong to the host reference only. Both solver source
 * files are included unchanged; compile ONLY this test file.
 */
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
#include "solver.c"
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

#define main solver2_cli_main
#include "solver2.c"
#undef main

static int read_number(const char *text, uint32_t *value)
{
    if (!*text)
        return 0;
    for (const char *p = text; *p; ++p)
        if (*p < '0' || *p > '9')
            return 0;
    errno = 0;
    char *end;
    unsigned long number = strtoul(text, &end, 10);
    if (errno || *end || number > ref_STATES)
        return 0;
    *value = (uint32_t)number;
    return 1;
}

static void print_input(FILE *out, const ref_state_t *state)
{
    for (int i = 0; i < ref_CUBIES; ++i)
        fprintf(out, "%u", (unsigned)state->p[i] + 1U);
    for (int i = 0; i < ref_CUBIES; ++i)
        fprintf(out, "%u", (unsigned)state->o[i] + 1U);
}

/* The reference table stores moves toward solved, not distances.
 * Following that BFS tree yields its exact shortest distance.
 */
static int exact_distance(ref_state_t state, const uint8_t *table)
{
    for (int distance = 0; distance <= MAX_DEPTH; ++distance) {
        uint32_t rank = ref_rank_state(&state);
        if (rank == 0)
            return distance;
        if (table[rank] >= ref_MOVES)
            return -1;
        state = ref_apply_move(state, table[rank]);
    }
    return -1;
}

static int check_table(const char *name, const uint8_t *table, int size)
{
    if (table[0] != 0) {
        fprintf(stderr, "FAIL H2: %s solved entry is not zero\n", name);
        return 0;
    }
    unsigned maximum = 0;
    for (int i = 0; i < size; ++i) {
        if (table[i] == UINT8_MAX || (i != 0 && table[i] == 0) ||
            table[i] > MAX_DEPTH) {
            fprintf(stderr, "FAIL H2: %s[%d]=%u\n", name, i, table[i]);
            return 0;
        }
        if (table[i] > maximum)
            maximum = table[i];
    }
    printf("PASS H2: %s, %d entries, solved=0, maximum=%u\n",
           name, size, maximum);
    return 1;
}

static int failure(const char *reason, uint32_t rank,
                   const ref_state_t *start, int h, int exact, int length)
{
    fprintf(stderr, "FAIL %s: rank=%u input=", reason, rank);
    print_input(stderr, start);
    fprintf(stderr, " h=%d exact=%d returned=%d\n", h, exact, length);
    return 1;
}

int main(int argc, char **argv)
{
    uint32_t begin = 0, count = ref_STATES;
    if (argc != 1 && (argc != 3 || !read_number(argv[1], &begin) ||
                      !read_number(argv[2], &count))) {
        fprintf(stderr, "usage: %s [START COUNT]\n", argv[0]);
        return 2;
    }
    if (begin >= ref_STATES || count == 0 || count > ref_STATES - begin) {
        fputs("invalid range: require 0 <= START < 3674160 and "
              "1 <= COUNT <= 3674160 - START\n", stderr);
        return 2;
    }
    uint32_t end = begin + count;
    printf("Testing ranks [%u, %u), %u states. Building reference BFS once...\n",
           begin, end, count);
    fflush(stdout);
    uint8_t diameter = 0;
    uint8_t *table = ref_build_table(&diameter);
    if (!table || diameter != MAX_DEPTH) {
        fprintf(stderr, "FAIL reference table: diameter=%u\n", diameter);
        free(table);
        return 1;
    }
    init_heuristic();
    if (!check_table("permutation", perm_dist, PERMUTATIONS) ||
        !check_table("orientation", orient_dist, ORIENTATIONS)) {
        free(table);
        return 1;
    }
    puts("Starting H1, H3 and independent reference-move replay...");
    fflush(stdout);
    uint32_t histogram[MAX_DEPTH + 1] = {0};
    int status = 0;
    time_t started = time(NULL);
    for (uint32_t rank = begin; rank < end; ++rank) {
        ref_state_t reference;
        ref_unrank_state(rank, &reference);
        if (!ref_valid(&reference) || ref_rank_state(&reference) != rank) {
            status = failure("reference rank round-trip", rank, &reference,
                             -1, -1, -1);
            break;
        }
        state_t start;
        for (int i = 0; i < CUBIES; ++i) {
            start.p[i] = reference.p[i];
            start.o[i] = reference.o[i];
        }
        int exact = exact_distance(reference, table);
        int h = heuristic(&start);
        if (exact < 0 || h < 0 || h > exact) {
            status = failure("H1/reference distance", rank, &reference,
                             h, exact, -1);
            break;
        }
        int solution[MAX_DEPTH];
        for (int i = 0; i < MAX_DEPTH; ++i)
            solution[i] = -1;
        int length = solve(start, solution);
        if (length != exact) {
            status = failure("H3 shortest length", rank, &reference,
                             h, exact, length);
            break;
        }
        ref_state_t replay = reference;
        for (int i = 0; i < length; ++i) {
            if (solution[i] < 1 || solution[i] > MOVES) {
                status = failure("invalid move", rank, &reference,
                                 h, exact, length);
                break;
            }
            replay = ref_apply_move(replay, (uint8_t)(solution[i] - 1));
        }
        if (status)
            break;
        if (ref_rank_state(&replay) != 0) {
            status = failure("solution replay", rank, &reference,
                             h, exact, length);
            break;
        }
        ++histogram[length];
        uint32_t done = rank - begin + 1;
        if (done % 10000U == 0 || done == count) {
            printf("PASS through rank %u: %u/%u; elapsed %.0f s; next rank %u\n",
                   rank, done, count, difftime(time(NULL), started), rank + 1);
            fflush(stdout);
        }
    }
    free(table);
    if (status)
        return status;
    for (int i = 0; i <= MAX_DEPTH; ++i)
        if (histogram[i])
            printf("distance %d: %u states\n", i, histogram[i]);
    printf("PASS %s: H1 + H3 + replay, %u states in [%u, %u).\n",
           begin == 0 && count == ref_STATES ? "FULL" : "RANGE ONLY",
           count, begin, end);
    return fflush(stdout) != 0 || ferror(stdout);
}
