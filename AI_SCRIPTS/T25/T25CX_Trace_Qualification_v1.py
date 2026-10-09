#!/usr/bin/env python3
"""T25CX: evidence-grade power handoff trace screen, NEVER standalone board PASS.

Python 3 standard library, ASCII source, Windows-compatible.
No fabricated mux/regulator/vendor models. Distinguishes current at input pins
from downstream output; refuses old T25CW incomplete schema.

Run: python T25CX_Trace_Qualification_v1.py --selftest --output T25CX_SELFTEST.json
Run: python T25CX_Trace_Qualification_v1.py --trace measured.csv --metadata metadata.json --output result.json
"""
import argparse, csv, io, json, math
from pathlib import Path

BASE_COLS = ["time_us","v_pack_loaded_v","v_bat_pin_v","v_bat_reg_v",
             "v_usb_reg_v","v_3v3_sys_v","v_mcu_vdd_v","v_sd_vdd_v",
             "i_usb_mux_input_a","i_bat_mux_input_a","i_mux_output_a",
             "i_load_a","nrst_asserted","sd_write_active"]
META_REQUIRED = ["topology","provenance","c_bus_effective_min_uf",
                 "c_bus_capacitance_basis","max_sample_interval_us",
                 "event_direction","sd_write_result_evidence"]


def parse_csv(txt):
    cr = csv.DictReader(io.StringIO(txt))
    rows = list(cr)
    return cr.fieldnames or [], rows


