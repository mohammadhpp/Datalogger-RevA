exec((__import__('pathlib').Path(__file__).with_name('T25CI_Run_Control_Fixtures_v1.py')).read_text().split('for amps in')[0])
CASES=EV/'monitor_draft';CASES.mkdir(exist_ok=True);(CASES/'.spiceinit').write_text(INIT)
stimuli={
 'slow_attach_remove':'PWL(0 0 100u 0 2100u 3.3 3100u 3.3 5100u 0 6100u 0)',
 'hard_unplug':'PWL(0 3.3 500u 3.3 500.01u 0 1000u 0)',
 'attach_priority':'PWL(0 0 100u 0 100.01u 3.3 1000u 3.3)',
 'brownout_recovery':'PWL(0 3.3 100u 3.3 1100u 2.75 1500u 2.75 2500u 3.3 3000u 3.3)',
 'usb_absent':'DC 0',
 'usb_only_static':'DC 3.3',
}
for name,stim in stimuli.items():
 stop='6100u' if name=='slow_attach_remove' else '3000u' if name=='brownout_recovery' else '1000u'
 run(name,f'''Unselected precise USB monitor draft: nominal vendor control fixture
* Ideal MON3.3V; no power-OR/regulator/mux/board qualification.
.include "{REF}"
.include "{CMP}"
VMON MON 0 3.3
VUSB USB 0 {stim}
RREF USB REF 1k
XREF 0 REF REF TLV431
RT USB SENSE 13.7k
RB SENSE 0 10k
RH SENSE OUT 200k
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
(EV/'monitor_draft_manifest.json').write_text(json.dumps({'scope':'unselected control fixture with ideal MON; vendor typical-only; REF_USB1k and OUT-to-PR5.1k are new electrical proposal, not fixes hidden in original fixture','results':results},indent=2)+'\n')
