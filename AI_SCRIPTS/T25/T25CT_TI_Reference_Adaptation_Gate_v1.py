#!/usr/bin/env python3
"""T25CT source-anchored static topology/reference screen, NOT PSpice or hardware proof.

The TI TIDA-00947 schematic and BOM are the source for R2/R3/R5/R6 and L1.
TI TPS54202 Rev C is the source for VFB, EN threshold and switching frequency.
No RevA CAD/BOM files are altered and reference design's 6.5-20 V evidence
MUST NOT be extrapolated into a verified USB=5.0 V result.
"""
import json
import hashlib
from decimal import Decimal as D, getcontext
from pathlib import Path

getcontext().prec=24
HERE=Path(__file__).resolve()
REPO_EVIDENCE=HERE.parents[2]/'AI_EVIDENCE'/'T25CT'
ROOT=REPO_EVIDENCE if REPO_EVIDENCE.is_dir() else HERE.parent

RTOP_EN_K=D('562')  # TIDA R2, VIN to EN
RBOT_EN_K=D('102')  # TIDA R5, EN to GND
RTOP_FB_K=D('200') # TIDA R3, VOUT to FB
RBOT_FB_K=D('44.2') # TIDA R6, FB to GND
VFB_RANGE=[D('0.581'),D('0.596'),D('0.611')] # TI at VIN12V - input caveat
VOUT=D('3.3')
ILOAD=D('0.280')
R_TOL=D('.01') # resistors are 1% in reference BOM
FREQ=[D('390000'),D('500000'),D('630000')] # TI operating interval
LINDS=[D('22e-6'),D('17.6e-6')] # nominal and hypothetical -20% L, not Murata/Tai-Tech guarantee
VIN=[D('5.0'),D('5.5'),D('12.0'),D('20.0')]


def divider(vin,rt,rb):
    return vin*rb/(rt+rb)

def setpoint(vref,rt,rb):
    return vref*(1+rt/rb)

def ripple(vin, vout, l, fsw):
    return vout*(vin-vout)/(vin*l*fsw)

fb_nom=setpoint(VFB_RANGE[1],RTOP_FB_K,RBOT_FB_K)
fb_min=setpoint(VFB_RANGE[0],RTOP_FB_K*(1-R_TOL),RBOT_FB_K*(1+R_TOL))
fb_max=setpoint(VFB_RANGE[2],RTOP_FB_K*(1+R_TOL),RBOT_FB_K*(1-R_TOL))
rows_en=[]
for v in [D('4.75'),*VIN]:
    base=divider(v,RTOP_EN_K,RBOT_EN_K)
    ven_min=divider(v,RTOP_EN_K*(1+R_TOL),RBOT_EN_K*(1-R_TOL))
    ven_max=divider(v,RTOP_EN_K*(1-R_TOL),RBOT_EN_K*(1+R_TOL))
    rows_en.append({'VIN_V':float(v),'EN_divider_nominal_V':float(base),
                    'EN_divider_1percent_min_V':float(ven_min),'EN_divider_1percent_max_V':float(ven_max),
                    'V_EN_rise_min_V_according_to_TI':1.21,
                    'EN_with_typical_0p7uA_plus_1p55uA_pullup_V_sensitivity':float(base + D('2.25e-6')*(RTOP_EN_K*D('1000'))*(RBOT_EN_K*D('1000'))/((RTOP_EN_K+RBOT_EN_K)*D('1000'))),
                    'resistor_only_best_case_below_TI_EN_rise_min':bool(ven_max<D('1.21'))})
rows_l=[]
for vin in VIN:
    for l in LINDS:
        for fsw in FREQ:
            r=ripple(vin,VOUT,l,fsw)
            rows_l.append({'VIN_V':float(vin),'VOUT_target_V':float(VOUT),
                'inductance_uH_scenario':float(l*D('1e6')),'fSW_kHz_scenario':float(fsw/D('1000')),
                'ripple_pp_A_ccm_approx':float(r),'peak_A_for_280mA_CCM_approx':float(ILOAD+r/2),
                'load_A_design':float(ILOAD)})

# Independent algebraic and monotonicity checks; numerical source is not model-vendor simulation.
assert len(rows_en)==5 and len(rows_l)==24
assert abs(divider(D('5'),RTOP_EN_K,RBOT_EN_K)-D('0.768072289156626506024096'))<D('.000000001')
assert fb_min<fb_nom<fb_max
assert all(r['resistor_only_best_case_below_TI_EN_rise_min'] for r in rows_en if r['VIN_V']<=5.5)
assert ripple(D('12'),VOUT,D('22e-6'),D('500000'))>ripple(D('5'),VOUT,D('22e-6'),D('500000'))
assert ripple(D('12'),VOUT,D('17.6e-6'),D('390000'))>ripple(D('12'),VOUT,D('22e-6'),D('500000'))