def check_trace(txt, meta):
    fields, raw = parse_csv(txt)
    missing = [c for c in BASE_COLS if c not in fields]
    absent_meta = [c for c in META_REQUIRED if c not in meta]
    ans = {"classification": "TEST_STAGED_AWAITING_QUALIFIED_DEVICE_OR_PHYSICAL_TRACE",
           "waveform_screen": "NOT_EVALUABLE", "system_pass": False,
           "missing_columns": missing, "missing_metadata": absent_meta,
           "violations": [], "warnings": [], "observed": {},
           "provenance": meta.get('provenance','UNDECLARED')}
    if missing or absent_meta:
        ans['violations'].append('REQUIRED_PROBE_OR_PROVENANCE_ABSENT')
        return ans
    if len(raw) < 3:
        ans['violations'].append('INSUFFICIENT_SAMPLES')
        return ans
    try:
        rows = [{k: float(row[k]) for k in BASE_COLS} for row in raw]
        ceff = float(meta['c_bus_effective_min_uf']) * 1e-6
        max_dt = float(meta['max_sample_interval_us'])
    except (ValueError, TypeError, KeyError) as e:
        ans['violations'].append('NONNUMERIC_TRACE_OR_METADATA: '+str(e))
        return ans
    if ceff <= 0 or not math.isfinite(ceff) or max_dt <= 0:
        ans['violations'].append('INVALID_CAPACITANCE_OR_RESOLUTION')
        return ans
    times = [r['time_us'] for r in rows]
    if not all(math.isfinite(v) for r in rows for v in r.values()):
        ans['violations'].append('NONFINITE_VALUES')
        return ans
    deltas = [b-a for a,b in zip(times, times[1:])]
    if any(d <= 0 for d in deltas):
        ans['violations'].append('NONMONOTONIC_OR_DUPLICATE_TIME')
        return ans
    if max(deltas) > max_dt + 1e-9:
        ans['violations'].append('UNDERRESOLVED_TRACE')
    if meta['topology'] != 'DOWNSTREAM_DUAL_REGULATED_MUX_UNAPPLIED':
        ans['warnings'].append('TRACE_TOPOLOGY_NOT_UNAPPLIED_PROPOSAL; review live routing independently')
    if meta['event_direction'] not in ('USB_TO_BAT', 'BAT_TO_USB'):
        ans['violations'].append('EVENT_DIRECTION_INVALID')
    if not any(r['sd_write_active'] >= 0.5 for r in rows):
        ans['violations'].append('NO_SD_WRITE_STIMULUS')
    if any(r['nrst_asserted'] > 0.5 for r in rows):
        ans['violations'].append('NRST_ASSERTION_OBSERVED')
    if min(r['v_mcu_vdd_v'] for r in rows) <= 2.04:
        ans['violations'].append('MCU_VDD_REACHES_PDR_MAX')
    if min(r['v_sd_vdd_v'] for r in rows) < 2.7:
        ans['violations'].append('SD_VDD_BELOW_STANDARD_MINIMUM')
    # The separate OLED carrier has NO verified electrical voltage floor.
    ans['warnings'].append('OLED_CARRIER_VOLTAGE_AND_SD_WRITE_INTEGRITY_NOT_INFERRED_FROM_THESE_WAVEFORMS')
    # CURRENT INTO mux = CURRENT OUT + estimated internal Iq (mostly negligible)
    # signed probe values must be positive into inputs and out to bus.
    mux_resid = [r['i_usb_mux_input_a']+r['i_bat_mux_input_a']-r['i_mux_output_a'] for r in rows]
    # Bus capacitor KCL: I_mux_out - I_load = Cbus*dV/dt. Midpoint test.
    bus_resid = []
    for a,b,dt in zip(rows, rows[1:], deltas):
        implied_cap = ceff*(b['v_3v3_sys_v']-a['v_3v3_sys_v'])/(dt*1e-6)
        i_mid = ((a['i_mux_output_a']+b['i_mux_output_a'])
                 -(a['i_load_a']+b['i_load_a']))/2
        bus_resid.append(i_mid-implied_cap)
    # Tolerances are SCREEN thresholds, not instrument specs. Assumes no other
    # branch current beyond the named output, Iload, and Cbus paths.
    mux_allowed = float(meta.get('mux_kcl_tolerance_a',0.01))
    bus_allowed = float(meta.get('bus_kcl_tolerance_a',0.015))
    if max(abs(x) for x in mux_resid)>mux_allowed:
        ans['violations'].append('MUX_INPUT_OUTPUT_CURRENT_NOT_CONSERVED')
    if max(abs(x) for x in bus_resid)>bus_allowed:
        ans['violations'].append('BUS_CBUS_LOAD_CURRENT_NOT_CONSERVED')
    if any(r['i_usb_mux_input_a'] < -mux_allowed or r['i_bat_mux_input_a'] < -mux_allowed for r in rows):
        ans['violations'].append('SOURCE_REVERSE_CURRENT_UNQUALIFIED')
    if meta['event_direction']=='USB_TO_BAT':
        # Source readiness can be checked against the mux's fast-collapse rule
        # if a rapid USB fall was captured. v_bat_reg is mux VIN2, not raw AA.
        fast_indices=[j for j,(a,b,dt) in enumerate(zip(rows,rows[1:],deltas))
                      if (a['v_usb_reg_v']-b['v_usb_reg_v'])/dt > 0.1]
        if fast_indices and min(rows[j]['v_bat_reg_v'] for j in fast_indices)<2.5:
            ans['violations'].append('BAT_MUX_INPUT_BELOW_2P5_DURING_FAST_USB_COLLAPSE')
    ans['observed']={"n":len(rows),"min_bus_v":min(r['v_3v3_sys_v'] for r in rows),
        "min_mcu_vdd_v":min(r['v_mcu_vdd_v'] for r in rows),
        "min_sd_vdd_v":min(r['v_sd_vdd_v'] for r in rows),
        "max_dt_us":max(deltas),"max_mux_kcl_residual_a":max(abs(x) for x in mux_resid),
        "max_bus_kcl_residual_a":max(abs(x) for x in bus_resid)}
    ans['waveform_screen']='CONDITIONAL_SCREEN_PASS' if not ans['violations'] else 'SCREEN_FAIL'
    # Screen PASS is NOT hardware/firmware PASS. NEVER promote automatically.
    if meta['provenance'] not in ('VALIDATED_VENDOR_MODEL_WITH_PIN_MAP','MEASURED_PHYSICAL_SUBASSEMBLY'):
        ans['warnings'].append('SOURCE_NOT_VENDOR_QUALIFIED_OR_PHYSICALLY_MEASURED')
    if meta.get('sd_write_result_evidence') in (None, '', 'NO_REAL_SD_WRITE_WITNESS'):
        ans['warnings'].append('NO_SD_WRITE_SUCCESS_AND_DATA_INTEGRITY_WITNESS')
    return ans


