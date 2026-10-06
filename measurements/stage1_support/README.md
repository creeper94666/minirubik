# Stage 1 reproduction aid

This AI-created loop is a reproducibility aid. AI-run records are supplemental,
not independently student-obtained coursework measurements.

```sh
python3 tools/measure_stage1.py --repetitions 3
```

The macOS runner builds RV32I ELF files and executes both RV32_ISS and RV32_5S.
Each performs 1,048,576 stores. The control reuses 4,096 bytes; the large case
writes 4,194,304 distinct bytes. Both use the same loop. A wrap reload occurs
more often for the control, so use measured retired counts rather than assuming
identical instruction counts. Addresses are deliberately outside program data.

For each model, calculate the difference of median peak RSS between the large
and control runs, divided by 4,190,208 additional guest bytes. Multiply that
slope by the original baseline peak of 18,405,414 bytes to estimate incremental
host storage. Report RSS variance and the limitations of process peak RSS;
this is an empirical slope, not a guaranteed allocator cost.

Rates use measured retired instructions divided by process wall time, including
startup/output. Run experiments alone, without simultaneous solver sweeps, for
formal rates. Record machine load, hardware, compiler and pinned Ripes binary.
The development smoke run used one repetition while other validation was active;
its rates must not be represented as isolated-machine benchmark results.

`/usr/bin/time -l` reports peak RSS in bytes on macOS. Do not reuse that unit
assumption on Linux. Raw commands, logs, stats and binary fingerprints are saved.

## AI-run smoke results

One repetition per pair, concurrent validation load; see the raw records.

| Model | RSS slope, host bytes / extra guest byte | Small-loop instructions / process second | Large-loop instructions / process second |
| --- | ---: | ---: | ---: |
| RV32_ISS | 47.085 | 3648959.1 | 2801330.7 |
| RV32_5S | 18.045 | 4872.5 | 8936.8 |

These are single paired peak-RSS estimates, not guaranteed per-byte storage costs.
The large pipeline test partly ran after the exhaustive ISS jobs completed, so
the load differed; do not interpret its higher rate as a memory-size speedup.
