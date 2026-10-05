# solver4: pointer-based direct moves

`solver3` remains unchanged. `solver4.c` uses:

```c
void apply_move(const state_t *src, state_t *dst,
                uint8_t face, uint8_t turns);
int solve(const state_t *start, int solution[MAX_DEPTH]);
```

Face is R=0, B=1, D=2. Turns is 1=90 degrees, 2=180, 3=270.
Input and output states must be distinct. The search decodes its move number
into face/turns before calling apply_move. Nine composed source/twist mappings
occupy 126 bytes and produce each output state in one seven-corner loop.
There is no repeated quarter-turn loop and no structure-by-value move API.
Explicit state copies still exist where necessary to retain search states;
eliminating memcpy calls does not imply eliminating all memory copying.

Build: `sh build_solver4.sh`. Outputs `solver4.s`, `solver4.elf`,
`solver4.dis`, `solver4.map`. Assembly is compiler-generated GNU RV32I,
not a hand-written assignment submission. Load the ELF in Ripes.

## Validation

- Full ELF has no memcpy symbol or calls, no external dependencies, and only
  RV32I instructions. Static data: 6,155 bytes; code: 3,436 bytes.
- All 51,921 abstract-state/move outputs (5,769 states times nine moves) match
  solver3 byte-for-byte. All 5,769 distance-table entries also match.
- Host tests with UBSan pass solved, one-move, distance-11, replay, malformed
  inputs, rank roundtrips and table completeness.
- Ripes RV32_ISS completes input `21345671111111`, prints the same 11 moves,
  validates the replay, and exits successfully. No timeout or ISA extensions.

| Version | Retired instructions |
|---|---:|
| solver3 | 435,132,487 |
| solver4 | 184,068,852 |

Saved 251,063,635 instructions (57.70%). This combined experiment
measures both pointer-based copying changes and composed direct moves; it does
not isolate the benefit of each individually. Still above the 50,000,000 limit.
No exhaustive end-to-end optimality gate or pipeline-model validation claimed.

## Reproduce

```sh
sh build_solver4.sh
clang -O2 -fno-builtin -Wall -Wextra -fsanitize=undefined \
  tests/solver4_host_test.c -o /tmp/cahw1_solver4_test
/tmp/cahw1_solver4_test
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli \
  --src solver4.elf -t elf --proc RV32_ISS \
  --iret --cycles --runinfo --timeout 0 -v \
  --output measurements/direct_moves/ripes-iret.txt \
  > measurements/direct_moves/run.log 2>&1
```

Detailed result: `measurements/direct_moves/comparison.json`.
