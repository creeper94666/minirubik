# AI-created reproducibility aid; students must independently run and analyze it.
# REGION_BYTES and ITERATIONS are explicit assembler parameters.
.section .text
.globl _start
_start:
    li a0, 0x400000
    li a1, 0x400000 + REGION_BYTES
    li t0, ITERATIONS
loop:
    sw t0, 0(a0)
    addi a0, a0, 4
    bltu a0, a1, next
    li a0, 0x400000
next:
    addi t0, t0, -1
    bnez t0, loop
    li a0, 0
    li a7, 93
    ecall
