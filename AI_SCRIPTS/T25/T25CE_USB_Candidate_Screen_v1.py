#!/usr/bin/env python3
"""T25CE reproducible USB candidate screen; no vendor simulation or board PASS.

Writes numerical sensitivity evidence and six PSpice decks for a *new* TPS54202
fixture. 19mA is the old observation; 280mA is the design envelope. Effective
capacitance, efficiency and fault waveform below are scenarios, not qualified
RevA values. No TPS2116/TPS631000 vendor model is used or replaced here.
"""
import argparse
import csv
import itertools
import json
import math
from pathlib import Path

ZIP_SHA = '39e524bc2cc9a71a22e8afb753ccc5f2f8ee16ca0f491763b52ba1eb9c16271b'
LIB_SHA = '2410b7f6f64162ffe6c3ca94565396870aa55e4cafbeccd2382bc2471d933d3d'

def corners():
    # Buck lower divider is two existing ARG05DTC1002 10k +/-0.5% in series.
    out = [v * (1 + rt / (rb1 + rb2))
           for v, rt, rb1, rb2 in itertools.product(
               (.581, .611), (99000, 101000), (9950, 10050), (9950, 10050))]
    pr = [v * (1 + (rt1 + rt2) / rb)
          for v, rt1, rt2, rb in itertools.product(
              (.92, 1.08), (9950, 10050), (9950, 10050), (9950, 10050))]
    return {'buck_static_min_v': min(out), 'buck_static_max_v': max(out),
            'pr_boundary_min_v': min(pr), 'pr_boundary_max_v': max(pr),
            'static_selection_margin_v': min(out) - max(pr)}

