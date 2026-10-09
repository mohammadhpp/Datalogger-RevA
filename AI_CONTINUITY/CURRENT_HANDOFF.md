# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CT USB5V regulated-input reference/EN gate, 2026-10-09

- Started from authoritative Git main 147e284 (T25CS) and read AI_START_HERE, CURRENT_HANDOFF, T25CS/T25CD/T25CP and relevant manufacturing/model limitations. Previous mismatched vendor PSpice fixtures were NOT repeated. No local Altium/CAD/BOM/purchase mutation.
- Verified TI official TPS54202 RevC electrical/timing/spec limits, **TI unencrypted transient model metadata SLVMBJ5C.ZIP only** (not downloaded/executed in this environment), and 2-layer TIDA-00947 reference schematic/BOM. Its qualified reference application is VIN **6.5..20V** at VOUT3.3V/1A; it does NOT validate USB 5.00/5.50V. TIDA BOM 22uH L1 THPC6045MF-220M and 2x22uF GRM21BZ71A226ME15L are *reference parts*, not Iran-qualified RevA purchases; original TPS631000/Murata1uH L1 remains unchanged.
- Distinct issue: TIDA EN resistors R2=562k VIN->EN, R5=102k EN->GND, with no external EN drive, produce V_EN 0.7681V at VIN5, 0.8449V at5.5; resistor1% highest at VIN5 0.7812V, below TI EN rising minimum1.21V. Adding nominal TI internal pull-up+hysteresis sensitivity gives0.9623V at VIN5; do not call it worst-case. Reference J1 exposes EN externally. Copying this divider is NOT an acceptable USB5V startup design. EN absmax7V, must never tie raw USB12V fault directly to EN.
- ACTUAL_EXECUTED_REFERENCE_ARITHMETIC_NOT_VENDOR_MODEL_PASS: 5 EN cases, 24 CCM inductor-ripple scenarios, 3 FB static corners computed with standard-library Python; independent Fraction audit verified **66 numeric relations**. Nominal TIDA R3=200k/R6=44.2k at VFBtyp.596 produces3.29283V; DC corners3.1579..3.4316V anchored to VFB spec at VIN12 only (not a guaranteed USB5V output). At Vin12, 22uH/500kHz/280mA, CCM ripple0.2175A and illustrative peak0.38875A; this does not cover light-load pulse skipping or exact L(I,T).
- Exact bytes of script/result/audit are committed under AI_SCRIPTS/T25 and AI_EVIDENCE/T25CT. Full technical report AI_CONTINUITY/T25CT_USB_REGULATED_REFERENCE_ADAPTATION_FA.md. Same-stage self-contained local ZIP available to user; no file production/board changes.
- NEXT EXECUTABLE ACTION: engineer **unapplied** USB5/5.50/12 EN/UVLO arrangement respecting abs7V; find exact Iran-available MPNs (inductor/Ceff etc.), then execute verified TI official SLVMBJ5C **only after obtaining actual bytes** in a new 5V-start/fault-return/load fixture. Work in parallel on BAT1.80V plus conservation-valid mux gap, postmux Cbus_eff, MCU NRST and SD integrity. Model listing ≠ actual simulation.
- BLOCKER REQUIRING USER: none for routine independent research; a consolidated power ECO, purchase or fabrication request requires one explicit informed approval. No power PASS / FABRICATION HOLD.

## PRIOR VERIFIED POINT — T25CS bounded USB OVP pass-through transient, 2026-10-09