payload={'stage':'T25CT','classification':'ACTUAL_EXECUTED_REFERENCE_ARITHMETIC_NOT_VENDOR_MODEL_PASS',
 'date':'2026-10-09','source':{
 'TPS54202_datasheet':'https://www.ti.com/lit/ds/symlink/tps54202.pdf',
 'TIDA_00947_reference_page':'https://www.ti.com/tool/TIDA-00947',
 'TIDA_00947_BOM':'https://www.ti.com/lit/pdf/tidrmf5',
 'TIDA_00947_schematic':'https://www.ti.com/lit/pdf/tidrmf4',
 'model_metadata':'TPS54202 Unencrypted PSpice Transient Model Package Rev C, SLVMBJ5C.ZIP, TI product page; bytes NOT retrieved/executed',
 'TI_reference_verified_VIN_V':[6.5,20]},
 'locked_RevA':{'USB5p50V_no_nuisance':True,'BAT_loaded_pack_min_V':1.8,'3V3_system_design_load_A':0.28},
 'reference_parts_not_RevA_BOM':{
 'TPS54202':'TPS54202DDCR','L1_22uH':'THPC6045MF-220M, 1.9A, 96mOhm, 6x6mm',
 'C4_C5':'GRM21BZ71A226ME15L x2, nominal22uF each',
 'R2_EN_upper':'562k 1%','R5_EN_lower':'102k 1%',
 'R3_FB_upper':'200k 1%','R6_FB_lower':'44.2k 1%',
 'C6_feedforward':'30pF C0G',
 'C3_input':'10uF 35V (reference)'},
 'device_characteristics':{'VIN_recommended_V':[4.5,28],
 'EN_rise_threshold_V':[1.21,1.28],
 'EN_absolute_max_V':7, 'EN_pullup_current_typical_uA':0.7, 'EN_hysteresis_current_typical_uA':1.55,
 'FB_reference_V_at_VIN12V':[float(x) for x in VFB_RANGE],
 'fSW_kHz':[390,500,630],'soft_start_ms_typical_not_startup_guarantee':5},
 'feedback_ideal_DC_screen':{'nominal_V':float(fb_nom),'corner_min_V':float(fb_min),
 'corner_max_V':float(fb_max),'note':'VFB limits specified at VIN12V, do not assert same guaranteed VOUT at USB5V'},
 'EN_divider_resistor_only':rows_en,
 'inductor_CCM_ripple_scenario':rows_l,
 'most_constraining_5V_EN_no_external_driver':{'VIN_V':5.0,
 'EN_resistor_only_nominal_V':float(divider(D('5'),RTOP_EN_K,RBOT_EN_K)),
 'EN_rise_min_V':1.21,
 'statement':'Reference EN resistors do not meet enable rise threshold for USB5V with ideal passive divider; TI typical pull-up and hysteresis current do not erase the deficit in this calculation. External EN header/drive may override: NOT tested or approved.'},
 'design_consequence':['Do not copy TIDA-00947 EN resistors into RevA USB5V; change only in consolidated candidate ECO after validated EN margins.','TIDA VIN6.5..20 measured performance must not be claimed for USB5V or 5.5V.','At 3.3V target directly before a downstream mux, VOUT drop across mux may under-run 3V3_SYS spec; true mux conduction and logic/BOR constraints OPEN.','Upstream buck avoids pass-through 12V forcing its input-side switch 12V directly onto mux; it does NOT guarantee output has no fault overshoot.','Vendor model official listing is a useful executable path but has not been downloaded/run in current container.','No independent BAT1.80V no-reset / SD write / OLED evidence here.','Candidate inductor exact MPN and output capacitor exact MPN not Iran-stock qualified.','EN absolute max7V means a 12V raw USB fault must never directly drive EN.','TIDA EN network may rely on external enable control: source screenshot shows an EN header; do not misrepresent it as fixed always-on.']}
raw=(json.dumps(payload,ensure_ascii=False,indent=2)+'\n').encode('utf-8')
out=ROOT/'T25CT_TI_Reference_Adaptation_Result.json'
out.write_bytes(raw)
print(json.dumps({'result':str(out),'sha256':hashlib.sha256(raw).hexdigest(),'EN5':rows_en[1],
'FB_nom':float(fb_nom),'FB_corners':[float(fb_min),float(fb_max)],
'CCM_examples':[r for r in rows_l if r['VIN_V']==12.0 and r['inductance_uH_scenario']==22 and r['fSW_kHz_scenario']==500]}))
