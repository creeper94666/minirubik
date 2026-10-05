OUTPUT_ARCH(riscv)
ENTRY(_start)
SECTIONS
{
    . = 0;
    .text : { KEEP(*(.text.start)) *(.text .text.*) }
    . = 0x10000;
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.* .sdata .sdata.*) }
    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss .bss.* .sbss .sbss.*) *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    }
    .stack (NOLOAD) : {
        . = ALIGN(16);
        __stack_bottom = .;
        . += 4096;
        __stack_top = .;
    }
    ASSERT(SIZEOF(.rodata) + SIZEOF(.data) + SIZEOF(.bss) <= 128K,
           "Static data exceeds assignment budget")
    ASSERT(ADDR(.text) + SIZEOF(.text) <= 0x10000, "Text overlaps data")
}