- Continued directly from T25CR Git main ab1fffd7606df05981c3b2d5ac15e3453b327aac. No invalid or completed T25 fixtures were repeated. No CAD/PCB/BOM, population, purchase or Gerber change.
- ACTUAL_TEST_WITH_RAW_EVIDENCE / BOUNDED_BEHAVIORAL_SIMULATION_NO_HARDWARE_PASS: 504 synthetic pass-through RC time points, 72 computed 6V cutoff roots; verified against five independent RK4 numerical trajectories (<20uV) and independent 504-row CSV consistency audit. Exact Python source and complete CSV/JSON/hash evidence are now Git tracked at AI_SCRIPTS/T25 and AI_EVIDENCE/T25CS; report: AI_CONTINUITY/T25CS_OVP_BOUNDED_SOURCE_TRANSIENT_FA.md.
- One explicitly conditional case (source5.5->12V in1us, R=0.128Ω, Ceff=22uF, historical max trip crossed as the *fictional timing reference*) yields 6.651681V for an ideal cutoff delayed1us after crossing; mathematical delay budget to remain <6V is0.620917us, NO margin. LCSC/FOSAN 128mΩ measured at VGS-2.5V does not certify true fault R; Ceff, actual TS431/PNP/MOS switching time, PNP gate charge, USB source current/impedance and real trip are not proven.
- Synthetic fixture has no exact device models, no actual measured output, no physically qualified OVP PASS/FAIL. TPS2116 6V absolute max is NOT a valid continuous regulator target; T25CC all-slow-fault >5.5V conflict remains; SS14 not an OVP clamp. Remain locked USB normal up to5.50V and BAT loaded1.80V/280mA.
- NEXT EXECUTABLE ACTION: identify/validate an exact pin-correct current-conserving TS431BCX RFG/BC857BLT1G/FSS2301S switching waveform with bounded 12V USB source and effective installed C; if unavailable prepare a complete regulated wide-input (non-pass-through) alternative with exact Iran-sourced MPN/BOM without ECO, then independently address TPS631000 battery1.8V/mux NRST/SD no-reset. Do not repeat invalid vendor fixtures. BLOCKER REQUIRING USER: none for continuing independently; consolidated new procurement/physical changes require explicit decision. **FABRICATION HOLD**.

## PRIOR VERIFIED POINT — T25CR Vishay exact-diode / USB LDO margin gate, 2026-10-09

- Continued from Git main 6dd7982 and verified the T25CQ Python/JSON match locally (semantic exact; assertions passed). Existing CJ/CK/CL/CN/CO/CP models are not rerun.
- 2026-10-09 new official-datasheet and Iran evidence: Vishay exact SS14-E3/61T, SMA 1A/40V, observed at Iranian Afranik catalog with MOQ10 and add-to-cart. Manufacturer/ordering string explicit but checkout/lot/reel stock/authenticity not checked. Exact-source candidate, NOT approved purchase/ECO.
- Vishay SS14 guaranteed/pulsed test: Vf<=0.50V at1A and25C, IR<=0.2mA @25C and <=6mA @100C at full40V reverse. These do not prove V_F max at every RevA condition or actual AA leakage at 3.3/5V. Do not transfer SS14FL SOD123F datasheet to SMA SS14.
- ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_BOARD_OR_COMPONENT_PASS: 27 scenarios of (USB, diode VF, TLV767 dropout) and 9 diode/LDO heat scenarios, script under AI_SCRIPTS/T25; compact audit JSON in AI_EVIDENCE/T25CR. At hypothetical USB5/VF0.5/TLV767 dropout0.9/OUT3.3, margin0.3V; 4.75V source scenario margin0.05V; no worst-case PASS. TI dropout0.9V is TYPICAL, not maximum. When OVP incorrectly passes12V, series diode does NOT clamp and LDO still dissipates illustrative2.296W at280mA (VF0.5).
- Full report AI_CONTINUITY/T25CR_EXACT_DIODE_AND_USB_HEADROOM_FA.md; do not select a diode/ideal-diode controller without package, reverse, thermal, real VF/IR, Iranian exact-MPN lot and whole-path requirements. No power ECO, no purchase/fab.
- NEXT EXECUTABLE ACTION: acquire/build source-bounded actual TS431BCX RFG/BC857BLT1G/FSS2301S switching waveform using physically credible models (or bounded documented thresholds, source current/slew, Ceff), while preparing BAT1.8V and current-conserving mux gate; no rerun invalid or repeated fixtures. BLOCKER REQUIRING USER: none for research; eventual combined purchase/ECO requires one explicit decision. FABRICATION HOLD.

## PRIOR VERIFIED POINT — T25CQ post-mux Cbus and diode reverse gate, 2026-10-09

