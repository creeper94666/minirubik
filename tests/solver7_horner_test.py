"""Check actual Horner assembly address calculations over every index tuple."""
from pathlib import Path
from itertools import product
import re
root=Path(__file__).resolve().parents[1]
s=(root/'solver7_optimization.s').read_text()
block=s[s.index('.Lopt_done:'):s.index('\tlw\ts2,4(sp)',s.index('.Lopt_done:'))]
parts=block.split('\tlbu a6,0(a4)')
assert len(parts)==2
count=0
for radix, offset, base, part in [(7,24,'s5',parts[0]),(3,31,'s4',parts[1])]:
    instructions=[]
    for line in part.splitlines():
        line=line.split('#')[0].strip()
        if not line or line.endswith(':') or line=='lbu a4,0(a4)': continue
        instructions.append(line.replace(',',' ').split())
    for values in product(range(radix),repeat=6):
        regs={'sp':1000,base:200000}
        mem=dict(zip(range(1000+offset,1006+offset),values))
        for op,*args in instructions:
            d=args[0]
            if op=='lbu':
                off,b=re.fullmatch(r'(\d+)\((\w+)\)',args[1]).groups()
                regs[d]=mem[regs[b]+int(off)]
            elif op=='slli': regs[d]=regs[args[1]]<<int(args[2])
            elif op=='add': regs[d]=regs[args[1]]+regs[args[2]]
            elif op=='sub': regs[d]=regs[args[1]]-regs[args[2]]
            else: raise AssertionError(op)
        expected=200000+sum(v*radix**(5-i) for i,v in enumerate(values))
        assert regs['a4']==expected, (radix,values)
        count+=1
print(f'PASS: {count} index tuples checked against weighted-sum reference.')
