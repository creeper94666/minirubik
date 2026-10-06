#!/bin/sh
set -eu
cd "$(dirname "$0")"
python3 tools/export_solver7_search_sequences_asm.py
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
"$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs -Wl,--no-relax,-T,solver7.ld,-Map,solver7_optimization.map solver7_optimization.s -o solver7_optimization.elf
"${prefix}objdump" -d -M no-aliases solver7_optimization.elf > solver7_optimization.dis
"${prefix}size" -A solver7_optimization.elf
test -z "$("${prefix}nm" -u solver7_optimization.elf)"