- This session resumed directly from Git main T25CP (commit 3ef4dd67), read AI_START_HERE, decisions, continuity protocol, T25X/AF/Z, CN/CO/CP and source archives. No CJ/CK/CL/CN/CO or CP invalid/redundant fixture rerun.
- ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_HARDWARE_PASS: T25CQ Python + JSON in AI_SCRIPTS/T25 and AI_EVIDENCE/T25CQ. Independent 3V3_SYS *post-mux* Cbus budget: at I=280mA, Vstart3.3/floor2.7 scenario a 10us source gap requires4.667uF EFFECTIVE Cbus; 50us requires23.333uF. True mux gap, Cbus_eff, MCU BOR and SD write boundary remain unknown. An upstream C_USB or LDO COUT cannot automatically be counted as Cbus.
- Illustrative LDO-CIN sensitivity only: series diode VF0.5V, dropout0.9V, 1uF effective CIN, 280mA assumed input -> pre-dropout no-source time1.071us at USB5V; NOT actual diode/guarantee. Diode assumed loss0.14W at VF0.5/280mA.
- Reverse: OUT-to-IN bypass protects intrinsic LDO path but not upstream discharge; series diode before CIN isolates upstream only and still requires validation of intrinsic OUT>IN path. CP model lacks intrinsic reverse diode. No actual diode selected.
- Iran exact diode screen: SS14 generic stocked offers found but Atrinelec advertises Toshiba while detail text says Vishay; no full manufacturer MPN+validated vendor data and temperature/IR/surge proof. ECA says out of stock. Manufacturer-specific onsemi SS14 global evidence not Iranian supply. NO exact-MPN Iran PASS, no purchase/ECO.
- Read AI_CONTINUITY/T25CQ_DIODE_AND_HOLDUP_GATES_FA.md. Live CAD PCB and power SchDoc blobs remain unmodified; existing T23/T24 DRC PASS only. TPS631000/Murata1uH retained, SD subgate closed screening, S1 triple-pole decision retained and exact sourcing deferred.
- NEXT EXECUTABLE ACTION: exact sourced diode data and validated TS431BCX/BC857BLT1G/FSS2301S real-node OVP response under bounded input-source fault; then current-valid mux BAT1.80V/NRST/SD no-reset. Do not re-run invalid or already accepted PSpice fixtures. BLOCKER REQUIRING USER: none for independent evidence work; physical instrumentation/board not authorized.
- NO WHOLE-POWER PASS, NO COMPLETE IRAN BOM, NO CAD ECO, NO GERBERS, FABRICATION HOLD.

## PRIOR VERIFIED POINT — T25CP LDO fault edges / reverse-model scope, 2026-10-06 UTC

