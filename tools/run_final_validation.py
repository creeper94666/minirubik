"""AI-executed exhaustive evidence collection; solver sources are not modified."""
import argparse
import concurrent.futures
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
TOTAL = 3674160
RIPES = Path('/Applications/Ripes.app/Contents/MacOS/Ripes')
MOVES = ['R', 'R2', "R'", 'B', 'B2', "B'", 'D', 'D2', "D'"]
SOURCE = [[1,4,2,0,3,5,6],[0,1,2,4,5,6,3],[0,2,5,3,1,4,6]]
TWIST = [[1,2,0,2,1,0,0],[0,0,0,1,2,1,2],[0,0,0,0,0,0,0]]

def sha(data): return hashlib.sha256(data).hexdigest()
def save(path, value):
    tmp = path.with_suffix(path.suffix + '.tmp')
    tmp.write_text(json.dumps(value, indent=2) + '\n')
    tmp.replace(path)

def input_offset(raw):
    if raw[:6] != b'\x7fELF\x01\x01': raise ValueError('expected little endian ELF32')
    hdr = struct.unpack_from('<16sHHIIIIIHHHHHH', raw)
    if hdr[2] != 243: raise ValueError('expected RISC-V')
    shoff, size, count = hdr[6], hdr[11], hdr[12]
    sections = [struct.unpack_from('<10I', raw, shoff+i*size) for i in range(count)]
    found = []
    for section in sections:
        if section[1] != 2: continue
        strings = sections[section[6]]
        names = raw[strings[4]:strings[4]+strings[5]]
        for pos in range(section[4], section[4]+section[5], section[9]):
            name, addr, nbytes, info, other, index = struct.unpack_from('<IIIBBH', raw, pos)
            if names[name:].split(b'\0',1)[0] == b'cube_input':
                data = sections[index]
                offset = data[4] + addr - data[3]
                if nbytes != 15 or raw[offset+14] != 0: raise ValueError('unexpected cube_input')
                found.append(offset)
    if len(found) != 1: raise ValueError('cube_input symbol not unique')
    return found[0]

def patch_input(raw, offset, text):
    if not re.fullmatch(r'[1-7]{7}[1-3]{7}', text): raise ValueError('bad cube string')
    if sorted(text[:7]) != list('1234567') or sum(int(x)-1 for x in text[7:]) % 3:
        raise ValueError('invalid cube')
    result = raw[:offset] + text.encode('ascii') + raw[offset+14:]
    assert len(result) == len(raw)
    return result

def parse_ripes(log, stats, returncode):
    if returncode != 0 or 'Program exited with code: 0' not in log:
        raise ValueError('Ripes process or guest did not exit successfully')
    if re.search(r'invalid|verification failed|no solution',log,re.I): raise ValueError('guest failure')
    if 'processor: RV32_ISS' not in stats or not re.search(r'^ISA extensions:[ \t]*$', stats, re.M):
        raise ValueError('wrong processor/extensions')
    counts = re.findall(r'^===== instructions retired\s*\n(\d+)', stats, re.M)
    if len(counts) != 1: raise ValueError('missing/duplicate instruction result')
    # CLI progress and guest characters share stdout. A progress record can
    # interrupt a move token, so remove that complete record without inserting
    # whitespace into the guest byte stream. Raw logs remain unchanged.
    guest_log = re.sub(r'INFO: [^\n]*\n', '', log)
    paths = [line.split() for line in guest_log.splitlines() if line.split() and all(x in MOVES for x in line.split())]
    if len(paths) != 1 or len(paths[0]) != 11: raise ValueError('expected one optimal 11-move path')
    return int(counts[0]), paths[0]

def replay(text, moves):
    p = [int(x)-1 for x in text[:7]]; o = [int(x)-1 for x in text[7:]]
    for move in moves:
        m = MOVES.index(move); face = m//3
        for _ in range(m%3+1):
            p = [p[SOURCE[face][i]] for i in range(7)]
            o = [(o[SOURCE[face][i]]+TWIST[face][i])%3 for i in range(7)]
    if p != list(range(7)) or o != [0]*7: raise ValueError('independent replay failed')

