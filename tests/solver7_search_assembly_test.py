"""Inverse indexing and cached move masks must match their C definitions."""
from pathlib import Path
from itertools import permutations,product
import random,re
from rv32_block import parse,run
root=Path(__file__).resolve().parents[1]
s=(root/'solver7_optimization.s').read_text()
assert '.Lsearch_inverse_begin:' in s, 'inverse orientation block is missing'
assert '.Lsearch_mask_begin:' in s, 'canonical sequence mask block is missing'
code,labels=parse(s,'.Lsearch_inverse_begin','.Lsearch_inverse_end')
initial=s[s.index('.Lsearch_initial_inverse_begin:'):s.index('.Lsearch_initial_inverse_end:')]
hot=s[s.index('.Lsearch_inverse_begin:'):s.index('.Lsearch_inverse_end:')]
assert initial.replace('.Lsearch_initial_inverse_', '.Lsearch_inverse_')==hot, 'initial and candidate inverse calculations differ'
rng=random.Random(701)
states=[(p,[1,0,2,1,0,2,0]) for p in permutations(range(7))]
for o in product(range(3),repeat=6):
 p=list(range(7));rng.shuffle(p);states.append((p,list(o)+[(-sum(o))%3]))
for p,o in states:
 inverse=[0]*7
 for i in range(7):inverse[p[i]]=(-o[i])%3
 index=sum(x*3**(5-i) for i,x in enumerate(inverse[:6]))
 registers=dict(sp=1000,t1=2000,s4=400000,a0=5,a1=77,a3=88,a5=20,t0=8,t3=2,t5=2168,t6=10,s2=11,s10=6,s11=123)
 memory=dict(enumerate(list(p)+list(o),2000));memory[400000+index]=7
 _,r,m,reads,writes=run(code,labels,registers,memory)
 assert r['a6']==7
 assert [m[1016+i] for i in range(7)]==inverse
 assert set(writes)==set(range(1016,1023))
 for reg in ('a0','a1','a3','a5','t0','t1','t3','t5','t6','s2','s10','s11'):assert r[reg]==registers[reg],reg
print(f'PASS: {len(states)} inverse scatter/index cases and live-register preservation.')
header=(root/'solver7_search_sequences.h').read_text();tables={}
for length in (3,4,5):
 body=re.search(r'sequence_reject'+str(length)+r'\[\d+\] = \{(.*?)\};',header,re.S)[1]
 tables[length]=list(map(int,re.findall(r'\d+',body)))
assert sum(map(len,tables.values()))==7371
code,labels=parse(s,'.Lsearch_mask_begin','.Lsearch_mask_end')
table_memory=dict(enumerate(tables[3]+tables[4]+tables[5],100000))
words=[list(w) for length in range(1,5) for w in product(range(1,10),repeat=length)]
words += [[rng.randrange(1,10) for _ in range(depth)] for depth in range(5,12) for _ in range(100)]
for word in words:
 depth=len(word);last=word[-1]-1;shift=0 if last<3 else 3 if last<6 else 6;expected=7<<shift
 if depth>=2:
  suffix=word[-4:];index=0
  for move in suffix:index=9*index+move-1
  byte=tables[len(suffix)+1][index];low=(1<<shift)-1;expected|=(byte&low)|((byte&~low)<<3)
 registers=dict(sp=1000,s3=1040,a5=1040+4*depth,s10=depth,t0=word[-1],s7=100000,s8=100810,a0=depth-1,a1=77,a3=88,t6=10,s2=11,s9=1088)
 memory=dict(table_memory);memory.update({1040+4*i:move for i,move in enumerate(word)})
 _,r,m,reads,writes=run(code,labels,registers,memory)
 assert m[1304+depth*4]==expected,(word,expected)
 assert writes==[1304+depth*4]
 for reg in ('a0','a1','a3','t6','s2','s3','s9','s10'):assert r[reg]==registers[reg],reg
print(f'PASS: {len(words)} cached sequence masks, depth addresses, and preserved live state.')
