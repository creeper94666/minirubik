# Ripes GUI observations (partial)

Observed on 2026-10-07 with the 5-stage RV32I processor after selecting `solver7_optimization_led.elf` from the project directory. These are actual GUI captures, not CLI-generated diagrams.

## Five stages

![Cycle 4](images/ripes-gui/pipeline-cycle-4.png)

At cycle 4: IF `0x10`, ID `0x0c`, EX `0x08`, MEM `0x04`, WB `0x00`. This shows five different startup instructions occupying the five stages simultaneously.

## Memory write enable

![Cycle 10](images/ripes-gui/pipeline-cycle-10-store.png)

At cycle 10, `sb x0, 0(x5)` at `0x1c` is in MEM and the data-memory write-enable indicator is green. Register x5 is `0x2ec7c`; x6 is `0x2ec80`. This captures the BSS-clear store. A before/after memory-content capture is still pending.

## Control-hazard flush

![Cycle 12](images/ripes-gui/pipeline-cycle-12-flush.png)

At cycle 12, after `jal x0, -12` at `0x24`, IF has returned to `0x18`; ID and EX display red `nop (flush)` labels. The younger sequential instructions were flushed.

## Remaining evidence

Forwarding selection, a load-use stall, before/after memory contents, and the initial LED GUI capture plus consecutive-move verification remain incomplete. Intermediate and solved LED captures are included below. This page does not claim completion of the GUI requirements.

## Actual LED GUI playback

The LED Matrix was added in Ripes on 2026-10-08. Its exported base is `0xf0000000`, width `0x23` (35), and height `0x19` (25), matching `solver7_gui.elf`. Playback used the RV32I ISA simulator; M and C were disabled. Execution was paused for screenshots.

![Observed intermediate LED state](images/ripes-gui/led-observed-intermediate.png)

![A different observed LED state](images/ripes-gui/led-observed-next.png)

![Solved LED state](images/ripes-gui/led-solved.png)

The two intermediate captures show different color arrangements; the solved capture shows six uniformly colored faces. These samples establish actual peripheral output and changing frames, but do not yet establish each consecutive move, the initial input frame, or an indexed correspondence between screenshots and replay steps.