def run_host(out, workers, source_label='solver7.c'):
    base=out/'host'; binary=base/'verify'; oracle=base/'oracle.bin'
    fingerprint={'binary':sha(binary.read_bytes()),'oracle':sha(oracle.read_bytes())}
    chunks=[(s,min(10000,TOTAL-s)) for s in range(0,TOTAL,10000)]
    started=time.monotonic(); utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime())
    def one(item):
        start,count=item; name=f'{start:07d}'; record=base/(name+'.json')
        if record.exists():
            r=json.loads(record.read_text())
            if r.get('fingerprint')==fingerprint and r['count']==count and r['H3']=='PASS' and sha((base/(name+'.csv')).read_bytes())==r['csv_sha256']: return r
            raise ValueError('stale host checkpoint '+name)
        command=[str(binary),'search',str(oracle),str(start),str(count),str(base/(name+'.csv'))]
        with (base/(name+'.log')).open('w') as log:
            result=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
        text=(base/(name+'.log')).read_text()
        match=re.findall(r'^RESULT (.+)$',text,re.M)
        if result.returncode or len(match)!=1: raise RuntimeError('host failed '+name+' '+text[-1000:])
        r=json.loads(match[0]); assert r['start']==start and r['count']==count
        r.update(fingerprint=fingerprint,command=command,csv_sha256=sha((base/(name+'.csv')).read_bytes()))
        save(record,r);return r
    records=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures={pool.submit(one,item):item for item in chunks}
        for future in concurrent.futures.as_completed(futures):
            records.append(future.result()); done=sum(r['count'] for r in records)
            save(base/'progress.json',{'states_completed':done,'states_total':TOTAL,'batch_elapsed_seconds':time.monotonic()-started,'complete':False})
            print(f'HOST {done}/{TOTAL}; {time.monotonic()-started:.1f}s',flush=True)
    records.sort(key=lambda x:x['start']); assert [(r['start'],r['count']) for r in records]==chunks
    # Re-read every per-state record and verify exhaustive, nonoverlapping coverage.
    histogram=[0]*12
    for r in records:
        with (base/(f"{r['start']:07d}.csv")).open() as stream:
            rows=csv.DictReader(stream); n=0
            for row in rows:
                rank=int(row['rank']); d=int(row['exact_distance']); length=int(row['returned_length'])
                assert rank==r['start']+n and d==length and len(row['path'])==length
                histogram[d]+=1;n+=1
            assert n==r['count']
    expected=json.loads((base/'oracle-summary.json').read_text())['histogram'];assert histogram==expected
    result={'H3':'PASS','independent_replay':'PASS','states':TOTAL,'coverage':'every rank exactly once','histogram':histogram,'workers':workers,'batch_started_utc':utc,'batch_wall_seconds':time.monotonic()-started,'sum_shard_wall_seconds':sum(r['wall_seconds'] for r in records),'fingerprint':fingerprint,'provenance':f'AI-executed validation of snapshot {source_label}; not a proof for modified assembly'}
    save(base/'summary.json',result);print(json.dumps(result),flush=True)

