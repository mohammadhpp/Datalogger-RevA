from pathlib import Path
import subprocess, os, json, time, hashlib, shutil
ROOT=Path(__file__).resolve().parents[2]
EV=ROOT/'AI_EVIDENCE/T25CI'
V=EV/'vendor'
RT=ROOT.parent/'runtime/spice'
BIN=Path(os.environ.get('NGSPICE_BIN') or (str(RT/'usr/bin/ngspice') if (RT/'usr/bin/ngspice').exists() else shutil.which('ngspice') or 'ngspice'))
CASES=EV/'isolated'
CASES.mkdir(exist_ok=True)
CMODELS=Path(os.environ.get('NGSPICE_CMODEL_DIR',str(RT/'usr/lib/x86_64-linux-gnu/ngspice')))
INIT='set ngbehavior=ps\n'+''.join('codemodel '+str(p)+'\n' for p in sorted(CMODELS.glob('*.cm')))
(CASES/'.spiceinit').write_text(INIT)
env=os.environ.copy();env['LD_LIBRARY_PATH']=str(RT/'usr/lib/x86_64-linux-gnu')
REF=V/'tlv431_pspice/TLV431_PSPICE/tlv431.lib'
CMP=V/'tlv170_pspice/tlv1701.lib'
results=[]
def run(name,deck,timeout=15):
    p=CASES/(name+'.cir');p.write_text(deck)
    start=time.monotonic()
    try:
        proc=subprocess.run([str(BIN),'-b','-o',name+'.out',p.name],cwd=CASES,env=env,capture_output=True,timeout=timeout)
        status='ENGINE_RETURNED';code=proc.returncode
        out=proc.stdout;err=proc.stderr
    except subprocess.TimeoutExpired as e:
        status='WALL_TIMEOUT';code=None;out=e.stdout or b'';err=e.stderr or b''
    (CASES/(name+'.stdout')).write_bytes(out);(CASES/(name+'.stderr')).write_bytes(err)
    log=(CASES/(name+'.out')).read_text(errors='replace') if (CASES/(name+'.out')).exists() else ''
    csv=CASES/(name+'.csv')
    rows=csv.read_text().splitlines() if csv.exists() else []
    rec={'case':name,'status':status,'returncode':code,'wall_seconds':time.monotonic()-start,'error_markers':[s for s in log.splitlines() if any(w in s.lower() for w in ['error','too small','aborted'])],'rows':max(0,len(rows)-1),'last_row':rows[-1] if len(rows)>1 else None,'deck_sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
    results.append(rec);print(json.dumps(rec),flush=True)
for amps in [0.0001,0.0002,0.001,0.01]:
    name='reference_'+str(int(amps*1e6))+'uA'
    run(name,f'''TLV431 isolated constant-current DC nominal test {amps}A
.include "{REF}"
IREF 0 REF {amps}
XREF 0 REF REF TLV431
.control
set wr_singlescale
set wr_vecnames
op
wrdata {name}.csv v(ref)
quit
.endc
.end
''')
run('comparator_pulse',f'''TLV1701 isolated 100mV-overdrive pulse nominal tool test
.include "{CMP}"
VMON MON 0 3.3
VREF REF 0 1.24
VIN SENSE 0 PWL(0 1.14 10u 1.14 10.01u 1.34 20u 1.34 20.01u 1.14 30u 1.14)
RPU MON OUT 5.1k
COUT OUT 0 15p
XCMP SENSE REF MON 0 OUT TLV1701
.control
set wr_singlescale
set wr_vecnames
tran 10n 30u 0 10n
wrdata comparator_pulse.csv v(sense) v(ref) v(out)
quit
.endc
.end
''')
(EV/'isolated_manifest.json').write_text(json.dumps({'engine':'ngspice42 locally extracted Ubuntu package; PSpice compatibility enabled; vendor models unmodified','scope':'isolated nominal fixture runtime only, no regulator/mux/hardware qualification','models':{str(p.relative_to(EV)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [REF,CMP]},'results':results},indent=2)+'\n')
