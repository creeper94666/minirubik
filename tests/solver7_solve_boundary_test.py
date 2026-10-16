"""Accepted boundary nodes must return without a new goal scan or child mask."""
from pathlib import Path
from rv32_block import parse, run

s = (Path(__file__).resolve().parents[1]/'solver7_optimization.s').read_text()
assert '.Lsolve_accept_end:' in s, 'acceptance-time goal detection missing'
code, labels = parse(s, '.L69', '.Lsolve_accept_end')
for limit in range(1, 12):
    for depth in range(1, limit+1):
        for move in range(1, 10):
            regs = dict(s3=1040, a5=4*(depth-1), t0=move, s10=depth, s2=limit,
                        a0=depth-1, a1=3000, a3=55, t6=88)
            stop,r,m,reads,writes = run(code, labels, regs, {}, stops=('.Lsolve_found',))
            assert (stop=='.Lsolve_found') == (depth==limit)
            assert m[1040+4*(depth-1)] == move
            assert writes == [1040+4*(depth-1)]
            for reg in ('a0','a1','a3','t6','s2','s3','s10'):
                assert r[reg]==regs[reg]
assert '.L8:' not in s, 'redundant per-node goal scan remains'
print('PASS: 594 acceptance/return decisions, move writes, and live registers.')
