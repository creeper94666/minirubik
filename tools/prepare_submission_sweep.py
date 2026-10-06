"""Prepare a fresh target sweep without mixing old ELF/checkpoint fingerprints."""
import argparse
import hashlib
from pathlib import Path
import shutil
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,default=ROOT/'measurements/solver7_submission_validation');a=p.parse_args();out=a.out.resolve()
source=ROOT/'solver7_optimization.elf';snapshot=out/'snapshot/solver7_optimization.elf'
if not source.exists():p.error('run sh build_solver7_optimization.sh first')
if (out/'ripes').exists() and any((out/'ripes').iterdir()):
    if not snapshot.exists() or snapshot.read_bytes()!=source.read_bytes():
        p.error('existing results require their original ELF; choose a fresh --out directory')
for d in ['snapshot','host','ripes']:(out/d).mkdir(parents=True,exist_ok=True)
for name in ['solver7_optimization.s','solver7_optimization.elf','solver7_search_sequences.inc','solver7_search_sequences.h','build_solver7_optimization.sh','solver7.ld']:
    shutil.copy2(ROOT/name,out/'snapshot'/name)
shutil.copy2(ROOT/'measurements/solver7_search/distance11.csv',out/'host/distance11.csv')
print('Prepared',out,'ELF SHA256',hashlib.sha256(source.read_bytes()).hexdigest())
