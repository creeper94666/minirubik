#include <stdint.h>
#include <stdio.h>
#include <string.h>

enum { CUBIES = 7, MOVES = 9, MAX_DEPTH = 11,
       PERMUTATIONS = 5040, ORIENTATIONS = 729 };

/* Same fixed-corner representation and turning rules as solver.c. */
typedef struct {
    uint8_t p[CUBIES], o[CUBIES];
} state_t;

static const char *const move_names[MOVES] = {
    "R", "R2", "R'", "B", "B2", "B'", "D", "D2", "D'"
};
static const uint8_t source[3][CUBIES] = {
    {1, 4, 2, 0, 3, 5, 6},
    {0, 1, 2, 4, 5, 6, 3},
    {0, 2, 5, 3, 1, 4, 6}
};
static const uint8_t twist[3][CUBIES] = {
    {1, 2, 0, 2, 1, 0, 0},
    {0, 0, 0, 1, 2, 1, 2},
    {0, 0, 0, 0, 0, 0, 0}
};

static state_t quarter_turn(state_t state, uint8_t face)
{
    state_t result;
    for (int i = 0; i < CUBIES; ++i) {
        uint8_t from = source[face][i];
        result.p[i] = state.p[from];
        int orientation = state.o[from] + twist[face][i];
        /* Both terms are 0..2, so the sum is at most 4. */
        if (orientation >= 3)
            orientation -= 3;
        result.o[i] = (uint8_t)orientation;
    }
    return result;
}

/* Decode a 0..8 move: R=0..2, B=3..5, D=6..8. */
static uint8_t move_face(uint8_t move)
{
    return (uint8_t)(move < 3 ? 0 : (move < 6 ? 1 : 2));
}

/* This function takes 0..8; the search records moves as 1..9. */
static state_t apply_move(state_t state, uint8_t move)
{
    uint8_t face = move_face(move);
    uint8_t turns = (uint8_t)(move + 1U);
    if (face == 2)
        turns = (uint8_t)(turns - 6U);
    else if (face == 1)
        turns = (uint8_t)(turns - 3U);
    for (uint8_t i = 0; i < turns; ++i)
        state = quarter_turn(state, face);
    return state;
}

static int is_solved(const state_t *state)
{
    for (int i = 0; i < CUBIES; ++i)
        if (state->p[i] != i || state->o[i] != 0)
            return 0;
    return 1;
}

/* Two abstract distance tables: 5769 bytes, not a full cube table. */
static uint8_t perm_dist[PERMUTATIONS];
static uint8_t orient_dist[ORIENTATIONS];
static int heuristic_ready;

/* Lehmer code: map the seven-corner permutation to 0..5039. */
static int permutation_index(const state_t *state)
{
    int rank = 0;
    for (int i = 0; i < CUBIES; ++i) {
        int smaller = 0;
        for (int j = i + 1; j < CUBIES; ++j)
            if (state->p[j] < state->p[i])
                ++smaller;
        /* Multiply by the remaining radix using RV32I shifts and adds. */
        switch (CUBIES - i) {
        case 7: rank = (rank << 2) + (rank << 1) + rank; break;
        case 6: rank = (rank << 2) + (rank << 1); break;
        case 5: rank = (rank << 2) + rank; break;
        case 4: rank <<= 2; break;
        case 3: rank = (rank << 1) + rank; break;
        case 2: rank <<= 1; break;
        case 1: break;
        }
        rank += smaller;
    }
    return rank;
}

/* The seventh orientation follows from the sum-modulo-three invariant. */
static int orientation_index(const state_t *state)
{
    int rank = 0;
    for (int i = 0; i < CUBIES - 1; ++i)
        rank = (rank << 1) + rank + state->o[i];
    return rank;
}

/* Decode one abstraction; the ignored component can start solved. */
static state_t abstract_state(int rank, int orientation_only)
{
    state_t state = {{0, 1, 2, 3, 4, 5, 6}, {0}};
    if (orientation_only) {
        static const int weight[] = {243, 81, 27, 9, 3, 1};
        int sum = 0;
        /* Decode from the highest ternary digit; at most two subtractions. */
        for (int i = 0; i < CUBIES - 1; ++i) {
            while (rank >= weight[i]) {
                rank -= weight[i];
                ++state.o[i];
            }
            sum += state.o[i];
        }
        while (sum >= 3)
            sum -= 3;
        state.o[CUBIES - 1] = (uint8_t)(sum == 0 ? 0 : 3 - sum);
    } else {
        static const int factorial[] = {720, 120, 24, 6, 2, 1, 1};
        uint8_t available[CUBIES] = {0, 1, 2, 3, 4, 5, 6};
        for (int i = 0; i < CUBIES; ++i) {
            int chosen = 0;
            /* Quotient selects a remaining cubie; rank retains the remainder. */
            while (rank >= factorial[i]) {
                rank -= factorial[i];
                ++chosen;
            }
            state.p[i] = available[chosen];
            for (int j = chosen; j < CUBIES - i - 1; ++j)
                available[j] = available[j + 1];
        }
    }
    return state;
}

/* Repeated edge relaxation until convergence (no BFS or recursion).
 * This standalone C prototype builds tables once at runtime. For RV32I,
 * these tables can instead be generated on the host and linked read-only;
 * the ranking arithmetic and target instruction cost still need work.
 */
