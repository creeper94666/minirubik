/* AI-executed allocation-size audit; this does not run the baseline BFS. */
#define main baseline_main
#include "../../../solver.c"
#undef main
int main(void) {
    size_t moves = (size_t)STATES * sizeof(uint8_t);
    size_t queue = (size_t)STATES * sizeof(uint32_t);
    size_t transitions = sizeof(uint16_t[3][PERMUTATIONS])
                       + sizeof(uint16_t[3][ORIENTATIONS]);
    printf("states=%d state_bytes=%zu move_table=%zu queue=%zu transitions=%zu dominant_live_payload=%zu\n",
           STATES, sizeof(state_t), moves, queue, transitions,
           moves + queue + transitions);
    return 0;
}
