# Customized solve control on RV32I

AI-assisted modification and AI-executed paired measurements, 2026-10-15. This is additional development evidence, not independently student-run coursework measurement.

## Change

Unroll the seven-corner node-goal test in `solve.part.0` using fixed byte offsets. Retain the original order of permutation/orientation comparisons and early rejection at the first mismatch. Remove the now-unused node-counter initialization and the old constant-seven initialization. Leave the public solved-input wrapper, search order, bounds, masks, moves, replay, and stack layout intact.

The original loop executes 49 instructions for a solved node, excluding its prior counter initialization. The specialized block executes 34. The deleted per-node initialization saves one more instruction on every node. This optimizes control overhead; it does not strengthen a heuristic or reduce generated candidates.

## Paired Ripes measurements

RV32_ISS, no extensions, no renderer. Includes startup, search, replay, output, and exit. Both baseline and final build were run in this session.

| Input | Baseline | Customized | Saved | Reduction |
|---|---:|---:|---:|---:|
| `21345671111111` | 15,147,934 | 15,092,396 | 55,538 | 0.3666% |
| `54721631111111` | 38,543,830 | 38,398,165 | 145,665 | 0.3779% |
| `12345671111111` | 424 | 424 | 0 | 0% |
| `25314672313211` | 1,236 | 1,218 | 18 | 1.4563% |

Returned paths match baseline and pass independent replay. The solved input bypasses the modified search-body block, explaining its unchanged result.

`.text` grows from 4,296 to 4,396 bytes (+100). Static data remains 126,079 bytes; stack reservation remains 4,096 bytes. Search frame remains 368 bytes.

## Verification

- Test-first node-goal work-budget check failed on the baseline and passed after modification.
- 10,812 isolated goal checks: every permutation, every seven-digit ternary orientation tuple, and byte mutations at every state offset. Check decisions, live registers, and absence of writes.
- Existing tests pass: 65,043 move cases; 118,378 index tuples; 25,872 bound combinations; 5,769 inverse scatter cases; 8,080 cached-mask cases; RV32I-only disassembly.
- Target regression results are retained in `target/results.json`, with independent replay, exact expected lengths, and baseline path comparison for distance-11 samples.

This experiment does not rerun the exhaustive 2,644-case target sweep or GUI/pipeline tests. The earlier exhaustive result applies to the old pinned ELF, not this newly built ELF.

## Reproduction and snapshots

```sh
sh build_solver7_optimization.sh
python3 tests/solver7_solve_control_test.py
python3 tests/solver7_optimization_test.py
python3 tests/solver7_horner_test.py
python3 tests/solver7_pruning_test.py
python3 tests/solver7_search_assembly_test.py
python3 measurements/solver7_solve_control/measure.py baseline 21345671111111 54721631111111 12345671111111 25314672313211
python3 measurements/solver7_solve_control/measure.py customized 21345671111111 54721631111111 12345671111111 25314672313211
python3 measurements/solver7_solve_control/validate_target.py
```

`baseline/` retains the original source, ELF, map, and disassembly. `customized/` retains the final measured build. `unrolled/` retains the intermediate version before removing obsolete initialization. Each measured case records fingerprints, command, path, retired instructions, and raw reports. Existing snapshots are reused by the measurement script; use a fresh stage name for a future changed build.

See `solve-control.diff` for the complete source delta. The separate LED build was not rebuilt by this experiment.
