#!/usr/bin/env python3
"""T25CS synthetic ON-path RC sensitivity, NOT a vendor-model OVP simulation.

No model of TS431, BC857, FSS2301S gate, zener, source backfeed, LDO,
external load or actual installed bias-reduced capacitance is implied.
Stdlib only. Designed to highlight *required cutoff delay* versus a 6V
absolute limit for an assumed 5.5V->12V USB fault source with finite slew.
"""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path

V_INITIAL = 5.5
V_FAULT = 12.0
V_ABS_LIMIT = 6.0
V_HIST_TRIP = 5.9157205069  # historical workbook MAX rise-trip, NOT physical clamp
R_OHMS = [0.05, 0.128, 0.5, 2.0]  # 0.128 is listing @ Vgs -2.5V, NOT min/on-state across fault
C_EFF_UF = [0.5, 1.0, 4.7, 10.0, 22.0, 44.0]  # scenario Ceff, NOT measured installed capacitors
RISE_US = [1, 10, 100]
AFTER_TRIP_US = [0.05, 0.1, 0.25, 0.5, 1, 2, 5]


def ramp(t_s, rise_s):
    return V_INITIAL + (V_FAULT - V_INITIAL) * min(max(t_s / rise_s, 0.0), 1.0)


def vcap(t_s, rise_s, resistance, ceff):
    """Exact solution: dVout/dt=(Vin(t)-Vout)/(R*C), initial Vout=5.5.

    Off switch assumed perfect at t_cut, all C at protected output,
    no load/leakage/inductance or source impedance beyond R.
    """
    tau = resistance * ceff
    slope = (V_FAULT - V_INITIAL) / rise_s
    t1 = min(t_s, rise_s)
    v1 = V_INITIAL + slope * (t1 - tau * (-math.expm1(-t1 / tau)))
    if t_s <= rise_s:
        return v1
    return V_FAULT + (v1 - V_FAULT) * math.exp(-(t_s - rise_s) / tau)


def crossing_time(rise_s, resistance, ceff, vlim=V_ABS_LIMIT):
    """Root by bisection: monotonic RC response; absolute time since ramp starts."""
    lo, hi = 0.0, rise_s + 100.0 * resistance * ceff
    assert vcap(lo, rise_s, resistance, ceff) < vlim < vcap(hi, rise_s, resistance, ceff)
    for _ in range(75):
        mid = (lo + hi) / 2
        if vcap(mid, rise_s, resistance, ceff) >= vlim:
            hi = mid
        else:
            lo = mid
    return (lo + hi) / 2


