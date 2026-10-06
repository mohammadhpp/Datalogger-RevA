from pathlib import Path
import itertools,json,csv
import numpy as np
ROOT=Path(__file__).resolve().parents[2];EV=ROOT/'AI_EVIDENCE/T25CI';EV.mkdir(exist_ok=True)
nom=(2000,10000,100000,10000,5100,10000)
tols=(.01,.005,.01,.005,.01,.005)
def corner(rs,x,ib,io,ip,vol):
 rt,rb,rh,pu,series,pd=rs;a,b,h=1/rt,1/rb,1/rh;g=1/pu+1/(series+pd)+h;alpha=pd/(series+pd)
 fall=(x*(a+b+h-h*h/g)+ib+h*(io+ip*alpha)/g)/(a+h/(pu*g))
 rise=x*(1+rt/rb+rt/rh)-vol*rt/rh+ib*rt
 mat=np.array([[a+b+h,-h,0],[-h,1/pu+h+1/series,-1/series],[0,-1/series,1/series+1/pd]])
 node=np.linalg.solve(mat,np.array([3.185094*a-ib,3.185094/pu-io,-ip]))
 low=vol*alpha-ip*series*pd/(series+pd)
 return dict(fall_V=fall,rise_V=rise,hysteresis_same_corner_V=rise-fall,healthy_PR1_V=float(node[2]),low_PR1_V=low,healthy_sense_V=float(node[0]))
rows=[]
# First table verified initial resistor tolerances only. Second is an explicit
# +/-100ppm/C all-resistor TCR sensitivity; not verified exact part TCR.
# LM4040-N D,I full-temp +/-49mV plus1.2mV current change within70uA..1mA.
for thermal_scenario in [False,True]:
 extra=.0065 if thermal_scenario else 0
 for signs in itertools.product((-1,1),repeat=6):
  rs=[r*(1+s*(t+extra)) for r,s,t in zip(nom,signs,tols)]
  for ref,vos,ib,io,ip,vol in itertools.product((2.4498,2.5502),(-.0055,.0055),(-20e-9,20e-9),(70e-9,10e-6),(-.1e-6,.1e-6),(0,.9)):
   rec=corner(rs,ref+vos,ib,io,ip,vol)
   rows.append(dict(thermal_scenario=thermal_scenario,resistor_signs=''.join('+' if s>0 else '-' for s in signs),REF_V=ref,VOS_V=vos,IB_A=ib,comparator_off_leak_scenario_A=io,PR_pin_leak_A=ip,VOL_scenario_V=vol,**rec))
with (EV/'lm4040_monitor_corners.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=rows[0]);w.writeheader();w.writerows(rows)
summary={}
for thermal in [False,True]:
 subset=[r for r in rows if r['thermal_scenario']==thermal]
 summary[str(thermal)]={k:{'min':min(r[k] for r in subset),'max':max(r[k] for r in subset)} for k in ['fall_V','rise_V','hysteresis_same_corner_V','healthy_PR1_V','low_PR1_V']}
 summary[str(thermal)]['attach_static_margin_V']=3.185094-summary[str(thermal)]['rise_V']['max']
 summary[str(thermal)]['low_logic_margin_V']=.92-summary[str(thermal)]['low_PR1_V']['max']
result={'status':'ACTUAL_TEST_WITH_RAW_EVIDENCE','scope':'conditional KCL corner screen; NO_BOARD_PASS','count':len(rows),'nominal':corner(nom,2.5,0,70e-9,0,.045),'summary':summary,'bias':{'RREF_2p4k_1pct':True,'at_USB_min_Iref_A':(3.185094-2.5502)/2424,'at_USB_max_Iref_A':(3.432960-2.4498)/2376,'at_fall_min_Iref_A':(summary['True']['fall_V']['min']-2.5502)/2424},'limitations':['USB3.185094 bound excludes regulator ripple/load transient/FB leakage and resistor TCR.','Output70nA is typical, no comparator leakage guaranteed maximum.10uA is declared sensitivity.','VOL0..0.9V is sensitivity based on specified900mVmax only at25C/36Vsupply/100mVoverdrive; no full-temp low-state guarantee at3V.','All-resistor100ppm/C sensitivity is not exact-MPN TCR qualification.','Full-temp reference limits assume70uA..1mA, pulse load regulation; thermal self-heating/aging not qualified.','No delay maximum, input-power sequencing, diode leakage, converters, mux or source currents qualified.']}
(EV/'lm4040_monitor_corners.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
