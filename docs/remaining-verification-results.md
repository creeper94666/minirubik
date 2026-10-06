# Remaining verification results

All new execution, observations, calculations and text in this record are **AI-executed / AI-generated support evidence**, not student-performed measurements or independently authored coursework analysis. Observation date: 2026-10-07, Asia/Taipei. This document can be pasted into HackMD after converting repository-relative evidence links to the corresponding published paths. This verification was originally recorded before publication. Publication was explicitly authorized on 2026-10-07; see docs/publication-status-20261007.md for the subsequent outcome.

## Status

| Requested work | Result |
| --- | --- |
| Stage 1, two models × two regions × three repetitions | Completed: 12 successful samples; background-load limitations apply |
| Final assembly LED GUI | Current exports and build verified in the initial attempt. Follow-up stopped the user program with authorization, but native load/control errors still prevent confirmed live replay |
| Pipeline signal walkthrough | Exact final renderer-off disassembly verified. Live stage/control observations remain blocked by unresolved native GUI/control errors |
| Original upstream fork commit | Fork relationship, current heads, common ancestor and earliest retained pre-push head verified. Creation-time SHA not conclusively established |

Evidence root: [`measurements/remaining_verification_20261007/`](../measurements/remaining_verification_20261007/). Existing files and old measurement records were preserved; new builds and raw output are isolated there.

## Stage 1 method

The inspected [`tools/measure_stage1.py`](../tools/measure_stage1.py) was executed unchanged from a byte-for-byte mirror under the evidence directory. Its fixed output path is relative to its own location; this mirror prevents overwriting the previous single-repetition smoke results. The assembly input was also copied unchanged. The runner executes all conditions sequentially, never in parallel. No exhaustive correctness or distance-11 workload was launched.

```sh
python3 measurements/remaining_verification_20261007/stage1/tools/measure_stage1.py --repetitions 3
```

Each ELF is built by `riscv64-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,--no-relax,-Ttext=0`, with explicit assembler parameters `REGION_BYTES=4096` or `4194304`, and `ITERATIONS=1048576`. Each measurement uses `/usr/bin/time -l` around Ripes CLI with `--proc RV32_ISS` or `RV32_5S`, `--iret --cycles --runinfo --timeout 0 -v`. Exact per-run command arrays, ELF hashes and unrounded numbers are in [records.json](../measurements/remaining_verification_20261007/stage1/measurements/stage1_support/results/records.json); stdout/stderr, simulator statistics and `time` output are retained alongside it. [Runner log](../measurements/remaining_verification_20261007/stage1/run.log) and [commands](../measurements/remaining_verification_20261007/stage1/commands.txt).

Hardware: Apple M1, 8 logical CPUs, 8,589,934,592 bytes RAM (8 GiB). OS: macOS 26.3.2, build 25D2140. Cross compiler: `riscv64-elf-gcc (GCC) 16.2.0`. [Machine/version/load evidence](../measurements/remaining_verification_20261007/environment/machine-start.json).

Ripes executable SHA-256: `bea887fcf020c1dda1f44177c19c27a13f3b93c625b17194ac37e3d421a34fc4`. Bundle fields are generic `1.0` / `1.0.0`; they are not asserted to identify an upstream release. This is the same executable used by the existing final-solver validation.

The first sandboxed attempt failed during Ripes startup with pasteboard/system-service errors; `/usr/bin/time` also reported `sysctl kern.clockrate: Operation not permitted`. It produced no valid sample and is excluded. [Failed startup evidence](../measurements/remaining_verification_20261007/stage1/sandbox-failed-results/RV32_ISS-4096-0.log). The sequential run was restarted with approved process permissions.

The user's existing Ripes GUI was auto-clocking; it was not stopped. Other desktop processes were also active. These are observed-background-load measurements, **not isolated-machine throughput benchmarks**. No other heavy validation was started by this task. The first ISS sample was slower than later samples, consistent with possible cold-start or load effects; this experiment does not isolate their causes. No warm-up was discarded.

