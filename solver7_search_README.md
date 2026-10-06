# Final C search and assembly comparison

AI-assisted development and AI-executed measurements; independent student work
and analysis remain required by the assignment.

The iterative search adds the orientation bound of the inverse cube and a
7,371-byte table of canonical move-suffix exclusions through length five. A
cached mask rejects candidates before generating a child. Surviving children
are written directly into the next state slot. Search still runs on the target.

```sh
sh build_solver7_search.sh
sh build_solver7_optimization.sh
```

| Build | Specified input instructions | Worst assembly input instructions | .text bytes | Static bytes |
| --- | ---: | ---: | ---: | ---: |
| Final C, GCC -O2 | 31,343,837 | 79,635,246 | 2,752 | 126,088 |
| Optimized assembly | 15,147,934 | 38,543,830 | 4,296 | 126,079 |

Inputs are `21345671111111` and `54721631111111`. Rendering is disabled; counts
include startup, search, verification, output and exit. Assembly uses more text
because moves and indexing are specialized; the report must explain this trade.

The C algorithm passes admissibility and exhaustive optimality/replay over all
3,674,160 states. The assembly passes all 2,644 distance-11 states on RV32_ISS,
maximum 38,543,830 instructions, and three cases on both ISS and RV32_5S.

- [Host and C reference evidence](measurements/solver7_search/README.md)
- [Assembly and model evidence](measurements/solver7_submission_validation/README.md)
- [Intermediate assembly measurements](measurements/solver7_pruning/README.md)
- [Shared LED/CLI build](solver7_optimization_led_README.md)
