# Freestanding solver3

> **Historical version — solver3.** Retained as an earlier optimization stage.
> For the current C solver use [solver7_search.c](solver7_search.c); for optimized
> RV32I use [solver7_optimization.s](solver7_optimization.s).
> See the [current-version index](README.md#current-rv32i-version).
> Build commands and measurements below apply only to this historical version.

`solver3.c` retains the solver2 search, with no standard headers or external C
library. It defines its own byte-copy and byte-fill routines. Target output uses
Ripes character-print ecall 11; startup exits through ecall 10.

## Build

```sh
sh build_solver3.sh
```

Requires `riscv64-elf-gcc`, matching binutils, and Python 3. Override the compiler
path with `RISCV_CC` if necessary. No Newlib or libgcc is linked.

Outputs:

- `solver3.s`: compiler-generated GNU RV32I assembly, including startup.
- `solver3.elf`: linked executable intended for loading as an ELF in Ripes.
- `solver3.dis`: full executable disassembly.
- `solver3.map`: link map.

`solver3.ld` provides the memory layout, BSS symbols, and a 4 KiB stack.
The `.s` file uses GNU directives and linker symbols; do not assume it can be
pasted directly into the Ripes assembly editor. Load the ELF instead.

Change `cube_input` in `solver3.c` and rebuild to change the embedded input.
Default: `21345671111111`. Successful output is a space-separated move list.
A solved input prints a newline. `solver3_status` records 0 for success, 1 for
search/replay failure, and 2 for invalid input. Every solution is replayed before
printing.

## Validation

```sh
clang -O2 -fno-builtin -Wall -Wextra -fsanitize=undefined \
    tests/solver3_host_test.c -o /tmp/solver3_host_test
/tmp/solver3_host_test
```

Host tests cover solved, one-move, and the specified distance-11 input, solution
replay, malformed inputs, every abstract index, and table completeness. These
are targeted tests, not exhaustive optimality verification over all cube states.
The build checks unresolved symbols, arithmetic helpers, RV32I instruction
membership, and the 128 KiB static-data budget.

Measured build sections: text 3,324 bytes; rodata 280; data 15; BSS 5,780.
Static data totals 6,075 bytes. The separately reserved stack occupies 4,100
bytes including alignment padding.

Ripes execution and retired-instruction counts have not yet been verified.
Heuristic tables are still built at runtime; instruction-budget compliance is
not established. No LED renderer is included. The generated assembly is a
compiler comparison artifact, not the assignment's required hand-written
assembly deliverable.
