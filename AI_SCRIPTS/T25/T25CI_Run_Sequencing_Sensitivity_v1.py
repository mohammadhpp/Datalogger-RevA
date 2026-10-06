exec((__import__('pathlib').Path(__file__).with_name('T25CI_Run_Control_Fixtures_v1.py')).read_text().split('for amps in')[0])
CASES=EV/'sequence';CASES.mkdir(exist_ok=True);(CASES/'.spiceinit').write_text(INIT)
REF=V/'lm4040_nd25/LM4040_ND2P5_PSPICE_TRANS/LM4040_ND2P5_TRANS.lib'
fixtures=[
 ('usb_only_slow',0,'PWL(0 0 100u 0 2100u 3.185094 3100u 3.185094 5100u 0 6100u 0)','6100u'),
 ('usb_only_hard',0,'PWL(0 0 100u 0 100.01u 3.185094 1000u 3.185094)','1000u'),
 ('battery_ready_attach',3.214242,'PWL(0 0 100u 0 100.01u 3.185094 1000u 3.185094)','1000u'),
 ('battery_ready_unplug',3.214242,'PWL(0 3.185094 500u 3.185094 500.01u 0 1000u 0)','1000u'),
 ('slow_brownout_plateau',3.214242,'PWL(0 3.185094 100u 3.185094 1100u 2.65 2100u 2.65 3100u 3.185094 4100u 3.185094)','4100u'),
]
for name,batt,stim,stop in fixtures:
 run(name,f'''Conditional MON sequencing sensitivity; official unmodified control models
* MON OR is zero-impedance behavioural max with FIXED0.41Vdrop at25C.
* It is NOT Infineon diode SPICE, converter, mux or actual startup proof.
.include "{REF}"
.include "{CMP}"
VUSB USB 0 {stim}
VBAT BAT_REG 0 {batt}
BMON MON 0 V=max(max(v(USB)-0.41,v(BAT_REG)-0.41),0)
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
(EV/'sequence_manifest.json').write_text(json.dumps({'scope':'ACTUAL_TEST_WITH_RAW_EVIDENCE, bounded behavioural monitor supply plus official nominal IC models only. No actual source-OR/regulator/mux/hardware PASS.','results':results},indent=2)+'\n')