def rk4_crosscheck(tstop, rise, r, c, steps=20000):
    """Independent time-integration of ON-path ODE (numeric validation only)."""
    dt = tstop / steps
    v = V_INITIAL
    tau = r * c
    def derivative(t, y):
        return (ramp(t, rise) - y) / tau
    for i in range(steps):
        t = i * dt
        k1 = derivative(t, v)
        k2 = derivative(t + dt/2, v + dt*k1/2)
        k3 = derivative(t + dt/2, v + dt*k2/2)
        k4 = derivative(t + dt, v + dt*k3)
        v += (dt/6)*(k1 + 2*k2 + 2*k3 + k4)
    return v


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output-dir', default='.', type=Path)
    a = parser.parse_args()
    out = a.output_dir
    out.mkdir(parents=True, exist_ok=True)
    rows = []
    thresholds = []
    for rise_us in RISE_US:
        rise = rise_us * 1e-6
        t_trip = (V_HIST_TRIP - V_INITIAL)/(V_FAULT-V_INITIAL)*rise
        for r in R_OHMS:
            for c_uf in C_EFF_UF:
                ceff = c_uf*1e-6
                crossing = crossing_time(rise, r, ceff)
                t_available = crossing - t_trip
                assert t_available > 0
                thresholds.append({'rise_us_scenario':rise_us,'R_total_ohm_scenario':r,
                                   'Ceff_uF_scenario':c_uf,
                                   'historical_trip_cross_us':round(t_trip*1e6,9),
                                   'total_time_to_6V_us':round(crossing*1e6,9),
                                   'latest_cutoff_after_trip_us_for_6V_scenario':round(t_available*1e6,9)})
                for d_us in AFTER_TRIP_US:
                    t_cut = t_trip + d_us * 1e-6
                    peak = vcap(t_cut, rise, r, ceff)
                    rows.append({'rise_us_scenario':rise_us, 'R_total_ohm_scenario':r,
                                 'Ceff_uF_scenario':c_uf,'cut_delay_after_historic_trip_us_scenario':d_us,
                                 'peak_USB_VBUS_PROT_V_at_ideal_cutoff':round(peak,9),
                                 'under_6V_within_synthetic_fixture':peak < V_ABS_LIMIT})
    # Analytic-vs-RK4 independent check across both sides of the linear-to-plateau join.
    cross = []
    for rise_us, r, c_uf, d_us in [(1,.128,22,.1),(1,.128,22,1),(1,.05,.5,1),(10,.5,4.7,2),(100,2,44,5)]:
        rise = rise_us*1e-6
        t_cross = (V_HIST_TRIP-V_INITIAL)/(V_FAULT-V_INITIAL)*rise
        t = t_cross + d_us*1e-6
        exact = vcap(t,rise,r,c_uf*1e-6)
        numeric = rk4_crosscheck(t,rise,r,c_uf*1e-6)
        error = abs(exact-numeric)
        assert error < 0.00002, (rise_us,r,c_uf,d_us,error)
        cross.append({'rise_us':rise_us,'R_ohm':r,'Ceff_uF':c_uf,'delay_us':d_us,
                      'analytic_V':round(exact,9),'RK4_V':round(numeric,9),'abs_difference_V':round(error,12)})
    # Critical cheap regression gates.
    assert len(rows)==len(RISE_US)*len(R_OHMS)*len(C_EFF_UF)*len(AFTER_TRIP_US)==504
    assert len(thresholds)==72
    assert abs(vcap(0,1e-6,.128,22e-6)-5.5) < 1e-12
    assert 0 < crossing_time(1e-6,.128,22e-6) < 1e-6
    assert abs(vcap(1e-6,1e-6,.128,22e-6) - 6.0) > 1e-2
    filename=out/'T25CS_SENSITIVITY_MATRIX.csv'
    with filename.open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    threshpath=out/'T25CS_CUTOFF_BUDGET.csv'
    with threshpath.open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=list(thresholds[0]));writer.writeheader();writer.writerows(thresholds)
    raw_data={'classification':'ACTUAL_TEST_WITH_RAW_EVIDENCE / BOUNDED_BEHAVIORAL_SIMULATION_NO_HARDWARE_PASS',
         'as_of':'2026-10-09',
         'source':'Synthetic source voltage 5.5->12V; known FSS2301S nominal Rds(on)128mOhm@-2.5V from FOSAN/LCSC listing; historical workbook trip5.9157205069V; 6V TPS2116 absolute stress limit.',
         'assumptions':{'source_start_V':V_INITIAL,'fault_peak_V':V_FAULT,
                        'historical_trip_V_NOT_physical_clamp':V_HIST_TRIP,
                        'stress_limit_V_NOT_recommended_operating':V_ABS_LIMIT,
                        'R_total_ohm':R_OHMS,'Ceff_uF':C_EFF_UF,'source_rise_us':RISE_US,
                        'delay_us_after_historical_trip':AFTER_TRIP_US,
                        'no_load':True,'no_L_or_stray_injection':True,'switch': 'fixed R until ideal abrupt OFF',
                        'DC_bias_and_temperature_in_Ceff':'not known'},
         'equations': ['tau=R*C', 't<=T: Vcap=V0 + a*(t-tau*(1-exp(-t/tau)))',
                       't>T: Vcap=Vmax+(Vcap(T)-Vmax)*exp(-(t-T)/tau)',
                       'a=(12-5.5)/T', 't_trip=(5.9157205069-5.5)/a',
                       'solve Vcap(t)=6 for cutoff budget'],
         'cases':len(rows),'budget_cases':len(thresholds),'crosschecks':cross,
         'status_assertions':['504 scenarios computed','72 time-budget roots converged','5 independent RK4 checks <20uV',
                              'no vendor device model is present','no synthesis of actual FET turnoff or regulated OVP'],
         'result_files':[filename.name,threshpath.name],
         'limitation':'No actual TS431, PNP, gate, Zener, capacitance-vs-bias, source R/current, LDO, mux, BAT, NRST or SD. Numerical PASS in the synthetic RC fixture NEVER qualifies hardware.'}
    with (out/'T25CS_EXECUTION_SUMMARY.json').open('w',encoding='utf-8') as f:
        json.dump(raw_data,f,ensure_ascii=False,indent=2);f.write('\n')
    h={}
    for p in [filename,threshpath,out/'T25CS_EXECUTION_SUMMARY.json']:
        h[p.name]=hashlib.sha256(p.read_bytes()).hexdigest()
    (out/'T25CS_SHA256_MANIFEST.json').write_text(json.dumps(h,indent=2)+'\n',encoding='utf-8')
    print('RESULT:',len(rows),'scenario rows,',len(thresholds),'cutoff budgets,',len(cross),'crosschecked ODE trajectories')
    for x in thresholds:
        if x['rise_us_scenario']==1 and x['R_total_ohm_scenario']==.128 and x['Ceff_uF_scenario'] in (1,10,22,44):
            print('selected 1us 0.128ohm Ceff',x['Ceff_uF_scenario'],'max delay after historical trip:',x['latest_cutoff_after_trip_us_for_6V_scenario'])
    for x in rows:
        if x['rise_us_scenario']==1 and x['R_total_ohm_scenario']==.128 and x['Ceff_uF_scenario']==22 and x['cut_delay_after_historic_trip_us_scenario'] in (.1,.5,1):
            print('selected Ceff22uF cut delay',x['cut_delay_after_historic_trip_us_scenario'],'peak:',x['peak_USB_VBUS_PROT_V_at_ideal_cutoff'])
    print('FILES:')
    for k,v in h.items(): print(k,v)

if __name__=='__main__': main()
