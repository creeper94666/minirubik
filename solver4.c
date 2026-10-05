/* Freestanding RV32I solver. No headers, libc, libgcc, heap or recursion.
 * Build: sh build_solver4.sh
 * Ripes: load solver4.elf (GNU assembly source is solver4.s).
 * Input: edit cube_input below, then rebuild.
 */
typedef unsigned char uint8_t;
typedef __SIZE_TYPE__ size_t;
#define UINT8_MAX 255

void *memset(void *destination, int value, size_t count)
{
    volatile unsigned char *dst = destination;
    for (size_t i = 0; i < count; ++i)
        dst[i] = (unsigned char)value;
    return destination;
}

enum { CUBIES = 7, MOVES = 9, MAX_DEPTH = 11,
       PERMUTATIONS = 5040, ORIENTATIONS = 729 };

/* Same fixed-corner representation and turning rules as solver.c.
 * apply_move reads one state and writes another via pointers. */
typedef struct {
    uint8_t p[CUBIES], o[CUBIES];
} state_t;

static const char *const move_names[MOVES] = {
    "R", "R2", "R'", "B", "B2", "B'", "D", "D2", "D'"
};
/* Fixed move compositions, generated on the host: 126 bytes total.
 * face: R=0, B=1, D=2; turns: 1=90, 2=180, 3=270 degrees.
 * src and dst must be distinct; each result is written once. */
static const uint8_t move_source[3][3][CUBIES] = {
    {{1, 4, 2, 0, 3, 5, 6}, {4, 3, 2, 1, 0, 5, 6}, {3, 0, 2, 4, 1, 5, 6}},
    {{0, 1, 2, 4, 5, 6, 3}, {0, 1, 2, 5, 6, 3, 4}, {0, 1, 2, 6, 3, 4, 5}},
    {{0, 2, 5, 3, 1, 4, 6}, {0, 5, 4, 3, 2, 1, 6}, {0, 4, 1, 3, 5, 2, 6}}
};
static const uint8_t move_twist[3][3][CUBIES] = {
    {{1, 2, 0, 2, 1, 0, 0}, {0, 0, 0, 0, 0, 0, 0}, {1, 2, 0, 2, 1, 0, 0}},
    {{0, 0, 0, 1, 2, 1, 2}, {0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 2, 1, 2}},
    {{0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0}}
};

static void copy_state(state_t *dst, const state_t *src)
{
    for (int i = 0; i < CUBIES; ++i) {
        dst->p[i] = src->p[i];
        dst->o[i] = src->o[i];
    }
}

static uint8_t move_face(uint8_t move)
{
    return (uint8_t)(move < 3 ? 0 : (move < 6 ? 1 : 2));
}

static uint8_t move_turns(uint8_t move, uint8_t face)
{
    return (uint8_t)(move + 1 - ((face << 1) + face));
}

static void apply_move(const state_t *src, state_t *dst,
                       uint8_t face, uint8_t turns)
{
    const uint8_t *from = move_source[face][turns - 1];
    const uint8_t *delta = move_twist[face][turns - 1];
    for (int i = 0; i < CUBIES; ++i) {
        uint8_t j = from[i];
        dst->p[i] = src->p[j];
        int orientation = src->o[j] + delta[i];
        if (orientation >= 3)
            orientation -= 3;
        dst->o[i] = (uint8_t)orientation;
    }
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
 * target instruction counts still require measurement in Ripes.
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
                    state_t next;
                    uint8_t face = move_face((uint8_t)move);
                    uint8_t turns = move_turns((uint8_t)move, face);
                    apply_move(&state, &next, face, turns);
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
int solve(const state_t *start, int solution[MAX_DEPTH])
{
    state_t states[MAX_DEPTH + 1];
    /* 每層目前試到的走法；0 表示尚未嘗試，1..9 表示走法編號。 */
    int moves[MAX_DEPTH + 1];

    if (is_solved(start))
        return 0;

    init_heuristic();

    /* 第一層：由起點下界開始，逐步增加允許的步數。 */
    for (int limit = heuristic(start); limit <= MAX_DEPTH; ++limit) {
        int depth = 0;
        copy_state(&states[0], start);
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

                state_t candidate;
                uint8_t face = move_face((uint8_t)(move - 1));
                uint8_t turns = move_turns((uint8_t)(move - 1), face);
                apply_move(&states[depth], &candidate, face, turns);
                int new_depth = depth + 1;
                if (new_depth + heuristic(&candidate) > limit)
                    continue;

                copy_state(&states[new_depth], &candidate);
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
    unsigned length = 0;
    while (length < 15 && input[length])
        ++length;
    if (length != 14)
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
    while (sum >= 3)
        sum -= 3;
    return sum == 0;
}


/* Ripes service 11: print character; service 10: exit. */
#ifdef SOLVER4_HOST_TEST
extern void solver4_host_putc(int c);
static void output_char(int c) { solver4_host_putc(c); }
#else
#if !defined(__riscv) || __riscv_xlen != 32
#error "Build with an RV32I compiler, or define SOLVER4_HOST_TEST for tests."
#endif
static void output_char(int c)
{
    register int a0 __asm__("a0") = c;
    register int a7 __asm__("a7") = 11;
    __asm__ volatile ("ecall" : "+r"(a0), "+r"(a7) : : "memory");
}
#endif

static void output_string(const char *text)
{
    while (*text)
        output_char((unsigned char)*text++);
}

int solver4_run(const char *input)
{
    state_t start;
    int solution[MAX_DEPTH];
    if (!parse_state(input, &start)) {
        output_string("invalid cube state\n");
        return 2;
    }
    int length = solve(&start, solution);
    if (length < 0) {
        output_string("no solution within 11 moves\n");
        return 1;
    }
    state_t check;
    copy_state(&check, &start);
    for (int i = 0; i < length; ++i) {
        if (solution[i] < 1 || solution[i] > MOVES) {
            output_string("invalid solution move\n");
            return 1;
        }
        state_t next;
        uint8_t face = move_face((uint8_t)(solution[i] - 1));
        uint8_t turns = move_turns((uint8_t)(solution[i] - 1), face);
        apply_move(&check, &next, face, turns);
        copy_state(&check, &next);
    }
    if (!is_solved(&check)) {
        output_string("solution verification failed\n");
        return 1;
    }
    for (int i = 0; i < length; ++i) {
        if (i) output_char(' ');
        output_string(move_names[solution[i] - 1]);
    }
    output_char('\n');
    return 0;
}

/* Writable so the compiler preserves the embedded input as data. */
char cube_input[] = "21345671111111";
volatile int solver4_status;
void solver4_main(void)
{
    solver4_status = solver4_run(cube_input);
}

#ifndef SOLVER4_HOST_TEST
/* Own startup: initialize stack and BSS, with no CRT or operating system.
 * Status is retained in solver4_status for inspection after Ripes exits. */
__asm__(
    ".section .text.start,\"ax\",@progbits\n"
    ".globl _start\n"
    "_start:\n"
    "la sp, __stack_top\n"
    "la t0, __bss_start\n"
    "la t1, __bss_end\n"
    "1:\n"
    "bgeu t0, t1, 2f\n"
    "sb zero, 0(t0)\n"
    "addi t0, t0, 1\n"
    "j 1b\n"
    "2:\n"
    "call solver4_main\n"
    "li a7, 10\n"
    "ecall\n"
    "3: j 3b\n"
    ".text\n"
);
#endif
