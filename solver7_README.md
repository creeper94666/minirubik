# solver7: remove incorrect-cubie lower bound

AI-assisted C experiment requested by the user. solver6 is preserved. The only algorithmic change is removal of incorrect-cubie counting and its `(incorrect + 3) / 4` bound. The heuristic now returns `max(hp, ho)` from the same direct-state abstract distance tables. Generated assembly is a compiler baseline, not hand-written assembly for submission.

## Verification

```sh
sh build_solver7.sh
clang -O2 -fno-builtin -Wall -Wextra -fsanitize=undefined tests/solver7_host_test.c -o /tmp/cahw1_solver7_test
/tmp/cahw1_solver7_test
```

Passed: all 5,769 abstract distances against independent move-based BFS, sparse-slot population, all 3,674,160 heuristic values against max of reference distances, solved/one-move/distance-11 solutions and replay, malformed inputs and rank roundtrips. The heuristic is weaker than solver6 for exactly 12 legal states and equal for the rest. This is not exhaustive end-to-end optimality testing or an independent full-cube admissibility gate.

Build checks pass for RV32I-only instructions, no unresolved dependencies, arithmetic helpers or memcpy. Static data remains 118,708 bytes, with 12,364 bytes remaining under 128 KiB. Compiler-generated .text is 2,668 bytes (solver6: 2,556).

## AI-executed Ripes measurement

Input `21345671111111`, RV32_ISS, no extensions, renderer absent:

| Version | Retired instructions |
|---|---:|
| solver6 (prior run) | 69,539,968 |
| solver7 | 53,779,947 |

Saved 15,760,021 instructions, about 22.66%. The run prints the same 11-move solution, validates replay internally and exits with code 0. It still exceeds 50,000,000 by 3,779,947 instructions. This single-input result does not establish worst-case performance; weaker heuristic states may affect other searches. Source-function profiling is available in measurements/profile7/README.md; its exclusive counts reconcile exactly with the original total.

```sh
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src solver7.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v --output measurements/solver7/ripes-iret.txt > measurements/solver7/run.log 2>&1
```

Raw logs and fingerprints are in measurements/solver7. Reproduce measurements independently for formal reporting under rule.md and retain AI disclosure. Full H1/H3, pipeline validation, renderer and hand-written assembly are not claimed.
