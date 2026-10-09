# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CU TPS54202 EN floating vs divider gate, 2026-10-09

- Continued from Git b2bcbb06 (T25CT), verified exact TI RevC February 2026 datasheet EN and VIN UVLO specs. User rule reinforced: do not stop for routine approval; keep advancing executable pre-fabrication gates, no repeat of invalid T25 fixtures.
- TI explicitly permits EN FLOAT to enable TPS54202. Vendor internal rising VIN UVLO 3.9..4.4V, EN recommended max5.5/abs7V, rising EN1.21..1.28V. EN typical sourcing currents Ip0.7uA, Ih1.55uA are NOT guaranteed upper bounds. Preferred un-applied topological screen: FLOAT EN, keep S1 USB pole; no unsafe direct EN-to-raw12V wire.
- ACTUAL_TEST_WITH_RAW_EVIDENCE conditional arithmetic: local executable Python 120 DC KCL corner cases at 1% R tolerance and 0/0.7/2.25uA *scenario* currents, machine-readable JSON and independently checked identities. Reference 562k/102k at USB5V cannot pass the EN rising minimum even with typ source (max0.977V). Alternative 150k/100k illustrates bounded VIN<=12V: at5V min1.976V; at12V max4.993V (typ current); but at VIN28V min11.066V > ABS EN7V, so NEVER use for full-rated 28V. Candidate not selected, source current max unguaranteed, no resistor procurement.
- Arithmetic proof: a passive fixed ratio with zero EN input current cannot both exceed EN rising max1.28V at VIN4.5 (ratio>=0.28444) and remain EN<=5.5 at VIN28 (ratio<=0.19643). Does not apply to floating EN or nonlinear limiters.
- Critical no-reset gate: TI buck internal soft start 5ms typical. Do not transfer load from BAT to USB before USB_REG3V3 is stable. Cbus-only fictitious hold-up for 5ms/280mA/3.3->2.7V would require2333uF effective: not a real observed source gap, nor installed BOM. Valid source-availability/current accounting and BAT1.80V/NRST/SD still OPEN.
- Exact unencrypted official SLVMBJ5C model is listed on TI website, but ZIP bytes were unavailable (network resolution blocked). Executed model-package gate returned MODEL_BYTES_ABSENT; PSpice/ngspice was NOT run; no fabricated device PASS. Full 6-file local ZIP (scripts/JSON/report/manifest) generated and SHA-verified; compact reproducible gate and evidence summary also committed in AI_SCRIPTS/T25, AI_EVIDENCE/T25CU and report T25CU_EN_UVLO_MODEL_GATE_FA.md.
- NEXT EXECUTABLE ACTION: obtain verified official SLVMBJ5C model bytes then validate exact pin mapping and build a new 5/5.5/12V bounded source + cold startup + 19/280mA load fixture; meanwhile prepare separate BAT1.80V current-conserving mux gate probing VIN/3V3_SYS/NRST/SD. No repeat prior invalid Windows fixtures, no PR1/SD/L1 changes.
- BLOCKER REQUIRING USER: none for analysis/research. Purchase, Altium ECO or fab only after complete one-shot BOM and explicit user decision. CAD unchanged, no whole-system PASS, FABRICATION HOLD.

## PRIOR VERIFIED POINT — T25CT USB5V regulated-input reference/EN gate, 2026-10-09

