#!/bin/sh
set -eu
cd "$(dirname "$0")"
host_cc=${HOST_CC:-cc}
generator=$(mktemp "${TMPDIR:-/tmp}/solver6-generator.XXXXXX")
trap 'rm -f "$generator" solver6_tables.h.tmp' EXIT HUP INT TERM
"$host_cc" -O2 -fno-builtin -Wall -Wextra tools/generate_solver6_tables.c -o "$generator"
"$generator" > solver6_tables.h.tmp
mv solver6_tables.h.tmp solver6_tables.h
cc=${RISCV_CC:-riscv64-elf-gcc}
prefix=${cc%gcc}
# No CRT, standard library, libgcc, compressed instructions or M extension.
"$cc" -O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin \
    -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables \
    -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax \
    -fno-asynchronous-unwind-tables -Wall -Wextra -S solver6.c -o solver6.s
python3 - <<'PYHEADER'
from pathlib import Path
p = Path("solver6.s")
p.write_text("# Compiler-generated RV32I from solver6.c; not hand-written assembly.\n"
             "# Build/link with build_solver6.sh and solver6.ld; load ELF in Ripes.\n" + p.read_text())
PYHEADER
"$cc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -nodefaultlibs \
    -Wl,--no-relax,-T,solver6.ld,-Map,solver6.map solver6.s -o solver6.elf
"${prefix}objdump" -d -M no-aliases solver6.elf > solver6.dis
"${prefix}size" -A solver6.elf
if [ -n "$("${prefix}nm" -u solver6.elf)" ]; then
    echo 'ERROR: unresolved external symbols' >&2
    exit 1
fi
if "${prefix}nm" solver6.elf | grep -E '__((u?div|u?mod|mul)[a-z0-9]*|.*[sd]f[23])$'; then
    echo 'ERROR: arithmetic helper found' >&2
    exit 1
fi
echo 'Built solver6.s and solver6.elf without external libraries.'
python3 - <<'PYCHECK'
import re
from pathlib import Path
allowed = set("lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak".split())
ops = set(re.findall(r"^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)", Path("solver6.dis").read_text(), re.M))
assert ops and not ops - allowed, f"Unexpected instructions: {ops - allowed}"
print("Verified: all disassembled instructions are RV32I.")
PYCHECK
if "${prefix}nm" solver6.elf | grep -q 'memcpy'; then
    echo 'ERROR: unexpected memcpy symbol' >&2
    exit 1
fi
echo 'Verified: no memcpy symbol or external dependency.'
