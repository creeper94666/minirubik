"""Execute the actual node-goal block and check its solved-path work budget."""
from pathlib import Path
from itertools import permutations, product
from rv32_block import parse, run

root = Path(__file__).resolve().parents[1]
# Historical block test: the current solver eliminates this scan entirely.
source = (root / 'measurements/solver7_solve_boundary/baseline/solver7_optimization.s').read_text()
start = source.index('\n.L8:')
end = source.index('\tbeq\ta0,zero,.L60', start)
block = source[start:end] + '\n.Lgoal_done:\n'
code, labels = parse(block, '.L8', '.Lgoal_done')
preserved = dict(a0=4, a1=3000, a3=5000, t1=32, t6=77,
                 s0=7, s2=11, s3=1040, s9=1088, s11=123)

def check(p, o, budget=100):
    registers = dict(preserved, a5=2000, a6=0)
    memory = dict(enumerate(list(p) + list(o), 2000))
    stop, result, after, reads, writes = run(
        code, labels, registers, memory, stops=('.L7',), limit=budget)
    solved = list(p) == list(range(7)) and not any(o)
    assert (stop is None) == solved, (p, o, stop)
    assert after == memory and not writes
    for name, value in preserved.items():
        assert result[name] == value, name

# Performance requirement: at most 35 executed instructions for a solved node.
check(range(7), [0]*7, budget=36)
count = 1
for p in permutations(range(7)):
    check(p, [0]*7)
    count += 1
for o in product(range(3), repeat=7):
    check(range(7), o)
    count += 1
for offset in range(14):
    for value in range(256):
        state = list(range(7)) + [0]*7
        state[offset] = value
        check(state[:7], state[7:])
        count += 1
print(f'PASS: {count} node-goal cases, live registers, no writes, solved work budget.')