### AI-executed results

All RSS values below are **bytes**, as reported by macOS `/usr/bin/time -l`. Repetition labels are 1-based here (0-based in the raw filenames). Rates are instructions per process wall-clock second.

| Model | Region bytes | Repeat | Peak RSS (bytes) | Retired instructions | Wall seconds | Instructions / second |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RV32_ISS | 4,096 | 1 | 68,861,952 | 5,243,910 | 1.842321 | 2,846,360.72 |
| RV32_ISS | 4,096 | 2 | 71,237,632 | 5,243,910 | 0.569786 | 9,203,296.02 |
| RV32_ISS | 4,096 | 3 | 71,204,864 | 5,243,910 | 0.534342 | 9,813,771.72 |
| RV32_5S | 4,096 | 1 | 103,088,128 | 5,243,910 | 52.090758 | 100,668.72 |
| RV32_5S | 4,096 | 2 | 78,807,040 | 5,243,910 | 58.252897 | 90,019.73 |
| RV32_5S | 4,096 | 3 | 77,856,768 | 5,243,910 | 52.967196 | 99,002.97 |
| RV32_ISS | 4,194,304 | 1 | 295,632,896 | 5,242,887 | 1.427082 | 3,673,851.58 |
| RV32_ISS | 4,194,304 | 2 | 290,734,080 | 5,242,887 | 0.782734 | 6,698,174.54 |
| RV32_ISS | 4,194,304 | 3 | 303,333,376 | 5,242,887 | 0.704394 | 7,443,121.90 |
| RV32_5S | 4,194,304 | 1 | 228,327,424 | 5,242,887 | 51.869166 | 101,079.07 |
| RV32_5S | 4,194,304 | 2 | 244,580,352 | 5,242,887 | 48.243480 | 108,675.56 |
| RV32_5S | 4,194,304 | 3 | 227,966,976 | 5,242,887 | 50.049622 | 104,753.78 |

| Model | Region bytes | RSS median (bytes) | RSS min–max (bytes) | RSS sample SD (bytes) | RSS sample variance (bytes²) | Median instructions / second |
| --- | ---: | ---: | --- | ---: | ---: | ---: |
| RV32_ISS | 4,096 | 71,204,864 | 68,861,952–71,237,632 | 1,362,238.71 | 1,855,694,307,328.00 | 9,203,296.02 |
| RV32_ISS | 4,194,304 | 295,632,896 | 290,734,080–303,333,376 | 6,351,352.22 | 40,339,675,021,312.00 | 6,698,174.54 |
| RV32_5S | 4,096 | 78,807,040 | 77,856,768–103,088,128 | 14,300,907.77 | 204,515,963,131,221.34 | 99,002.97 |
| RV32_5S | 4,194,304 | 228,327,424 | 227,966,976–244,580,352 | 9,489,396.31 | 90,048,642,241,877.33 | 104,753.78 |

Sample variance uses denominator n−1. No outliers were removed.

| Model | Median RSS difference (bytes) | Host bytes / extra guest byte | Payload-only extrapolation for 18,405,414 guest bytes (host bytes) |
| --- | ---: | ---: | ---: |
| RV32_ISS | 224,428,032 | 53.560117 | 985,796,133 |
| RV32_5S | 149,520,384 | 35.683284 | 656,765,623 |

The last column is an approximate incremental host-memory projection, **not observed baseline peak RSS**. It excludes the fixed process/model cost, assumes scaling beyond the measured range, and inherits all peak-RSS limitations below.


### Interpretation and limitations

Both programs execute 1,048,576 four-byte stores. The control cycles through 4,096 guest bytes, whereas the large case touches 4,194,304 distinct guest bytes. The extra guest footprint is therefore **4,190,208 bytes**, not the number of bytes written including repeated writes. Both begin at guest address `0x400000`.