- Continued from authoritative CM/CN/CO commit258d351; Windows local repo remained e6f9a36/T25CF, CAD blobs01_POWER/07_EXPANSION/PCB identical. No edits to the user's working repo, CAD, population, purchase or physical stage.
- Read T25CP_LDO_FAULT_EDGE_AND_REVERSE_SCOPE_FA.md and T25CP_WHOLE_POWER_DRAFT_FA.md. Exact CN SLVMCY1 LIB and RevD PDF re-fetched with matching hashes. Portable official Windows ngspice42 executed13 NEW analyses:1DC/12TRAN, all completed; every transient valid1.5..1.9ms prestate and3ms finish. Independent CSV audit includes all rounded-equal timestamps and extrema. No CJ/CK/CL/CN/CO repeat.
- Ten imposed-input line fixtures at25C,31.6k/10k,1uF ideal CIN,10mohm output ESR:12V pulses with1us edges/10 or100us plateau,10uF output yield minima2.526850/2.535699V on falling edges;10us edge/100us plateau/10uF gives3.039326..3.664428V.100us-edge cases and four historical5.915721V-ceiling cases remain inside the illustrative2.7..3.6 rail screen. These are nominal sensitivity results, not qualified source/Ceff/OVP/SD/MCU limits;5.915721 is historic trip, not physical peak cap.
- NEW reverse-model gap: forced OUT3.3/IN0 DC draws only+1.5uA; vendor G_ABMII1 and ideal VIN_ORG omit physical OUT-to-IN body diode. Two collapse transients exceed OUT-IN+.3, so reject their physical reverse/hold-up inference. I(V_SRC) includes ideal CIN displacement current; negative edge spikes are not isolated LDO reverse current.
- TI reverse guidance separates OUT-to-IN bypass from a series diode before CIN. Bypass protects the LDO path but does not block upstream energy. Exact new diode MPN/Iran/VF/IR/surge, CIN retention, assembly/heat, source bounds and actual mux backfeed remain OPEN. No generic diode or substitute model selected.
- PSpice NEW DC attempt timed out60s without log/data, progressUNKNOWN; no repeat. Initial ngspice launcher quoted codemodel paths incorrectly; preserved loader output and fixed only quoting before valid runs. No blind numerical retry.
- Full raw ZIP11625345bytes, SHA256d270b43e1a98a202099984868fe9eb22a9e6173c15390a4d8f89b7b5c182db65; local ZIP CRC and all member hashes verified. Raw Git blob cf37183bc949fd5ee47a7ecc35f262cfe589e65f matches the full local archive; user explicitly authorized publication on2026-10-07. Included in this same Git transaction. Prior CJ/CK/CL/CN_CO retention remains valid and superseded pending claims remain superseded.
- Retain TPS631000/L1, closed SD TPS22918 subgate, deferred exactS1, separate futureAUX5V with unappliedR_EXP_PWR_EN DNP correction. Do not integrate abstract TPS2121 via artificial shadow current. No board/fabrication PASS; FABRICATION HOLD.

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

Exact pre-T25CP handoff is preserved in `HANDOFF_ARCHIVE_BEFORE_T25CP_2026-10-06.md` (blob ec23ab520c9428f1b6d1bda4219b7bda6d05d5f6).

Exact pre-CM/CN/CO handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CM_CN_CO_2026-10-06.md` (source blob 084c6e3e2a1ca8a687f27ad3b07b06f32e6e56f6).

Exact pre-CJ/CK handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CJ_T25CK_2026-10-06.md` (source blob 734e40adb5353bb0d2ff0decfd5d760400eb85de).

Exact pre-T25CI handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CI_2026-10-06.md` (source blob c9b58bb90bff1a125590200388bd7af182875597).

Exact pre-T25CH handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CH_2026-10-06.md` (source blob 4ac0055e0e3b1a87a5315998e5b5a6756224dbf3).

Exact pre-T25CG handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CG_2026-10-06.md` (source blob 540c0318277f1ee1070cc0a618534c0d1f03f28c).

Exact pre-T25CF live handoff archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CF_2026-10-06.md` (source blob e8a342bcb91f580285ef7f27cdc1377668ddbb19).

Exact pre-T25CE live handoff is also archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CE_2026-10-02.md` (source blob7416df90961a0981cfc3421791806ead75979d9f).

The exact pre-compaction live handoff is preserved byte-for-byte in
`AI_CONTINUITY/HANDOFF_ARCHIVE_PRE_COMPACTION_2026-10-02.md`
(source blob `7374eeb3fe3b931a72e22d68cd9438fbbe0b294b`, baseline main `3a1c713a1e371546a2fa72116adc5fe235e5686c`).

Read archived details only when needed; the sole active continuation point is the T25CP section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Qualify the exact series/bypass diode and its Iran source, and obtain a validated or bounded TS431BCX/BC857BLT1G/FSS2301S OVP waveform for the LDO input. Use the CP edge matrix to define the next distinct input-protection fixture; do not rerun it unchanged or use a historical trip as a dynamic clamp. Keep BAT1.80V and model-current-valid mux integration as separate unresolved gates. The whole-power draft is prepared, not selected.

**BLOCKER REQUIRING USER:** None for routine continuation or publication: user explicitly approved transferring the CP raw archive and documents to this private repo on2026-10-07. No Windows rerun or physical stage requested. Technical whole-power proof remains blocked by named BAT/mux/reverse/OVP model gaps and real source/Ceff/load/thermal bounds; consolidated purchase/ECO is not ready.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
