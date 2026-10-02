#!/usr/bin/env python3
"""Audit a T25CE result ZIP without executing vendor code; never board PASS."""
import argparse
import hashlib
import json
import re
import zipfile
from pathlib import Path

def parse_tables(raw):
    columns = []
    waves = {}
    for line in raw.splitlines():
        tokens = line.split()
        if not tokens:
            continue
        if tokens[0] == 'TIME':
            columns = tokens[1:]
            continue
        if len(tokens) != len(columns) + 1 or not columns:
            continue
        try:
            numbers = [float(x) for x in tokens]
        except ValueError:
            continue
        for column, value in zip(columns, numbers[1:]):
            name = column.upper().replace('[', '').replace(']', '')
            waves.setdefault(name, {})[numbers[0]] = value
    return waves

def window(wave, lo, hi):
    rows = [(t,v) for t,v in wave.items() if lo <= t <= hi]
    return {'samples':len(rows), 'min':min((v for _,v in rows),default=None),
            'max':max((v for _,v in rows),default=None)}

def audit(raw):
    waves = parse_tables(raw)
    vout = waves.get('V(VOUT)', {})
    pre = window(vout, .013, .014)
    errors = len(re.findall(r'^\s*(?:ERROR(?:\(|\s|--)|WARNING(?:\(|\s|--))',raw,re.M))
    valid = ('JOB CONCLUDED' in raw and not errors and len(vout)>=1000
             and max(vout,default=0)>=.0279 and pre['samples']>=10
             and pre['min']>=3.576*.95 and pre['max']<=3.576*1.05)
    return {'status':'VALID_USB_FIXTURE_PRESTATE_ONLY' if valid else 'INVALID_OR_INCOMPLETE_FIXTURE',
            'solver_error_warning_count':errors,'vout_samples':len(vout),'prestate':pre,
            'fault_12V':window(vout,.015,.020),
            'usb_5p5V':window(vout,.021,.024),
            'unplug':{key:window(value,.025,.028) for key,value in waves.items()},
            'scope':'NO_MUX_NO_TPS631000_NO_BOARD_OR_FABRICATION_PASS'}

def self_test():
    # Split PRINT tables with unequal column counts must not mix rows/timestamps.
    raw='TIME V([VIN]) V([VOUT])\n0.000E+00 5.000E+00 3.576E+00\n2.000E-06 5.000E+00 3.575E+00\n\nTIME V([EN])\n0.000E+00 1.500E+00\n2.000E-06 1.501E+00\n'
    w=parse_tables(raw)
    assert w['V(VOUT)']=={0.:3.576,2e-6:3.575}
    assert w['V(EN)']=={0.:1.5,2e-6:1.501}
    assert audit(raw)['status']=='INVALID_OR_INCOMPLETE_FIXTURE'
    complete='TIME V([VOUT])\n'+'\n'.join(f'{i*2e-6:.9e} 3.576' for i in range(14001))+'\nJOB CONCLUDED\n'
    assert audit(complete)['status']=='VALID_USB_FIXTURE_PRESTATE_ONLY'
    assert audit(complete.replace('3.576','0.5'))['status']=='INVALID_OR_INCOMPLETE_FIXTURE'
    print('Parser split-table and valid/invalid prestate checks passed. Synthetic data only.')

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('zip',type=Path,nargs='?')
    ap.add_argument('--self-test',action='store_true')
    a=ap.parse_args()
    if a.self_test:
        self_test(); return
    if not a.zip:
        ap.error('result ZIP required')
    results={}
    with zipfile.ZipFile(a.zip) as z:
        for item in z.infolist():
            if item.filename.lower().endswith('.out'):
                if item.file_size>50_000_000: raise ValueError('Oversized output')
                name=Path(item.filename.replace('\\','/')).name
                if name in results: raise ValueError('Duplicate output basename')
                results[name]=audit(z.read(item).decode('utf-8',errors='replace'))
    result={'result_zip_sha256':hashlib.sha256(a.zip.read_bytes()).hexdigest(),
            'scope':'USB_CANDIDATE_ONLY_NO_BOARD_PASS','cases':results}
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
