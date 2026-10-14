# CURRENT HANDOFF — Datalogger RevA

## ACTIVE USER EXECUTION RULE — 2026-09-28, 23:40 Tehran

- User explicitly instructed: **«منتظر تأیید نباش؛ اینو در هندآف ثبت کن»**. Continue the Datalogger RevA power-block work autonomously through read-only investigation, calculations, source checks, design drafts, reversible documentation and necessary validation. Do not stop at each intermediate gate with “موافقی؟ / مرحله بعد؟”, do not repeatedly ask for limits already locked in the workbook, and do not impose another Windows PSpice→ZIP/upload cycle whose model has already proved invalid.
- User also instructed: **«S1 بعد پیدا می‌کنیم؛ ادامه بده»**. Defer exact S1 three-pole sourcing; preserve the user-approved three-pole functional architecture and the live four-pole CAD mismatch in T25BX/T25BY. Continue USB/OVP/handoff and other independent power analysis.
- Prepare a single concrete, reviewable consolidated power proposal, Iran-sourced exact new-part list, test criteria and one ECO/purchase decision when technically ready. User's instruction to continue removes routine confirmation pauses; it does **not** turn unverified simulations into PASS or authorize claiming fabricated hardware. Do not ask for routine permission to write continuity reports or investigate candidates. If an irreversible purchase/fabrication action or a material change of locked product requirements truly requires a user choice, complete all independent work first and present the specific decision once.
- Keep GitHub `main` authoritative, maintain one live CURRENT EXACT POINT, and carry these instructions across chats. Preserve T24 0/0 DRC as a CAD-only checkpoint and FABRICATION HOLD until power gates are actually closed.

## CURRENT EXACT POINT — T25DB user-selected TLV61070ADBVR AA Boost, 2026-10-15

- **Explicit user choice:** preferred AA-source boost MPN is `TLV61070ADBVR` in hand-solderable 6-lead SOT23 DBV; do not choose `MCP1642B` for the principal battery path. This locks the user's part preference, **not** unqualified Iranian order/ECO or final system PASS. Full official-TI-based gate: AI_CONTINUITY/T25DB_TLV61070A_USER_SELECTED_AA_BOOST_GATE_FA.md.
- TI Rev B July2026: pinmap 1 SW,2 GND,3 EN,4 FB,5 VOUT,6 VIN; adjustable boost, nominal FB0.500V. Existing 510k/91k resistor values can nominally target3.3022V in a single integrated future ECO, if tolerances/FB leakage close. TI design inductor 2.2..4.7uH (2.2uH start) is NEW, not original 1uH Murata. No exact Iranian MPN stock yet. 20uA no-load from VOUT typical, not battery standby guarantee.
- Important unclosed design limitation: TLV61070A pass-through when pack VIN>regulated VOUT; test fresh two alkaline AA above 3.3V and MCU/SD max3.6V/USB priority. 1.8V loaded pack/280mA output, battery holder/S1 loop, switcher layout single-sided and USB→BAT transfer/NRST/SD are NOT validated. TI 1.8V/0.5A EVM capability is evidence only on four-layer vendor board under test conditions.
- NEXT EXECUTABLE ACTION: exact Iran-stock IC + shielded 2.2uH with verified DCR/Isat and bias-qualified caps, user DIY laser test coupon plus honest one-layer boost layout preflight; build true 1.8V/280mA test with USB switches and SD/MCU qualified gates. BLOCKER REQUIRING USER: only one informed full ECO/purchase/fabrication approval after sourcing and qualification. **NO ECO / NO GERBER / FABRICATION HOLD**.

## PRIOR VERIFIED POINT — T25DA DIY single-copper-layer laser power coupons feasibility, 2026-10-10

- Source-reviewed four proposed boards: 35x25mm process coupon first; 70x50mm TPS2113APW mux/load carrier conditional on 0.20mm pad gap process; separate 45x40mm TPS54202 USB buck and TLV61070A AA boost one-copper-side remain **UNQUALIFIED** because manufacturer EVMs rely on multi-layer GND and critical switching loops.
- A source-grounded report was committed at AI_CONTINUITY/T25DA_ONE_SIDED_LASER_PCB_FEASIBILITY_FA.md. Git repository has NO one-sided routed PCB, no copper Gerber, no drill file; dimensions are preliminary only. Do not claim a working single-layer switcher from package/board size alone. Existing final RevA stays 2 layers, manually assembled, all prior electrical/stock acceptance gates OPEN.
- NEXT EXECUTABLE ACTION: laser etch process isolation/pad pitch coupon 0.20..0.50mm, then a source-correct TPS2113APW one-layer carrier PCB; only then route/check separate buck/boost, revert small 2-layer modules if hot-loop/ground constraints fail. BLOCKER REQUIRING USER: local verification of 0.20mm separation for TSSOP and later one consolidated parts/fab approval. **NO PCB/GERBER GENERATED; REV A FABRICATION HOLD**.

