# Acceptance-time goal detection in solve

AI-assisted code and AI-executed Ripes development measurements, 2026-10-17.

## Design and invariant

The public `solve` wrapper handles the already-solved input. For non-solved input, limits begin at an admissible lower bound and increase by one. A solved node cannot be encountered at depth less than the current limit before the first successful iteration: its shortest distance would have caused an earlier iteration to succeed. Canonical sequence pruning retains a shortest representative.

Every accepted child satisfies both `depth+hp<=limit` and `depth+ho<=limit`. At `depth==limit`, nonnegative exact abstraction distances must both be zero. For valid cube states this means permutation and orientation are solved. Consequently the search can return immediately when an accepted child reaches the boundary. No per-node goal scan is required.

The implementation saves the current move, checks `s10==s2`, and jumps to the existing solution copy/epilogue. Boundary children do not compute a new mask. Interior children continue normally. The existing root wrapper, move order, bound rejection, inverse checks, input validation, and final replay remain intact.

The removed goal scan also makes the per-node state-address calculation and depth-equals-limit branch unnecessary. The depth-times-eight calculation is retained for move setup. Return code is relocated so the normal search entry falls through into expansion.

This relies on the current exact pattern tables, valid-state invariant, admissible threshold schedule, and first-solution search. It is not a generic replacement for a goal test with arbitrary heuristic tables or arbitrary starting thresholds.

## Paired measurements

RV32_ISS, no extensions or renderer; startup, search, replay, output and exit included. Both binaries rerun in this session.

| Input | Previous customized solve | Boundary return | Saved | Reduction |
|---|---:|---:|---:|---:|
| `21345671111111` | 15,092,396 | 14,836,245 | 256,151 | 1.697% |
| `54721631111111` | 38,398,165 | 37,730,599 | 667,566 | 1.739% |
| `12345671111111` | 424 | 424 | 0 | 0% |
| `25314672313211` | 1,218 | 1,162 | 56 | 4.598% |

Paths match baseline and independently replay correctly. `.text` shrinks from 4,396 to 4,252 bytes (-144). Static data stays 126,079 bytes. Search frame remains 368 bytes.

## Verification and reproduction

The new acceptance-block test first failed on the baseline, then passed 594 depth/limit/move combinations, checking decision, move write, and live registers. Existing move, index, inverse-bound, and mask tests pass. The historical fixed-offset goal test now explicitly reads the saved previous source because that scan no longer exists in the current solver.

```sh
sh build_solver7_optimization.sh
python3 tests/solver7_solve_boundary_test.py
python3 tests/solver7_optimization_test.py
python3 tests/solver7_horner_test.py
python3 tests/solver7_pruning_test.py
python3 tests/solver7_search_assembly_test.py
python3 measurements/solver7_solve_boundary/measure.py baseline 21345671111111 54721631111111 12345671111111 25314672313211
python3 measurements/solver7_solve_boundary/measure.py boundary 21345671111111 54721631111111 12345671111111 25314672313211
python3 measurements/solver7_solve_boundary/validate_target.py
python3 measurements/solver7_solve_boundary/validate_depths.py
```

`target/results.json` records 31 regression cases with expected lengths, independent replay, and baseline paths for hard samples. `target_depths/results.json` records one oracle-selected state at every exact distance 0 through 11. The oracle is the retained full-state BFS artifact, not regenerated in this experiment. Raw logs, commands, source/ELF/Ripes hashes and before/after snapshots are retained.

This experiment does not rerun all 2,644 distance-11 cases, all-state target validation, or pipeline/GUI tests. Previous exhaustive target results apply to their pinned older ELF. The updated lecture package copies only source/build/lecture files, leaving evidence here.
