"""Interpret the changed assembly block and compare against original move tables."""
from pathlib import Path
import ast
import itertools
import re
root = Path(__file__).resolve().parents[1]
c = (root / 'solver7.c').read_text()
def table(name):
    value = re.search(r'static const uint8_t '+name+r'\[3\]\[3\]\[CUBIES\] = (.*?);', c, re.S)[1]
    return ast.literal_eval(value.replace('{', '[').replace('}', ']'))
source, twist = table('move_source'), table('move_twist')
s = (root / 'solver7_optimization.s').read_text()
block = s[s.index('.L17:'):s.index('.Lopt_done:')]
code, labels = [], {}
for line in block.splitlines():
    line = line.split('#')[0].strip()
    if not line: continue
    if line.endswith(':'): labels[line[:-1]] = len(code)
    else: code.append(line.replace(',', ' ').split())
labels['.Lopt_done'] = len(code)
def run(p, o, move):
    r = dict(sp=1000, t5=2168, t0=move, t3=2, s2=123, t4=456)
    mem = dict(enumerate(p + o, 2000))
    pc = 0
    while pc < len(code):
        op, *args = code[pc]; pc += 1
        if op == 'li': r[args[0]] = int(args[1])
        elif op == 'addi': r[args[0]] = r[args[1]] + int(args[2])
        elif op in ('lbu', 'sb', 'sw'):
            offset, base = re.fullmatch(r'(-?\d+)\((\w+)\)', args[1]).groups()
            addr = r[base] + int(offset)
            if op == 'lbu': r[args[0]] = mem[addr]
            elif op == 'sb': mem[addr] = r[args[0]] & 255
            else: mem[addr] = r[args[0]]
        elif op == 'j': pc = labels[args[0]]
        elif op in ('beq', 'ble'):
            a, b = r[args[0]], r[args[1]]
            if (a == b if op == 'beq' else a <= b): pc = labels[args[2]]
        else: raise AssertionError(op)
    assert r['t1'] == 1024 and mem[1004] == 123 and mem[1008] == 456
    assert r['t0'] == move and r['t5'] == 2168 and r['t3'] == 2
    return [mem[1024+i] for i in range(14)]
n = 0
for m in range(9):
    f, t = divmod(m, 3)
    states = itertools.chain(((list(p), [0]*7) for p in itertools.permutations(range(7))),
                             ((list(range(7)), list(o)) for o in itertools.product(range(3), repeat=7)))
    for p, o in states:
        expected = [p[j] for j in source[f][t]] + [(o[j]+d)%3 for j,d in zip(source[f][t],twist[f][t])]
        assert run(p, o, m+1) == expected, (m,p,o)
        n += 1
print(f'PASS: {n} assembly-block cases (all permutations and all orientation tuples independently, nine moves).')
allowed = set('lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and fence ecall ebreak'.split())
ops = set(re.findall(r'^\s*[0-9a-f]+:\s+[0-9a-f]{8}\s+(\S+)', (root/'solver7_optimization.dis').read_text(), re.M))
assert ops and not ops-allowed, ops-allowed
print('PASS: RV32I-only disassembly.')
