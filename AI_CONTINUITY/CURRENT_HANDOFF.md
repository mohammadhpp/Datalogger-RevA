# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CI precise monitor model execution and Iran draft, 2026-10-06 UTC

- Read `AI_CONTINUITY/T25CI_PRECISE_MONITOR_EXECUTION_AND_IRAN_DRAFT_FA.md`. Locally executed ngspice42 with unmodified official TLV1701, TLV431 and LM4040-N models; decks/logs/full raw data retained. No Windows rerun is requested; no integrated/board PASS.
- TLV431 low-bias reference prestate was invalid:100/200uA produced1.058467/1.138759V;1/10mA reached~1.24V. SLIM005 PSpice electrical core equals oldTINA; encryption removal is not a new model. Original transient aborted; boundedGear40s timeout actualsimulatedprogressUNKNOWN. Do not repeat this reference/profile loop.
- New unselected precise monitor: TLV1701AIDBVR plus LM4040DIM3X-2.5 (correct LM4040-N family/SNOM542D2.5), reference bias2.4k fromUSB_REG, Rt2k/Rb10k/Rh100k, pullup10kUSB, OUT->PR1series5.1k/pulldown10k. MON independently diodeORs regulated rails; never depend on muxVOUT for coldstart. Correct physical pins and source map in report.
- All6 nominal control fixtures atidealMON3.3V completed;9 referenceDC cases completed butTOL=-1 is~1.5mV below25Cgradefloor. VendorTOL isnot exhaustivecornerqualification. New sequencing sensitivity with behaviouralMONfixed0.41Vdrop:3/5initialcasescomplete;2hard-attachabortatinternalreference. C_REF100n closesonlyUSB-onlyhard-attach,notbattery-readyattach; notselected. Noactualdiode/regulator/muxwaveformorNRST/SD-writeevidence.
- Executed8192 conditionalKCLcorners. In declaredall-resistor100ppm/C sensitivity:fall2.931708..3.096395V,attach2.949472..3.134188V;USBattachmargin50.906mV,minsame-cornerhysteresis16.043mV;PRhighmin1.238795,PRlowmax0.601987. Leakage10uA/VOL0.9/TCR arequalified-as-scenarios,notfulltempdatasheetguarantees. Ripple/FB_TCR/sourcecollapse/open.
- Iran declaredstock:TLV1701AIDBVR64,LM4040DIM3X-2.5 889,BAS7004E6327HTSA1 424. Diodeisseriespair,use2packages forOR;VF/leakbounds25Conly. SellerLM4040 omitsNOPBsuffix; do notassumeit. Existingresistor/passivetypesneedextraquantities,notstealFB/CC/SD/OLEDparts. OtherintegratedmonitorsnotverifiedIraninthissearch; do notclaimunavailableeverywhere.
- Raw package preservation and exactSHA are indexed in `AI_EVIDENCE/T25CI/EVIDENCE_INDEX.json`. Noarchitectureselected;mainconverterencrypted/boundedprestate,USBbucktimeout,muxmodeldiscrepancy,actualCeff/source/loadand5V_AUXprotectionremainOPEN. SDsubgateclosed;TPS631000/L1 retained;S1exactdeferred.
- No CAD/ECO/purchase/DRC/fabricationchange. **FABRICATION HOLD.**

## Accepted design and validation baseline

- Live engineering source: private GitHub `mohammadhpp/Datalogger-RevA`, branch `main`, and the user's Windows repo `C:\#MHP FILES\DataLoger`. Historical ZIPs are rollback/evidence only. Read `AI_START_HERE.md` and its required source registry and continuation rules first.
- No RevA PCB has been fabricated. Existing final PCB-mounted parts were purchased; proposed new power parts are not an approved purchase. Canonical PCB `DATALOGER_RevA.PcbDoc`, library `Datalogger_RevA_Clean.PcbLib`.
- T23 routing CLOSED/PASS; T24 courtyards 129/129 persistent, last accepted Full Batch DRC 0 warnings / 0 violations at `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`. No fresh DRC or functional PASS is claimed.
- Locked requirements: two-layer PCB; schematic grid 100 mil; readable PCB RefDes/polarity/pin-1; correct connectors for off-board devices; loaded pack minimum 1.80V; no USB nuisance cutoff at 5.50V; uninterrupted USB-priority battery↔USB transfers, zero MCU reset and no intentional AA backfeed.
- **19 mA** is the old prototype observation with unknown bandwidth; **280 mA** is the historical RevA maximum design envelope, not a measured peak. Keep both provenance labels. SD 400mA is a historic switch-drop sizing point, not a measured card peak.
- Retain TPS631000 and Murata `DFE322512F-1R0M=P2` 1µH L1. TPS54202DDCR and its separate USB coil remain exploratory, unselected; do not silently substitute them.
- S1 three-pole maintained functional architecture is user-approved: BAT, USB, and common return ends of the two separate CC Rd resistors. Live CAD still shows four contacts; see T25BX/T25BY. Exact switch procurement is deferred by user.
- Every new replacement part needs exact-MPN technical and practical Iranian availability evidence. Close the whole power block, present one consolidated purchase/ECO proposal, then obtain that single concrete design decision before modifying Altium. No partial order or power ECO.