The control wraps its address pointer 1,024 times; the large condition wraps once. Each wrap executes an extra address reload, so the control retires **1,023 more instructions**. Both models reported 5,243,910 control instructions and 5,242,887 large-region instructions. The exact retired counts must be used rather than assuming equal work. These loops do not run the solver, and their throughput is specific to this instruction mix and configuration.

For each model, the empirical slope is:

`(median(large peak RSS) - median(control peak RSS)) / 4,190,208`

Its unit is host bytes per additional guest byte. It is a difference of independent process peaks, not a direct accounting of simulator memory cells. Allocator history, resident page state, model data structures, initialization and background pressure can alter the peaks. A peak may occur at different execution points in the two conditions. Three samples provide a variability check, not a general confidence bound or a guarantee of linear scaling.

`retired instructions / process wall-clock second` uses the runner's `time.monotonic()` interval around the timed subprocess. It includes process launch, Qt/Ripes initialization, ELF loading, simulation, output and teardown, plus small wrapper overhead. It is not simulated clock frequency or steady-state simulation-only throughput. Startup costs matter especially for subsecond ISS samples. Pipeline cycle counts also describe the simulated machine, not host elapsed time.

### Baseline allocation audit

The checked baseline is this workspace's [`solver.c`](../solver.c), SHA-256 `562764bae4a5ca52a57ea82ac7a8490b09f92805ae3fd5bde1a4e67af82fbdfc`. `STATES=5040*729=3,674,160`; queue entries are `uint32_t`; the two factored transition arrays are `uint16_t[3][5040]` and `uint16_t[3][729]`. Both heap allocations and both automatic arrays coexist during BFS.

| Dominant live storage | Calculation | Bytes |
| --- | --- | ---: |
| Move toward solved | 3,674,160 × sizeof(uint8_t) | 3,674,160 |
| BFS rank queue | 3,674,160 × sizeof(uint32_t) | 14,696,640 |
| Quarter-turn transition arrays | 3 × (5,040 + 729) × sizeof(uint16_t) | 34,614 |
| Total dominant live payload | Sum | **18,405,414** |

A small [size probe](../measurements/remaining_verification_20261007/stage1/baseline_sizes.c) includes the actual baseline source and reports [these sizes](../measurements/remaining_verification_20261007/stage1/baseline_sizes.txt) without running BFS. This confirms the allocation calculation rather than reusing an unchecked estimate. A [source comparison](../measurements/remaining_verification_20261007/stage1/baseline-source-comparison.json) also checks this local baseline against the retained upstream commit. It is **not a measured full process peak**, and excludes allocator metadata, other stack locals/call frames, static objects, executable/runtime storage and simulator overhead. Projecting the measured slope onto this payload is only an extrapolation from the 4 KiB–4 MiB experiment, not a baseline Ripes RSS measurement.

## Final LED assembly GUI

The actual running GUI exports were captured, not inferred from historical settings:

```c
#define LED_MATRIX_0_BASE   (0xf0000000)
#define LED_MATRIX_0_SIZE   (0xdac)
#define LED_MATRIX_0_WIDTH  (0x23)
#define LED_MATRIX_0_HEIGHT (0x19)
```

Thus LED Matrix 0 is 35 × 25 with 3,500 MMIO bytes. [Actual accessibility state](../measurements/remaining_verification_20261007/gui/initial-running-ax.txt), [real screenshot of the existing running GUI](../measurements/remaining_verification_20261007/gui/initial-running.png), and [export transcription](../measurements/remaining_verification_20261007/gui/exports.txt). That screenshot documents configuration and the blocker; it is **not a final-solver replay screenshot**. The observed processor status was `5-stage processor`, ISA `RV32I`; the loaded user program was not identified as the final solver.

Build performed:

```sh
python3 tools/build_solver7_optimization_led.py --render 1 \
  --base 0xf0000000 \
  --output measurements/remaining_verification_20261007/gui/solver7_gui
```

The generated `.s` is byte-identical to the final root `solver7_optimization_led.s` (SHA-256 `9b7bc5cd321928ef1324c59b65eaf2547f07eae7c561c70a04e5bd3544ef7ce0`). Renderer-enabled ELF SHA-256: `8655b79a8658ca9447155a10d39273a5534384bf1fee103e1130fdaa26c8353f`. [Build output](../measurements/remaining_verification_20261007/gui/build.log), [ELF](../measurements/remaining_verification_20261007/gui/solver7_gui.elf), [disassembly](../measurements/remaining_verification_20261007/gui/solver7_gui.dis). Linked `.text` is 5,416 bytes; `.rodata + .data + .bss` is 127,099 bytes. Build checks passed for RV32I-only disassembly, no unresolved symbols and the static-data limit. Default delay 10,000 and infinite replay were preserved.

Input is `21345671111111`. The previously verified solver solution is `R B' D2 R' B R' B' R D2 R B` ([existing target result](../measurements/solver7_submission_validation/models/RV32_ISS-21345671111111.json)); this is **prior execution evidence**, not a newly observed GUI output.

**Initial attempt (superseded blocker):** not completed. Ripes had Auto clock enabled, and Select processor / Reset / Clock / Run controls were disabled. The user explicitly required not stopping their programs. No stop, reset, load or replacement was performed. The user was asked to stop it themselves when convenient; a [final read-only check](../measurements/remaining_verification_20261007/gui/final-running-ax.txt) still showed Auto clock enabled. Consequently there are no initial/intermediate/completed final-solver screenshots and no observed per-move redraw claim. The earlier RAM-rendering test and C/browser displays are not substituted for this requirement.

### Authorized GUI follow-up

The user subsequently authorized stopping the existing program. Auto clock was stopped and the ELF load dialog opened. An AX path-setting operation stalled in Ripes file validation; its [process sample](../measurements/gui_followup_20261007/gui/ripes-process-sample.txt) records the blocked open call. Only that Ripes process was closed through Activity Monitor and reopened. The native file picker left Open disabled; an atomic paste of a byte-identical temporary ELF enabled OK, but after clicking it native observations failed again. A [second sample](../measurements/gui_followup_20261007/gui/ripes-restarted-sample.txt) showed a normal event loop, so the later control failure is not attributed to the same blocked-open cause without evidence.

No final ELF load or LED frame was confirmed. The current blocker is the unresolved native GUI/control error, **not lack of permission to stop the old program**. [Detailed action/error record](../measurements/gui_followup_20261007/gui/attempt-log.md). Recheck peripheral exports after restart before using the previously built MMIO binary. [Report version review and replacement sections](report-final-review.md) distinguish the current verified solver from the historical Horner snapshot.

### Steps for the student to complete the LED observation

1. Finish and stop the existing GUI program. Recheck the current LED Matrix 0 exports; rebuild if the base or geometry changed.
2. Select RV32I without M/C; load the new evidence-directory `solver7_gui.elf` as an ELF executable. Record model and hash with the observation.
3. Locate `draw`, `led_replay_step`, `led_replay_round` and `cube_led_write` in the exact ELF symbol/disassembly listing. For this exact GUI ELF, `draw=0x10e4`, `cube_led_write=0x14f4`, `led_replay_step=0x2f078` and `led_replay_round=0x2f074`. Use a breakpoint at `0x1128`, the delay initialization immediately after the MMIO writer returns, so each pause captures a fully written frame rather than a partial framebuffer. Advance past the breakpoint once before continuing to the next frame.
4. Run search once. Compare its actual printed path with the independently replayed path. At replay step 0, save `led-initial.png`; at a chosen intermediate step, save `led-intermediate.png`; at step 11, save `led-solved.png`. Record actual step counters and path, not merely screenshot filenames.
5. Continue through all 12 frame pauses (input plus 11 moves), recording the move, step index and visible cube state. Compare each move's facelets with independently applied moves; verify row-major addressing and all six colors. An end-state-only screenshot is insufficient.