## PRIOR VERIFIED POINT — T25CZ manual assembly package screening, 2026-10-09

- New user LOCK: final RevA is MANUALLY ASSEMBLED. Reject new QFN/DFN/WLCSP/hidden-pad choices; old TPS2121RUXR QFN and tiny TPS631000DRLR SOT-5x3 are unsuitable for the final hand build despite historical proposal/purchase. Supersedes T25CY PDF purchasing recommendations.
- Leaded TECHNICAL candidates (not final buylist): TPS2113APW TSSOP8 mux, TI 55uA typ operating, local Iran ISEE listing from Tehran IC-Kala not physically confirmed; TLV61070ADBVR SOT23-6 boost, TI1.3V startup min, low-load20uA typ, exact Iranian availability and actual1.8V/280mA performance OPEN. Optional MCP1642B-33I/MS MSOP8 with trial solder pilot. Keep TPS54202DDCR SOT23-6 USB buck, TPS22918DBVT SOT23-6 SD.
- See full AI_CONTINUITY/T25CZ_FINAL_MANUAL_ASSEMBLY_POWER_MPN_GATE_FA.md; no schematic, PCB, Gerber, order or product functional PASS. T25CY static test unaffected as historic evidence but network for new mux is NOT transferred.
- NEXT EXECUTABLE ACTION: verify Iran exact-stock and valid manual lead footprints, then one combined ECO with full electrical verification loadedAA1.80V/280mA, USB5/5.5/12 bounded, both transfer directions, NRST and SD integrity.
- BLOCKER REQUIRING USER: single final parts/purchase/fabrication decision only after technical supply resolved. FABRICATION HOLD.

## PRIOR VERIFIED POINT — T25CY one-shot proposal; manual-assembly parts superseded by T25CZ, 2026-10-09

- User requested speed to fabrication, one concise engineering solution and exact change/buy list. No routine confirmation interruptions. **ONE UNAPPLIED PROPOSAL** at AI_CONTINUITY/T25CY_FAST_FAB_CONSOLIDATED_POWER_ECO_FA.md and T25CY_CONSOLIDATED_CANDIDATE_BOM.md. Full offline local T25CY ZIP SHA256 4d17ff792fbfdb136b53257e7e73a1306a35161711f72ba8cc380ca7a9c41e46.
- Proposed dual-regulated USB/BAT then TPS2121RUXR OUT=3V3_SYS, replacing upstream TPS2116 and legacy pass-through OVP; USB branch TPS54202 output **3.305V (NOT3.576)** to avoid violating STM32/SD 3.6V. Keep TPS631000+original Murata1uH and T25BL SD selection. USB 5.5 no nuisance; 12V *bounded* VIN buck source. S1 3 poles BAT USB two Rd return ends only.
- ACTUAL_EXECUTED_STATIC_ARITHMETIC_NOT_VENDOR_SPICE: 256 USB FB 1% x battery historical static x priority divider 1% cases; PR1 USB20k/100k, CP2 BAT33k/100k gives static normal priority min margin+69.21mV, equality crossing2.87608..3.08628V; lowest illustrative crossing with adverse TI max40mV comparator offset 2.82824V. Real analog noise/current leak/load ripple and dynamic acceptance OPEN.
- NEW exact 10uH TDK SPM4020T-100M-LR technical only **no exact Iran supply**. TPS54202 Lion local listing today shows221, TPS2121 Lion28 previous checkpoint unconfirmed fresh, SD T25BL historic source screenshot, S1/holder exact MPN still open. 20-line sourcing CSV in offline ZIP; Git source-friendly BOM summary above. **NO ONE-SHOT FINAL VERIFIED BUYLIST**.
- Fastest truthful finish: source exact Iran BOM, apply one approved consolidated Altium power ECO (new TPS2121 RUX footprint not pin compatible with old TPS2116 DRL), Full DRC 0/0, **three qualified power tests** USB5/5.50/12 bounded, AA pack1.80 loaded both USB transfers, MCU.NRST+SD_VDD/write CRC. Vendor integrated PSpice not valid; prototype power coupon or prototype PCB tests are needed if genuine model unattainable. Do not manufacture as production PASS.
- NEXT EXECUTABLE ACTION: exact MPN Iran supply + 3PST board connector and battery Rpath, secure one consolidated approval, execute Altium ECO and 3 proof gates. BLOCKER REQUIRING USER: one irreversible procurement/ECO/sample board informed decision only when all sources resolved. **CAD UNCHANGED / NO PURCHASE / FABRICATION HOLD**.

## PRIOR VERIFIED POINT — T25CX real-evidence handoff verifier, 2026-10-09

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
