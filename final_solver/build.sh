#!/bin/sh
set -eu
cd "$(dirname "$0")"
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
case "${1:-asm}" in
asm)
    "$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs -Wl,--no-relax,-T,solver7.ld solver7_optimization.s -o solver7_optimization.elf
    output=solver7_optimization.elf
    ;;
c)
    "$cc" -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax -fno-asynchronous-unwind-tables -Wall -Wextra -S solver7_search.c -o solver7_search.s
    "$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs -Wl,--no-relax,-T,solver7.ld solver7_search.s -o solver7_search.elf
    output=solver7_search.elf
    ;;
*) echo 'Usage: sh build.sh [asm|c]' >&2; exit 2 ;;
esac
test -z "$("${prefix}nm" -u "$output")"
"${prefix}size" -A "$output"
