# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CE USB separate-branch executable gate, 2026-10-02 UTC

- User authorized autonomous continuation; S1 sourcing deferred. TPS631000/Murata L1 retained; SD T25BK/T25BL screened. No CAD/ECO/purchase or new hardware/fabrication PASS.
- Read `AI_CONTINUITY/T25CE_USB_SEPARATE_BRANCH_AND_EXECUTABLE_MODEL_GATE_FA.md`. Live 07_EXPANSION shows USB_VBUS_PROT feeds USB_5V_AUX through zero-ohm R_EXP_PWR_EN: **do not replace that whole rail with3.576V**. Exploratory preregulator needs its own USB_PMUX_REG/VIN1 branch; separate 5V expansion protection remains OPEN.
- Executed Python static corners/LC sweep/cap-only energy traces, committed raw CSV/JSON. Buck3.442642..3.712055V, proposed PR static2.741692..3.261709V, margin180.933mV; hysteresis/leakage/dynamics excluded. Worst-Vout pre-Cff f0 screen needs Ceff>28.6844uF;44uF nameplate alone is not proof. Conditional CCM Ipeak max0.931416A with declared L/eta/frequency scenarios.
- Direct Iran pages: SRN1060-100M stock1980, size approximately10x9.8x6mm/fit open; manufacturerDCR29mOhm versus retailer290mOhm discrepancy. TDK SPM6530T-100M is “به زودی”; TPSM863257 exact listing exists but out of stock. Exact Fenghua56pF C0G0603 listing3450 stock; Cff56pF still a fixture start point. No part selected.
- **New** official TPS54202 USB-only model test staged:6 decks, ASCII PS5.1/CMD with pinned TI ZIP/LIB hashes, pilot prestate gate, per-case180s/total900s stop limits and ZIP logs. Payload encrypted despite download title; Linux has no PSpice/PowerShell. Python numerical execution and split-PRINT/prestate parser self-check passed; Windows vendor numerical and PS runtime remain PENDING. Do not repeat old invalid TPS2116/TPS631000 fixtures.
- Fault source12V/1us/0.1ohm and22/44uF Ceff are declared sensitivity fixtures, not bounded real fault domain. Full battery startup/no-reset transfer, actual Ceff/card/module, layout and both USB branches still OPEN; FABRICATION HOLD.

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

Exact pre-T25CE live handoff is also archived in `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CE_2026-10-02.md` (source blob7416df90961a0981cfc3421791806ead75979d9f).

The exact pre-compaction live handoff is preserved byte-for-byte in
`AI_CONTINUITY/HANDOFF_ARCHIVE_PRE_COMPACTION_2026-10-02.md`
(source blob `7374eeb3fe3b931a72e22d68cd9438fbbe0b294b`, baseline main `3a1c713a1e371546a2fa72116adc5fe235e5686c`).

Read archived details only when needed; the sole active continuation point is the T25CE section above. Further evidence and older checkpoints remain in `HISTORY.md`, dated T25 reports and source archives.

The 2026-09-28 cleanup audit is `GITHUB_CLEANUP_AUDIT_2026-09-28.md`: canonical SchLib was restored byte-identically; duplicate PcbLib and T23/T24 evidence retained pending dependency/path checks. Do not delete evidence to reduce apparent clutter. This compaction repairs documentation only.

**NEXT EXECUTABLE ACTION:** After normal Git_Save.cmd sync, run AI_SCRIPTS\\T25\\Run_T25CE_USB_Official_Model_v1.cmd once. Independently audit the generated Result ZIP with T25CE_Audit_Printed_Output_v1.py before interpreting fault/5.5V/unplug traces. Continue complete two-branch USB protection/Ceff/layout and retained battery/no-reset work; do not repeat invalid old fixtures.

**BLOCKER REQUIRING USER:** The new TPS54202 official encrypted model needs the user's existing Windows PSpice engine; prepared one-click run and resulting ZIP are required for this vendor evidence. No routine design approval requested. A consolidated ECO/purchase decision remains later, once technically ready.

**FABRICATION HOLD.** Continuity CI validates file retention and metadata; it does not certify circuit function.
