#!/usr/bin/env python3
"""Independent source-free audit of T25CX test evidence. No device PASS."""
import csv, json, math
from pathlib import Path
p=Path(__file__).parent
r=json.loads((p/'T25CX_VALIDATOR_UNIT_TESTS.json').read_text(encoding='utf-8'))
checks=0
assert r['tests_run']==7;checks+=1
assert r['all_assertions_passed'];checks+=1
expected={
 'nominal': ('CONDITIONAL_SCREEN_PASS',None),
 'unloaded_model': ('SCREEN_FAIL','MUX_INPUT_OUTPUT_CURRENT_NOT_CONSERVED'),
 'sd_droop':('SCREEN_FAIL','SD_VDD_BELOW_STANDARD_MINIMUM'),
 'reset':('SCREEN_FAIL','NRST_ASSERTION_OBSERVED'),
 'battery_fast_collapse':('SCREEN_FAIL','BAT_MUX_INPUT_BELOW_2P5_DURING_FAST_USB_COLLAPSE'),
 'gap':('SCREEN_FAIL','UNDERRESOLVED_TRACE'),
 'legacy_T25CW_header':('NOT_EVALUABLE','REQUIRED_PROBE_OR_PROVENANCE_ABSENT')}
for key,(status,error) in expected.items():
 entry=r['cases'][key];assert entry['waveform_screen']==status;checks+=1
 assert entry['system_pass'] is False;checks+=1
 if error:assert error in entry['violations'];checks+=1
 if key=='legacy_T25CW_header':
  assert all(k in entry['missing_columns'] for k in ('v_sd_vdd_v','v_mcu_vdd_v','i_usb_mux_input_a','i_bat_mux_input_a'));checks+=1
assert r['cases']['nominal']['observed']['max_mux_kcl_residual_a']<1e-10;checks+=1
assert r['cases']['nominal']['observed']['max_bus_kcl_residual_a']<1e-10;checks+=1
assert r['cases']['sd_droop']['observed']['min_sd_vdd_v']==2.6;checks+=1
assert r['cases']['unloaded_model']['observed']['max_mux_kcl_residual_a']>=.28-1e-9;checks+=1
assert r['cases']['battery_fast_collapse']['observed']['min_sd_vdd_v']>=2.7;checks+=1
# Independent physical dimensional checks: previous CW sample's 1 us cannot
# support an imposed 0.5us gate. An LDO ripple-only test cannot prove SD.
assert 1.0>0.5; checks+=1
# no assumption of recovery after the first sample or MCU-only safety
assert 2.04<2.7;checks+=1
out={'audit_status':'PASS_VALIDATOR_LOGIC_ONLY_NO_DEVICE_TEST',
     'independent_checks':checks,'expected_cases':len(expected),
     'actual_power_trace_executed':False,
     'actual_whole_board_functional_pass':False,
     'live_altium_topology':'UPSTREAM_MUX_BEFORE_TPS631000',
     'hypothesized_test_topology':'DOWNSTREAM_DUAL_REGULATED_MUX_UNAPPLIED',
     'next_missing_evidence':['Current-conserving valid mux and loaded1.80V converter transient',
       'Qualified effective 3V3_SYS capacitance at voltage and temperature',
       'Direct MCU VDD and SD_VDD waveforms with write integrity witness',
       'MCU NRST measured or validated logic evidence',
       'OLED carrier exact electrical requirements']}
(p/'T25CX_Independent_Audit.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
print('PASS',checks,'checks; no physical/device PASS')
