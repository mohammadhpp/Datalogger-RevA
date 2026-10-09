#!/usr/bin/env python3
"""T25CQ deterministic, conditional power-path budget; NOT a circuit simulation.

No third-party dependencies. Source parameters are explicitly scenario-only.
No transistor/LDO/diode/mux behavioral models or PASS assertions.
"""
import argparse
import json
from decimal import Decimal


def d(x):
    return Decimal(str(x))


def bus_cmin_uf(load_ma, dead_us, start_v, floor_v):
    assert d(start_v) > d(floor_v) and d(load_ma) >= 0 and d(dead_us) >= 0
    return d(load_ma) * d(dead_us) / (d(start_v) - d(floor_v)) / 1000


def bus_gap_us(load_ma, ceff_uf, start_v, floor_v):
    assert d(load_ma) > 0 and d(ceff_uf) >= 0
    return d(ceff_uf) * (d(start_v) - d(floor_v)) * 1000 / d(load_ma)


def ldo_cin_gap_us(cin_uf, iin_ma, source_v, series_vf, output_v, vdrop):
    assert d(iin_ma) > 0 and d(cin_uf) >= 0
    margin = d(source_v) - d(series_vf) - d(output_v) - d(vdrop)
    return max(Decimal(0), d(cin_uf) * margin * 1000 / d(iin_ma))


def main():
    a = argparse.ArgumentParser(description=__doc__)
    a.add_argument('--out', default='', help='Optional JSON output path')
    v = a.parse_args()
    # All numbers are explicitly scenarios, not installed components/measurement.
    case = {'I_LOAD_mA': 280, 'BUS_START_V': 3.3, 'SCREEN_FLOOR_V': 2.7,
            'LDOCIN_mA': 280, 'LDOCIN_uF_scenario': 1,
            'LDO_OUTPUT_V_scenario': 3.3, 'LDO_DROPOUT_V_scenario': 0.9,
            'SERIES_DIODE_VF_V_scenario': 0.5}
    gaps = [5, 10, 25, 50, 100]
    ceffs = [0.5, 1, 4.7, 10, 22, 44]
    result = {
        'status': 'ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_HARDWARE_PASS',
        'scope': 'Capacitor-only lower-bound C and upper-bound source gap; constant current, no replenishment, fixed scenario thresholds. Not a mux/LDO fault simulation.',
        'assumptions': case,
        'required_Cbus_effective_uF': [
            {'gap_us': t, 'c_eff_min_uF': float(bus_cmin_uf(280, t, 3.3, 2.7))}
            for t in gaps],
        'available_gap_us_if_Cbus_effective': [
            {'Cbus_effective_uF': c, 'max_gap_us': float(bus_gap_us(280, c, 3.3, 2.7))}
            for c in ceffs],
        'illustrative_ldo_input_cap_gap_us': [
            {'USB_V': usb, 'Cin_effective_uF': c,
             'pre_dropout_gap_us': float(ldo_cin_gap_us(c, 280, usb, .5, 3.3, .9))}
            for usb in [5.0, 5.5] for c in [1, 4.7, 10]],
        'diode_forward_heat_W_at_280mA': [
            {'VF_scenario_V': f, 'diode_heat_W': float(d('.280') * d(f))}
            for f in ['0.3', '0.5', '0.6']],
        'non_claims': ['Cbus effective capacitance unknown: do not identify it with C_USB1/C_USB2/CIN/COUT or a nameplate',
                       '2.7 V is illustrative T25CP rail screen, NOT proven MCU BOR/SD write limit',
                       '0.9 V LDO dropout, 0.5 V diode VF and 280 mA input are hypothetical constant values; no worst-case guarantee',
                       'Series diode alone does not protect LDO output-to-input intrinsic body path; bypass diode alone does not block upstream discharge',
                       'T25CP reverse vendor model omits physical body diode; do not infer reverse PASS',
                       'Do not use missing TPS2121/TPS2116 current model as whole-system evidence'],
        'source_basis': ['Git main T25CP_LDO_FAULT_EDGE_AND_REVERSE_SCOPE_FA.md',
                         'Git main T25CP_WHOLE_POWER_DRAFT_FA.md',
                         'TI TLV767 RevD section 9.1.4',
                         'Git main T25X_OVP_MODEL_AND_BIAS_FEASIBILITY_FA.md']}
    # Numeric regression checks: separate Cbus is essential and monotonic.
    assert bus_cmin_uf(280, 10, 3.3, 2.7) == d(280)*10/d('.6')/1000
    assert bus_cmin_uf(280, 100, 3.3, 2.7) > bus_cmin_uf(280, 10, 3.3, 2.7)
    assert bus_gap_us(280, 10, 3.3, 2.7) == d(10)*d('.6')*1000/d(280)
    assert ldo_cin_gap_us(1, 280, 5, .5, 3.3, .9) == d(1)*d('.3')*1000/d(280)
    payload = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
    if v.out:
        with open(v.out, 'w', encoding='utf-8') as f:
            f.write(payload)
    else:
        print(payload)


if __name__ == '__main__':
    main()
