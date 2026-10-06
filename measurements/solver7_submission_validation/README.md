# Current assembly submission validation

AI-executed development evidence, not independently student-obtained measurements.

## Exhaustive distance-11 target sweep

**PASS**: all 2,644 exact distance-11 states were executed on
RV32_ISS with no extensions and no renderer. Each returned 11 moves and passed
independent replay. The maximum is **38,543,830** retired
instructions at `54721631111111`.
Cases above 50,000,000: **0**.
Specified input `21345671111111`: **15,147,934**.
The four-worker batch took 1916.386 seconds, including
startup/output. This wall time was measured under concurrent validation load.
The retired instruction counts are architectural counts, not rates.

Only the 14 input bytes differ between target ELFs. Fingerprints, input offset,
per-case commands, paths and raw stats are retained. Counts include startup,
search, internal replay, output and exit. The runner independently checks replay.

- `ripes/summary.json`: final aggregate and binary/Ripes fingerprints.
- `ripes/results.csv`: every input, path and retired count.
- `ripes-records.tar.gz`: published log/checkpoint archive; unpack at this directory.
- `fingerprints.json`: root-source and measured-binary fingerprints; source is retained once at repository root.
- `environment.json`: compiler, operating system and Ripes binary identification.

The local development directory additionally retains every original per-case record and ELF
snapshot. Rebuildable binaries are not required in the public source repository.
Published copies redact user/project path prefixes; numerical results and target
binary fingerprints are unchanged.

## Shared-source model checks

All three cases passed on both RV32_ISS and RV32_5S, with no ISA extensions,
correct expected length and independent replay. Renderer-off allocated bytes
were separately verified identical to the exhaustively measured solver.

| Model | Input | Optimal moves | Retired instructions |
| --- | --- | ---: | ---: |
| RV32_5S | `12345671111111` | 0 | 423 |
| RV32_5S | `25314672313211` | 1 | 1,235 |
| RV32_5S | `21345671111111` | 11 | 15,147,933 |
| RV32_ISS | `12345671111111` | 0 | 424 |
| RV32_ISS | `25314672313211` | 1 | 1,236 |
| RV32_ISS | `21345671111111` | 11 | 15,147,934 |

ISS and pipelined models may count the terminating ecall differently. Each model's
actual report is preserved. A successful CLI RV32_5S run does not establish a
personal GUI walkthrough of signals or observed MMIO animation.

## LED integration

The finite RAM-rendering build exits successfully after two replay rounds with
15,464,846 ISS instructions. The host sanitizer test independently checks 24
frames and RGB words. Its address 0x40000 is test RAM, not a peripheral default.
The GUI uses explicitly supplied peripheral assembler symbols and 35x25 checks.
See `../../solver7_optimization_led_README.md`.

## Reproduce a fresh sweep

```sh
sh build_solver7_optimization.sh
python3 tools/prepare_submission_sweep.py --out measurements/new_sweep
python3 tools/run_final_validation.py ripes --workers 4 --out measurements/new_sweep
python3 tools/build_solver7_optimization_led.py --render 0
python3 tools/validate_submission_models.py
```

The full sweep establishes the performance bound for the matching assembly ELF.
H3 over all 3,674,160 states is the separate C validation; this sweep does not run
every legal state in assembly.
