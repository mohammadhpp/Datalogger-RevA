#!/usr/bin/env python3
"""T25CV conditional, KCL-correct AA pack VIN path model, not vendor simulation."""
from decimal import Decimal as D
from pathlib import Path
import json
pack=D('1.8');vstart=D('1.65');pout=D('3.3')*D('.280')
eta=[D('.70'),D('.75'),D('.80'),D('.85'),D('.90')]
res=[D('0'),D('.05'),D('.10'),D('.15'),D('.20'),D('.25'),D('.30')]
rows=[];limits=[]
for e in eta:
 maxr=(pack-vstart)*vstart*e/pout
 limits.append({'eta':float(e),'R_at_device_1p65_ohm':float(maxr)})
 for r in res:
  delta=pack*pack-4*r*pout/e
  if delta<0:rows.append({'eta':float(e),'Rohm':float(r),'status':'no_constant_power_solution'});continue
  vin=(pack+delta.sqrt())/2
  i=pout/(e*vin)
  assert abs(pack-vin-r*i)<D('1e-25')
  rows.append({'eta':float(e),'Rohm':float(r),'pin_V':float(vin),'input_A':float(i),'startup_Vgt1p65':bool(vin>vstart)})
assert len(rows)==35
Path('T25CV_Git_Result.json').write_text(json.dumps({'classification':'CONDITIONAL_DC_ONLY_NO_DEVICE_PASS',
 'TI':'https://www.ti.com/lit/ds/symlink/tps631000.pdf','Pout_W':float(pout),
 'Rlimits':limits,'rows':rows},indent=2)+'\n')
print('35 KCL input pin DC scenario checks; NOT a PSpice/board PASS')