- Started from authoritative Git main 147e284 (T25CS) and read AI_START_HERE, CURRENT_HANDOFF, T25CS/T25CD/T25CP and relevant manufacturing/model limitations. Previous mismatched vendor PSpice fixtures were NOT repeated. No local Altium/CAD/BOM/purchase mutation.
- Verified TI official TPS54202 RevC electrical/timing/spec limits, **TI unencrypted transient model metadata SLVMBJ5C.ZIP only** (not downloaded/executed in this environment), and 2-layer TIDA-00947 reference schematic/BOM. Its qualified reference application is VIN **6.5..20V** at VOUT3.3V/1A; it does NOT validate USB 5.00/5.50V. TIDA BOM 22uH L1 THPC6045MF-220M and 2x22uF GRM21BZ71A226ME15L are *reference parts*, not Iran-qualified RevA purchases; original TPS631000/Murata1uH L1 remains unchanged.
- Distinct issue: TIDA EN resistors R2=562k VIN->EN, R5=102k EN->GND, with no external EN drive, produce V_EN 0.7681V at VIN5, 0.8449V at5.5; resistor1% highest at VIN5 0.7812V, below TI EN rising minimum1.21V. Adding nominal TI internal pull-up+hysteresis sensitivity gives0.9623V at VIN5; do not call it worst-case. Reference J1 exposes EN externally. Copying this divider is NOT an acceptable USB5V startup design. EN absmax7V, must never tie raw USB12V fault directly to EN.
- ACTUAL_EXECUTED_REFERENCE_ARITHMETIC_NOT_VENDOR_MODEL_PASS: 5 EN cases, 24 CCM inductor-ripple scenarios, 3 FB static corners computed with standard-library Python; independent Fraction audit verified **66 numeric relations**. Nominal TIDA R3=200k/R6=44.2k at VFBtyp.596 produces3.29283V; DC corners3.1579..3.4316V anchored to VFB spec at VIN12 only (not a guaranteed USB5V output). At Vin12, 22uH/500kHz/280mA, CCM ripple0.2175A and illustrative peak0.38875A; this does not cover light-load pulse skipping or exact L(I,T).
- Exact bytes of script/result/audit are committed under AI_SCRIPTS/T25 and AI_EVIDENCE/T25CT. Full technical report AI_CONTINUITY/T25CT_USB_REGULATED_REFERENCE_ADAPTATION_FA.md. Same-stage self-contained local ZIP available to user; no file production/board changes.
- NEXT EXECUTABLE ACTION: engineer **unapplied** USB5/5.50/12 EN/UVLO arrangement respecting abs7V; find exact Iran-available MPNs (inductor/Ceff etc.), then execute verified TI official SLVMBJ5C **only after obtaining actual bytes** in a new 5V-start/fault-return/load fixture. Work in parallel on BAT1.80V plus conservation-valid mux gap, postmux Cbus_eff, MCU NRST and SD integrity. Model listing ≠ actual simulation.
- BLOCKER REQUIRING USER: none for routine independent research; a consolidated power ECO, purchase or fabrication request requires one explicit informed approval. No power PASS / FABRICATION HOLD.

## Archived prior points — non-destructive compaction

Exact prior T25CS/T25CR/T25CQ/T25CP handoff sections and all older evidence are preserved byte-for-byte in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CT_COMPACTION_2026-10-09.md` (origin commit `57b41428fe434254638ce05a56aaa10fba152a8c`). Read those stage reports and the authoritative `AI_CONTINUITY/T25CS_OVP_BOUNDED_SOURCE_TRANSIENT_FA.md`, `T25CR_EXACT_DIODE_AND_USB_HEADROOM_FA.md`, `T25CQ_DIODE_AND_HOLDUP_GATES_FA.md` and `T25CP_LDO_FAULT_EDGE_AND_REVERSE_SCOPE_FA.md` for exact provenance. Current live point is T25CT only; do not repeat prior invalid fixtures.

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

Read archived details only when needed; the sole active continuation point is the T25CT section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Validate an independent TPS54202 USB5V EN/UVLO scheme with safe EN<7V under bounded USB12V fault, sourced exact components, and ONLY THEN run the official unencrypted TI model SLVMBJ5C (not available as bytes in this environment yet) against USB5 startup, USB5.5 no-nuisance, 12V bounded fault/return, 280mA load and real mux-current accounting. Address BAT1.80V/no-reset and real MCU NRST/SD write limits independently; keep T25CS/CR/CQ/CP as archival evidence, not rerun fixtures.

**BLOCKER REQUIRING USER:** None for independent design research/fixture preparation; a single consolidated purchase/ECO or fabrication change requires a concrete explicit user decision after technical and Iran sourcing gates close.

**FABRICATION HOLD.** Existing DRC/CI only validate PCB geometry/continuity, not power operation.