## Pipeline signals

The final renderer-disabled ELF was copied unchanged to [final-renderer-off.elf](../measurements/remaining_verification_20261007/pipeline/final-renderer-off.elf). SHA-256: `9cf031504897e541e37f875217c3d3ac00406cdd3f70745b76e86a76bfec1edd`. Its allocated binary bytes equal those of the exhaustively checked optimized solver. [Actual disassembly](../measurements/remaining_verification_20261007/pipeline/final-renderer-off.dis) and [symbols](../measurements/remaining_verification_20261007/pipeline/symbols.txt) were freshly extracted.

| Actual PC | Actual decoded instruction | Architecture-level expected effect, not a GUI observation |
| --- | --- | --- |
| 0x18 | `bgeu t0,t1,0x28` | Fall through while t0 < t1; exit when equal; no GPR result |
| 0x1c | `sb zero,0(t0)` | Store zero byte to t0; no GPR result |
| 0x20 | `addi t0,t0,1` | ALU adds immediate 1; write result to t0 |
| 0x24 | `jal zero,0x18` | Redirect PC to loop head; x0 remains zero |

The exact renderer-off BSS interval is `[0x2ec7c,0x2ec80)`: four byte stores. The renderer-enabled binary instead clears `[0x2ed04,0x2f07c)`, 888 bytes. Do not mix those addresses.

| Required observation | Actual GUI observation for this final ELF |
| --- | --- |
| IF / ID / EX / MEM / WB instruction and PC, each cycle | Not observed; final-ELF load/control could not be confirmed after authorized recovery |
| Register write enable | Not observed |
| ALU operand mux / operation and WB mux selection | Not observed |
| Branch decision and next-PC mux | Not observed |
| Store address/data/write control and memory update edge | Not observed |
| Forwarding / stall / flush | Not observed |

No cycle values, mux encodings, forwarding paths or signal screenshots are invented. The existing CLI RV32_5S pass is not a signal observation.

### Steps for the student to complete the signal record

1. After stopping their own program, load the exact copied renderer-off ELF and choose the visual five-stage processor with hazard detection and forwarding, RV32I without extensions. Reset and capture model/settings and PC 0.
2. Show processor signal values and the memory view around `0x2ec7c`. Step with F5, recording the clock count and every IF/ID/EX/MEM/WB PC/instruction, including bubbles or invalid stages. Follow the loop until the taken exit at `0x28` and wrong-path instructions are cleared.
3. For each cycle containing `sb`, `addi`, `bgeu` or `jal`, capture the actual displayed register-write control, ALU input selectors, WB selector and branch/next-PC selector. Record raw labels/values as shown by this build before interpreting them. A raw write-enable signal for `jal x0` need not be zero even though x0 cannot change.
4. Track store addresses `0x2ec7c` through `0x2ec7f`, zero data, byte write mask and the edge that performs each update. These BSS bytes may already be zero: an unchanged zero byte alone does not prove the write occurred. Correlate it with the MEM-stage store and write control; if using a nonzero memory prefill as a separate experiment, disclose that modified initial state.
5. Check `addi`'s t0 result and its later consumers, recording actual forwarding, stalls and flushes rather than assuming exact timing from ISA semantics. Explain why the observed transitions implement the disassembled loop.
6. Save screenshots named by cycle and fill a table with columns `cycle, IF, ID, EX, MEM, WB, RegWrite, ALU mux, WB mux, next PC/branch, store address/data/write, forward/stall/flush, screenshot`. Keep architectural expectations separate from observations.

## Upstream fork audit

