# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CM recovery / T25CN USB LDO / T25CO protection, 2026-10-06 UTC

- User says **«ادامه بده متوقف نشو»** and **«خراب شدی»**. Continue effective independent execution without routine approval or a report-only substitute for tests; one consolidated technical/Iran proposal precedes any CAD/ECO/purchase.
- Read T25CM_RAW_RECOVERY_AND_RETENTION_FA.md, T25CN_TLV76701_EXECUTION_AND_IRAN_FA.md, T25CO_PROTECTION_MODEL_EXECUTION_AND_LIMITS_FA.md. Runtime recovered. All9 original CK CSVs/counts/endtimes/deck hashes audited, no CK rerun. Complete CJ/CK/CL raw ZIPs saved; pinned versions rematerialized, exact bytes/CRC verified. See AI_EVIDENCE/T25CM/PERSISTENCE_VERIFIED.json and RAW_MANIFEST.json. Prior runtime/raw-pending claims are superseded.
- CL recovered TLV76701DRVR Lion4876 stock81. Fixed76733 soon only. CN exact official unencrypted SLVMCY1 executed unchanged in ngspice42/ps. First100ns startup wall-timeout45s, simulated progress UNKNOWN; DC and two nominal controls complete. TI SLVMCY2 profile explicitly20ns/3ms/TNOM25; one justified profile change completed startup151419rows/final3.3075142V. Do not retry failed100ns profile.
- Iran draft FOJAN FRC0603F3162TS31.6k/1%/0603 stock5000, FRC0603F1002TS10k/1%/0603 stock92000; primary FRC datasheet100ppm/C. Four31.6k/10k model fixtures complete: startup peak3.37413896V;5→5.5 line3.32878602..3.35446495V; exact constant-current19→280mA3.30302207..3.34827337V. Resistive equivalent explicitly voltage-dependent;19mA is historical observation, not measured waveform. 192 conditional DC corners3.19503518..3.46709664V. NineCNanalyses:1DC/8TRAN,7TRANcomplete/1timeout.
- CN no temperature/noise model. DRV exposed-pad/manual assembly open; theta77.7 reference is not actual PCB. IQ80uA max is no-load, not IGND280mA bound. Twelve-volt continuous operation not thermally qualified. OUT>VIN+.3 requires external reverse protection; Ceff/ripple/source/load/thermal/assembly gates open. No LM1117/LD1117/TLV761 model substitution.
- CO nine new fixtures,6complete/3abort. TPS259621 normal5/5.5 complete;12V1us and100us faults abort; eFuse+LDO startup abort. TPS25953312V fault completes but is REJECTED for physical OVC proof: model has independent5.7V/3us OVLO shutdown, while TI specifies clamp. Do not call its output collapse a physical thermal response; exact path in MODEL_SCOPE_AUDIT.json.
- TPS259533+TLV76701 startup completes, early1.5..1.9ms window invalid. Justified later3ms event/4ms stop yields valid2.5..2.9ms prestate and normal5→5.5 line result202944rows,REG3.30073012..3.32563870V. This fixture uses31.25k/10k, not CN Iran31.6k. Helpers scoped with nested wrappers, original model bytes unchanged. No fault/wholeboard/NRST/SD PASS.
- Do not directly couple TPS2121 model to converters: CK inputs omit output load current and would falsely unload upstream regulators. No artificial shadow-current substitute. CK8complete/1abort and32PRcorners remain nominal timing evidence; no AA-backfeed/thermal proof.
- CJ aux R_EXP_PWR_EN historicalDNP/Open intent versus live0R/noDNP/noVariant remains unapplied population ECO. USB3V3 does not replace futureAUX5V; futuremodule load unqualified. BAT TPS631000 dynamic prestate at loadedAA1.80V remains blocked; keep TPS631000/L1, closed SD TPS22918 subgate and deferred exactS1. No unchanged Windows/CI/CK/CO numerical loops. **FABRICATION HOLD.**

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

Read archived details only when needed; the sole active continuation point is the T25CM/CN/CO section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** Build the one whole-power draft using retained TPS631000/L1 and executed USB LDO screen. Independently screen existing OVP plus wide-input LDO as a bounded alternate; do not reuse invalid eFuse fault output. Resolve reverse protection, assembly/heat, exact biased Ceff/source/load and valid1.80V BAT dynamics. No unchanged TPS2116/TPS631000/TPS54202/CI/CK/CO loops, SD reselection or partial ECO.

**BLOCKER REQUIRING USER:** No routine approval, Windows rerun or new physical stage requested. Runtime/raw-retention blockers CLOSED. Whole pre-fabrication proof remains blocked by named invalid/abstract BAT/mux/OVC models and missing source/Ceff/load/thermal/reverse bounds. Consolidated technical+Iran PASS list is not ready; nominal USB success is not board/fabrication PASS.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
