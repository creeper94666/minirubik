"""AI-run target checks of the shared source on ISS and five-stage pipeline."""
from pathlib import Path
import concurrent.futures
import importlib.util
import json
import re
import subprocess
import time
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('v',ROOT/'tools/run_final_validation.py')
v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
out=ROOT/'measurements/solver7_submission_validation/models';out.mkdir(exist_ok=True)
raw=(ROOT/'solver7_optimization_led.elf').read_bytes();offset=v.input_offset(raw)
cases=[('12345671111111',0),('25314672313211',1),('21345671111111',11)]
# Generate the one-turn test independently from the published quarter-turn rules.
p=[i+1 for i in v.SOURCE[0]];o=[i+1 for i in v.TWIST[0]]
cases[1]=(''.join(map(str,p+o)),1)
def run(task):
    proc,text,distance=task
    name=proc+'-'+text; program=out/(name+'.elf')
    program.write_bytes(v.patch_input(raw,offset,text))
    cmd=[str(v.RIPES),'--mode','cli','--src',str(program),'-t','elf','--proc',proc,'--iret','--cycles','--runinfo','--timeout','0','-v','--output',str(out/(name+'.txt'))]
    start=time.monotonic()
    with (out/(name+'.log')).open('w') as log: result=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT)
    log=(out/(name+'.log')).read_text();stats=(out/(name+'.txt')).read_text()
    assert result.returncode==0 and 'Program exited with code: 0' in log
    assert 'processor: '+proc in stats and re.search(r'^ISA extensions:[ \t]*$',stats,re.M)
    guest=re.sub(r'INFO: [^\n]*\n','',log)
    paths=[line.split() for line in guest.splitlines() if line.split() and all(m in v.MOVES for m in line.split())]
    assert len(paths)==int(distance!=0)
    path=paths[0] if paths else [];assert len(path)==distance;v.replay(text,path)
    counts=re.findall(r'^===== instructions retired\s*\n(\d+)',stats,re.M);assert len(counts)==1
    r=dict(processor=proc,input=text,distance=distance,path=path,replay='PASS',retired_instructions=int(counts[0]),wall_seconds=time.monotonic()-start,command=cmd,elf_sha256=v.sha(program.read_bytes()),source_sha256=v.sha((ROOT/'solver7_optimization_led.s').read_bytes()),ripes_sha256=v.sha(v.RIPES.read_bytes()))
    v.save(out/(name+'.json'),r);program.unlink();print('PASS',proc,text,counts[0],flush=True);return r
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    records=list(pool.map(run,[(proc,text,d) for proc in ['RV32_ISS','RV32_5S'] for text,d in cases]))
v.save(out/'summary.json',dict(cases=records,provenance='AI-executed CLI tests of both processor models; not a GUI signal walkthrough.'))
