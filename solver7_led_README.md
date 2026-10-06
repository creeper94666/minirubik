# Solver7 C LED replay

> **Historical C-based LED integration.** The current GUI / CLI build is
> [solver7_optimization_led.s](solver7_optimization_led.s); follow its
> [LED build guide](solver7_optimization_led_README.md).
> This page's commands and results apply to the older `solver7_led.c` integration.

AI-assisted C prototype. The solver first computes and validates a complete solution, then renders the initial state and one frame after each solution move. Half turns are one frame/HTM move. Invalid inputs or failed validation do not draw. The existing optimized assembly is unchanged; this renderer currently integrates with the C solver7 implementation.

## Representation and geometry

Internal p/o values are zero-based. The input text uses 1..7 and 1..3 and is converted by parse_state.

| Slot/cubie ID | Corner | Ordered sticker faces |
|---|---|---|
| 0 | UFR | U R F |
| 1 | DFR | D F R |
| 2 | DFL | D L F |
| 3 | UBR | U B R |
| 4 | DBR | D R B |
| 5 | DBL | D B L |
| 6 | UBL | U L B |
| 7 (implicit fixed) | UFL | U F L |

For destination corner slot s and sticker slot k, the color comes from the ordered home sticker `(k + o[s]) mod 3` of cubie `p[s]`. The fixed UFL corner is restored with cubie 7 and orientation 0. Face cells are row-major TL, TR, BL, BR, viewed from outside the cube. U has B on its top edge; D has F on its top edge; B is viewed from behind. Tests use an independent xyz sticker-rotation oracle rather than copying the renderer tables.

| Face | Origin x,y | Solved color / ID |
|---|---|---|
| U | 9,2 | White / 1 |
| L | 0,9 | Orange / 2 |
| F | 9,9 | Green / 3 |
| R | 18,9 | Red / 4 |
| B | 27,9 | Blue / 5 |
| D | 9,16 | Yellow / 6 |

0 is off/black. Each facelet occupies 4x3 pixels, each face 8x6, adjacent faces have a one-pixel gap. The net is 35x20, placed within 35x25 with two blank rows above and three below. Within a face there is no extra gap between facelets.

For face cell c (0..3) and local pixel dx=0..3, dy=0..2:

```
x = face_origin_x + (c & 1)*4 + dx
y = face_origin_y + (c >> 1)*3 + dy
byte_offset = 4 * (y*35 + x)
address = LED_MATRIX_0_BASE + byte_offset
```

`measurements/solver7_led/facelet_offsets.csv` lists all 24 facelets and their 12 byte offsets. A 875-byte buffer stores color IDs. `cube_led_write` translates IDs into RGB words and writes through a volatile 32-bit pointer: `base[y*35+x]`. Do not multiply by four again when indexing this pointer. Color IDs 0..6 are NOT directly written as LED colors. RGB palette: 000000, FFFFFF, FF8000, 00FF00, FF0000, 0000FF, FFFF00.

Official Ripes MMIO example: https://github.com/mortbopet/Ripes/blob/master/examples/C/switchesAndLeds.c

## Host tests and preview

```sh
cc -O2 -fno-builtin -Wall -Wextra -Wno-unused-function -fsanitize=undefined,address tests/solver7_led_test.c cube_led.c -o /tmp/solver7_led_test
/tmp/solver7_led_test measurements/solver7_led/frames.json
python3 tools/preview_solver7_led.py
open measurements/solver7_led/preview.html
```

The preview plays the actual C-generated pixel frames, not a separate JavaScript cube simulation. It has play/pause and a step slider. Input `21345671111111` produces 12 frames: initial plus 11 moves. Static initial/solved preview: `measurements/solver7_led/initial_and_solved.png`.

Tests pass: 9000 geometric move comparisons across 1000 reachable states and all nine moves, solved face colors, 288 unique pixel offsets in range, exactly 48 pixels per color and 587 off pixels, guard-protected RGB writes, solved/invalid/11-move replay and solved final frame. Existing solver7 host tests also pass, including all 3,674,160 heuristic values.

## Ripes build and configuration

1. Add an LED Matrix in the I/O tab and configure width 35, height 25.
2. Copy its actual LED_MATRIX_0_BASE address.
3. Build `sh build_solver7_led.sh YOUR_ACTUAL_BASE_ADDRESS 1000000` (replace the address placeholder).
4. Load solver7_led.elf, run, and view the LED Matrix. Keep the I/O configuration used when building.

The optional second argument is delay-loop iterations, NOT milliseconds; adjust it for your GUI speed. It defaults to 1000000, and 0 disables delay. The LED target now loops the replay indefinitely after solving once; use Run/F8 to pause. Each cycle starts from the original scrambled state. The initial frame is drawn only after search and replay validation finish, as requested. This draws discrete move states, not intermediate physical turning animation.

C entry: solver7_led.c; mapping: cube_led.c/.h; opt-in replay hook: SOLVER7_LED in solver7.c. Ordinary build_solver7.sh does not define SOLVER7_LED and therefore performs no rendering/delay.

A compile-only build with base 0 checks the toolchain, RV32I instruction set and section budget; it is preserved as measurements/solver7_led/compile_check_not_for_mmio.elf and MUST NOT be run to drive hardware. No real base address has been supplied, so live Ripes LED display and wall-clock pacing have not been tested.

Compile-only build size: .text 3836, .rodata 118780, .data 15, .bss 880 bytes. Static data totals 119675 bytes, leaving 11397 bytes under 128 KiB. No unresolved symbols or non-RV32I instructions. Actual base-address compilation can change instruction encoding/size. The renderer-enabled C binary does not inherit the 34,934,509-instruction measurement of the separately optimized renderer-free assembly, and delay instructions should not be included in solver-only benchmarks.

Renderer-disabled C assembly was compared with the preserved solver7.s: identical except source-line comments.

## Confirmed Ripes setup (2026-10-05)

LED Matrix 0 exports base 0xf0000000, size 0xdac, width 35, height 25. Built with `sh build_solver7_led.sh 0xf0000000 10000`; loaded solver7_led.elf into the GUI and started RV32I 5-stage execution. See measurements/solver7_led_pipeline for the completed independent RAM/pipeline test and live-display status.

## Looping replay (2026-10-05)

solver7_led.c defines SOLVER7_LED_LOOP. The replay loop is located after solve and validation, so search executes once. Each pass resets the state to start and applies the saved solution. Non-LED builds and single-pass host tests are unchanged. tests/solver7_led_loop_test.c verifies three identical 12-frame cycles with a single printed solution; sanitizer tests passed. Built with base 0xf0000000 and delay 10000 and loaded/run on the GUI five-stage model. New .text: 3804 bytes; static data unchanged at 119675 bytes. Live execution was observed Running; repeated GUI frames have not yet been observed.