The requested working directory has no `.git`, so it cannot itself supply a remote or reflog. Read-only Git inspection found retained checkouts under `/private/tmp/cahw1-upload-checkout`, `/private/tmp/cahw1-submission-checkout` and `/private/tmp/cahw1-required-only`. Their remote URLs, full retained history and reflogs were saved in [local-git-history.json](../measurements/remaining_verification_20261007/upstream/local-git-history.json). No Git ref was updated.

The [live repository response](../measurements/remaining_verification_20261007/upstream/fork-repository.json) reports `fork: true`, with both parent and source `sysprog21/minirubik`, and creation time `2026-10-05T10:08:52Z`. [Current upstream](../measurements/remaining_verification_20261007/upstream/current-upstream-main.json), [current fork](../measurements/remaining_verification_20261007/upstream/current-fork-main.json), [comparison](../measurements/remaining_verification_20261007/upstream/compare.json), [public push events](../measurements/remaining_verification_20261007/upstream/fork-events.json) and [retrieval endpoints](../measurements/remaining_verification_20261007/upstream/retrieval.txt) are retained.

| Identity | Full SHA / established fact |
| --- | --- |
| Original upstream commit at the instant of fork creation | **Not conclusively established by retained creation-time evidence** |
| Earliest retained clone HEAD, 2026-10-05 18:39:43 +0800 | `231796cc48868f4ea276f652139b6bebbad0cd02` |
| Head before earliest visible public push, 2026-10-05T11:18:34Z | `231796cc48868f4ea276f652139b6bebbad0cd02` |
| Current common ancestor from GitHub comparison | `231796cc48868f4ea276f652139b6bebbad0cd02` |
| Current upstream main at retrieval | `231796cc48868f4ea276f652139b6bebbad0cd02` |
| Current fork main at retrieval | `25bf01290c594bdf06040b1b444e1e1694fe55dd` |
| Published revision documented in the older local manifest | `d565c5b9636610f5c88f363f16a543b26599b8e1` |

The earliest visible push explicitly records `before=231796cc48868f4ea276f652139b6bebbad0cd02` and `head=2a4458e1c5f3cf7cbc1aad63619449a5f1ce2ab1`. Together with the clone reflog, this is stronger evidence than the current common ancestor alone: it establishes the fork's main before that recorded coursework push. However, the first retained clone is approximately 31 minutes after repository creation, and the push is approximately 70 minutes after creation. The available API event list has no creation-time branch SHA or complete branch-update audit for that gap. It therefore does not exclude an earlier sync/reset. The candidate SHA is not relabeled as a proven original fork commit.

Still needed: a contemporaneous fork-creation/head record, an immediately-after-creation ref capture, or a complete trustworthy branch-history record connecting creation to the first retained head. A commit's author/committer date alone is insufficient. Student confirmation should identify its evidence rather than infer the original SHA from today's upstream HEAD.

## Reuse of completed verification and preservation

[Fresh fingerprint audit](../measurements/remaining_verification_20261007/environment/prior-validation-audit.json) confirms byte equality of the current optimized assembly, ELF, sequence include and linker script against the pinned sweep snapshot. The C source matches the existing exhaustive H3 source SHA. The renderer-disabled shared-source ELF has identical allocated bytes to the optimized solver. [All source/binary hashes](../measurements/remaining_verification_20261007/environment/fingerprints.json).

Accordingly, no all-state correctness or distance-11 sweep was repeated. The existing [2,644-case summary](../measurements/solver7_submission_validation/ripes/summary.json) reports maximum 38,543,830 retired instructions with zero cases above 50,000,000. This is reused evidence for the matching renderer-disabled build, not a new measurement and not proof of GUI signal observation. No solver defect was identified and no solver/environment-default changes were made.

The student must independently perform the measurements and core explanation required by the coursework, complete the live GUI observations once native GUI control is restored, and obtain creation-time provenance if an exact original fork SHA is claimed. This support record does not claim those student-authorship requirements are satisfied.
