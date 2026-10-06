# solver5: indexed heuristic initialization

> **Historical version — solver5.** Retained as an earlier optimization stage.
> For the current C solver use [solver7_search.c](solver7_search.c); for optimized
> RV32I use [solver7_optimization.s](solver7_optimization.s).
> See the [current-version index](README.md#current-rv32i-version).
> Build commands and measurements below apply only to this historical version.

AI-assisted C prototype implementing the user's selected nine-move transition-table experiment. solver4 is preserved. This is not student-authored assembly or a submission-ready assignment solution; retain AI disclosure and follow rule.md section 18.

Only heuristic initialization changes: `transition[rank][move]` replaces decode/move/encode inside repeated distance relaxation. The search and its state representation remain unchanged, including permutation/orientation ranking on each heuristic call. Distances are still built on the target. This is not a fully indexed search.

`tools/generate_solver5_tables.c` uses solver4 move semantics on the host to emit `solver5_tables.h`. The two read-only unsigned-short arrays contain 51,921 abstract transitions (103,842 bytes), not complete cube distances. Rebuilding regenerates the header.

## Build and host verification

```sh
sh build_solver5.sh
clang -O2 -fno-builtin -Wall -Wextra -fsanitize=undefined tests/solver5_host_test.c -o /tmp/cahw1_solver5_test
/tmp/cahw1_solver5_test
```

Build output: solver5.s, solver5.elf, solver5.dis and solver5.map. Assembly is compiler-generated, not hand-written.

Development checks passed: all abstract transitions match move-based computation; all 5,769 distance entries match a separate queue-based BFS over the abstract states; solved, one-move and distance-11 inputs solve and replay successfully; malformed inputs are rejected. The host-only BFS queue is not linked into the target.

The linked artifact has `.rodata` 104,152 bytes, `.data` 15 bytes and `.bss` 5,780 bytes: 109,947 bytes total, with 21,125 bytes remaining under 128 KiB. `.text` is 2,740 bytes. These are build section sizes, not Ripes performance measurements. The build checks RV32I instructions, absence of unresolved symbols, arithmetic helpers and memcpy.

## Student target verification still required

Load solver5.elf in Ripes. For a renderer-free CLI run using the same installed build as prior experiments:

```sh
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src solver5.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v
```

An AI-executed development run on RV32_ISS completed input `21345671111111` with 110,209,922 retired instructions and cycles, an 11-move solution, successful internal replay validation and exit code 0. Against the prior solver4 record of 184,068,852 instructions, this saves 73,858,930 instructions (40.1257%). It still exceeds the 50,000,000 threshold by 60,209,922 instructions. This one input is not a worst-case survey. Raw logs and comparison metadata are in `measurements/solver5/`. The student must reproduce measurements for assignment reporting under rule.md. Exhaustive full-cube H1/H3 verification, pipeline validation, renderer and hand-written assembly remain outside this experiment. Existing search costs remain and may dominate after initialization is reduced.
