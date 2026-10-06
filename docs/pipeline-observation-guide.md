# Personal GUI observation worksheet

This is an AI-created procedure, not a record of observed GUI signals. Complete
the observations yourself for the exact source/binary used in your report.

## LED demonstration

1. Instantiate LED Matrix 0, width 35 and height 25, and copy its exported base.
2. Run `python3 tools/build_solver7_optimization_led.py --render 1 --base YOUR_EXPORTED_BASE --output solver7_gui`.
3. Load `solver7_gui.elf` as an ELF executable in Ripes. Select RV32I without M/C.
4. Run the solver. Its actual solution is printed and internally replay-verified
   before LED replay starts. The renderer displays the input then every returned
   move. The default is an infinite replay of that computed solution.
5. Capture the initial cube, an intermediate frame and solved frame. Check all
   six colors and the unfolded net. Record the binary hash, processor model and
   peripheral exports. A RAM test is not evidence of these visible observations.

## Short pipeline example

Load the renderer-disabled `solver7_optimization_led.elf`, select the five-stage
processor with hazard detection/forwarding, and step from reset. This avoids
waiting for a full search merely to inspect a few instructions. With the current
renderer-disabled binary, the startup sequence includes:

```asm
# PC 0x18
bgeu t0,t1,done_clear
sb   zero,0(t0)
addi t0,t0,1
jal  zero,clear_loop
```

Use the disassembly of your exact binary for addresses; enabling the renderer
changes data addresses and BSS length. The current renderer-disabled BSS starts
at 0x2ec7c and ends at 0x2ec80, so the loop writes four zero bytes.

Record observations for each instruction as it traverses IF, ID, EX, MEM and WB:

| Observation to record | Expected behavior to check, not an observed result |
| --- | --- |
| Instruction/PC in each stage | Match the active instruction to the corresponding stage register |
| `sb` source/address inputs | Store data comes from x0; address uses t0 plus immediate zero |
| Memory write control | `sb` writes one byte during the memory stage |
| Register write enable | Store and conditional branch do not write a general-purpose register; `addi` updates t0 |
| ALU input selection | Address/add-immediate operations select the immediate operand |
| WB input selection | The `addi` result comes from the ALU path |
| Branch/PC selection | `bgeu` exits once t0 reaches t1; `jal x0` redirects PC without retaining a link |
| Forwarding or stalls | Record what the selected model actually does when dependent instructions overlap |
| Memory before/after | Check the bytes in [t0_initial,t1); observe which cycle changes each byte |

Do not invent exact mux labels or waveform values: labels and signals depend on
the Ripes build/model. Include annotated screenshots and explain your actual
observations in your own words. The CLI model test proves execution results,
not the contents of a signal walkthrough.