static void init_heuristic(void)
{
    if (heuristic_ready)
        return;
    for (int kind = 0; kind < 2; ++kind) {
        uint8_t *distance = kind ? orient_dist : perm_dist;
        int count = kind ? ORIENTATIONS : PERMUTATIONS;
        memset(distance, UINT8_MAX, (size_t)count);
        distance[0] = 0;
        int changed;
        do {
            changed = 0;
            for (int rank = 0; rank < count; ++rank) {
                if (distance[rank] == UINT8_MAX)
                    continue;
                state_t state = abstract_state(rank, kind);
                for (int move = 0; move < MOVES; ++move) {
                    state_t next = apply_move(state, (uint8_t)move);
                    int index = kind ? orientation_index(&next)
                                     : permutation_index(&next);
                    int candidate = distance[rank] + 1;
                    if (candidate < distance[index]) {
                        distance[index] = (uint8_t)candidate;
                        changed = 1;
                    }
                }
            }
        } while (changed);
    }
    heuristic_ready = 1;
}

/* Call init_heuristic first. Each abstraction ignores a requirement;
 * take the maximum, never the sum. Retain the old bound as well.
 */
static int heuristic(const state_t *state)
{
    int incorrect = 0;
    for (int i = 0; i < CUBIES; ++i)
        if (state->p[i] != i || state->o[i] != 0)
            ++incorrect;
    int bound = (incorrect + 3) / 4;
    int hp = perm_dist[permutation_index(state)];
    int ho = orient_dist[orientation_index(state)];
    if (hp > bound)
        bound = hp;
    if (ho > bound)
        bound = ho;
    return bound;
}

/* Precondition: start is valid; solution has room for MAX_DEPTH integers.
 * Return the number of moves (0 for solved), or -1 if none fits in 11.
 * Only solution[0..return_value-1] is written, using move numbers 1..9.
 * No recursion, heap, BFS queue, or complete-state table is used.
 */
int solve(state_t start, int solution[MAX_DEPTH])
{
    state_t states[MAX_DEPTH + 1];
    /* 每層目前試到的走法；0 表示尚未嘗試，1..9 表示走法編號。 */
    int moves[MAX_DEPTH + 1];

    if (is_solved(&start))
        return 0;

    init_heuristic();

    /* 第一層：由起點下界開始，逐步增加允許的步數。 */
    for (int limit = heuristic(&start); limit <= MAX_DEPTH; ++limit) {
        int depth = 0;
        states[0] = start;
        moves[0] = 0;

        /* 第二層：沿目前路徑前進，走不下去就回溯。 */
        while (depth >= 0) {
            if (is_solved(&states[depth])) {
                for (int i = 0; i < depth; ++i)
                    solution[i] = moves[i];
                return depth;
            }

            if (depth == limit) {
                --depth;
                continue;
            }

            int descended = 0;
            /* 第三層：從上次尚未試過的走法，依序試到 9。 */
            for (int move = moves[depth] + 1; move <= MOVES; ++move) {
                /* 保存目前走法；失敗或回溯後，從下一種繼續試。 */
                moves[depth] = move;

                /* Consecutive turns of one face combine into at most one
                 * move, so a shortest solution never needs such a pair.
                 */
                if (depth > 0 &&
                    move_face((uint8_t)(move - 1)) ==
                    move_face((uint8_t)(moves[depth - 1] - 1)))
                    continue;

                state_t candidate = apply_move(states[depth], (uint8_t)(move - 1));
                int new_depth = depth + 1;
                if (new_depth + heuristic(&candidate) > limit)
                    continue;

                states[new_depth] = candidate;
                depth = new_depth;
                moves[depth] = 0;
                descended = 1;
                break;
            }

            /* 九種走法都處理完：父層狀態已在 states 中，不需逆轉。 */
            if (!descended)
                --depth;
        }
    }
    return -1;
}

static int parse_state(const char *input, state_t *state)
{
    if (strlen(input) != 2 * CUBIES)
        return 0;
    unsigned seen = 0;
    int sum = 0;
    for (int i = 0; i < CUBIES; ++i) {
        if (input[i] < '1' || input[i] > '7' ||
            input[i + CUBIES] < '1' || input[i + CUBIES] > '3')
            return 0;
        state->p[i] = (uint8_t)(input[i] - '1');
        state->o[i] = (uint8_t)(input[i + CUBIES] - '1');
        unsigned bit = 1U << state->p[i];
        if (seen & bit)
            return 0;
        seen |= bit;
        sum += state->o[i];
    }
    return sum % 3 == 0;
}

int main(int argc, char **argv)
{
    state_t start;
    int solution[MAX_DEPTH];
    if (argc != 2 || !parse_state(argv[1], &start)) {
        fprintf(stderr, "usage: %s PPPPPPPOOOOOOO\n",
                argc > 0 && argv[0] ? argv[0] : "solver2");
        return 2;
    }

    int length = solve(start, solution);
    if (length < 0) {
        fputs("no solution within 11 moves\n", stderr);
        return 1;
    }

    /* Replay the returned path before printing it. */
    state_t check = start;
    for (int i = 0; i < length; ++i) {
        if (solution[i] < 1 || solution[i] > MOVES) {
            fputs("invalid solution move\n", stderr);
            return 1;
        }
        check = apply_move(check, (uint8_t)(solution[i] - 1));
    }
    if (!is_solved(&check)) {
        fputs("solution verification failed\n", stderr);
        return 1;
    }
    for (int i = 0; i < length; ++i)
        printf("%s%s", i ? " " : "", move_names[solution[i] - 1]);
    putchar('\n');
    return fflush(stdout) != 0 || ferror(stdout);
}
