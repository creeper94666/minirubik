"""macOS/Ripes reproducibility aid. Raw logs explicitly identify AI-run evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--repetitions',type=int,default=3);a=p.parse_args()
if a.repetitions<1:p.error('positive repetitions required')
out=ROOT/'measurements/stage1_support/results';out.mkdir(exist_ok=True)
cc=os.environ.get('RISCV_CC','riscv64-elf-gcc')
ripes='/Applications/Ripes.app/Contents/MacOS/Ripes'
records=[]
for region in [4096,4194304]:
    elf=out/f'loop-{region}.elf'
    subprocess.run([cc,'-march=rv32i','-mabi=ilp32','-nostdlib','-nostartfiles','-Wl,--no-relax,-Ttext=0',f'-Wa,--defsym,REGION_BYTES={region}','-Wa,--defsym,ITERATIONS=1048576',str(ROOT/'measurements/stage1_support/memory_loop.s'),'-o',str(elf)],check=True)
    for model in ['RV32_ISS','RV32_5S']:
        for repeat in range(a.repetitions):
            name=f'{model}-{region}-{repeat}';log=out/(name+'.log');stats=out/(name+'.txt');rss=out/(name+'-time.txt')
            command=['/usr/bin/time','-l','-o',str(rss),ripes,'--mode','cli','--src',str(elf),'-t','elf','--proc',model,'--iret','--cycles','--runinfo','--timeout','0','-v','--output',str(stats)]
            started=time.monotonic()
            with log.open('w') as stream:r=subprocess.run(command,stdout=stream,stderr=subprocess.STDOUT)
            elapsed=time.monotonic()-started
            assert r.returncode==0 and 'Program exited with code: 0' in log.read_text()
            count=int(re.search(r'^===== instructions retired\s*\n(\d+)',stats.read_text(),re.M)[1])
            peak=int(re.search(r'(\d+)\s+maximum resident set size',rss.read_text())[1])
            record=dict(model=model,region_bytes=region,iterations=1048576,repetition=repeat,retired=count,process_wall_seconds=elapsed,retired_per_process_second=count/elapsed,peak_rss_bytes=peak,command=command,elf_sha256=hashlib.sha256(elf.read_bytes()).hexdigest())
            records.append(record);(out/'records.json').write_text(json.dumps(records,indent=2)+'\n')
            print(json.dumps({k:v for k,v in record.items() if k!='command'}),flush=True)
(out/'provenance.json').write_text(json.dumps(dict(ripes_sha256=hashlib.sha256(Path(ripes).read_bytes()).hexdigest(),compiler=subprocess.check_output([cc,'--version'],text=True),scope='AI-executed support measurement; process wall time includes startup and output. Memory slope requires paired region comparison for each model. Student independent runs and interpretation remain required.'),indent=2)+'\n')
