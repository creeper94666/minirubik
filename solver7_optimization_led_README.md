# Optimized solver7 plus compiled C LED replay

Deliverable: solver7_optimization_led.s (self-contained assembly with tables and renderer), solver7_optimization_led.elf. Original solver7_optimization.s is unchanged.

The builder preserves the optimized search and hooks the successful solver7_run return block, after the original solution replay verification and printed solution. ABI inputs to led_replay: a0=start state at sp+20, a1=solution at sp+68, a2=length from t0. t4 is saved/restored for finite tests. Stack alignment and the original return address are preserved. The C replay and cube_led units are compiled to RV32I with unique local label prefixes and appended. No hand-specialized search code is replaced with compiler output.

Configuration: LED Matrix 0 at 0xf0000000, 35x25, delay 10000 loop iterations per frame. Search runs once. The initial cube and the computed eleven solution moves replay forever. This is automatic looping; D-Pad previous/next control is not included because no D-Pad base has been provided.

Rebuild:

```sh
python3 tools/build_solver7_optimization_led.py
```

Override options: --base 0xf0000000 --delay 10000 --cycles 0. Zero cycles means infinite replay; positive cycles are for finite verification. This default base matches the user's confirmed Ripes device exports, not a universal Ripes address.

Load solver7_optimization_led.elf through Ripes File > Load Program > Executable (ELF). Keep the 35x25 LED Matrix at the configured address. Loading restarts the program and therefore requires one initial search. Existing running GUI program is not replaced automatically by this build.

.text 4904 bytes. Static data: .rodata 118828 + .data 15 + .bss 888 = 119731 bytes; 11341 bytes remain under 128 KiB. RV32I-only and no unresolved external symbols verified.

Validation:

- Sanitized host test tests/solver7_optimization_led_test.c: 24 frames (two full loops) and every RGB word match the original apply_move reference, including initial and solved states.
- Actual Ripes RV32_ISS integration test: compiled with RAM output base 0x40000, delay 0, two replay cycles; printed the same 11-move solution and exited with code 0. 35,251,419 retired instructions, including both replay rounds and all setup. This is not a solver-only benchmark or live MMIO display verification.
- Live GUI playback of this new combined binary has not been verified. Prior C-only LED binary was displayed successfully.

```sh
cc -O2 -fno-builtin -Wno-unused-function -fsanitize=undefined,address tests/solver7_optimization_led_test.c cube_led.c -o /tmp/solver7_optimization_led_test
/tmp/solver7_optimization_led_test
python3 tools/build_solver7_optimization_led.py --base 0x40000 --delay 0 --cycles 2 --output measurements/solver7_optimization_led/test_two_rounds
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src measurements/solver7_optimization_led/test_two_rounds.elf -t elf --proc RV32_ISS --iret --cycles --runinfo --timeout 0 -v --output measurements/solver7_optimization_led/test-iret.txt > measurements/solver7_optimization_led/test.log 2>&1
```

AI-assisted experimental assembly combination; source C is solver7_led_replay.c and cube_led.c. The final assembly contains everything needed to assemble/link with solver7.ld.
