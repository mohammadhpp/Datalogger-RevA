#!/usr/bin/env python3
"""T25CW source-current-conserving *conditional* handoff analysis.

No silicon model of TPS2116, TPS631000 or actual MCU/SD. All timing,
forward-current limits, regulator readiness and effective capacitance are
illustrative scenario parameters. Standard-library Python 3.
"""
import csv, json, math
from pathlib import Path
ROOT=Path(__file__).resolve().parent
VPACK=1.80
PLOAD=3.3*0.280
IBUS=0.280
VMUX_IN=3.3  # hypothetical stabilized source from either regulated rail
RON=0.040    # TI mux typical, not guaranteed worst case
VBUS_INITIAL=VMUX_IN-IBUS*RON  # hypothetical 3.3V upstream at 280mA
FLOORS=(2.7, 2.8)  # SD standard supply floor, OLED conditional panel minimum

def battery_dc(eta, r):
    disc=VPACK**2-4*r*PLOAD/eta
    if disc < 0:
        return {'eta_assumed':eta,'r_post_pack_ohm_assumed':r, 'power_balance_root':'absent'}
    pin=(VPACK+math.sqrt(disc))/2
    ii=PLOAD/(eta*pin)
    assert abs(pin+r*ii-VPACK)<1e-12
    assert abs(eta*pin*ii-PLOAD)<1e-12
    return dict(eta_assumed=eta,r_post_pack_ohm_assumed=r,
                vpin_V=pin,iin_A=ii,
                startup_pin_above_1p65=pin>1.65,
                running_pin_at_least_1p60=pin>=1.60,
                classification='DC_ONLY_NO_FULL_LOAD_OR_STARTUP_GUARANTEE')

def analytic_cap(gap_us, floor):
    if VBUS_INITIAL<=floor:
        return math.inf
    return IBUS*gap_us/(VBUS_INITIAL-floor) # A*us / V = uF

def steady_gap_limit(cap_uf, floor):
    return cap_uf*(VBUS_INITIAL-floor)/IBUS # uF*V/A=us

def simulate(cap_uf, gap_us, ramp_us, sample_step_us=.05, end_us=180):
    # Incoming source ideal 3.3V (not proven from battery converter), RON=typ.
    # Current capped at hypothetical 560mA, with optional ideal linear availability ramp.
    cap=cap_uf*1e-6
    dt=sample_step_us*1e-6
    steps=int(round(end_us/sample_step_us))
    v=VBUS_INITIAL
    source_charge=0.0
    load_charge=0.0
    rows=[]
    min_v=v
    min_t=0.0
    for k in range(steps+1):
        t_us=k*sample_step_us
        if t_us<gap_us:
            src=0.0
        else:
            rel=t_us-gap_us
            limit=0.560*(min(1.0,rel/ramp_us) if ramp_us>0 else 1.0)
            src=min(limit,max(0.0,(VMUX_IN-v)/RON))
        if k<steps:
            # KCL: C dV/dt = Isource - Iload, no compensating shadow currents.
            vnext=v+dt*(src-IBUS)/cap
            source_charge += src*dt
            load_charge += IBUS*dt
            residual=cap*(vnext-v)-dt*(src-IBUS)
            assert abs(residual)<1e-17
            if vnext<min_v:
                min_v=vnext;min_t=t_us+sample_step_us
        else:
            vnext=v
        if (k % 20)==0 or (k==steps):
            rows.append({'time_us':round(t_us,4),'vbus_V':round(v,9),'source_current_A':round(src,9),'load_A':IBUS})
        v=vnext
    charge_residual=cap*(v-VBUS_INITIAL) -(source_charge-load_charge)
    assert abs(charge_residual)<1e-12
    return (dict(cap_eff_uF_assumed=cap_uf,deadtime_us_assumed=gap_us,
                 source_current_ramp_us_assumed=ramp_us,source_current_cap_A_assumed=.560,
                 rail_start_after_typ_mux_Ron_V=VBUS_INITIAL,min_rail_V=min_v,time_min_us=min_t,
                 end_rail_V=v,source_charge_uC=source_charge*1e6,
                 load_charge_uC=load_charge*1e6,
                 integrated_KCL_residual_nC=charge_residual*1e9,
                 crosses_SD_2p7=min_v<2.7,
                 crosses_OLED_2p8_only_if_matching_panel=min_v<2.8,
                 result_status='MODEL_CONDITIONAL_ONLY'),rows)

