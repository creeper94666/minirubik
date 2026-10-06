/* Reuse the independent upstream BFS oracle and replay implementation. */
#define SOLVER7_VALIDATION_SOURCE "../solver7_search.c"
#define SOLVER7_VALIDATION_HEURISTIC(state) search_bound(state, MAX_DEPTH)
#include "solver7_exhaustive_test.c"
