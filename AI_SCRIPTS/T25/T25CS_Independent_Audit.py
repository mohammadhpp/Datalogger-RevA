#!/usr/bin/env python3
"""Independent analysis of full T25CS CSV output; not a board qualification."""
import csv, json, hashlib
from pathlib import Path
p=Path(__file__).parent
rows=list(csv.DictReader((p/'T25CS_SENSITIVITY_MATRIX.csv').open()))
bud=list(csv.DictReader((p/'T25CS_CUTOFF_BUDGET.csv').open()))
assert len(rows)==504 and len(bud)==72
for b in bud:
 k=(b['rise_us_scenario'],b['R_total_ohm_scenario'],b['Ceff_uF_scenario'])
 series=[r for r in rows if (r['rise_us_scenario'],r['R_total_ohm_scenario'],r['Ceff_uF_scenario'])==k]
 assert len(series)==7
 last=-1
 for r in sorted(series,key=lambda x:float(x['cut_delay_after_historic_trip_us_scenario'])):
  peak=float(r['peak_USB_VBUS_PROT_V_at_ideal_cutoff']); delay=float(r['cut_delay_after_historic_trip_us_scenario'])
  assert 5.5<=peak<=12.0 and peak>=last  # plateau can round to 12.0
  assert (peak<6)==(r['under_6V_within_synthetic_fixture']=='True')
  last=peak
 assert abs(float(b['historical_trip_cross_us'])/float(b['rise_us_scenario']) - (5.9157205069-5.5)/6.5)<3e-9
selected=[float(r['peak_USB_VBUS_PROT_V_at_ideal_cutoff']) for r in rows if r['rise_us_scenario']=='1' and r['R_total_ohm_scenario']=='0.128' and r['Ceff_uF_scenario']=='22.0' and r['cut_delay_after_historic_trip_us_scenario']=='1']
assert len(selected)==1 and abs(selected[0]-6.651681306)<1e-8
sha={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in p.iterdir() if f.is_file() and f.name!='T25CS_INDEPENDENT_AUDIT.json'}
audit={'check':'T25CS independent CSV audit','status':'PASS_CONDITIONAL_RC_ONLY','rows':len(rows),'cutoff_budgets':len(bud),
       'checks':['monotonic nondecreasing peak for same RC/rise','peak<=12V source','<6V flag consistent','trip crossing scales with ramp duration','independent selected numerical fixture'],
       'sha256':sha,'interpretation':'Numerical reproducibility only; no TS431/PNP/FET physical model or hardware PASS'}
(p/'T25CS_INDEPENDENT_AUDIT.json').write_text(json.dumps(audit,indent=2)+'\n')
print('INDEPENDENT AUDIT PASS',len(rows),len(bud),len(sha),'hashed files')
