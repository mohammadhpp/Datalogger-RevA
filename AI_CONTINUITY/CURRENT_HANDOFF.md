# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25CX real-evidence handoff verifier, 2026-10-09

- Continued from real Git T25CW checkpoint `47ea976391df3157bf85e21c3cd2973853a27003`. Live Altium still places TPS2116 mux **before** TPS631000 battery converter. T25CW simulation instead uses unapplied two regulated rails **before** a downstream mux. Do not equate them.
- ACTUAL_TEST_WITH_RAW_EVIDENCE / VALIDATOR_SOFTWARE_ONLY: executed 7 synthetic verifier unit cases, 30 independent audit assertions PASS. Complete **byte-exact** Python, CSV/JSON, README, SHA256 manifest archived on Git at AI_SCRIPTS/T25 and AI_EVIDENCE/T25CX. Full local offline ZIP separately available to user (SHA256 `adb0d80cd287c37e525a8428efcbaa4cb61de8f0d1e0acb70cc7670b48e43077`).
- Detects 0 measured mux input current versus 280mA output (invalid-model nonconservation), SD supply <2.7V despite MCU healthy, NRST assertion, fast USB collapse with BAT_REG1.80<2.50, insufficient sample interval and historic incomplete 4-column T25CW CSV. The one nominal artificial case is **CONDITIONAL_SCREEN_PASS, system_pass=false**; NONE are physical or vendor circuit PASS.
- Tool expects two mux INPUT currents and output current, capacitive-bus/load current, MCU pin VDD+NRST, actual SD_VDD+write activity, pack-terminal1.80V, BAT_REG/USB_REG, time resolution and Cbus **effective** with trace provenance. 0.5us sampling is just the chosen trace screening resolution, not proven waveform bandwidth. No SD CRC/write-completion or OLED carrier proof exists.
- Exact report `AI_CONTINUITY/T25CX_EVIDENCE_GATED_HANDOFF_VERIFIER_FA.md` enumerates all evidence requirements. No official TPS6310001.80V full-prestate vendor proof, no current-conserving mux model trace and no board exist. Do not rerun invalid BF/BT/T25AE/T25CK fixtures.
- NEXT EXECUTABLE ACTION: qualify an authentic loaded1.80V converter + current-conserving priority-mux transient source, export both USB->BAT and BAT->USB waveforms with separate MCU/SD/NRST and source currents into T25CX format; in parallel finish USB12V OVP or fully Iran-sourced regulated-input architecture. The new SD power-switch screen T25BK/BL remains closed as a sub-gate, L1 and TPS631000 unchanged, S1 3-pole exact source deferred. BLOCKER REQUIRING USER: none for investigation; single explicit approval for consolidated new purchase/ECO/fabrication later only. **NO WHOLE-POWER PASS / FABRICATION HOLD**.

## Prior handoff archive (full, non-destructive)

Immediately previous T25CW live handoff is retained byte-for-byte at `AI_CONTINUITY/HANDOFF_ARCHIVE_BEFORE_T25CX_2026-10-09.md` (existing Git blob `f8b692c17d4785393fbe158459783455575ca5cc`), including all earlier accepted PASS/OPEN history. Read archive and dated reports if needed.

## Accepted design and validation baseline

- Live engineering source: private GitHub `mohammadhpp/Datalogger-RevA`, branch `main`, and the user's Windows repo `C:\#MHP FILES\DataLoger`. Historical ZIPs are rollback/evidence only. Read `AI_START_HERE.md` and its required source registry and continuation rules first.
- No RevA PCB has been fabricated. Existing final PCB-mounted parts were purchased; proposed new power parts are not an approved purchase. Canonical PCB `DATALOGER_RevA.PcbDoc`, library `Datalogger_RevA_Clean.PcbLib`.
- T23 routing CLOSED/PASS; T24 courtyards 129/129 persistent, last accepted Full Batch DRC 0 warnings / 0 violations at `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`. No fresh DRC or functional PASS is claimed.
- Locked requirements: two-layer PCB; schematic grid 100 mil; readable PCB RefDes/polarity/pin-1; correct connectors for off-board devices; loaded pack minimum 1.80V; no USB nuisance cutoff at 5.50V; uninterrupted USB-priority battery↔USB transfers, zero MCU reset and no intentional AA backfeed.
- **19 mA** is the old prototype observation with unknown bandwidth; **280 mA** is the historical RevA maximum design envelope, not a measured peak. Keep both provenance labels. SD 400mA is a historic switch-drop sizing point, not a measured card peak.
- Retain TPS631000 and Murata `DFE322512F-1R0M=P2` 1µH L1. TPS54202DDCR and its separate USB coil remain exploratory, unselected; do not silently substitute them.
- S1 three-pole maintained functional architecture is user-approved: BAT, USB, and common return ends of the two separate CC Rd resistors. Live CAD still shows four contacts; see T25BX/T25BY. Exact switch procurement is deferred by user.
- Every new replacement part needs exact-MPN technical and practical Iranian availability evidence. Close the whole power block, present one consolidated purchase/ECO proposal, then obtain that single concrete design decision before modifying Altium. No partial order or power ECO.


## Continuity rules retained

- One CURRENT EXACT POINT only. Existing final T24 DRC 0/0 is a geometry checkpoint, NOT a functional power PASS.
- Current CAD, PCB, procurement and two-layer constraint unchanged. All new power parts require exact Iran source and ONE consolidated design/purchase decision before Altium ECO. No fabrication, no Gerbers.

**NEXT EXECUTABLE ACTION:** Obtain physically valid, current-accounting TPS631000 at loaded BAT1.80V and mux priority model or qualified actual waveforms, then run both source transfers through the exact T25CX trace verifier with MCU/SD/NRST/write evidence. Work independently on exact Iran BOM and USB12V OVP/regulated input. No repeated invalid prior fixtures.

**BLOCKER REQUIRING USER:** None for continuing read-only independent engineering or preparing valid fixtures. A real hardware test, consolidated purchase/ECO and manufacturing action require their specific separate explicit approval. **FABRICATION HOLD.**
