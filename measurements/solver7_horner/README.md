# Solver7 Horner index experiment

AI-assisted development change and measurement. Input `21345671111111`, RV32_ISS, no extensions, renderer absent.

| Version | Retired instructions |
|---|---:|
| Original solver7 | 53,779,947 |
| Nine specialized moves | 40,549,573 |
| Nine specialized moves + Horner indices | 34,934,509 |

Horner saves 5,615,064 instructions (13.85% relative to move specialization). Margin below 50 million: 15,065,491. The 24-instruction reduction per hot-block execution accounts for exactly 233,961 executions. Only the candidate heuristic index block was changed; initial heuristic and replay code remain unchanged.

Both indices use five fully unrolled Horner stages: radix 7 for permutation and radix 3 for orientation. .text is 3,788 bytes, 96 bytes smaller; static data remains 118,708 bytes.

Validation: 118,378 index tuples checked by interpreting actual modified arithmetic against the weighted-sum reference (7^6 permutation tuples and 3^6 orientation tuples). Existing 65,043 move-block cases and RV32I-only disassembly checks pass. Ripes outputs the same 11 moves `R B' D2 R' B R' B' R D2 R B`, passes original table-based replay, and exits with code 0. This does not establish the bound for all distance-11 states.

Reproduce from repository root:

```sh
sh build_solver7_optimization.sh
python3 tests/solver7_optimization_test.py
python3 tests/solver7_horner_test.py
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src solver7_optimization.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v --output measurements/solver7_horner/ripes-iret.txt > measurements/solver7_horner/run.log 2>&1
```

Pre-Horner assembly and ELF are preserved in `measurements/solver7_optimization/solver7_optimization_pre_horner.s` and `.elf`.

- SHA-256 `solver7_optimization.s`: `524ebcdc26e3aad35876632e88f89f9ac3042dd643ea0ae39e5d17804eea12d7`
- SHA-256 `solver7_optimization.elf`: `951fc46ffc6d8435c5f1673a19b2f46a5b96493a7625c58e044d7ba404ad7c7c`
