#!/usr/bin/env python3
"""Reproducible T25CU condensed TI EN sensitivity; not a device model."""
import json
from decimal import Decimal as D
from itertools import product
from pathlib import Path
tol=D('0.01'); currents=[D('0'),D('.7e-6'),D('2.25e-6')]
networks={'TIDA_562K_102K':(D('562000'),D('102000')),
          'UNSELECTED_150K_100K':(D('150000'),D('100000'))}
rows=[]
for name,(top,bot) in networks.items():
 for vin,p,q,i in product(map(D,['4.5','5','5.5','12','28']),[-tol,tol],[-tol,tol],currents):
  rt=top*(1+p);rb=bot*(1+q)
  v1=vin*rb/(rt+rb)+i*rt*rb/(rt+rb)
  v2=(vin/rt+i)/(1/rt+1/rb)
  assert abs(v1-v2)<D('1e-20')
  rows.append(dict(network=name,VIN=float(vin),EN=float(v1),Ip_microA=float(i*1000000)))
assert len(rows)==120
def filt(n,v,ip):
 return [r['EN'] for r in rows if r['network']==n and r['VIN']==v and r['Ip_microA']==ip]
assert max(filt('TIDA_562K_102K',5.,2.25))<1.21
assert min(filt('UNSELECTED_150K_100K',5.,0.))>1.28
assert max(filt('UNSELECTED_150K_100K',12.,2.25))<5.5
assert min(filt('UNSELECTED_150K_100K',28.,0.))>7
assert D('1.28')/D('4.5')>D('5.5')/D('28')
out={'classification':'ACTUAL_TEST_WITH_RAW_EVIDENCE__CONDITIONAL_MATH_ONLY','count':len(rows),
 'official_ti_reference':'https://www.ti.com/lit/ds/symlink/tps54202.pdf',
 'preferred_TI_datasheet_configuration':'FLOAT_EN_TO_ENABLE',
 'warnings':['Internal currents 0.7/1.55uA are typical only','No verified TI SLVMBJ5C model bytes; no simulator run','No CAD/BOM or manufacturing PASS'],
 'rows':rows}
Path('T25CU_Git_Corner_Result.json').write_text(json.dumps(out,indent=2)+'\n')
print('PASS 120 independent KCL checked corner results; vendor simulation NOT RUN')