def main():
    battery=[battery_dc(eta,r) for eta in (.70,.75,.80,.85,.90) for r in (.05,.10,.15,.20,.25)]
    hold=[{'deadtime_us':t,'floor_V_assumed':floor,
           'min_C_postmux_effective_uF':analytic_cap(t,floor)}
          for floor in FLOORS for t in (6.2,10,25,50,100)]
    traces=[]; selected=None
    for c in (10,22,47):
        for gap in (6.2,25,50):
            for ramp in (0,10,50):
                result,rows=simulate(c,gap,ramp)
                traces.append(result)
                if (c,gap,ramp)==(22,25,50):selected=rows
    with (ROOT/'T25CW_BAT_DC_CASES.csv').open('w',newline='',encoding='utf-8') as f:
        wr=csv.DictWriter(f,fieldnames=list(battery[0].keys()))
        # standardized keys for every row
        for row in battery:
            row.setdefault('power_balance_root','high_V_branch')
        wr=csv.DictWriter(f,fieldnames=list(battery[0].keys()))
        wr.writeheader();wr.writerows(battery)
    with (ROOT/'T25CW_CURRENT_LIMITED_HANDOFF.csv').open('w',newline='',encoding='utf-8') as f:
        wr=csv.DictWriter(f,fieldnames=list(traces[0].keys()));wr.writeheader();wr.writerows(traces)
    with (ROOT/'T25CW_SELECTED_TRACE.csv').open('w',newline='',encoding='utf-8') as f:
        wr=csv.DictWriter(f,fieldnames=list(selected[0].keys()));wr.writeheader();wr.writerows(selected)
    data={
       'classification':'ACTUAL_TEST_WITH_RAW_EVIDENCE / BOUNDED_CURRENT_CONSERVING_MODEL_NO_HARDWARE_PASS',
       'locked_requirements':{'loaded_AA_terminal_voltage_V':1.8,'output_design_A':.280,'output_V':3.3},
       'assumed_silicon_analogs':{'mux_Ron_typical_ohm':RON,'incoming_rail_hypothetical_V':VMUX_IN,
              'battery_pre_regulated_and_ready':True,'source_ability_max_scenario_A':.560,
              'actual_mux_deadtime':'unknown','actual_TPS631000_transient_current':'unknown',
              'NRST_voltage':'not simulated','SD_write_integrity':'not simulated'},
       'battery_dc_screens':battery,'postmux_cap_floor_budgets':hold,
       'postmux_27_dynamic_current_screens':traces,
       'nonclaims':['6.2us is TI typical tSW only with CL=10uF RL=10ohm at VIN3.3V; it is NOT actual 280mA T25 source-transfer deadtime bound.',
                    '2.8V OLED floor applies only if actual carrier matches source bare panel; it is not established.',
                    'SD at 2.7..3.6V still cannot guarantee data integrity/write completion.',
                    'MCU STM32G070KBT6 PDR falling upper value 2.04V does not alone prove zero NRST/watchdog reset.',
                    'Typical Ron 40mOhm not worst-case, efficiency 70..90% not guaranteed, actual Ceff / battery R unknown.',
                    'Battery converter must be awake/3.3V pre-regulated before switching; source capped/ramped dynamically only as a declared scenario.',
                    'No physical board or manufacturer TPS2116/current-corrected vendor macro integrated test was run.']}
    (ROOT/'T25CW_RESULT.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('battery scenarios:',len(battery),'cap-floor:',len(hold),'dynamic:',len(traces))
    for c in (10,22,47):
        print('Cap_eff',c,'uF: t_to_SD_floor',round(steady_gap_limit(c,2.7),5),'us; OLED_screen',round(steady_gap_limit(c,2.8),5),'us')
    q=[x for x in traces if x['cap_eff_uF_assumed']==22 and x['deadtime_us_assumed']==25 and x['source_current_ramp_us_assumed']==50][0]
    print('Sample conditional waveform:',json.dumps(q))
    print('Per-step KCL and each DC root balance asserted; NOT a board test.')

if __name__=='__main__':main()
