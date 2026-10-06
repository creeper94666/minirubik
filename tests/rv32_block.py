"""Strict interpreter for isolated RV32I assembly test blocks."""
import re
def parse(source,start,end):
    block=source[source.index(start+':'):source.index(end+':')];code=[];labels={}
    for line in block.splitlines():
        line=line.split('#',1)[0].strip()
        if not line:continue
        if line.endswith(':'):labels[line[:-1]]=len(code)
        else:code.append(line.replace(',',' ').split())
    labels[end]=len(code)
    return code,labels
def run(code,labels,registers,memory,stops=(),limit=10000):
    r=dict(registers,zero=0);m=dict(memory);reads=[];writes=[];pc=0
    def put(name,value):
        if name!='zero':r[name]=value&0xffffffff
    def signed(x):return x if x<0x80000000 else x-0x100000000
    stops=set(stops)
    for _ in range(limit):
        for label in stops:
            if label in labels and pc==labels[label]:return label,r,m,reads,writes
        if pc==len(code):return None,r,m,reads,writes
        op,*a=code[pc];pc+=1
        if op=='li':put(a[0],int(a[1],0))
        elif op=='mv':put(a[0],r[a[1]])
        elif op in ('addi','andi','xori','slli','srli'):
            x,y=r[a[1]],int(a[2],0)
            put(a[0],x+y if op=='addi' else x&y if op=='andi' else x^y if op=='xori' else x<<y if op=='slli' else x>>y)
        elif op in ('add','sub','and','or','sll','srl'):
            x,y=r[a[1]],r[a[2]]
            put(a[0],x+y if op=='add' else x-y if op=='sub' else x&y if op=='and' else x|y if op=='or' else x<<(y&31) if op=='sll' else x>>(y&31))
        elif op in ('lbu','lw','sb','sw'):
            off,base=re.fullmatch(r'(-?\d+)\((\w+)\)',a[1]).groups();address=(r[base]+int(off))&0xffffffff
            if op in ('lbu','lw'):put(a[0],m[address]);reads.append(address)
            else:m[address]=r[a[0]]&(255 if op=='sb' else 0xffffffff);writes.append(address)
        elif op=='j':
            if a[0] in stops:return a[0],r,m,reads,writes
            pc=labels[a[0]]
        elif op in ('beq','bne','ble','bge','blt','bgt','beqz','bnez'):
            x=r[a[0]];y=0 if op.endswith('z') else r[a[1]];target=a[-1]
            take=x==y if op in ('beq','beqz') else x!=y if op in ('bne','bnez') else signed(x)<=signed(y) if op=='ble' else signed(x)>=signed(y) if op=='bge' else signed(x)<signed(y) if op=='blt' else signed(x)>signed(y)
            if take:
                if target in stops:return target,r,m,reads,writes
                pc=labels[target]
        else:raise AssertionError(('unsupported instruction',op,a))
    raise AssertionError('block did not terminate')
