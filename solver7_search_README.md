# Solver7 search algorithm variant

Current-root assembly update: `solver7_optimization.s/.elf` subsequently received
acceptance-time goal detection that removes the per-node goal scan. New paired measurements
and validation scope are recorded in
[solve-control results](measurements/solver7_solve_boundary/README.md).
The historical assembly counts and exhaustive sweep below refer to the earlier
pinned ELF; they are not a rerun of that sweep for the new root binary.

AI-assisted experimental C variant of solver7, built independently so the
original C and manually optimized assembly remain available for comparison.

```sh
sh build_solver7_search.sh
```

Load `solver7_search.elf` in Ripes. `solver7_search.s` is compiler-generated
RV32I, not a manually ported version of `solver7_optimization.s`.

## What changed

The iterative IDA* search keeps the original move order and optimality objective.
Two changes reduce candidate generation:

1. A 7,371-byte table identifies move suffixes of length up to five whose cube
   transformation has a shorter or lexicographically earlier equivalent word.
   A per-depth cached mask rejects these moves before `apply_move` and heuristic
   lookup. It includes the original same-face pruning. For example, `B2 R2 B2`
   and `R2 B2 R2` have the same transformation; only the earlier word is needed.
2. The heuristic additionally consults the orientation abstraction of the inverse
   cube, reusing the existing orientation distance table. This extra lookup is
   performed only when `max(hp, ho)` has not already rejected the candidate.

Accepted candidates are written directly into the next state slot. No recursion,
heap, transposition table or full-state solution database is added. The static
data footprint is 126,088 bytes, below 131,072; `.text` is 2,752 bytes.

## Measured candidate counts

| Input | Original | New | Reduction |
| --- | ---: | ---: | ---: |
| `21345671111111` | 233,961 | 118,198 | 49.48% |
| `54721631111111` | 639,792 | 300,250 | 53.07% |
| All 2,644 distance-11 states, total | 546,298,522 | 276,474,256 | 49.39% |

Each generated candidate makes one search `apply_move` call and one original
`heuristic` evaluation inside `search_bound`. There is one additional initial
bound evaluation per non-solved input. Inverse orientation lookups are additional
work: 29,099 and 74,101 calls for the two named inputs, respectively. These counts
exclude output replay and are not CPU instruction counts.

Every distance-11 case generated no more candidates than baseline, returned the
same original lexicographically first 11-move solution and passed independent replay.

The combined C solver also passed exhaustive optimality and independent replay
for all **3,674,160 legal states**, plus a full-state heuristic admissibility check
and 31 real Ripes target samples. Exhaustive host search took 415.31 seconds with
four workers. This is not an exhaustive validation of the generated assembly.

## Compiled-C Ripes comparison before the assembly port

All measurements use RV32_ISS with no extensions and no renderer, including
startup, search, replay, output and exit. Original and new C use GCC `-O2`.

| Input | Original compiled C | New compiled C | Retained manually optimized assembly |
| --- | ---: | ---: | ---: |
| `21345671111111` | 53,779,947 | 31,343,837 | 25,813,248 |
| `54721631111111` | 147,099,504 | 79,635,246 | 70,613,418 |

The algorithm reduces compiled-C instructions by 41.72% and 45.86%. A subsequent
port into `solver7_optimization.s` retains its move/Horner optimizations and now
uses **15,147,934 / 38,543,830** instructions. See the
[assembly-port results](measurements/solver7_search_assembly/README.md). The table
above preserves the earlier C-versus-assembly comparison; no exhaustive target
worst-case pass is claimed for the new port.

See [measurement and validation evidence](measurements/solver7_search/README.md)
for reproducible commands, alternative experiments and verification coverage.

## Exhaustive assembly performance update

The matching optimized assembly now passes all 2,644 distance-11 inputs on
RV32_ISS: maximum **38,543,830** retired instructions, zero above 50,000,000.
Each returned an optimal 11-move path and passed independent replay. This is
AI-executed evidence for the pinned assembly ELF, separate from the C H3 result.
See `measurements/solver7_submission_validation/README.md`.
