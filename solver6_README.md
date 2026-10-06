# solver6: direct state distance lookup experiment

> **Historical version — solver6.** Retained as an earlier optimization stage.
> For the current C solver use [solver7_search.c](solver7_search.c); for optimized
> RV32I use [solver7_optimization.s](solver7_optimization.s).
> See the [current-version index](README.md#current-rv32i-version).
> Build commands and measurements below apply only to this historical version.

AI-assisted C implementation and development measurement of the user's requested direct-state lookup experiment. Preserve AI disclosure; this is not student-authored assembly, analysis or measurements for submission under rule.md section 18. solver4 and solver5 remain unchanged.

The search still carries state_t, uses the same moves and incorrect-cubie bound, and takes the maximum of the same two abstract distances. The heuristic now accesses:

```c
perm_dist[p[0]][p[1]][p[2]][p[3]][p[4]][p[5]];
orient_dist[o[0]][o[1]][o[2]][o[3]][o[4]][o[5]];
```

The seventh permutation value is uniquely determined by the other six for valid inputs. The seventh orientation is determined by the modulo-three invariant. The compiler still calculates array addresses; this removes Lehmer ranking, not all address arithmetic. The host-only reference encoders in solver6.c are excluded from the target.

## Tables and memory

`tools/generate_solver6_tables.c` builds abstract distances using solver4 on the host and emits solver6_tables.h. Permutation storage is 7^6 = 117,649 bytes, with exactly 5,040 valid entries and 112,609 unused entries set to 255. Orientation storage is 3^6 = 729 bytes. This is two independent abstract tables, not a complete cube distance table. Input validation rejects malformed states before search.

No target transition table or heuristic initialization is needed. The build emits .rodata = 118,689 bytes, .data = 15 bytes and .bss = 4 bytes. Total static data = 118,708 bytes, leaving 12,364 bytes under 128 KiB. Compiler-generated .text = 2,556 bytes. The linked stack section is separate from the assignment's named static-data sum.

## Verification

```sh
sh build_solver6.sh
clang -O2 -fno-builtin -Wall -Wextra -fsanitize=undefined tests/solver6_host_test.c -o /tmp/cahw1_solver6_test
/tmp/cahw1_solver6_test
```

Passed: all 5,769 abstract distances compared with a separate move-based BFS, sparse-slot population, and all 3,674,160 legal heuristic values compared with the prior formula. Host solved/one-move/distance-11 tests, solution replay, malformed-input checks and rank roundtrips pass under UBSan. Build checks confirm RV32I only, no unresolved dependencies, arithmetic helpers or memcpy.

Exhaustive heuristic equivalence is not an independent admissibility proof against a full-cube oracle and is not exhaustive end-to-end optimality testing. The full assignment H1/H3 and target pipeline/renderer gates are not claimed.

## Ripes development result

Input: `21345671111111`, RV32_ISS, no extensions, renderer absent. AI-executed run returns the same 11-move solution as solver5, validates replay internally, and exits with code 0.

| Version | Retired instructions |
|---|---:|
| solver5 (prior run) | 110,209,922 |
| solver6 | 69,539,968 |

Saved 40,669,954 instructions (36.90%). Still 19,539,968 over the 50,000,000 threshold for this input. This is not a worst-case survey. The difference includes both direct-state lookup and removal of target distance initialization, plus compiler effects; it does not isolate ranking cost.

Raw records and executable fingerprints: measurements/solver6/.

```sh
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src solver6.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v --output measurements/solver6/ripes-iret.txt > measurements/solver6/run.log 2>&1
```

The generated solver6.s is a compiler baseline, not hand-written RV32I. Formal assignment measurements must be reproduced by the student.
