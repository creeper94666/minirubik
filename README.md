# minirubik — RV32I coursework

[Current files](#current-rv32i-version) · [Three target tests](#three-target-tests) ·
[H1–H4 / T5–T7](#correctness-gates) · [Performance and memory](#performance-and-memory)

## Current RV32I version

**Start with the files below. `solver7.c` and `solver7.s` are older baselines;
the current C solver is `solver7_search.c`.**

| Component | Current source | Build / guide |
| --- | --- | --- |
| C solver | [solver7_search.c](solver7_search.c) | [build_solver7_search.sh](build_solver7_search.sh), [C guide](solver7_search_README.md) |
| Optimized RV32I solver | [solver7_optimization.s](solver7_optimization.s) | [build_solver7_optimization.sh](build_solver7_optimization.sh) |
| Shared GUI / CLI assembly | [solver7_optimization_led.s](solver7_optimization_led.s) | [LED build guide](solver7_optimization_led_README.md), [builder](tools/build_solver7_optimization_led.py) |
| LED rendering and replay | [cube_led.c](cube_led.c), [cube_led.h](cube_led.h), [solver7_led_replay.c](solver7_led_replay.c) | Used by the shared assembly builder |

Build the current C and renderer-disabled assembly:

```sh
sh build_solver7_search.sh
sh build_solver7_optimization.sh
python3 tools/build_solver7_optimization_led.py --render 0
```

For LED animation, follow the [GUI build instructions](solver7_optimization_led_README.md#gui-build)
and supply the peripheral base exported by Ripes. `RENDER=0` disables the renderer;
`RENDER=1` enables it in the shared source.

The current assembly passes all **2,644 distance-11 inputs**, with a maximum of
**38,543,830 retired instructions** on the pinned RV32_ISS build. Solved, one-move
and distance-11 cases also pass on RV32_5S. See [validation evidence](measurements/solver7_submission_validation/README.md).

Development code and records include disclosed AI assistance. See
[submission status](docs/submission-status.md) for remaining student-owned work
and GUI observations; these results do not mean the entire assignment is complete.

## Assignment verification results

The results below apply to the **current version**, with rendering disabled.
They are AI-executed development measurements; independent student measurements
and analysis remain required. Links lead directly to the supporting records.

### Three target tests

All three return the expected shortest length and pass independent solution replay
on both processors, with no ISA extensions enabled.

| Test | Input | Optimal moves | RV32_ISS retired instructions | RV32_5S retired instructions |
| --- | --- | ---: | ---: | ---: |
| Solved | `12345671111111` | 0 | [424](measurements/solver7_submission_validation/models/RV32_ISS-12345671111111.json) | [423](measurements/solver7_submission_validation/models/RV32_5S-12345671111111.json) |
| One move | `25314672313211` | 1 | [1,236](measurements/solver7_submission_validation/models/RV32_ISS-25314672313211.json) | [1,235](measurements/solver7_submission_validation/models/RV32_5S-25314672313211.json) |
| Distance 11 | `21345671111111` | 11 | [15,147,934](measurements/solver7_submission_validation/models/RV32_ISS-21345671111111.json) | [15,147,933](measurements/solver7_submission_validation/models/RV32_5S-21345671111111.json) |

For **`21345671111111`**, the returned 11-move solution is:

```text
R B' D2 R' B R' B' R D2 R B
```

Counts differ by one between models; each measured count is reported without
adjustment. [All six results](measurements/solver7_submission_validation/models/summary.json)
and [raw logs / instruction reports](measurements/solver7_submission_validation/models/)
are retained.

### Correctness gates

| Gate | Result and coverage | Evidence |
| --- | --- | --- |
| H1 — admissible heuristic | PASS for all 3,674,160 states against exact BFS distances | [H1/H2 summary](measurements/solver7_search/full/host/oracle-summary.json) |
| H2 — distance tables | PASS: legal/unused slots, solved entries and maxima checked; permutation maximum 7, orientation maximum 6 | [H1/H2 summary](measurements/solver7_search/full/host/oracle-summary.json) |
| H3 — optimal search | PASS for all 3,674,160 C states, with optimal lengths and independent replay; 415.31 s using four workers | [H3 summary](measurements/solver7_search/full/host/summary.json), [reproduction commands](measurements/solver7_search/README.md) |
| H4 — packed accessors | No nibble-packed distance table is used. Canonical move masks are separately checked over 8,080 contexts | [Applicability](docs/submission-status.md#validation-evidence), [mask test](tests/solver7_search_assembly_test.py) |
| T5 — target replay | PASS for all 2,644 distance-11 assembly runs and the three model-test inputs | [Per-input results](measurements/solver7_submission_validation/ripes/results.csv), [model results](measurements/solver7_submission_validation/models/summary.json) |
| T6 — specified input | PASS: `21345671111111` returns 11 moves and replays to solved | [Specified-input result](measurements/solver7_submission_validation/models/RV32_ISS-21345671111111.json) |
| T7 — processor models | All three selected inputs PASS on RV32_ISS and RV32_5S; unseen grader inputs are not claimed as already tested | [Six model tests](measurements/solver7_submission_validation/models/summary.json), [runner](tools/validate_submission_models.py) |

H3 exhaustively validates the **C search**. The assembly evidence covers all
2,644 distance-11 states and the listed model cases, not every legal assembly input.
A CLI pipeline run does not replace the required personal GUI signal walkthrough
or live LED demonstration. [Actual GUI captures](docs/ripes-gui-observations.md) now document five occupied stages, a store write-enable, a control-hazard flush, and intermediate/solved LED states. Additional captures now show forwarding and a load-use stall. Initial-state capture, consecutive-move verification, and before/after memory contents remain outstanding.

### Performance and memory

Counts include startup, search, internal replay, output and exit on the pinned
RV32_ISS build. Static data means `.rodata + .data + .bss`; code size means linked
`.text`, with the renderer compiled out.

| Metric | Required limit | Current optimized assembly |
| --- | ---: | ---: |
| Worst case over all 2,644 distance-11 inputs | ≤ 50,000,000 retired instructions | **38,543,830 — PASS**; 0 inputs above the limit |
| Worst-case input | — | `54721631111111` |
| Specified input `21345671111111` | Report separately | **15,147,934** retired instructions |
| `.rodata` | — | 126,060 bytes |
| `.data` | — | 15 bytes |
| `.bss` | — | 4 bytes |
| **Total static data** | **≤ 131,072 bytes (128 KiB)** | **126,079 bytes — PASS** |
| Linked `.text` | Compare with final C | 4,296 bytes |
| Reserved stack, separate from static-data total | Report working memory | 4,096 bytes |

| Final C vs assembly, same inputs/build conventions | C, GCC `-O2` | Optimized assembly |
| --- | ---: | ---: |
| `21345671111111` retired instructions | 31,343,837 | 15,147,934 |
| `54721631111111` retired instructions | 79,635,246 | 38,543,830 |
| Linked `.text` | 2,752 bytes | 4,296 bytes |
| Static data | 126,088 bytes | 126,079 bytes |

The assembly executes fewer instructions but uses more code bytes; specialized
move bodies and indexing trade code size for execution cost.

Evidence: [full sweep summary](measurements/solver7_submission_validation/ripes/summary.json),
[all 2,644 counts and paths](measurements/solver7_submission_validation/ripes/results.csv),
[C comparison](solver7_search_README.md),
[compiler / Ripes build](measurements/solver7_submission_validation/environment.json),
[source / binary fingerprints](measurements/solver7_submission_validation/fingerprints.json).

New 2026-10-07 evidence: [12 Stage 1 samples, methods and limitations](docs/remaining-verification-results.md), [current report corrections and upstream section-7 critique](docs/report-final-review.md). New 2026-10-08 [actual GUI evidence](docs/ripes-gui-observations.md) includes screenshots of pipeline stages, store enable, flush, forwarding, a load-use stall, and intermediate/solved LED output. The linked page lists remaining observations; the earlier [GUI attempt log](measurements/gui_followup_20261007/gui/attempt-log.md) is historical.

Other required measurements: [Stage 1 memory/rate reproduction aid and qualified pilot results](measurements/stage1_support/README.md)
and [step-by-step assembly optimization measurements](measurements/solver7_pruning/README.md).

## Historical files — retained for comparison

| Files | Role |
| --- | --- |
| `solver.c`, `mini.c`, `Makefile`, `report.md` | Upstream host BFS solver, oracle/reference and documentation |
| `solver2.c` through `solver7.c` | Earlier C development stages |
| `solver3.s` through `solver7.s` | Compiler-generated assembly for earlier C stages |
| `build_solver3.sh` through `build_solver7.sh` | Build the corresponding historical stages |
| `solver7_led.c`, `build_solver7_led.sh` | Earlier C-based LED integration |
| `test_all.c` | Historical solver2 test; not exhaustive verification of the current solver |

These files preserve the optimization history and reference implementations.
Their measurements apply to their own versions. Use the current-version table
above for new builds; the upstream instructions below describe the host baseline.

---

## Upstream host solver — historical baseline

An optimal C99 solver for the 2×2×2 Rubik’s Cube. It builds a breadth-first
table for all 3,674,160 states and solves every valid position in at most 11
half-turn-metric moves.

### Why a cube is a graph

Ernő Rubik created the original cube in 1974 to demonstrate how parts can move
independently without breaking the whole. A 3×3 cube has 20 moving pieces and
about 4.3 × 10¹⁹ reachable arrangements. The smaller 2×2 cube keeps the eight
corners and removes the edges and fixed centers. [Philo Li’s formula-free
introduction](https://philoli.com/zh/blog/solve-rubiks-cube-without-formulas/)
offers the key intuition: every turn is reversible, turns can be composed, and
their order matters—`R U` is generally not `U R`.

Human solvers use those facts to move a few pieces while restoring the rest;
the commutator `A B A⁻¹ B⁻¹` is the standard example. This program uses the
same group structure differently: it treats every valid arrangement as a node,
every face turn as an edge, and searches the entire graph once. It does not use
the article’s 3×3 Roux stages or a library of memorized algorithms.

The solver gives the eight corner positions the numbers `0–7`. The 2.5D
walkthrough below shows where those numbers are on the physical cube.

### How it works

1. Fix one corner to remove whole-cube rotations.
2. Rank the remaining corner permutation and six independent orientations into
   a dense integer.
3. Breadth-first search outward from solved using `R`, `B`, and `D`, including
   inverse and half turns.
4. Store one move toward solved for every state; following those moves gives an
   optimal solution of at most 11 moves.

### Build and run the upstream host baseline

```sh
make
make check
make prove   # optional: Frama-C WP proof, needs frama-c and alt-ergo
./solver 21345671111111
```

`make` builds two binaries. `solver` is the documented one, with contracts, a
`--self-test` mode, and diagnostics on stderr. `mini` is a golfed variant that
solves the same input and prints the same line, kept as a readability contrast;
it has no `--self-test` and prints nothing on failure, and it trades roughly
eight times the runtime and three times the memory for its brevity.

The 14-digit argument describes the scramble and the printed line is the
solution. Both formats are explained below.

#### Reading the 14-digit input

The program receives one 14-digit code with no spaces. For explanation, split
it into two groups:

```diagram
2134567 1111111
└── P ─┘ └── O ─┘
  cubies   twists
```

Imagine seven numbered seats and seven students. A position is a seat fixed in
space; a cubie is the physical corner that can move to another seat. In the
solved cube, cubie 1 sits in position 1, cubie 2 in position 2, and so on.
The real cube has no printed numbers; `0–7` are labels used only by this solver.

##### Step 1: Hold the cube in one direction

Keep `FRONT` facing you and `UP` pointing upward. Position `0` is the corner
nearest the upper-left of the front face. It is an anchor for describing the
other corners; the physical cubie is not glued in place.

```diagram
                              BACK
                    ·───────────────·
                   ╱               ╱│
                  ╱        UP     ╱ │
                 ╱               ╱  │
              [0]───────────────·   │
               │                │   │
               │     FRONT      │ R │
               │                │   ·
               │                │  ╱
               │                │ ╱
               │                │╱
               ·────────────────·
```

`R` marks the narrow `RIGHT` face.

##### Step 2: Separate the front and back layers

A 2×2×2 cube has only corner cubies. Looking from the fixed direction, four
corner positions touch the front face and four touch the back face. Each
bracketed number below names one whole corner, not one colored sticker:

```diagram
 FRONT LAYER                          BACK LAYER

 upper-left   upper-right             upper-left   upper-right
     [0]────────[1]                       [7]────────[4]
      │          │                         │          │
      │          │       front ↔ back      │          │
     [3]────────[2]                       [6]────────[5]
 down-left    down-right               down-left    down-right
```

The front layer runs clockwise from its upper-left corner as `0, 1, 2, 3`.
The back layer is drawn as if seen through the cube from the front: `7` is
upper-left, followed clockwise by `4, 5, 6`.

##### Step 3: Join the two layers into positions 0–7

Slide the back square up and to the right, the same direction the cube recedes
in Step 1, to get the complete 2.5D position map. The back edges are drawn
through the front face rather than hidden behind it:

```diagram
                           BACK
                      [7]────────[4]
                     ╱ │        ╱ │
                  [0]──│─────[1]  │
                   │   │      │   │
                   │  [6]─────│──[5]
                   │ ╱        │ ╱
                  [3]────────[2]
                      FRONT
```

The seven characters of `P` describe positions `1, 2, 3, 4, 5, 6, 7` in that
order; the anchor at position `0` is left out.

##### Step 4: Put the cubies into those positions

Compare the position map on the left with the filled cube on the right. Read
`P = 2134567` from left to right to fill the positions. The arrows below the
figure identify the two positions that change.

```diagram
 POSITION MAP                             AFTER P = 2134567
 (fixed seats)                            (cubies now in seats)

     [7]────────[4]                           [7]────────[4]
    ╱ │        ╱ │                           ╱ │        ╱ │
 [0]──│─────[1]  │                        [0]──│─────[2]  │
  │   │      │   │                         │   │      │   │
  │  [6]─────│──[5]                        │  [6]─────│──[5]
  │ ╱        │ ╱                           │ ╱        │ ╱
 [3]────────[2]                           [3]────────[1]
     FRONT                                    FRONT

 position:     1 2 3 4 5 6 7
 P says:       2 1 3 4 5 6 7
               │ │ └───────── cubies 3–7 stay in their matching seats
               │ └─────────── put cubie 1 in position 2: [2] becomes [1]
               └───────────── put cubie 2 in position 1: [1] becomes [2]
```

So the first two digits, `21`, exchange the two corners on the front-right
edge. The remaining digits, `34567`, leave the other five movable corners
where they were. `P` must contain every digit from `1` through `7` exactly
once; otherwise a cubie would be missing or duplicated.

The seven seats named by `P` are:

| Position | Corner of the cube |
| :---: | :--- |
| 1 | front, upper, right |
| 2 | front, down, right |
| 3 | front, down, left |
| 4 | back, upper, right |
| 5 | back, down, right |
| 6 | back, down, left |
| 7 | back, upper, left |

The second group, `O = 1111111`, describes the twist of the cubie in each of
those same seven positions:

| Digit | Meaning |
| :---: | :--- |
| 1 | not twisted |
| 2 | twisted by +120° |
| 3 | twisted by −120° |

Here every orientation digit is `1`, so the two corners change places without
being twisted. For a valid cube, convert orientation digits to `0`, `1`, and
`2`; their sum must be divisible by three. The solved code is
`12345671111111`. `make check` uses the exchanged-corner example above.

### Reading the solution

```sh
$ ./solver 21345671111111
B' R' D2 R' B R B' R D2 B R'
```

Each token is one face turn. Apply them left to right; after the last one the
cube is solved.

| Token | Meaning |
| :---: | :--- |
| `R` | turn the `RIGHT` face 90° clockwise |
| `B` | turn the `BACK` face 90° clockwise |
| `D` | turn the `DOWN` face 90° clockwise |

Clockwise means clockwise as seen by someone looking directly at that face from
outside the cube, so you have to walk around to the back to read `B` and look up
from underneath to read `D`. Two suffixes modify a turn:

| Suffix | Meaning |
| :---: | :--- |
| none | 90° clockwise |
| `'` | 90° counterclockwise, the inverse |
| `2` | 180°, direction does not matter |

`R`, `B`, and `D` are the only faces that appear, because turning `UP`, `FRONT`,
or `LEFT` would move the anchor at position `0`. A turn counts as one move
whichever suffix it carries, which is the half-turn metric; under that metric no
position needs more than 11 moves. Solving an already-solved cube prints an
empty line.

See [`report.md`](report.md) for the model, algorithm, diagrams, and Frama-C
validation notes.
