#!/bin/sh
set -eu
cd "$(dirname "$0")"
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
# No CRT, standard library, libgcc, compressed instructions or M extension.
"$cc" -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin \
    -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
    -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax \
    -fno-asynchronous-unwind-tables -Wall -Wextra -S solver3.c -o solver3.s
python3 - <<'PYHEADER'
from pathlib import Path
p = Path("solver3.s")
p.write_text("# Compiler-generated RV32I from solver3.c; not hand-written assembly.\n"
             "# Build/link with build_solver3.sh and solver3.ld; load ELF in Ripes.\n" + p.read_text())
PYHEADER
"$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs \
    -Wl,--no-relax,-T,solver3.ld,-Map,solver3.map solver3.s -o solver3.elf
"${prefix}objdump" -d -M no-aliases solver3.elf > solver3.dis
"${prefix}size" -A solver3.elf
if [ -n "$("${prefix}nm" -u solver3.elf)" ]; then
    echo 'ERROR: unresolved external symbols' >&2
    exit 1
fi
if "${prefix}nm" solver3.elf | grep -E '__((u?div|u?mod|mul)[a-z0-9]*|.*[sd]f[23])$'; then
    echo 'ERROR: arithmetic helper found' >&2
    exit 1
fi
echo 'Built solver3.s and solver3.elf without external libraries.'
python3 - <<'PYCHECK'
import re
from pathlib import Path
allowed = set("lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak".split())
ops = set(re.findall(r"^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)", Path("solver3.dis").read_text(), re.M))
assert ops and not ops - allowed, f"Unexpected instructions: {ops - allowed}"
print("Verified: all disassembled instructions are RV32I.")
PYCHECK
