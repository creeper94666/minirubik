"""Build a standalone preview using frames emitted by the C renderer test."""
from pathlib import Path
import json,csv
root=Path(__file__).resolve().parents[1]
p=root/'measurements/solver7_led'
frames=json.loads((p/'frames.json').read_text())
assert len(frames)==12 and all(len(f['pixels'])==875 for f in frames)
html='''<!doctype html><meta charset="utf-8"><title>Solver7 LED replay</title>
<style>body{font:16px system-ui;background:#171b24;color:#eee;max-width:800px;margin:24px auto;padding:0 16px}canvas{width:100%;image-rendering:pixelated}button,input{margin:12px 8px 12px 0}button{padding:8px 18px}input{width:60%}</style>
<h1>35 × 25 LED · 解法回放</h1><p>U：白　L：橙　F：綠　R：紅　B：藍　D：黃</p>
<canvas id="led" width="700" height="500" aria-label="魔方六面 LED 展開圖"></canvas>
<div><button id="play">播放</button><input id="step" type="range" min="0" max="11" value="0" aria-label="步驟"><span id="label"></span></div>
<script>
const frames=FRAMES, colors=['#000000','#ffffff','#ff8000','#00ff00','#ff0000','#0000ff','#ffff00'];
const moves=['初始狀態','R','R2',"R'",'B','B2',"B'",'D','D2',"D'"];
const canvas=document.getElementById('led'), ctx=canvas.getContext('2d'), slider=document.getElementById('step'), button=document.getElementById('play');let timer=null;
function draw(){const i=Number(slider.value),f=frames[i];ctx.fillStyle='#090b10';ctx.fillRect(0,0,700,500);f.pixels.forEach((c,j)=>{ctx.fillStyle=colors[c];ctx.fillRect((j%35)*20+1,Math.floor(j/35)*20+1,18,18)});document.getElementById('label').textContent=i+' / 11 · '+moves[f.move]+(i===11?' · 已還原':'');}
function stop(){clearInterval(timer);timer=null;button.textContent='播放';}
button.onclick=()=>{if(timer){stop();return;}if(Number(slider.value)===11)slider.value=0;draw();button.textContent='暫停';timer=setInterval(()=>{slider.value=Number(slider.value)+1;draw();if(Number(slider.value)===11)stop()},700)};
slider.oninput=()=>{stop();draw()};draw();
</script>'''
(p/'preview.html').write_text(html.replace('FRAMES',json.dumps(frames)))
origins=[(9,2),(0,9),(9,9),(18,9),(27,9),(9,16)]
with (p/'facelet_offsets.csv').open('w') as out:
    w=csv.writer(out);w.writerow(['face','cell_row_major','x','y','12_byte_offsets_add_to_LED_MATRIX_0_BASE'])
    for face,(x,y) in zip('ULFRBD',origins):
        for cell in range(4):
            a=x+(cell%2)*4;b=y+(cell//2)*3
            w.writerow([face,cell,a,b,' '.join(str(4*((b+dy)*35+a+dx)) for dy in range(3) for dx in range(4))])
print('Created preview.html and facelet_offsets.csv')