## Evidence already completed; do not repeat

- T25BD/T25BE: 12/12 valid user PSpice capacitor-only cases independently match T25AZ. Conditional source/capacitor scenarios do not qualify physical RevA.
- T25BF/T25BG and T25BT/T25BV official encrypted TPS631000 short/precharged/SS=1 fixtures completed jobs but failed the regulated 3.3V pre-state gate. Post-step outputs are rejected. No hardware failure inferred; do not request another identical Windows run.
- T25AE TPS2116 vendor-model behavior conflicts with independent TI evidence. Do not repeat the discrepant fixture or interpret its output as hardware transfer PASS/FAIL.
- T25BH conditional slew targets are sensitivity results, not actual AO3401A gate timing.
- **SD controlled-inrush sub-gate is already screened**: T25BK independently audited 16 TPS22918 official-model cases; T25BL gives the unapplied ECO and exact Iranian sourcing. Do not reopen SD selection.
- SD candidate: `TPS22918DBVT`, CT `C1608NP01H472J080AA` 4.7nF C0G 0603, input bypass `C2012X7R1H105K125AB` 1µF X7R 0805, existing 100k ON pulldown. Correct physical pads 1 VIN, 2 GND, 3 ON, 4 CT, 5 QOD, 6 VOUT. Exact T25BL sourcing supersedes earlier provisional Samsung parts. This is a sub-gate technical/procurement screen, not an applied ECO or complete power purchase list.
- Actual card/module transients, TPS631000 source/startup at loaded 1.80V, exact biased Ceff, OVP and weak-battery no-reset handoff remain OPEN. No integrated system or fabrication PASS.
- Historical T25AI Altium netlist preparation does not establish an Altium execution. Newer T25CD and the active execution rule govern continuation; do not restart old compatibility loops merely from chat memory.

## Cleanup and preserved history

Exact pre-T25CI handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CI_2026-10-06.md` (source blob c9b58bb90bff1a125590200388bd7af182875597).

Exact pre-T25CH handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CH_2026-10-06.md` (source blob 4ac0055e0e3b1a87a5315998e5b5a6756224dbf3).

Exact pre-T25CG handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CG_2026-10-06.md` (source blob 540c0318277f1ee1070cc0a618534c0d1f03f28c).

Exact pre-T25CF live handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CF_2026-10-06.md` (source blob e8a342bcb91f580285ef7f27cdc1377668ddbb19).

Exact pre-T25CE live handoff is also archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CE_2026-10-02.md` (source blob7416df90961a0981cfc3421791806ead75979d9f).

The exact pre-compaction live handoff is preserved byte-for-byte in
`AI_CONTINUITY/HANDOFF_ARCHIVE_PRE_COMPACTION_2026-10-02.md`
(source blob `7374eeb3fe3b931a72e22d68cd9438fbbe0b294b`, baseline main `3a1c713a1e371546a2fa72116adc5fe235e5686c`).

Read archived details only when needed; the sole active continuation point is the T25CI section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Continue USB_5V_AUX protection and consolidated whole-power draft/exact Iran BOM/Ceff evidence. Monitorfulltemp/ripple/diodeOR/startup and valid power-macromodel gaps remain named. Do not repeat unchanged hard-attach/oldWindows/profile loops or reopen SD. Prepare one reviewable whole proposal; no silent requirement/topology change or partial ECO.

**BLOCKER REQUIRING USER:** None for independent sourcing/review/draft currently. Integrated pre-fabrication verification remains BLOCKED by valid TPS631000/TPS54202/mux dynamic evidence, actualsource/Ceff/load and monitorcoldstart/ripple/leakbounds. No request for blindWindowsrerun, purchase or hardwarebuild at this checkpoint.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
