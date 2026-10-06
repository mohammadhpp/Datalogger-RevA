exec((__import__('pathlib').Path(__file__).with_name('T25CI_Run_Control_Fixtures_v1.py')).read_text().split('for amps in')[0])
CASES=EV/'lm4040_monitor';CASES.mkdir(exist_ok=True);(CASES/'.spiceinit').write_text(INIT)
REF=V/'lm4040_nd25/LM4040_ND2P5_PSPICE_TRANS/LM4040_ND2P5_TRANS.lib'
for tol in [-1,0,1]:
 for amps in [.0001,.0003,.001]:
  name=f'reference_tol{tol}_{int(amps*1e6)}uA'
  run(name,f'''LM4040-N D2P5 official model isolated DC
.include "{REF}"
IREF 0 REF {amps}
XREF REF 0 LM4040_ND2P5 PARAMS: TOL={tol}
.control
set wr_singlescale
set wr_vecnames
op
wrdata {name}.csv v(ref)
quit
.endc
.end
''')
text=Path(__file__).with_name('T25CI_Run_Monitor_Draft_v1.py').read_text();stimuli=eval(text.split('stimuli=')[1].split('\nfor name')[0])
for name,stim in stimuli.items():
 stop='6100u' if name=='slow_attach_remove' else '3000u' if name=='brownout_recovery' else '1000u'
 run(name,f'''Unselected LM4040-N D2.5 / TLV1701 nominal USB monitor fixture
* MON is ideal3.3V. No diode-OR or actual regulator/mux/system in fixture.
.include "{REF}"
.include "{CMP}"
VMON MON 0 3.3
VUSB USB 0 {stim}
RREF USB REF 2.4k
XREF REF 0 LM4040_ND2P5 PARAMS: TOL=0
RT USB SENSE 2k
RB SENSE 0 10k
RH SENSE OUT 100k
RPU USB OUT 10k
RS OUT PR1 5.1k
RPD PR1 0 10k
CPR PR1 0 15p
XCMP SENSE REF MON 0 OUT TLV1701
.options reltol=1e-4 abstol=1n vntol=1u
.control
set wr_singlescale
set wr_vecnames
tran 100n {stop} 0 100n
wrdata {name}.csv v(usb) v(mon) v(ref) v(sense) v(out) v(pr1) i(vusb)
quit
.endc
.end
''',timeout=25)
(EV/'lm4040_monitor_manifest.json').write_text(json.dumps({'scope':'ACTUAL_TEST_WITH_RAW_EVIDENCE; isolated official-model nominal controls only. Ideal MON and no converter/mux. No hardware PASS. TOL +/-1 are model-supported extremes, not exhaustive part qualification.','models':{str(p.relative_to(EV)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [REF,CMP]},'results':results},indent=2)+'\n')
