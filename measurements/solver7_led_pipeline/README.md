# Ripes five-stage LED integration verification

GUI processor selected: 5-stage processor, RV32I (M/C disabled), with hazard detection and forwarding.

The user configured LED Matrix 0 at 0xf0000000, width 35, height 25. This was verified in the GUI exports. solver7_led.elf was built with delay 10000, loaded through File > Load Program as ELF, and Run was started on RV32I 5-stage. Visible animation completion is not yet verified.

`solver7_led.c` contained an invalid address identifier (`ㄗㄗ`); this was restored to `LED_MATRIX_0_BASE`. Existing host renderer tests were rerun and passed.

A target RAM test completed successfully with the same C solver/replay and renderer, input 21345671111111, and delay disabled. The forced header replaces the peripheral with 875 RGB words in RAM. It is distinct from the real MMIO build. Its static data is 123175 bytes (including the test buffer), under 128 KiB.

Build and run from repository root:

```sh
riscv64-elf-gcc -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax -fno-asynchronous-unwind-tables -DLED_FRAME_DELAY=0 -include measurements/solver7_led_pipeline/ram_test.h -nostdlib -nostartfiles -nodefaultlibs -Wl,--no-relax,-T,solver7.ld solver7_led.c cube_led.c -o measurements/solver7_led_pipeline/ram_test.elf
/Applications/Ripes.app/Contents/MacOS/Ripes --mode cli --src measurements/solver7_led_pipeline/ram_test.elf -t elf --proc RV32_5S --iret --cycles --cpi --runinfo --timeout 0 -v --output measurements/solver7_led_pipeline/pipeline.txt > measurements/solver7_led_pipeline/pipeline.log 2>&1
```

Completion must be checked in pipeline.log (exit code 0 and solution) and pipeline.txt; an in-progress log is not a passing test. This is the C version, not the hand-specialized solver7_optimization.s.

Once the 35x25 LED Matrix base has been obtained, build with `sh build_solver7_led.sh ACTUAL_BASE 10000`, load solver7_led.elf through File > Load Program, keep the RV32I 5-stage processor, and Run. The explicit 10000 delay is a starting point for the slower pipeline; adjust as needed. The default delay in the source is unchanged. Search completes before the initial cube and solution replay are drawn.

RAM pipeline result: 63,025,325 cycles, 53,952,452 retired instructions, CPI 1.168164238392724, exit code 0. Runtime approximately 13 minutes 38 seconds. This includes C solver and RAM rendering, excludes frame delay, and is not the optimized assembly solver-only measurement.
