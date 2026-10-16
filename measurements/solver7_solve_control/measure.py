"""Snapshot and measure a cumulative optimization stage on real Ripes."""
from pathlib import Path
import importlib.util
import json
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('validation', ROOT/'tools/run_final_validation.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)
stage = Path(__file__).resolve().parent / sys.argv[1]
stage.mkdir(exist_ok=True)
for suffix in ('s', 'elf', 'dis', 'map'):
    dest = stage / ('solver7_optimization.' + suffix)
    if not dest.exists():
        shutil.copy2(ROOT / dest.name, dest)
raw = (stage/'solver7_optimization.elf').read_bytes()
offset = v.input_offset(raw)
cases = sys.argv[2:] or ['21345671111111', '54721631111111']
records = []
for text in cases:
    program = stage / (text+'.elf')
    program.write_bytes(v.patch_input(raw, offset, text))
    stats = stage / (text+'-iret.txt')
    logpath = stage / (text+'.log')
    cmd = [str(v.RIPES), '--mode', 'cli', '--src', str(program), '-t', 'elf',
           '--proc', 'RV32_ISS', '--iret', '--cycles', '--runinfo', '--timeout',
           '0', '-v', '--output', str(stats)]
    start = time.monotonic()
    with logpath.open('w') as stream:
        result = subprocess.run(cmd, stdout=stream, stderr=subprocess.STDOUT)
    log = logpath.read_text()
    report = stats.read_text()
    assert result.returncode == 0 and 'Program exited with code: 0' in log
    assert not re.search(r'invalid|verification failed|no solution', log, re.I)
    assert 'processor: RV32_ISS' in report
    assert re.search(r'^ISA extensions:[ \t]*$', report, re.M)
    guest = re.sub(r'INFO: [^\n]*\n', '', log)
    paths = [line.split() for line in guest.splitlines()
             if line.split() and all(move in v.MOVES for move in line.split())]
    expected = {'12345671111111': 0, '25314672313211': 1}.get(text, 11)
    assert len(paths) == int(expected != 0), (text, paths)
    path = paths[0] if paths else []
    assert len(path) == expected, (text, path)
    counts = re.findall(r'^===== instructions retired\s*\n(\d+)', report, re.M)
    assert len(counts) == 1
    count = int(counts[0])
    v.replay(text, path)
    record = dict(input=text, instructions=count, path=path, replay='PASS',
                  seconds=time.monotonic()-start, command=cmd,
                  source_sha256=v.sha((stage/'solver7_optimization.s').read_bytes()),
                  elf_sha256=v.sha(raw), ripes_sha256=v.sha(v.RIPES.read_bytes()))
    records.append(record)
    (stage/(text+'.json')).write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps(record), flush=True)
(stage/'results.json').write_text(json.dumps(records, indent=2)+'\n')
