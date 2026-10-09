#!/usr/bin/env python3
"""Independent audit of T25CW saved CSV/JSON without importing simulator."""
import csv, json, math, hashlib
from pathlib import Path
from decimal import Decimal as D, getcontext
getcontext().prec=40
root=Path(__file__).resolve().parent
readcsv=lambda name:list(csv.DictReader((root/name).open(encoding='utf-8',newline='')))
original=json.loads((root/'T25CW_RESULT.json').read_text(encoding='utf-8'))
battery=readcsv('T25CW_BAT_DC_CASES.csv')
dynamic=readcsv('T25CW_CURRENT_LIMITED_HANDOFF.csv')
raw=readcsv('T25CW_SELECTED_TRACE.csv')
errors=[]; checks=0

def check(claim,label):
    global checks
    checks+=1
    if not claim:errors.append(label)

check(len(battery)==25,'DC row count')
check(len(dynamic)==27,'transient scenario count')
check(len(raw)==181,'trace 1us sampling rows')
check(len(original['battery_dc_screens'])==25,'JSON DC row count')
for i, row in enumerate(battery):
    r=D(row['r_post_pack_ohm_assumed']);eta=D(row['eta_assumed']);pin=D(row['vpin_V']);ib=D(row['iin_A'])
    check(abs(D('1.8')-r*ib-pin)<D('1e-12'),f'BAT KVL {i}')
    check(abs(eta*pin*ib-D('0.924'))<D('1e-12'),f'BAT power {i}')
    check(bool(row['startup_pin_above_1p65']=='True')==(pin>D('1.65')),f'BAT startup threshold {i}')
    check(bool(row['running_pin_at_least_1p60']=='True')==(pin>=D('1.60')),f'BAT run threshold {i}')
    ref=original['battery_dc_screens'][i]
    check(abs(float(pin)-ref['vpin_V'])<1e-12,f'JSON DC match {i}')
for j,row in enumerate(original['postmux_cap_floor_budgets']):
    gap=D(str(row['deadtime_us']));floor=D(str(row['floor_V_assumed']));value=D(str(row['min_C_postmux_effective_uF']))
    expected=D('0.28')*gap/(D('3.3')-D('0.28')*D('0.04')-floor)
    check(abs(value-expected)<D('1e-10'),f'charge eq {j}')
for k,case in enumerate(dynamic):
    c=float(case['cap_eff_uF_assumed']); gap=float(case['deadtime_us_assumed']);ramp=float(case['source_current_ramp_us_assumed']);minv=float(case['min_rail_V']); mint=float(case['time_min_us'])
    # Independent closed-form no-source interval; minimum over entire trace <= at deadtime.
    at_gap=3.3-0.28*.04-0.28*gap/c
    check(minv <= at_gap+3e-6,f'deadtime envelope {k}')
    check(minv>0 and 0<=mint<=180.000001,f'domain {k}')
    check(abs(float(case['source_charge_uC'])-float(case['load_charge_uC'])-(float(case['end_rail_V'])-(3.3-.28*.04))*c)<5e-7,f'charge conservation {k}')
    check(case['crosses_SD_2p7'].lower()==str(minv<2.7).lower(),f'SD threshold {k}')
    check(case['crosses_OLED_2p8_only_if_matching_panel'].lower()==str(minv<2.8).lower(),f'OLED threshold {k}')
for k,row in enumerate(raw):
    check(int(round(float(row['time_us'])))==k,f'trace time {k}')
    check(0<=float(row['source_current_A'])<=0.560000001,f'src envelope {k}')
    check(abs(float(row['load_A'])-.280)<1e-12,f'load envelope {k}')
# Induced min from saved trace is a sampling upper estimate; 1us resolution vs simulation .05us.
obs=min(float(t['vbus_V']) for t in raw)
match=[x for x in original['postmux_27_dynamic_current_screens'] if x['cap_eff_uF_assumed']==22 and x['deadtime_us_assumed']==25 and x['source_current_ramp_us_assumed']==50]
check(len(match)==1,'selected trace identity')
check(abs(obs-match[0]['min_rail_V'])<.00065,'selected trace vs 0.05us min')
files={p.name:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sorted(root.glob('T25CW_*')) if p.name not in ('T25CW_Independent_Audit.json','T25CW_PACKAGE_MANIFEST.json')}
audit={'status':'PASS' if not errors else 'FAIL','assertions':checks,'errors':errors,'provenance':'independent Decimal DC/KVL/KCL/threshold and trace consistency; not a hardware or vendor-model certification','input_files':files}
(root/'T25CW_Independent_Audit.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8')
print('AUDIT',audit['status'], 'assertions',checks,'errors',len(errors))
if errors: print('\n'.join(errors[:25])); raise SystemExit(1)
