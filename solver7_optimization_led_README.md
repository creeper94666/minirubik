# Shared solver and LED assembly source

`solver7_optimization_led.s` combines the current optimized solver with the
C-compiled renderer. This is AI-assisted development code, not independently
student-written assembly. `RENDER` is an assembler-time switch, defaulting to 0.

## Measurement build

```sh
sh build_solver7_optimization.sh
python3 tools/build_solver7_optimization_led.py --render 0
python3 tests/solver7_renderer_switch_test.py
```

The generated source embeds the sequence table, so it does not depend on an
external assembly include. With `RENDER=0`, the renderer and its hook/data are
absent. All allocated file bytes equal `solver7_optimization.elf`, as checked by
`objcopy -O binary`. The solver is therefore exactly the measured implementation.
Static data is 126,079 bytes and linked `.text` is 4,296 bytes.

## GUI build

Create LED Matrix 0 in Ripes with Width=35 and Height=25. Copy its exported
`LED_MATRIX_0_BASE` value; do not assume the address from another setup.

```sh
python3 tools/build_solver7_optimization_led.py --render 1 --base YOUR_EXPORTED_BASE --output solver7_gui
```

Load `solver7_gui.elf` with File > Load Program > Executable (ELF). The builder
passes `RENDER`, `LED_MATRIX_0_BASE`, `LED_MATRIX_0_WIDTH`, and
`LED_MATRIX_0_HEIGHT` as assembler symbols. The base is an absolute symbolic
relocation in the renderer; width and height are assembly-time checked against
the renderer's 35-column row stride and 25-row buffer. Invalid geometry fails
assembly. The source contains no assumed peripheral address.

The shared source is identical for GUI and CLI; only the renderer switch and
its peripheral symbols differ. Default frame delay remains 10,000 iterations;
default replay remains infinite. Search runs once, then actual returned moves
are replayed from the input state. Each move redraws all facelets.

## Verification

```sh
cc -O2 -fno-builtin -Wno-unused-function -fsanitize=undefined,address tests/solver7_optimization_led_test.c cube_led.c -o /tmp/replay-test
/tmp/replay-test
python3 tools/build_solver7_optimization_led.py --render 1 --base 0x40000 --delay 0 --cycles 2 --output measurements/solver7_submission_validation/led_ram
python3 tools/validate_submission_models.py
```

The host test compares 24 frames and all RGB words against independently applied
moves. The finite target RAM test exits successfully after two replay rounds,
using 15,464,846 retired instructions on RV32_ISS. Its static data is 127,099
bytes and linked `.text` is 5,456 bytes. RAM at 0x40000 is a test destination,
not the GUI peripheral address. This count includes rendering and is not the
renderer-disabled performance result.

Raw ISS and RV32_5S model checks are in
`measurements/solver7_submission_validation/models/`. A successful CLI pipeline
run does not replace a personal GUI demonstration or signal walkthrough.
Live MMIO animation of this new combined version has not yet been observed.
