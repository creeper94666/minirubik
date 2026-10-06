"""AI-executed statistical summary of the unchanged Stage 1 runner output."""
from pathlib import Path
import json, statistics as st, re
root=Path(__file__).resolve().parents[3]
base=Path(__file__).resolve().parent
raw=base/'measurements/stage1_support/results'
records=json.loads((raw/'records.json').read_text())
assert len(records)==12
summary={}
lines=['### AI-executed results','', 'All RSS values below are **bytes**, as reported by macOS `/usr/bin/time -l`. Repetition labels are 1-based here (0-based in the raw filenames). Rates are instructions per process wall-clock second.','', '| Model | Region bytes | Repeat | Peak RSS (bytes) | Retired instructions | Wall seconds | Instructions / second |','| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
for r in records:
 name=f"{r['model']}-{r['region_bytes']}-{r['repetition']}"
 assert 'Program exited with code: 0' in (raw/(name+'.log')).read_text()
 count=int(re.search(r'^===== instructions retired\s*\n(\d+)',(raw/(name+'.txt')).read_text(),re.M)[1]);assert count==r['retired']
 peak=int(re.search(r'(\d+)\s+maximum resident set size',(raw/(name+'-time.txt')).read_text())[1]);assert peak==r['peak_rss_bytes']
 lines.append(f"| {r['model']} | {r['region_bytes']:,} | {r['repetition']+1} | {peak:,} | {count:,} | {r['process_wall_seconds']:.6f} | {r['retired_per_process_second']:,.2f} |")
lines+=['','| Model | Region bytes | RSS median (bytes) | RSS min–max (bytes) | RSS sample SD (bytes) | RSS sample variance (bytes²) | Median instructions / second |','| --- | ---: | ---: | --- | ---: | ---: | ---: |']
for m in ['RV32_ISS','RV32_5S']:
 summary[m]={}
 for region in [4096,4194304]:
  rows=[r for r in records if r['model']==m and r['region_bytes']==region];assert len(rows)==3
  rss=[r['peak_rss_bytes'] for r in rows];rate=[r['retired_per_process_second'] for r in rows]
  s={'n':3,'rss_median_bytes':st.median(rss),'rss_min_bytes':min(rss),'rss_max_bytes':max(rss),'rss_sample_sd_bytes':st.stdev(rss),'rss_sample_variance_bytes_squared':st.variance(rss),'rss_cv_percent':100*st.stdev(rss)/st.mean(rss),'rate_median':st.median(rate),'rate_sample_sd':st.stdev(rate)}
  summary[m][str(region)]=s
  lines.append(f"| {m} | {region:,} | {s['rss_median_bytes']:,} | {min(rss):,}–{max(rss):,} | {st.stdev(rss):,.2f} | {st.variance(rss):,.2f} | {st.median(rate):,.2f} |")
lines+=['','Sample variance uses denominator n−1. No outliers were removed.','', '| Model | Median RSS difference (bytes) | Host bytes / extra guest byte | Payload-only extrapolation for 18,405,414 guest bytes (host bytes) |','| --- | ---: | ---: | ---: |']
for m in summary:
 delta=summary[m]['4194304']['rss_median_bytes']-summary[m]['4096']['rss_median_bytes'];slope=delta/4190208
 summary[m]['slope_host_bytes_per_guest_byte']=slope
 summary[m]['payload_extrapolation_host_bytes']=slope*18405414
 lines.append(f'| {m} | {delta:,} | {slope:.6f} | {slope*18405414:,.0f} |')
lines+=['','The last column is an approximate incremental host-memory projection, **not observed baseline peak RSS**. It excludes the fixed process/model cost, assumes scaling beyond the measured range, and inherits all peak-RSS limitations below.','']
(base/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
(base/'results-tables.md').write_text('\n'.join(lines))
doc=root/'docs/remaining-verification-results.md'
s=doc.read_text().replace('<!-- STAGE1_RESULTS -->','\n'.join(lines)).replace('Results inserted below after the sequential runner completes','Completed: 12 successful samples; background-load limitations apply')
s=s.replace('Use a breakpoint at the delay immediately after the MMIO writer returns','For this exact GUI ELF, `draw=0x10e4`, `cube_led_write=0x14f4`, `led_replay_step=0x2f078` and `led_replay_round=0x2f074`. Use a breakpoint at `0x1128`, the delay initialization immediately after the MMIO writer returns')
doc.write_text(s)
print(json.dumps(summary,indent=2))
