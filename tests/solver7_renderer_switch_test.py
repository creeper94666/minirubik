"""The measurement build must preserve every allocated solver byte."""
from pathlib import Path
import os
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[1]
cc = os.environ.get('RISCV_CC', 'riscv64-elf-gcc')
prefix = cc.removesuffix('gcc')
with tempfile.TemporaryDirectory() as tmp:
    out = Path(tmp)/'combined'
    subprocess.run(['python3', str(ROOT/'tools/build_solver7_optimization_led.py'),
                    '--render', '0', '--output', str(out)], cwd=ROOT, check=True)
    binaries=[]
    for i, elf in enumerate([ROOT/'solver7_optimization.elf', Path(str(out)+'.elf')]):
        binary=Path(tmp)/f'{i}.bin'
        subprocess.run([prefix+'objcopy', '-O', 'binary', str(elf), str(binary)], check=True)
        binaries.append(binary.read_bytes())
    assert binaries[0] == binaries[1], 'renderer-off allocated bytes differ from benchmarked solver'
    bad_geometry=subprocess.run([cc, '-march=rv32i', '-mabi=ilp32', '-c',
        '-Wa,--defsym,RENDER=1', '-Wa,--defsym,LED_MATRIX_0_BASE=0x40000',
        '-Wa,--defsym,LED_MATRIX_0_WIDTH=34', '-Wa,--defsym,LED_MATRIX_0_HEIGHT=25',
        str(out)+'.s', '-o', str(Path(tmp)/'bad.o')],capture_output=True,text=True)
    assert bad_geometry.returncode != 0 and 'width must be 35' in bad_geometry.stderr
    source=Path(str(out)+'.s').read_text()
    assert '.if RENDER' in source
    for symbol in ['LED_MATRIX_0_BASE','LED_MATRIX_0_WIDTH','LED_MATRIX_0_HEIGHT']:
        assert symbol in source
    rejected=subprocess.run(['python3', str(ROOT/'tools/build_solver7_optimization_led.py'),
                            '--render','1','--output',str(out)],cwd=ROOT,capture_output=True,text=True)
    assert rejected.returncode != 0 and '--base' in rejected.stderr
print('PASS: renderer-off bytes match measured solver; enabled renderer requires explicit peripheral base.')