def demo_case(kind='nominal'):
    cols=BASE_COLS[:]
    io_buf=io.StringIO(newline='')
    wr=csv.DictWriter(io_buf,fieldnames=cols,lineterminator='\n');wr.writeheader()
    for idx in range(41):
        t=.25*idx
        r={'time_us':t,'v_pack_loaded_v':1.80,'v_bat_pin_v':1.70,
           'v_bat_reg_v':3.3,'v_usb_reg_v':3.3,'v_3v3_sys_v':3.3,
           'v_mcu_vdd_v':3.3,'v_sd_vdd_v':3.3,
           'i_usb_mux_input_a':.28,'i_bat_mux_input_a':0,
           'i_mux_output_a':.28,'i_load_a':.28,
           'nrst_asserted':0,'sd_write_active':1}
        if kind=='unloaded_model': r['i_usb_mux_input_a']=0
        if kind=='sd_droop': r['v_sd_vdd_v']=2.60
        if kind=='reset': r['nrst_asserted']=int(idx==20)
        if kind=='battery_fast_collapse':
            r['v_usb_reg_v']=3.3 if idx<10 else 0
            r['v_bat_reg_v']=1.80
        if kind=='gap':
            r['time_us']=2*idx
        wr.writerow(r)
    return io_buf.getvalue()


def demo_meta():
    return {"topology":"DOWNSTREAM_DUAL_REGULATED_MUX_UNAPPLIED",
            "provenance":"SYNTHETIC_UNIT_TEST_NOT_A_DEVICE_MODEL",
            "c_bus_effective_min_uf":22.0,
            "c_bus_capacitance_basis":"HYPOTHETICAL_NOT_INSTALLED",
            "max_sample_interval_us":.5,
            "event_direction":"USB_TO_BAT",
            "sd_write_result_evidence":"NO_REAL_SD_WRITE_WITNESS"}


def selftest():
    meta=demo_meta()
    cases=['nominal','unloaded_model','sd_droop','reset','battery_fast_collapse','gap']
    outputs={k:check_trace(demo_case(k),meta) for k in cases}
    assert outputs['nominal']['waveform_screen']=='CONDITIONAL_SCREEN_PASS'
    assert outputs['nominal']['system_pass'] is False
    assert 'MUX_INPUT_OUTPUT_CURRENT_NOT_CONSERVED' in outputs['unloaded_model']['violations']
    assert 'SD_VDD_BELOW_STANDARD_MINIMUM' in outputs['sd_droop']['violations']
    assert 'NRST_ASSERTION_OBSERVED' in outputs['reset']['violations']
    assert 'BAT_MUX_INPUT_BELOW_2P5_DURING_FAST_USB_COLLAPSE' in outputs['battery_fast_collapse']['violations']
    assert 'UNDERRESOLVED_TRACE' in outputs['gap']['violations']
    # Legacy CW archive has only bus/source summary; must never pass full gate.
    old_schema='time_us,vbus_V,source_current_A,load_A\n0,3.3,0,.28\n1,3.28,0,.28\n2,3.27,0,.28\n'
    outputs['legacy_T25CW_header']=check_trace(old_schema,meta)
    assert outputs['legacy_T25CW_header']['waveform_screen']=='NOT_EVALUABLE'
    assert 'v_sd_vdd_v' in outputs['legacy_T25CW_header']['missing_columns']
    return {"tests_run":7,"all_assertions_passed":True,
            "status":"VALIDATOR_UNIT_TEST_PASS_NO_PHYSICAL_OR_VENDOR_POWER_PASS",
            "cases":outputs}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--selftest',action='store_true')
    p.add_argument('--trace');p.add_argument('--metadata');p.add_argument('--output')
    args=p.parse_args()
    if args.selftest:
        result=selftest()
    elif args.trace and args.metadata:
        result=check_trace(Path(args.trace).read_text(encoding='utf-8-sig'),
                           json.loads(Path(args.metadata).read_text(encoding='utf-8-sig')))
    else:
        p.error('Use --selftest or both --trace and --metadata')
    output=json.dumps(result,ensure_ascii=False,indent=2,allow_nan=False)+'\n'
    if args.output: Path(args.output).write_text(output,encoding='utf-8')
    else:print(output)

if __name__=='__main__': main()
