# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CH architecture/PR1 corner proof and exact Iran monitor candidate, 2026-10-06 UTC

- Read `AI_CONTINUITY/T25CH_ARCHITECTURE_PR1_CORNER_PROOF_FA.md`. Executed9 PR-divider windows,48 energy sensitivities and6 battery-source budgets; script/CSV/JSON retained. No vendor/system/board PASS.
- New post-regulator USB FB candidate91k±1% / two10k±0.5%: nominal3.3078V, static3.185094..3.432960V. Retainedbattery FB gives3.214242..3.392396V. Dynamics/ripple/leakage excluded; no resistor reallocated or CAD changed.
- **Passive PR1 downstream option rejected under these assumptions:** atfloor2.7V and0.5% resistors k_min1.954228>k_max1.929767. Even ideal resistors cannot coverfloor2.72V. Olddivider may never choose healthycornerUSB;18k variant can keep selecting sustained2.65V USB. BiggerCbus cannot fix sustained undervoltage. Highest-voltage mode does not guarantee USBpriority because rails overlap.
- Exact `TPS3823-33DBVR` Iran listing Lion5418 announces1300 stock; saved rawexcerpt/hash. CandidateONLY: falling2.86..3.00V, release120..300ms underTI timing conditions, assertion25usnom NOT guaranteedmax; logic-hightestcondition/ripple/sequencing/inrush/absence remainOPEN. Do not silently accept attachmentdelay or125°C retailer spec (ordinarypartTI85°C). MAX809T/S listings are“به زودی”; S isUMW, not automaticallyADI-equivalent. Sourcingdeclaredstock isnotpurchase.
- Upstreammux option still requires verified slowUSBcollapse at1.80V; downstream requires backupregalwaysready, precisePR andnewCbus. Neither selectedasfinal. RetainTPS631000/L1/SDscreen; exactS1deferred; USB5Vexpansion protection remainsOPEN.
- T25CF audit retained: CASE_TIMEOUT240.1857s, parsing/bias completed, transientannounced, zeroPRINT/noDAT/nocompletion; actualsimulatedprogressUNKNOWN. **BoundedTPS54202 macro-model route BLOCKED; no unchangedT25CE/CF rerun.** No model/IC universalfailureinferred.
- No CAD/ECO/purchase/DRC/fabricationchange; lastT24DRC0/0CAD-only. **FABRICATION HOLD.**

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

Exact pre-T25CH handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CH_2026-10-06.md` (source blob 4ac0055e0e3b1a87a5315998e5b5a6756224dbf3).

Exact pre-T25CG handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CG_2026-10-06.md` (source blob 540c0318277f1ee1070cc0a618534c0d1f03f28c).

Exact pre-T25CF live handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CF_2026-10-06.md` (source blob e8a342bcb91f580285ef7f27cdc1377668ddbb19).

Exact pre-T25CE live handoff is also archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CE_2026-10-02.md` (source blob7416df90961a0981cfc3421791806ead75979d9f).

The exact pre-compaction live handoff is preserved byte-for-byte in
`AI_CONTINUITY/HANDOFF_ARCHIVE_PRE_COMPACTION_2026-10-02.md`
(source blob `7374eeb3fe3b931a72e22d68cd9438fbbe0b294b`, baseline main `3a1c713a1e371546a2fa72116adc5fe235e5686c`).

Read archived details only when needed; the sole active continuation point is the T25CG section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Continue whole-power draft with a precise monitor route and/or qualified upstream USB fall control. Close candidate monitor logic-high/ripple/timing/USB-priority delay and biased capacitor/source/RCB budgets before staging any newly valid integrated model. Do not repeat passive-divider tuning, unchanged Windows macro-model retries or the already screened SD sub-gate. Complete exact Iran whole-BOM/expansion5V protection and a single reviewable ECO/purchase proposal; no silent topology or requirement change.

**BLOCKER REQUIRING USER:** None for independent review/sourcing/draft preparation. Integrated pre-fabrication verification remains BLOCKED by valid TPS631000/TPS54202/mux dynamic evidence, actual source/Ceff/load parameters and monitor sequencing. TPS3823 introduces an attachment delay that is not accepted as an immediate-priority requirement change; resolve alternatives before one concrete decision. Do not request hardware spending or another unchanged run as the current step.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
