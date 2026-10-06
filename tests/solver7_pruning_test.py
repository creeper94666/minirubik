"""Actual assembly decisions must include the inverse-orientation bound."""
from pathlib import Path
from rv32_block import parse,run
root=Path(__file__).resolve().parents[1]
source=(root/'solver7_optimization.s').read_text()
code,labels=parse(source,'.Lopt_done','.L69')
count=0
for hp in range(8):
 for ho in range(7):
  for hi in range(7):
   for bound in range(1,12):
    for depth in range(1,bound+1):
     registers=dict(sp=1000,t1=1024,s5=200000,s4=400000,s2=bound,s10=depth)
     memory=dict(enumerate([0,1,2,3,4,5,6,1,0,0,0,0,0,2],1024))
     pidx=sum(v*7**(5-i) for i,v in enumerate(range(6)))
     memory.update({200000+pidx:hp,400243:ho,400486:hi})
     stop,r,m,reads,writes=run(code,labels,registers,memory,('.L69','.Lopt_reject'))
     assert (stop=='.L69')==(depth+max(hp,ho,hi)<=bound),(hp,ho,hi,depth,bound,stop)
     if depth+hp>bound:assert not any(1031<=addr<=1037 or addr==400243 for addr in reads)
     if depth+max(hp,ho)>bound:assert 400486 not in reads and not writes
     count+=1
print(f'PASS: {count} hp/ho/inverse pruning decisions and short-circuit checks.')
