#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ "$#" -lt 1 ]; then
    echo 'Usage: sh build_solver7_led.sh LED_MATRIX_0_BASE [delay_iterations]' >&2
    echo 'Copy the base from the Ripes I/O tab after adding a 35x25 LED Matrix.' >&2
    exit 2
fi
led_base=$1
led_delay=${2:-1000000}
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
"$cc" -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin \
    -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
    -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax \
    -fno-asynchronous-unwind-tables -Wall -Wextra \
    -DLED_MATRIX_0_BASE="$led_base" -DLED_FRAME_DELAY="$led_delay" \
    -nostdlib -nostartfiles -nodefaultlibs \
    -Wl,--no-relax,-T,solver7.ld,-Map,solver7_led.map \
    solver7_led.c cube_led.c -o solver7_led.elf
"${prefix}objdump" -d -M no-aliases solver7_led.elf > solver7_led.dis
"${prefix}size" -A solver7_led.elf
test -z "$("${prefix}nm" -u solver7_led.elf)"
python3 - <<'PY'
import re
from pathlib import Path
allowed=set('lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak'.split())
ops=set(re.findall(r'^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)',Path('solver7_led.dis').read_text(),re.M))
assert ops and not ops-allowed,ops-allowed
print('PASS: RV32I only, no unresolved external symbols; linker enforces static data <=128 KiB.')
PY
