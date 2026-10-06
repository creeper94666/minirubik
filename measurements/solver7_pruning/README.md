# Intermediate assembly refinement measurements

AI-assisted changes and AI-executed development measurements. These are historical
stages; current results are in [final validation](../solver7_submission_validation/README.md).

All counts use RV32_ISS without extensions or rendering and include startup,
search, internal replay, output and exit. Linked code size means `.text` bytes.

| Cumulative stage | `21345671111111` | `54721631111111` | .text bytes |
| --- | ---: | ---: | ---: |
| Specialized moves + Horner | 34,934,509 | 95,558,619 | 3,788 |
| Early permutation rejection | 30,872,719 | 84,444,452 | 3,796 |
| Remove obsolete setup and spills | 27,953,564 | 76,465,950 | 3,668 |
| Direct child-slot writes | 25,813,248 | 70,613,418 | 3,620 |
| Canonical suffix pruning + inverse bound | 15,147,934 | 38,543,830 | 4,296 |

Early rejection skips orientation work when permutation distance alone exceeds
the remaining budget. Removing obsolete setup eliminates work no longer used by
the specialized move bodies. Direct writes remove the accepted-child copy. The
last stage reduces candidate generation before move/heuristic work.

`baseline/`, `early/`, `cleanup/`, and `direct/` retain raw instruction reports and
result records containing source/ELF fingerprints. Duplicate historical source
and binary snapshots remain local. Earlier move-specialization and Horner records
were already committed in the fork. Only the final stage has the new exhaustive
2,644-input PASS; do not treat intermediate sample maxima as exhaustive results.