def run_ripes(out,workers,limit):
    base=out/'ripes'; elf=out/'snapshot/solver7_optimization.elf'; raw=elf.read_bytes();offset=input_offset(raw)
    cases=list(csv.DictReader((out/'host/distance11.csv').open()));assert len(cases)==2644 and len({r['input'] for r in cases})==2644
    fingerprint={'elf_sha256':sha(raw),'ripes_sha256':sha(RIPES.read_bytes()),'cases_sha256':sha((out/'host/distance11.csv').read_bytes()),'input_offset':offset}
    if limit:cases=cases[:limit]
    started=time.monotonic();utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime());records=[]
    def one(case):
        rank=int(case['rank']);text=case['input'];case_dir=base/f'{rank:07d}';case_dir.mkdir(exist_ok=True)
        record=case_dir/'result.json'
        if record.exists():
            r=json.loads(record.read_text())
            if r.get('fingerprint')==fingerprint and r.get('input')==text and r.get('replay')=='PASS':
                iret,path=parse_ripes((case_dir/'run.log').read_text(),(case_dir/'iret.txt').read_text(),0)
                replay(text,path);assert iret==r['retired_instructions'];return r
            raise ValueError('stale target checkpoint '+text)
        patched=patch_input(raw,offset,text);program=case_dir/'input.elf';program.write_bytes(patched)
        command=[str(RIPES),'--mode','cli','--src',str(program),'-t','elf','--proc','RV32_ISS','--iret','--cycles','--runinfo','--timeout','0','-v','--output',str(case_dir/'iret.txt')]
        t=time.monotonic()
        with (case_dir/'run.log').open('w') as log:
            p=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
        elapsed=time.monotonic()-t
        iret,path=parse_ripes((case_dir/'run.log').read_text(),(case_dir/'iret.txt').read_text() if (case_dir/'iret.txt').exists() else '',p.returncode)
        replay(text,path)
        r={'rank':rank,'input':text,'exact_distance':11,'retired_instructions':iret,'path':path,'replay':'PASS','elapsed_seconds':elapsed,'within_50000000':iret<=50000000,'elf_sha256':sha(patched),'fingerprint':fingerprint,'command':command,'process_returncode':p.returncode}
        save(record,r);program.unlink();return r
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures=[pool.submit(one,case) for case in cases]
        for future in concurrent.futures.as_completed(futures):
            records.append(future.result()); worst=max(records,key=lambda r:r['retired_instructions'])
            progress={'completed':len(records),'total':len(cases),'maximum_so_far':worst['retired_instructions'],'slowest_input_so_far':worst['input'],'over_threshold_so_far':sum(not r['within_50000000'] for r in records),'batch_elapsed_seconds':time.monotonic()-started,'complete':False}
            save(base/'progress.json',progress)
            if len(records)%20==0 or not records[-1]['within_50000000']:print('RIPES '+json.dumps(progress),flush=True)
    assert {r['rank'] for r in records}=={int(c['rank']) for c in cases}
    records.sort(key=lambda r:r['rank']);maximum=max(r['retired_instructions'] for r in records)
    with (base/('pilot.csv' if limit else 'results.csv')).open('w') as stream:
        writer=csv.writer(stream);writer.writerow(['rank','input','retired_instructions','within_50000000','elapsed_seconds','path'])
        for r in records:writer.writerow([r['rank'],r['input'],r['retired_instructions'],r['within_50000000'],r['elapsed_seconds'],' '.join(r['path'])])
    summary={'complete':not limit,'states_measured':len(records),'maximum_instructions':maximum,'slowest_inputs':[r['input'] for r in records if r['retired_instructions']==maximum],'over_threshold':sum(not r['within_50000000'] for r in records),'all_within_threshold':all(r['within_50000000'] for r in records),'workers':workers,'batch_started_utc':utc,'batch_wall_seconds':time.monotonic()-started,'sum_case_elapsed_seconds':sum(r['elapsed_seconds'] for r in records),'fingerprint':fingerprint,'provenance':'AI-executed actual Ripes RV32_ISS runs; only embedded input bytes differ; renderer absent; includes startup, search, verification, output and exit'}
    save(base/('pilot-summary.json' if limit else 'summary.json'),summary);print(json.dumps(summary),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('mode',choices=['host','ripes']);p.add_argument('--source-label',default='solver7.c');p.add_argument('--workers',type=int,default=4);p.add_argument('--limit',type=int,default=0);p.add_argument('--out',type=Path,default=ROOT/'measurements/solver7_final_validation');a=p.parse_args()
    if a.workers<1: p.error('workers must be positive')
    a.out=a.out.resolve()
    if a.mode=='host':run_host(a.out,a.workers,a.source_label)
    else:run_ripes(a.out,a.workers,a.limit)
