"""Export the validated C sequence masks verbatim for optimized assembly."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
source=(root/'solver7_search_sequences.h').read_text()
lines=['# Generated from solver7_search_sequences.h; 7371 bytes.', '.section .rodata', '.balign 1']
for length in (3,4,5):
    body=re.search(r'sequence_reject'+str(length)+r'\[\d+\] = \{(.*?)\};',source,re.S)[1]
    values=list(map(int,re.findall(r'\d+',body)))
    assert len(values)==9**(length-1) and all(0<=v<64 for v in values)
    lines.extend([f'.type opt_sequence{length}, @object',f'.size opt_sequence{length}, {len(values)}',f'opt_sequence{length}:'])
    lines.extend('.byte '+','.join(map(str,values[i:i+32])) for i in range(0,len(values),32))
(root/'solver7_search_sequences.inc').write_text('\n'.join(lines)+'\n')
