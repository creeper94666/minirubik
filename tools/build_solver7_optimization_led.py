"""Compile renderer C, namespace local symbols, append to optimized assembly."""
from pathlib import Path
import os,re,subprocess,argparse,tempfile
root=Path(__file__).resolve().parents[1]
os.chdir(root)
p=argparse.ArgumentParser();p.add_argument('--base',default='0xf0000000');p.add_argument('--delay',type=int,default=10000);p.add_argument('--cycles',type=int,default=0);p.add_argument('--output',default='solver7_optimization_led');a=p.parse_args()
cc=os.environ.get('RISCV_CC','riscv64-elf-gcc');prefix=cc.removesuffix('gcc')
flags='-O2 -march=rv32i -mabi=ilp32 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -fno-jump-tables -fno-tree-loop-distribute-patterns -msmall-data-limit=0 -mno-relax -fno-asynchronous-unwind-tables -Wall -Wextra'.split()
s=Path('solver7_optimization.s').read_text()
start=s.index('.L116:\n');end=s.index('.L121:\n',start)
body=s[start:end]
needle='\tlw\tra,124(sp)'
assert body.count(needle)==1
hook='''\t# ABI: original start at sp+20, solution at sp+68, length in t0.
\tsw t4,4(sp)
\taddi a0,sp,20
\taddi a1,sp,68
\tmv a2,t0
\tcall led_replay
\tlw t4,4(sp)
'''
s=s[:start]+body.replace(needle,hook+needle)+s[end:]
s='# Generated combination: optimized solver7 + C-compiled LED replay.\n'+s
with tempfile.TemporaryDirectory() as tmp:
 for name in ['solver7_led_replay','cube_led']:
  out=Path(tmp)/(name+'.s')
  subprocess.run([cc,*flags,f'-DLED_MATRIX_0_BASE={a.base}',f'-DLED_FRAME_DELAY={a.delay}',f'-DLED_REPLAY_CYCLES={a.cycles}','-S',name+'.c','-o',str(out)],check=True)
  unit=re.sub(r"^\s*\.attribute[^\n]*\n", "", out.read_text(), flags=re.M)
  unit=re.sub(r'\.L([A-Za-z0-9_.$]*)',lambda m:'.L'+name+'_'+m[1],unit)
  s+='\n# C-compiled unit: '+name+'\n'+unit
out=Path(a.output);out.parent.mkdir(parents=True,exist_ok=True)
s=re.sub(r'^\s*\.section\s+\.note\.GNU-stack[^\n]*', '', s, flags=re.M)
s+='\n\t.section .note.GNU-stack,"",@progbits\n'
Path(str(out)+'.s').write_text(s)
subprocess.run([cc,'-march=rv32i','-mabi=ilp32','-nostdlib','-nostartfiles','-nodefaultlibs',f'-Wl,--no-relax,-T,solver7.ld,-Map,{out}.map',str(out)+'.s','-o',str(out)+'.elf'],check=True)
assert not subprocess.check_output([prefix+'nm','-u',str(out)+'.elf'],text=True).strip()
dis=subprocess.check_output([prefix+'objdump','-d','-M','no-aliases',str(out)+'.elf'],text=True);Path(str(out)+'.dis').write_text(dis)
allowed=set('lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak'.split())
ops=set(re.findall(r'^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)',dis,re.M));assert ops and not ops-allowed,ops-allowed
subprocess.run([prefix+'size','-A',str(out)+'.elf'],check=True)
print('PASS: single assembly file, RV32I-only, no unresolved symbols; linker checks 128 KiB static data limit.')
