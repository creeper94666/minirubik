"""Target regression sample: solved, all one-move states, and distance 11."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import csv
import importlib.util
import json
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('validation', ROOT/'tools/run_final_validation.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)
out = Path(__file__).resolve().parent/'target_depths'
out.mkdir(exist_ok=True)
raw = (ROOT/'solver7_optimization.elf').read_bytes()
offset = v.input_offset(raw)
fingerprint = dict(elf=v.sha(raw), source=v.sha((ROOT/'solver7_optimization.s').read_bytes()),
                   ripes=v.sha(v.RIPES.read_bytes()))
cases = {'12345671111111': dict(distance=0)}
for face in range(3):
    p, o = list(range(7)), [0]*7
    for turn in range(3):
        p = [p[v.SOURCE[face][i]] for i in range(7)]
        o = [(o[v.SOURCE[face][i]]+v.TWIST[face][i])%3 for i in range(7)]
        text = ''.join(str(x+1) for x in p+o)
        cases[text] = dict(distance=1)
prior = list(csv.DictReader((ROOT/'measurements/solver7_final_validation/ripes/results.csv').open()))
sample = sorted(prior, key=lambda row: int(row['retired_instructions']), reverse=True)[:10]
sample += prior[::len(prior)//10]
sample += [row for row in prior if row['input'] == '21345671111111']
for row in sample:
    cases[row['input']] = dict(distance=11, baseline_instructions=int(row['retired_instructions']),
                              baseline_path=row['path'].split())

# Extra target samples across every exact distance from the retained oracle.
cases = {}
import math
oracle = (ROOT/'measurements/solver7_final_validation/host/oracle.bin').read_bytes()
assert len(oracle) == 3674160
for distance in range(12):
    rank = oracle.index(distance)
    pr, orient = divmod(rank,729)
    available = list(range(7)); permutation = []
    for i in range(7):
        selected, pr = divmod(pr, math.factorial(6-i))
        permutation.append(available.pop(selected))
    digits = []
    for weight in (243,81,27,9,3,1):
        digit, orient = divmod(orient,weight); digits.append(digit)
    digits.append((-sum(digits))%3)
    text = ''.join(str(x+1) for x in permutation+digits)
    cases[text] = dict(distance=distance, oracle_rank=rank)

def run(item):
    text, expected = item
    program = out/(text+'.elf')
    program.write_bytes(v.patch_input(raw, offset, text))
    logpath, stats = out/(text+'.log'), out/(text+'-iret.txt')
    cmd = [str(v.RIPES), '--mode', 'cli', '--src', str(program), '-t', 'elf',
           '--proc', 'RV32_ISS', '--iret', '--cycles', '--runinfo', '--timeout', '0',
           '-v', '--output', str(stats)]
    with logpath.open('w') as stream:
        result = subprocess.run(cmd, stdout=stream, stderr=subprocess.STDOUT)
    log, report = logpath.read_text(), stats.read_text()
    assert result.returncode == 0 and 'Program exited with code: 0' in log, log
    assert not re.search(r'invalid|verification failed|no solution', log, re.I), log
    assert 'processor: RV32_ISS' in report
    assert re.search(r'^ISA extensions:[ \t]*$', report, re.M)
    guest = re.sub(r'INFO: [^\n]*\n', '', log)
    paths = [line.split() for line in guest.splitlines()
             if line.split() and all(move in v.MOVES for move in line.split())]
    assert len(paths) == int(expected['distance'] != 0), (text, paths)
    path = paths[0] if paths else []
    assert len(path) == expected['distance'], (text, path)
    v.replay(text, path)
    if 'baseline_path' in expected:
        assert path == expected['baseline_path'], (text, path, expected)
    counts = re.findall(r'^===== instructions retired\s*\n(\d+)', report, re.M)
    assert len(counts) == 1
    record = dict(input=text, expected=expected, path=path, instructions=int(counts[0]),
                  replay='PASS', command=cmd, fingerprint=fingerprint)
    (out/(text+'.json')).write_text(json.dumps(record, indent=2)+'\n')
    program.unlink()
    print(f'PASS {text}: {len(path)} moves, {counts[0]} instructions', flush=True)
    return record

start = time.monotonic()
with ThreadPoolExecutor(max_workers=2) as pool:
    records = list(pool.map(run, cases.items()))
(out/'results.json').write_text(json.dumps(dict(cases=records, seconds=time.monotonic()-start,
                                               fingerprint=fingerprint), indent=2)+'\n')
print(f'PASS: {len(records)} actual Ripes cases, independent replay and exact expected lengths.')
