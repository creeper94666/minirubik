#!/bin/sh
set -eu
cd "$(dirname "$0")"
python3 tools/generate_solver7_search_sequences.py > solver7_search_sequences.h.tmp
mv solver7_search_sequences.h.tmp solver7_search_sequences.h
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
"$cc" -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin \
    -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
    -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax \
    -fno-asynchronous-unwind-tables -Wall -Wextra -S solver7_search.c -o solver7_search.s
"$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs \
    -Wl,--no-relax,-T,solver7.ld,-Map,solver7_search.map solver7_search.s -o solver7_search.elf
"${prefix}objdump" -d -M no-aliases solver7_search.elf > solver7_search.dis
"${prefix}size" -A solver7_search.elf
test -z "$("${prefix}nm" -u solver7_search.elf)"
python3 - <<'PY'
import re, subprocess
from pathlib import Path
allowed=set('lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak'.split())
ops=set(re.findall(r'^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)',Path('solver7_search.dis').read_text(),re.M))
assert ops and not ops-allowed, ops-allowed
print('PASS: RV32I-only, link budget, no unresolved symbols.')
PY
