# Solver7 move specialization experiment

AI-assisted assembly modification and AI-executed development measurement.

Input: `21345671111111`. Processor: RV32_ISS, no extensions, renderer absent.

| Version | Retired instructions |
|---|---:|
| Original solver7 (rerun) | 53,779,947 |
| solver7_optimization | 40,549,573 |

Saved 13,230,374 instructions (24.60%). The optimized run is 9,450,427 below 50,000,000. Both runs print `R B' D2 R' B R' B' R D2 R B`, pass internal replay validation and exit with code 0.

Only the search's .L17 move block is replaced. Nine fully unrolled move bodies use fixed source offsets and constant twists; they share the original heuristic continuation. Original register spills and candidate pointer initialization are retained. The final solution replay remains the original table-based implementation.

.text grows from 2,668 to 3,884 bytes. Static data remains 118,708 bytes. Build has no unresolved symbols; disassembly contains RV32I instructions only.

Validation: `python3 tests/solver7_optimization_test.py` passes 65,043 assembly-block interpreter cases: all 5,040 permutations and all 2,187 orientation tuples independently for each move, compared with original C tables. This checks the separate permutation/orientation mappings, dispatch and required preserved state; it is not a full CPU emulator or exhaustive end-to-end solver test. Actual target execution is checked by the Ripes benchmark and original replay implementation.

This single-input measurement does not establish a worst-case bound across distance-11 states. These artifacts are AI-assisted development evidence, not independently user-executed coursework measurements.

Rebuild and reproduce from repository root:

```sh
sh build_solver7_optimization.sh
python3 tests/solver7_optimization_test.py
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src solver7_optimization.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v --output measurements/solver7_optimization/ripes-iret.txt > measurements/solver7_optimization/run.log 2>&1
```

SHA-256 fingerprints:

- `solver7.s`: `cf97ca6a2b9db316206d695b3d67bc013ad310aa79575d7ee6751210272f01aa`
- `solver7.elf`: `11d38ea935f8a5462b62dcf2a49f32acb62d912e1927420e7e4f7b878c21955c`
- `solver7_optimization.s`: `6dadf2c5eb233cda05b13186f05790c6491b646b618fd3be1044c7e24a6591e0`
- `solver7_optimization.elf`: `e634cc7dbd588debeae74f7475b834e2c96c6375cd7f1bc12606854629019004`

## Later Horner revision

The root solver7_optimization.s/.elf now include Horner indices. To reproduce the historical 40,549,573 count, use the preserved solver7_optimization_pre_horner.elf in this directory. Current measurements are in ../solver7_horner/README.md.
