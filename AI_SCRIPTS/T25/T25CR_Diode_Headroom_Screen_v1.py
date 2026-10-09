#!/usr/bin/env python3
"""T25CR: scenario-only deterministic diode / LDO headroom and 12V thermal stress screen.

No part model, guaranteed LDO dropout, supplier stock proof, SPICE output,
or circuit-level acceptance is claimed. Standard-library only.
"""
import json
from decimal import Decimal as D
from pathlib import Path

OUTPUT = Path(__file__).with_name('T25CR_Diode_Headroom_Screen_Result.json')
VOUT = D('3.3')
ILOAD = D('.280')

def headroom(vusb, vf, vdrop):
    return D(str(vusb)) - D(str(vf)) - VOUT - D(str(vdrop))

def ldo_heat(vusb, vf):
    return (D(str(vusb)) - D(str(vf)) - VOUT) * ILOAD

def diode_heat(vf):
    return D(str(vf)) * ILOAD

def row(vusb, vf, vdrop):
    h = headroom(vusb, vf, vdrop)
    return {'USB_V_assumed':float(vusb),'diode_VF_V_assumed':float(vf),
            'LDO_dropout_V_assumed':float(vdrop),'headroom_V_sensitivity':float(h),
            'margin_sign_only':'nonnegative' if h >= 0 else 'negative'}

# All values below are sensitivity assumptions, not manufacturer worst cases.
cases = [row(src,vf,vdrop) for src in map(D,['4.75','5.00','5.50'])
         for vf in map(D,['0.30','0.50','0.60'])
         for vdrop in map(D,['0.20','0.90','1.20'])]
thermal = [{'source_V_assumed':float(src),'VF_V_assumed':float(vf),
            'diode_heat_W':float(diode_heat(vf)),
            'LDO_heat_W_if_unregulated_OVP_W':float(ldo_heat(src,vf)),
            'LDO_theta_JA_77p7_C_per_W_JEDEC_only':float(ldo_heat(src,vf)*D('77.7'))}
           for src in map(D,['5','5.5','12']) for vf in map(D,['0.3','0.5','0.6'])]
assert headroom('5','.5','.9') == D('.3')
assert headroom('4.75','.5','.9') == D('.05')
assert headroom('5','.6','1.2') == D('-.1')
assert ldo_heat('12','.5') == D('2.2960')
assert diode_heat('.5') == D('.1400')
assert len(cases) == 27 and len(thermal) == 9
obj={'classification':'ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_BOARD_OR_COMPONENT_PASS',
     'source_as_of':'2026-10-09',
     'basis':{'vishay_exact_MPN':'SS14-E3/61T',
       'official_pdf':'https://www.vishay.com/docs/88746/ss12.pdf',
       'vishay_rating':'SS14 VRRM40V, IFAV1A, IFSM40A on 8.3ms waveform',
       'vishay_forward_test':'VF max0.50V at 1A, TA25C, 300us pulse 1% duty; not all-temperature/280mA guaranteed VF',
       'vishay_reverse_test':'IR max0.2mA at TA25C and 6mA at TA100C, at rated blocking 40V; no battery reverse at 3.3V inferred',
       'ti_TLV767':'https://www.ti.com/product/TLV767',
       'ldo_dropout':'900mV TYPICAL product page, not a production worst-case',
       'iran_listing':'https://afranik.ir/passive/diode.html',
       'iran_listing_status':'Vishay exact string SS14-E3/61T displayed with MOQ10 and add-to-cart in indexed page. Actual lot/reel and checkout stock unverified.'},
     'headroom_screen':cases, 'thermal_screen':thermal,
     'limits':['Vusb 4.75V is a hypothetical input scenario, not a locked USB requirement.',
       'Vf and dropout swept independently as sensitivity, not measured correlations.',
       '12V series diode conducts when forward biased and cannot regulate an OVP fault.',
       '77.7 C/W is TLV767 reference-board thetaJA, not validated on 2-layer PCB.',
       'A diode before CIN can block upstream discharge; reverse current in TLV767 OUT->IN requires separate qualification and bypass-path consideration.',
       'No validated OVP model, true mux dead-time, BAT1.80V waveforms, Ceff, board PASS, procurement authorization, or ECO.']}
OUTPUT.write_text(json.dumps(obj,indent=2,ensure_ascii=False)+'\n', encoding='utf-8')
print(OUTPUT)
print('SS14 headroom at USB5,VF.5,dropout.9 (scenario):',headroom('5','.5','.9'))
print('12V fault LDO dissipation at VF.5 (scenario):',ldo_heat('12','.5'))
print('Cases:',len(cases),'Thermal cases:',len(thermal))
