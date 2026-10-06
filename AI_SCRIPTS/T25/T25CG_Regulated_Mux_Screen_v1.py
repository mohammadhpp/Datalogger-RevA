#!/usr/bin/env python3
"""Capacitor energy only; draft post-regulator mux; NOT a converter/mux simulation."""
import csv,json,math
from pathlib import Path

def main():
    root=Path(__file__).resolve().parents[2];out=root/'AI_EVIDENCE/T25CG';out.mkdir(parents=True,exist_ok=True)
    vstart=3.3*.95 # Proposed scenario, not a qualified regulator minimum.
    floor=2.7 # Rail-level working-voltage reference; downstream SD switch excluded.
    rows=[]
    for load in (.019,.280):
        power=3.3*load
        for gap_us in (6.2,50.,100.):
            for c_uF in (10.4,22.,47.):
                t=gap_us*1e-6;c=c_uF*1e-6;rad=vstart*vstart-2*power*t/c
                vend=math.sqrt(rad) if rad>=0 else None
                rows.append(dict(load_3V3_A=load,power_W=power,gap_us=gap_us,
                    gap_source='TI_TYP_AT_3p3V_RL10ohm_CL10uF_NOT_MAX' if gap_us==6.2 else 'DECLARED_SENSITIVITY_NOT_GUARANTEE',
                    Cbus_eff_uF=c_uF,Vstart_scenario_V=vstart,Vend_energy_V=vend,
                    Cbus_req_to_2p7V_uF=2*power*t/(vstart*vstart-floor*floor)*1e6))
    with (out/'regulated_mux_cap_energy.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=rows[0]);w.writeheader();w.writerows(rows)
    data={'status':'EXECUTED_CAPACITOR_ENERGY_SCREEN_NO_CONVERTER_OR_MUX_SIMULATION',
          'load_provenance':{'19mA':'old prototype observation, bandwidth unknown','280mA':'historical design envelope; not measured peak'},
          'Vstart_scenario_V':vstart,'backup_condition_margin_to_2p5V_V':vstart-2.5,
          'old_USB_candidate_static_max_V':3.712055,'direct_MCU_feed_3p6V_excess_V':3.712055-3.6,
          'notes':['3.135V is illustrative -5% rail, not verified TPS631000 or USB minimum.',
                   'Cbus is a new downstream mux capacitor requirement, not existing upstream C_OUT.',
                   'No ESR/wiring/RCB/control/source recovery/SD switch drop included.',
                   '6.2us is TI typical under stated load/cap conditions, not max or qualified system gap.',
                   'All scenarios exclude real card/module characterization and actual source current ceiling.'],
          'cases':rows}
    (out/'regulated_mux_screen.json').write_text(json.dumps(data,indent=2)+'\n')
    print(json.dumps({'cases':len(rows),'backup_margin_scenario_V':data['backup_condition_margin_to_2p5V_V'],
        'Cbus_req_280mA_6p2us_uF':rows[9]['Cbus_req_to_2p7V_uF'],
        'Cbus_req_280mA_100us_uF':rows[15]['Cbus_req_to_2p7V_uF'],
        'scope':data['status']},indent=2))
if __name__=='__main__':main()