def deck(load_ma, cout_uf, cff_pf=56):
    # Resistive fixture equivalent at the nominal 3.576V. Not a real load profile.
    pin = 3.3 * load_ma / 1000 / .75
    rload = 1e9 if pin == 0 else 3.576**2 / pin
    return f'''T25CE TPS54202 USB ONLY - NO BOARD PASS
* Effective capacitors and source waveform are declared sensitivity fixtures.
* Do not connect this 3.576V rail to USB_5V_AUX.
.LIB "TPS54202_TRANS.LIB"
V_SRC SRC 0 PWL(0 0 1u 5 15m 5 15.001m 12 20m 12 20.001m 5.5 28m 5.5)
R_SOURCE SRC USB_SRC 0.1
V_CONNECT CONNECT 0 PWL(0 0 1u 1 24.999m 1 25m 0 28m 0)
S_CABLE USB_SRC VIN CONNECT 0 CABLE_SW
.MODEL CABLE_SW VSWITCH(RON=0.01 ROFF=1G VON=0.9 VOFF=0.1)
* Cable unplug OPENS the source; it does not short VIN to zero.
R_CIN VIN CIN 0.005
C_CIN CIN 0 22u
R_LEAK VIN 0 1G
X_USB 0 PH VIN FB EN BOOT TPS54202_TRANS PARAMS: STEADY_STATE=0
* EN left floating per TI; never tied to raw 12V.
C_BOOT BOOT PH 100n
L_USB PH LX 10u
R_DCR LX VOUT 0.029
R_COUT VOUT COUT 0.005
C_COUT COUT 0 {cout_uf}u
R_TOP VOUT FB 100k
R_BOTTOM1 FB FBMID 10k
R_BOTTOM2 FBMID 0 10k
C_FF VOUT FB {cff_pf}p
R_LOAD VOUT 0 {rload:.12g}
.TRAN 2u 28m 0 0.2u
.OPTIONS ADVCONV
.PROBE64 V([VIN]) V([VOUT]) V([EN]) V([FB]) I(L_USB) I(V_SRC)
.PRINT TRAN V([VIN]) V([VOUT]) V([EN]) I(L_USB) I(V_SRC)
.END
'''

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[2])
    a = ap.parse_args()
    evidence = a.root / 'AI_EVIDENCE/T25CE'
    decks = a.root / 'AI_SCRIPTS/T25/T25CE_DECKS'
    evidence.mkdir(parents=True, exist_ok=True)
    decks.mkdir(parents=True, exist_ok=True)
    c = corners()
    cases = []
    # Start with maximum design equivalent and 44uF: valid prestate is mandatory.
    for load, cap in ((280, 44), (280, 22), (19, 44), (19, 22), (0, 44), (0, 22)):
        name = f'LOAD_{load}mA_CEFF_{cap}uF'
        (decks / (name + '.cir')).write_text(deck(load, cap), encoding='ascii')
        cases.append({'name': name, 'load_mA_at_3V3_equivalent': load,
                      'Cout_effective_scenario_uF': cap, 'eta_scenario': .75})
    sweep = []
    for eta, vout, vin, leff in itertools.product((.70, .75, .90),
                                                (c['buck_static_min_v'], 3.576, c['buck_static_max_v']),
                                                (5., 5.5, 12.), (8e-6, 5.6e-6)):
        pout = .924 / eta
        iavg = pout / vout
        ripple = vout * (1-vout/vin) / (leff * 400000)
        rms = math.sqrt(iavg**2 + ripple**2 / 12)
        sweep.append({'eta_scenario': eta, 'vout_V': vout, 'vin_V': vin,
                      'L_effective_scenario_uH': leff*1e6,
                      'I_avg_A': iavg, 'delta_I_pp_A': ripple,
                      'I_peak_CCM_screen_A': iavg + ripple/2,
                      'I_rms_CCM_screen_A': rms,
                      'DCR_25C_0p029ohm_loss_W': rms*rms*.029})
    p = .924/.75
    c.update({'power_at_280mA_W': .924,
              'cout_eff_for_f0_40kHz_at_min_vout_uF': 3.95/(c['buck_static_min_v']*40000)*1e6,
              'vin1_cap_eff_for_slope_0p1V_per_us_uF_at_eta_0p70':
                  (.924/.70)/(c['pr_boundary_min_v']*1e5)*1e6,
              'I_peak_max_CCM_sweep_A': max(x['I_peak_CCM_screen_A'] for x in sweep),
              'c_mux_eff_100us_to_1p84V_at_eta_0p75_uF':
                  2*p*100e-6/(c['pr_boundary_min_v']**2-1.84**2)*1e6})
    with (evidence/'T25CE_USB_LC_corner_sweep.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(sweep[0]));w.writeheader();w.writerows(sweep)
    # Actual execution of capacitor-only energy traces. No hidden device dynamics.
    with (evidence/'T25CE_USB_cap_only_unplug_trace.csv').open('w',newline='') as f:
        w=csv.writer(f);w.writerow(['Ceff_scenario_uF','eta_scenario','time_s','VIN1_conditional_V'])
        for cap in (4.2, 10, 22, 44):
            for eta in (.70,.75,.90):
                for i in range(501):
                    t=i*1e-6
                    v=math.sqrt(max(0,3.576**2-2*(.924/eta)*t/(cap*1e-6)))
                    if v < 1.6: break
                    w.writerow([cap,eta,t,v])
    result={'status':'ACTUAL_TEST_WITH_RAW_EVIDENCE',
            'scope':'EXECUTED_STATIC_AND_CAPACITOR_ONLY_SENSITIVITY_NO_HARDWARE_PASS',
            'vendor_model_status':'TEST_STAGED_AWAITING_USER_RUN_OR_HARDWARE',
            'cad_unchanged':True, 'fabrication_hold':True,
            'zip_sha256':ZIP_SHA,'lib_sha256':LIB_SHA,
            'model_encrypted_despite_download_title':True,
            'corners':c,'cases':cases,
            'warnings':['PR1 hysteresis/leakage/dynamic margin NOT covered by static corners',
                        'CCM ripple math is a screen; Eco-mode/light load/saturation/temperature NOT proven',
                        '500kHz typical; 400kHz minimum frequency used in LC screen',
                        'No actual TPS2116 gap, no TPS631000 rail, no card-write evidence',
                        'A 12V/1us/0.1ohm fixture is NOT an approved fault envelope']}
    (evidence/'T25CE_executed_screen.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(c,indent=2))
    print('Generated 6 isolated USB vendor-model fixtures; none executed here.')

if __name__ == '__main__': main()
