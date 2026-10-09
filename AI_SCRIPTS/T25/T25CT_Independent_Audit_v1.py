#!/usr/bin/env python3
"""Independent read-only audit of T25CT conditional reference-design evidence.

Uses exact rational arithmetic separate from Decimal script; no hardware claims.
"""
import json,hashlib
from fractions import Fraction as F
from pathlib import Path
here=Path(__file__).resolve()
repo_evidence=here.parents[2]/'AI_EVIDENCE'/'T25CT'
root=repo_evidence if repo_evidence.is_dir() else here.parent
src=root/'T25CT_TI_Reference_Adaptation_Result.json'
raw=src.read_bytes(); payload=json.loads(raw)
checks=[]
def eq(label,got,want,tol=1e-11):
    delta=abs(got-float(want))
    assert delta<tol,(label,got,float(want),delta)
    checks.append(label)

def frac(v):return F(str(v))
for row in payload['EN_divider_resistor_only']:
    vin=frac(row['VIN_V'])
    eq('ENnom'+str(vin),row['EN_divider_nominal_V'],vin*102/(562+102))
    eq('ENmin'+str(vin),row['EN_divider_1percent_min_V'],vin*(102*F('0.99'))/(562*F('1.01')+102*F('0.99')))
    eq('ENmax'+str(vin),row['EN_divider_1percent_max_V'],vin*(102*F('1.01'))/(562*F('0.99')+102*F('1.01')))
for row in payload['inductor_CCM_ripple_scenario']:
    vi=frac(row['VIN_V']);L=frac(row['inductance_uH_scenario'])*F('0.000001')
    freq=frac(row['fSW_kHz_scenario'])*1000
    rip=F('3.3')*(vi-F('3.3'))/(vi*L*freq)
    eq('ripple_%s_%s_%s'%(vi,L,freq),row['ripple_pp_A_ccm_approx'],rip)
    eq('peak_%s_%s_%s'%(vi,L,freq),row['peak_A_for_280mA_CCM_approx'],F('0.28')+rip/2)
fb=payload['feedback_ideal_DC_screen']
eq('FBnom',fb['nominal_V'],F('.596')*(1+F('200')/F('44.2')))
eq('FBmin',fb['corner_min_V'],F('.581')*(1+F('200')*F('.99')/(F('44.2')*F('1.01'))))
eq('FBmax',fb['corner_max_V'],F('.611')*(1+F('200')*F('1.01')/(F('44.2')*F('.99'))))
assert len(checks)==66,len(checks)
assert payload['source']['TI_reference_verified_VIN_V']==[6.5,20]
assert all(row['EN_divider_1percent_max_V']<1.21 for row in payload['EN_divider_resistor_only'] if row['VIN_V']<=5.5)
result={'classification':'AUDIT_PASS_OF_CONDITIONAL_EQUATIONS_ONLY','rows_checked':len(checks),
        'source_json_sha256':hashlib.sha256(raw).hexdigest(),
        'explicit_nonclaims':['not TPS54202 PSpice run','not controller actual EN startup proof','not USB5V reference design qualification','not L inductance derating guarantee','not output voltage/MCU BOR PASS','not Iranian procurement approval']}
dest=root/'T25CT_Independent_Audit.json'
dest.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result))
