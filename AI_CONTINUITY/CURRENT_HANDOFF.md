# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25B vendor-model archive preflight PASS; runtime test pending — 2026-09-23

- User ran `Git_Save.cmd` v2.5; GitHub `main` checkpoint `248879d3e7488af5a5920b54f0a4a5a5c01821e0` fast-forwarded after T25A. It changed `DATALOGER_final.PrjPcb` and `Script_Project1.PrjScr` only. The canonical PCB/PcbLib and schematic binaries remain at the prior T24/T25A engineering state.
- Official TI TPS631000 `SLVMDV2.ZIP` and TPS2116 `SLVMDI4A.ZIP` were downloaded; both passed ZIP integrity checks. Full SHA256, actual `.SUBCKT` headers, physical pin map, limitations and next procedure: `AI_CONTINUITY/T25B_TI_MODEL_ARCHIVE_PREFLIGHT.md`, commit `ff277ab00baf3a497df16f657876f96784c31d4c`.
- TPS631000 encrypted interface pin order matches `U_SYS` physical pins 1–8. TPS2116 unencrypted interface order is **GND, MODE, PR1, ST, VIN1, VIN2, VOUT_0, VOUT_1**; it does NOT match numeric physical order. Both VOUT pins map to `VIN_MUX`.
- The TPS631000 supplied soft-start example references an absent `tps631000.lib` filename; the archive instead contains `TPS631000_SYMBOL.lib` with the encrypted subcircuit. Resolve path only in an isolated copy when running a supported PSpice smoke test.
- `DATALOGER_final.PrjPcb` references `Datalogger_RevA_Clean.SchLib`, which is missing from GitHub `main`. Confirm the **current local** library before ever attaching a simulation model or performing schematic ECO; do not substitute the older T23 ZIP.
- **Static archive/pin audit PASS; PSpice runtime, Altium compatibility and project-specific transient simulation remain PENDING.** No new DRC was run or needed for this read-only step; last accepted Full Batch DRC is T24 0/0.
- NEXT EXACT ACTION: on an available full Cadence PSpice installation, run each TI-supplied example (TI support reports TPS631000 trouble in the limited PSpice for TI edition) in an isolated folder and record version/errors/waveforms. For TPS631000 correct only the example's library reference to the included file in that isolated copy. After successful vendor examples, create a separate Datalogger power bench with actual sourced load/source parameters. Keep the canonical schematic/PCB unchanged.

## CURRENT EXACT POINT — T25A source/model audit COMPLETE — 2026-09-23

- T23 routing and T24 courtyard remain CLOSED / PASS. Canonical engineering checkpoint is `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`; canonical PCB `DATALOGER_RevA.PcbDoc`, PcbLib `Datalogger_RevA_Clean.PcbLib`.
- T25A read-only power-tree/model audit is recorded in `AI_CONTINUITY/T25A_POWER_TREE_SIMULATION_MODEL_AUDIT.md` (report commit `7554e792df1de75474c11a8607d8857ac7ff4c94`). The current `main` binary `01_POWER.SchDoc` and five related power-load sheets were parsed and Git blob verified.
- Confirmed path: battery / USB through S1 and USB OVP → TPS2116 priority mux → VIN_MUX → TPS631000 with EN tied to VIN_MUX → 3V3_SYS; SD and OLED are separate AO3401A high-side branches with 54.1 µF and 10.1 µF nominal local capacitor sums, respectively.
- All 115 components in the six inspected sheets attach only `PCBLIB` model records. TI publishes an encrypted TPS631000 PSpice model and an unencrypted TPS2116 transient model, but neither is attached or validated against the project's simulator. Card/OLED/module current waveforms, AA source impedance and effective capacitor values remain unsourced.
- **T25A PASS as an evidence audit only. No circuit simulation has run, no numeric transient PASS is claimed and no engineering file was modified.** Last Full Batch DRC remains T24's user-confirmed 0 warnings / 0 violations; no fresh DRC was run for this read-only audit.
- NEXT EXACT ACTION (T25B): obtain/inspect the exact TI model archives, verify pin mapping and license, run supported-simulator smoke tests on isolated copies, then build a source-and-load stimulus matrix using sourced current profiles. Do not place guessed models or loads into the canonical schematic. If encrypted converter model cannot run in the chosen simulator, use a clearly labeled averaged behavioral model for system-level exploration and reserve switching/startup qualification for TI-compatible simulation and bench measurements.
- Git workflow: the report and this handoff were written to GitHub `main`; on the local Windows working repo run the established `Git_Save.cmd` v2.5 once to safely fetch/fast-forward and sync `localbackup`. Check for divergence before any binary edit.

## CHAT MIGRATION HANDOFF — T24 CLOSED, T25 FUNCTIONAL VERIFICATION / SIMULATION NEXT — 2026-09-23

- Chat migration is now REQUIRED under `AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md`; the conversation became heavy and the migration should have been proposed proactively earlier.
- Authoritative branch/repo: `main` of private GitHub repo `mohammadhpp/Datalogger-RevA`.
- Canonical working PCB: `DATALOGER_RevA.PcbDoc`.
- Canonical PCB library: `Datalogger_RevA_Clean.PcbLib`.
- T23 routing: CLOSED / PASS.
- T24 courtyard/manufacturing-prep subtask: **PASS / SAVED / CLOSED**.
- Final courtyard persistence after Save/Close/Reopen: **129 / 129 PASS**.
- Final Full Batch DRC after courtyard completion: **0 warnings / 0 rule violations**.
- Final Snapshot Exporter run completed from canonical `DATALOGER_RevA.PcbDoc`; snapshot header generated `2026-09-23 18:35:51` using Collision-Aware FULL Board Snapshot v1.4.2.
- Final user `Git_Save.cmd` checkpoint: `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8` (`Auto checkpoint 2026-09-23 18:36:49 | 11 file(s)`).
- Continuity note after that checkpoint records T24 closure; do not reopen the stale `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc` as the working source.
- The promoted generated PcbLib was binary-audited before use. Eight target footprint families have persistent courtyard data; the final generated candidate SHA256 was `a2f2aea3592b79934fbeb8042ce90b2089791ea83b71c2a39a27efa3ba9514a2`.
- Controlled ECO updated exactly 16 target PCB components using only mechanical/courtyard content; final ECO showed all Check/Done green.

### NEXT TASK — T25 Functional Verification & Simulation

- User approved starting a new phase focused on functional verification/simulation before manufacturing release.
- First recommended substage: **T25A — Power Tree / Simulation Model Audit**.
- Start by reading the actual schematic and source files, especially `01_POWER.SchDoc`, then extract the real power tree and identify which parts have usable simulation models versus which require behavioral/load equivalents.
- Primary initial focus: `TPS631000` power path / `3V3_SYS`, startup, load-step behavior, transient response, SD/OLED switched loads, and any power-enable / load-switch interaction.
- Do not claim whole-board firmware/MCU behavior can be fully SPICE-simulated. Separate: (1) analog/power simulation, (2) digital/load behavioral checks, (3) post-layout signal-integrity checks for relevant high-speed nets if warranted.
- Before any simulation setup or model substitution, inspect the current schematic/BOM/library evidence from Git. Do not invent missing model parameters.
- Preserve all existing locked project constraints: 2-layer PCB, current canonical PCB/PcbLib, manual-assembly requirements, 100mil schematic grid, current routing and courtyard state.
- No additional T24 changes are required before T25.

### NEW CHAT START PROCEDURE

1. Read `AI_START_HERE.md`.
2. Read `AI_CONTINUITY/CURRENT_HANDOFF.md`.
3. Read `DECISIONS_AND_CONSTRAINTS.md`, `LESSONS_LEARNED.md`, `HISTORY.md`, `CHAT_MANAGEMENT_RULE.md`, and `UPDATE_PROTOCOL.md`.
4. Inspect the latest Git commits and canonical engineering files.
5. Continue exactly from **T25A — Power Tree / Simulation Model Audit**.

## CURRENT EXACT POINT — T24 Courtyard CLOSED / final checkpoint saved — 2026-09-23

- Canonical PCB: `DATALOGER_RevA.PcbDoc`.
- Final persistence audit: **PASS 129 / 129 courtyard coverage** after Save/Close/Reopen.
- Full Batch DRC: **0 warnings / 0 rule violations**.
- Snapshot Exporter completed successfully after final DRC.
- Latest snapshot header: source `DATALOGER_RevA.PcbDoc`, generated `2026-09-23 18:35:51`, exporter format `Collision-Aware FULL Board Snapshot v1.4.2`.
- `Git_Save.cmd` completed and produced checkpoint commit `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8` (`Auto checkpoint 2026-09-23 18:36:49 | 11 file(s)`).
- That checkpoint includes canonical PCB, canonical `Datalogger_RevA_Clean.PcbLib`, latest snapshot, final persistence audit report, project file, and related backup artifacts.
- T24 Courtyard work is **PASS / SAVED / CLOSED**.
- Next project work should start from this checkpoint; do not reopen the stale `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc` as the working source.

## CURRENT EXACT POINT — T24 Courtyard FINAL PASS / DRC 0 — 2026-09-23

- Canonical PCB: `DATALOGER_RevA.PcbDoc`.
- Final persistence audit after Save/Close/Reopen: **PASS 129 / 129 courtyard coverage**.
- All 16 repaired components passed the final read-only layer/persistence checks.
- Full Batch DRC run after persistence audit: **Warnings = 0, Rule Violations = 0**.
- Therefore T24 Courtyard repair is technically COMPLETE / PASS.
- Canonical generated library used for the controlled update: `Datalogger_RevA_Clean.PcbLib` with the audited 8 target footprints carrying persistent courtyard data.
- NEXT EXACT ACTIONS before leaving T24: run Snapshot Exporter v1.3.2, then run `Git_Save.cmd`, then record resulting checkpoint and move to the next project task.

## CURRENT EXACT POINT — ECO complete; final Save/Reopen persistence audit is next — 2026-09-23

- Controlled 16-component footprint ECO completed successfully with all Check/Done green.
- User should have saved canonical `DATALOGER_RevA.PcbDoc`, closed it, and reopened it before the next audit.
- New read-only script: `AI_SCRIPTS/T24/T24_Courtyard_Final_Persistence_Audit_v1.pas`.
- Entry: `AuditT24_Courtyard_Final_Persistence_v1`.
- PASS requires 129 total components, 129/129 with M2/M4 courtyard data, the 15 repaired Top-side targets at M2=4/M4=0, and bottom-side `U_RTC` at M2=0/M4=4.
- Script writes `T24_Courtyard_Final_Persistence_Audit_v1.txt` and makes no PCB changes.
- NEXT: run this persistence audit. If PASS, immediately run Full Batch DRC. If DRC=0, run Snapshot Exporter and Git_Save.

## CURRENT EXACT POINT — controlled 16-component ECO executed successfully — 2026-09-23

- Canonical generated `Datalogger_RevA_Clean.PcbLib` was used to update only the 16 T24 courtyard-target components in `DATALOGER_RevA.PcbDoc`.
- Update comparison was restricted to `Top Courtyard` and `Bottom Courtyard`; Component Update Options were restricted to `Other -> On Mechanical Layers` only. Text, silk, other layers, pad attributes, and footprint parameters were disabled.
- ECO contained exactly `Change Physical Footprints (16)` for: C_OLED_BULK, C_SD_MID, C_SENSOR_BULK, D_ESD, D_ESD1, D_ESD2, D_EXT1, D_EXT2, D_EXT3, J_NAV, J_SD, J_SHIELD, J_SWD, Q_OLED, Q_SD, U_RTC.
- User executed ECO; screenshot confirms all 16 rows have green `Check` and green `Done`, with no reported error.
- NEXT EXACT ACTION: close ECO, save canonical `DATALOGER_RevA.PcbDoc`, close/reopen that PcbDoc, then run a read-only 129/129 courtyard persistence audit before Full Batch DRC.

## CURRENT EXACT POINT — promote audited generated library and update only 16 PCB instances — 2026-09-23

- User approved promotion of the final audited generated PcbLib.
- Final generated candidate SHA256: `a2f2aea3592b79934fbeb8042ce90b2089791ea83b71c2a39a27efa3ba9514a2`.
- A canonically named copy has been prepared for local replacement as `Datalogger_RevA_Clean.PcbLib`.
- Git connector cannot directly replace the binary PcbLib; user must overwrite the local project file with the prepared canonical copy, then later run `Git_Save.cmd` to commit it.
- To avoid manually selecting 16 PCB instances, new helper script `AI_SCRIPTS/T24/T24_Select16_ForLibraryUpdate_v1.pas` selects exactly the 16 target components and nothing else.
- After replacing the local PcbLib and reopening Altium, run `SelectT24_Courtyard16_ForLibraryUpdate_v1`; expected PASS = exactly 16 selected.
- Then right-click one selected component > `Component Actions > Update Current Components From PCB Libraries`.
- In `Update From PCB Libraries - Options`, include ONLY Mechanical 2 and Mechanical 4 / Top-Bottom Courtyard layers. Do not update pads, overlay, solder mask, paste, models, or unrelated footprint primitives.
- Review the comparison/ECO before execution; it should affect only the selected 16 components and courtyard-layer primitives.
- After ECO Execute Changes: Save PCB, close/reopen, verify courtyard persistence, run Full Batch DRC, Snapshot Exporter, then `Git_Save.cmd`.

## CURRENT EXACT POINT — regenerated PcbLib v3 FINAL BINARY AUDIT PASS — 2026-09-23

- User supplied regenerated `DATALOGER_RevA(1).PcbLib` after running `T24_All16_TransientCourtyards_ForMakeLib_v3.pas` and native `Design > Make PCB Library`.
- Direct binary OLE/CFB audit result: **PASS** for all 8 unique T24 target footprints.
- File size: 294912 bytes. SHA256: `a2f2aea3592b79934fbeb8042ce90b2089791ea83b71c2a39a27efa3ba9514a2`.
- Every target footprint has exactly 4 new 0.05mm-equivalent courtyard tracks on Mechanical2 / Top Courtyard with the expected T24 envelope geometry.
- `MAXIM_W16H2_SO16_90_0107` (U_RTC) specifically corrected: 4 courtyard tracks are now on Mechanical2 / Top Courtyard; previous candidate had them on Mechanical4.
- Exact audited geometries (mm): MAXIM 11.449987x10.599976; AOS SOT23 3.000017x3.300016; GOSUN 12.799972x2.639972; WIRE_DRAIN 2.500018x2.500018; ATOM J_SD 16.800015x12.499998 centered at Y +5.099990; SHOUHAN 15.099993x5.900011; ST SOT23-6 3.600016x2.599992; MURATA 2.499992x1.350007.
- Native generated library contains 37 currently-used footprints. Two unused legacy footprints from the prior canonical library are absent: `OMRON_B3F_12X12_THT_4P` and `CR2032_HOLDER_P20_2P_THT`; their current replacements are present. This is not a current-board functional issue but is a library-history difference.
- Audit report committed as `T24_Final_Generated_PcbLib_Binary_Audit.txt`.
- NEXT DECISION: either promote this 37-footprint generated library as the new canonical `Datalogger_RevA_Clean.PcbLib` (legacy footprints remain recoverable from Git history), or preserve the two unused legacy footprints by merging them before promotion. For speed/current-board correctness, promoting the 37-footprint library is technically sufficient.
- After promotion: update/associate `DATALOGER_RevA.PcbDoc` from the promoted library, save, close/reopen, verify courtyard persistence, Full Batch DRC, Snapshot Exporter, Git_Save.

## CURRENT EXACT POINT — first Make PCB Library candidate audited; persistence solved, U_RTC source courtyard layer needs one automated regeneration — 2026-09-23

- User supplied generated `DATALOGER_RevA.PcbLib` from native `Design > Make PCB Library` after transient 129/129 staging.
- Binary CFB/PcbLib audit confirmed the new courtyards are **persistent in the generated library**. The workaround fundamentally works.
- 7 of the 8 unique target footprints have exactly four 0.05mm courtyard tracks on Mechanical2 / Top Courtyard with the expected T24 envelope geometry: `AOS_SOT23_AO3401A_3P`, `GOSUN_PLS_2P54_1X5_THT`, `WIRE_DRAIN_1P_D1P20_P2P40_THT`, `ATOM_MR01A_01245_10P`, `SHOUHAN_2P50_1X05_ZZMS_THT`, `ST_SOT23_6L_USBLC6_6P`, `MURATA_GRM21_0805_CAP_2P`.
- `MAXIM_W16H2_SO16_90_0107` (`U_RTC`) has correct 11.45x10.60mm geometry and 0.05mm tracks, but its four new tracks are on Mechanical4 because v2 staged that bottom-placed component on Bottom Courtyard before native extraction. In a source PcbLib this should be Mechanical2 / Top Courtyard so the M2/M4 pair can flip correctly when the component is placed on Bottom.
- The generated library contains 37 footprints. Compared with the pre-T23 baseline plus the two later replacement footprints, native Make PCB Library has intentionally omitted two unused legacy footprints: `OMRON_B3F_12X12_THT_4P` and `CR2032_HOLDER_P20_2P_THT`. Their replacements `TACT_6X6_H5_P6P5_X4P5_4P_THT_REV_A` and `CR2032_HOLDER_VERTICAL_P20_D0P90_2P_THT_REV_B` are present. This does not affect the current board but must be documented if the generated library becomes canonical.
- Do NOT promote the first generated `DATALOGER_RevA.PcbLib` yet solely because of U_RTC's source courtyard layer.
- Automated fix script created: `AI_SCRIPTS/T24/T24_All16_TransientCourtyards_ForMakeLib_v3.pas`, entry `ApplyT24_All16_TransientCourtyards_ForMakeLib_v3`. It is identical to v2 except that extraction staging for `U_RTC` is deliberately Mechanical2/Top Courtyard.
- NEXT: close the generated candidate PcbLib; close canonical `DATALOGER_RevA.PcbDoc` WITHOUT saving the transient 129/129 staging; reopen `DATALOGER_RevA.PcbDoc` to restore verified 113/129 baseline; run v3; after PASS immediately `Design > Make PCB Library`; submit the regenerated PcbLib for final binary audit.

## CURRENT EXACT POINT — transient courtyard staging PASS 129/129; extract native PcbLib now — 2026-09-23

- `T24_All16_TransientCourtyards_ForMakeLib_v2.pas` ran successfully on canonical `DATALOGER_RevA.PcbDoc`.
- Script result confirmed: `PASS: 16 missing courtyards created IN MEMORY` and `129 / 129 components now have courtyard data`.
- Current PCB memory state contains all 16 previously missing courtyards. This is a transient staging state; do NOT save/close/reopen the PCB before library extraction.
- NEXT EXACT ACTION: dismiss the PASS dialog, then immediately use Altium native `Design > Make PCB Library` on the still-open `DATALOGER_RevA.PcbDoc`.
- Save the generated library under a temporary candidate name, recommended `Datalogger_RevA_Clean_T24_CANDIDATE.PcbLib`; do NOT overwrite canonical `Datalogger_RevA_Clean.PcbLib` yet.
- After generation, audit the candidate PcbLib for the 8 unique target footprints and verify persistent Top/Bottom Courtyard content before any replacement of the canonical library.

## CURRENT EXACT POINT — canonical PCB filename changed to DATALOGER_RevA.PcbDoc — 2026-09-23

- User created a backup of the previous board state and explicitly promoted `DATALOGER_RevA.PcbDoc` as the canonical working PCB filename from this point forward.
- Do not require or target `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc` anymore unless explicitly restoring/inspecting an older checkpoint.
- `T24_All16_TransientCourtyards_ForMakeLib_v1.pas` aborted safely because it was intentionally filename-locked to the old PENDING filename; no board change occurred.
- Replacement script: `AI_SCRIPTS/T24/T24_All16_TransientCourtyards_ForMakeLib_v2.pas`, entry `ApplyT24_All16_TransientCourtyards_ForMakeLib_v2`.
- v2 targets only `DATALOGER_RevA.PcbDoc`; all geometry, 129-component / 113-covered baseline guards, 64-track transient courtyard build, 129/129 postcheck, and Make PCB Library workflow remain unchanged.
- After v2 PASS: do NOT save/close/reopen the PCB before `Design > Make PCB Library`.

## CURRENT EXACT POINT — no-manual-drawing workaround selected: transient PcbDoc patch + native Make PCB Library — 2026-09-23

- User explicitly does not want manual courtyard drawing.
- Direct PcbLib DelphiScript mutation v1-v4 is abandoned because of ScriptingSystem.DLL crashes on AD 26.8.1.
- PcbDoc component-child mutation is proven to work in-memory in T24 (`Apply13` and ESD12 postchecks). Its only defect was persistence after PcbDoc Save/Reopen.
- New workaround uses that proven in-memory PcbDoc mutation only as a staging step, then immediately invokes Altium's native `Design > Make PCB Library` command to regenerate a persistent PcbLib from the active PCB. Altium documentation explicitly supports generating an exact working PcbLib from placed PCB footprints.
- New script: `AI_SCRIPTS/T24/T24_All16_TransientCourtyards_ForMakeLib_v1.pas`, entry `ApplyT24_All16_TransientCourtyards_ForMakeLib_v1`.
- Script requires the verified 129-component / 113-courtyard baseline, adds all 16 missing courtyards (64 component-owned M2/M4 tracks) in memory, with 0.05mm line width and outer boundary equal to audited PAD/Mechanical1 union. J_SD uses its audited pad envelope fallback.
- Expected script postcheck: 129/129 components have courtyard data IN MEMORY.
- CRITICAL: after PASS, do NOT save/close/reopen the PENDING PcbDoc before library extraction. Immediately run native `Design > Make PCB Library`; the generated PcbLib is the candidate persistent library. Then audit that generated PcbLib before replacing `Datalogger_RevA_Clean.PcbLib`.
- This path requires no manual footprint/rectangle drawing; only script execution plus the native Make PCB Library command.

## CURRENT EXACT POINT — fast native Courtyard path selected; use one Rectangle per unique footprint — 2026-09-23

- Recheck of project history found two successful PcbLib delta-builder runs on the SAME Altium Designer 26.8.1 Build 31: `T23_BT2_PCBLIB_DELTA_BUILDER_v0.1.0_REPORT.txt` and `T23_RESET_6X6_PCBLIB_DELTA_BUILDER_v0.1.0_REPORT.txt`.
- Those reports show real PcbLib mutations persisted successfully: BT2 library 37->38 footprints / 537->555 primitives (+18), RESET library 38->39 footprints / 555->569 primitives (+14), including a Mechanical2 courtyard on the reset footprint.
- Therefore the recent T24 crashes do NOT prove that Altium 26.8.1 cannot mutate PcbLib at all; they only prove the recent v1-v4 mutation path is unsafe. The original delta-builder source scripts are not present in the current repo, so do not reconstruct them from guesswork.
- Fast/safe completion path: use Altium native `Place > Rectangle` in the PCB Library Editor on `Top Courtyard`. Rectangle placement is supported natively in PcbLib and replaces four separate line placements with one closed object.
- Remaining scope is 8 unique source footprints, therefore only 8 native Rectangle objects are needed to cover all 16 missing-courtyard PCB instances.
- T24-approved boundary policy remains the audited PAD/Mechanical1 union, with Track Width 0.05 mm and no extra invented margin in this cleanup step. Component Clearance 10mil remains a separate board rule.
- Audited local rectangle sizes/centers (mm): `MAXIM_W16H2_SO16_90_0107` 11.45x10.60 @ center 0,0; `AOS_SOT23_AO3401A_3P` 3.00x3.30 @ 0,0; `GOSUN_PLS_2P54_1X5_THT` 12.80x2.64 @ 0,0; `WIRE_DRAIN_1P_D1P20_P2P40_THT` 2.50x2.50 @ 0,0; `ATOM_MR01A_01245_10P` 16.80x12.50 @ center 0,+5.10; `SHOUHAN_2P50_1X05_ZZMS_THT` 15.10x5.90 @ 0,0; `ST_SOT23_6L_USBLC6_6P` 3.60x2.60 @ 0,0; `MURATA_GRM21_0805_CAP_2P` 2.50x1.35 @ 0,0.
- After all 8 rectangles are saved in `Datalogger_RevA_Clean.PcbLib`, propagate to `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, then visually verify persistence and run Full Batch DRC.

## CURRENT EXACT POINT — latest PENDING PCB + snapshot re-audited; no actual <10mil physical-envelope collision found — 2026-09-23

- User-uploaded `DATALOGER_RevA_T24_Courtyard_PENDING(2).PcbDoc` is byte-identical to repo `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`: Git blob SHA `1dbf8d1a54ce2b165286154bcd9cc2432d360c5a`.
- Latest collision snapshot is `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`, generated 2026-09-23 00:25:29 from the same PENDING PCB state.
- Latest saved Full Batch DRC reports **0 violations**, including electrical clearance, shorts, unrouted nets, modified polygons, widths, hole rules, silk/mask, board clearance, and Component Clearance 10mil.
- Persistent courtyard metadata is still incomplete: **113 / 129 components** have component-owned M2/M4 courtyard data; 16 instances are missing courtyard primitives (`U_RTC`, `Q_SD`, `Q_OLED`, `J_SWD`, `J_SHIELD`, `J_NAV`, `D_EXT1/2/3`, `D_ESD`, `D_ESD1`, `D_ESD2`, `C_SENSOR_BULK`, `C_SD_MID`, `C_OLED_BULK`, `J_SD`).
- Independent recheck using each missing component's actual **PAD/Mechanical1 union envelope** (no artificial extra margin) against all persisted existing courtyard envelopes and against the other missing envelopes found **zero pairs below 10mil**.
- Nearest physical-envelope pairs: `D_ESD2` vs `C_SD_HF` = exactly **10.000 mil**; `D_ESD1` vs `C_SD_HF` = **10.905 mil**; `J_NAV` vs `D_NAV1` = **11.693 mil**; `C_SD_MID` vs `D_ESD2` = **12.244 mil**.
- Therefore the remaining courtyard issue is currently a **library/assembly-DRC metadata completeness problem**, not evidence of a copper/electrical fault or an actual component-body overlap in the current placement.
- Missing courtyards do not alter Gerber copper, solder mask, drill, routing, polygons, connectivity, BOM values, or normal electrical operation. Their practical risk is false-negative/weak automated assembly-clearance checking, 3D/mechanical interference checking, placement DFM, and future edits where a component can be moved too close without the intended component-clearance boundary.
- Because `D_ESD2` is exactly at the 10mil target using the audited physical envelope, it is the tightest placement and should not be moved closer without a fresh mechanical clearance check.
- PcbLib scripting remains DO NOT USE on Altium 26.8.1 due ScriptingSystem native crashes. Native/manual PcbLib courtyard cleanup is optional for release quality but recommended before declaring T24 library-quality closure.

## CURRENT EXACT POINT — stay on Altium 26.8.1; abandon PcbLib scripting; finish courtyards with native UI — 2026-09-23

- User chose to continue with the installed Altium Designer 26.8.1 Build 31 instead of spending time on an upgrade.
- PcbLib DelphiScript mutation is CLOSED as a failed path on this build: v1/v2/v3/v4 all produced native `ScriptingSystem.DLL` access violations or non-persistent results.
- Do not run the stale PcbLib mutation scripts again.
- Continue using only native Altium PcbLib editing for the remaining persistent courtyard corrections.
- Engineering scope remains the 8 unique source footprints that cover the 16 missing-courtyard PCB instances. After all 8 PcbLib footprints are corrected and saved, propagate them to `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, then run visual check + Full Batch DRC before any promotion of the PENDING PCB.
- Main PCB routing/polygon checkpoint remains unchanged by the scripting crashes.

## CURRENT EXACT POINT — PcbLib scripting root cause narrowed to Altium ScriptingSystem native crash — 2026-09-23

- `T24_CurrentFootprint_Courtyard_Repair_v4.pas` also crashes with the same native Access Violation address in `ScriptingSystem.DLL` (`00000001D0D1B837`, null-address read) seen with v2/v3.
- The repeated identical native crash survives removal of LibraryIterator mutation, component navigation, state-rebuild methods, and exception flow. Therefore the failure is no longer attributed to those script structures.
- Proven T23 scripts use the same `PCBServer.PreProcess -> PCBObjectFactory -> AddPCBObject -> PCBM_BoardRegisteration -> PostProcess` pattern successfully on PcbDoc. The crash occurs specifically when that family of operations is applied to PcbLib footprint child primitives in the user's current Altium build.
- Altium's official PCB API documents `GetCurrentPCBBoard` for PcbLib, `IPCB_Library.CurrentComponent`, `IPCB_LibComponent.AddPCBObject`, group iterators, and PCBServer registration as supported. Thus v4 is using documented interfaces; the native null dereference points to a ScriptingSystem implementation defect/regression or an internal PcbLib-state bug, not a DelphiScript parser error.
- Public evidence exists for the same class of `ScriptingSystem.DLL` access violation during scripted footprint/component creation, and Altium historical release notes include prior fixes for script-based library-loader access violations.
- Treat **all PcbLib mutation scripts v1/v2/v3/v4 as STALE / DO NOT RUN** in this Altium build. Do not save a PcbLib after a crash; reopen it from disk.
- Keep the engineering geometry/audit data from T24, but finish persistent courtyard creation through native Altium UI/library editing rather than scripted PcbLib mutation unless a different Altium build proves the API path stable.
- No change to the main PCB routing/polygon checkpoint is implied by this scripting crash.

## CURRENT EXACT POINT — v3 PcbLib crash; recovery switched to proven T23 transaction pattern — 2026-09-23

- `T24_PcbLib_MissingCourtyards_Apply_v3.pas` also caused an Access Violation in `ScriptingSystem.DLL`. Treat the crashed Altium/PcbLib session as invalid and do not save it.
- User explicitly requested preserving project continuity and reusing the proven successful script architecture.
- Recheck of successful T23 scripts (`Stage4H1`, `Stage5A`, `Stage6A`) shows the stable mutation pattern: all read-only iterators finish first; mutation uses one simple `PCBServer.PreProcess` / `PostProcess` transaction, `PCBObjectFactory`, owner `AddPCBObject`, `PCBM_BoardRegisteration`, then postcheck. No iterator traversal or page switching during mutation.
- Official Altium PCB API confirms `GetCurrentPCBBoard` is valid for either PcbDoc or PcbLib, and for a PcbLib the active footprint is `IPCB_Library.CurrentComponent`; `IPCB_LibComponent.AddPCBObject` is the supported way to add child primitives.
- New safe script: `AI_SCRIPTS/T24/T24_CurrentFootprint_Courtyard_Repair_v4.pas`.
- v4 operates ONLY on the currently displayed footprint in `Datalogger_RevA_Clean.PcbLib`; it does not use `LibraryIterator`, `SetBoardToComponentByName`, `GetComponentByName`, state rebuild methods, or exception flow.
- v4 has one entry: `ApplyT24_CurrentFootprint_Courtyard_v4`. It internally preflights footprint name, pad count, Mechanical1 count, audited envelope dimensions, and absence of existing M2/M4 courtyard before mutation.
- Run the same v4 procedure one footprint at a time for the 8 target source footprints, saving the PcbLib after each PASS. Only after all 8 pass should `Tools > Update PCB With All Footprints` be used.
- v1/v2/v3 PcbLib repair scripts are stale / DO NOT USE.

## CURRENT EXACT POINT — PcbLib v2 crashed ScriptingSystem; use direct-component v3 — 2026-09-23

- `T24_PcbLib_MissingCourtyards_Apply_v2.pas` compiled but caused an Access Violation in `ScriptingSystem.DLL` while operating on the PcbLib. User must close Altium without saving the PcbLib and reopen it from disk.
- No PCB document was intentionally modified by v2. Treat in-memory PcbLib state from the crashed session as invalid; do not save it.
- Likely unsafe pattern: mutating footprints while a `LibraryIterator` is active, combined with unnecessary group state rebuild calls.
- Official Altium PCB API provides direct `IPCB_Library.GetComponentByName` and `SetBoardToComponentByName`; v3 uses those instead of a LibraryIterator during mutation.
- v3 also removes `SetState_LayersUsedArray` and `SetState_XSizeYSize`, and uses no Raise/exception flow.
- Use only `AI_SCRIPTS/T24/T24_PcbLib_MissingCourtyards_Apply_v3.pas`, entry `ApplyT24_PcbLib_MissingCourtyards_v3`, after reopening `Datalogger_RevA_Clean.PcbLib` cleanly.
- v1 and v2 are stale / DO NOT USE.

## CURRENT EXACT POINT — PcbLib courtyard repair v1 parser failure; use parser-safe v2 — 2026-09-23

- `T24_PcbLib_MissingCourtyards_Apply_v1.pas` failed to compile in Altium with `Then expected` at the single-line `If ... Then Raise(...)` pattern. No script execution/mutation occurred.
- Root cause: DelphiScript parser compatibility. Previous known-good T24 scripts use `If ... Then Begin Raise('...'); End;`.
- v2 rewrites all single-line Raise statements with `Begin/End`, replaces `W Div 2` with explicit `MilsToCoord(0.984252)`, and splits the combined size guard into two parser-simple checks.
- Use only `AI_SCRIPTS/T24/T24_PcbLib_MissingCourtyards_Apply_v2.pas`, entry `ApplyT24_PcbLib_MissingCourtyards_v2`.
- v1 is stale / DO NOT USE.

## CURRENT EXACT POINT — root-cause fix moved to PcbLib; one persistent repair script ready — 2026-09-23

- Recheck resolved the apparent contradiction about courtyard size. For this project, T24 intentionally uses the missing-footprint boundary itself (PAD / Mechanical1 union) and keeps the separate board-level Component Clearance rule at 10 mil. Therefore do NOT add another 10 mil expansion inside the newly created missing courtyards; that would double-count clearance and recreate the 11 known conflicts.
- The transient PCB-child scripts (`T24_Courtyard_Step2A_Apply13_v2`, `T24_Courtyard_ESD12_Final_v1`) are not a release solution because their newly added child tracks do not persist correctly through Save/reload.
- Persistent fix is now at the SOURCE library: `AI_SCRIPTS/T24/T24_PcbLib_MissingCourtyards_Apply_v1.pas`.
- Script commit: `baf265d2179249c0ff82892ecbb1443289dca83f`.
- The script targets `Datalogger_RevA_Clean.PcbLib`, internally preflights, and modifies exactly 8 unique footprint families covering all 16 currently missing board instances:
  - `MAXIM_W16H2_SO16_90_0107`
  - `AOS_SOT23_AO3401A_3P`
  - `GOSUN_PLS_2P54_1X5_THT`
  - `WIRE_DRAIN_1P_D1P20_P2P40_THT`
  - `ATOM_MR01A_01245_10P`
  - `SHOUHAN_2P50_1X05_ZZMS_THT`
  - `ST_SOT23_6L_USBLC6_6P`
  - `MURATA_GRM21_0805_CAP_2P`
- It adds exactly 4 Mechanical2 tracks per footprint (32 tracks total), width 0.05 mm, with track centerlines inset by half-width so the OUTER boundary equals the audited PAD/M1 union exactly.
- `J_SD` uses its audited 12.5 x 16.8 mm pad envelope as a documented engineering fallback because the current project footprint lacks a complete Mechanical1 body outline; this is not claimed as a manufacturer-certified IPC courtyard.
- Official ST verification: USBLC6-2SC6 is SOT23-6L; ST publishes an official Altium Symbol/Footprint resource and datasheet footprint recommendation. This supports the project land pattern identity, but the T24 boundary policy remains the already-approved PAD/M1 union + external 10 mil rule.
- Exact next action: open `Datalogger_RevA_Clean.PcbLib` and run only `ApplyT24_PcbLib_MissingCourtyards_v1`. On PASS, save the PcbLib, then use `Tools > Update PCB With All Footprints` with Mechanical-layer primitives enabled (avoid unrelated primitive updates), return to the PENDING PCB, verify 129/129 courtyard coverage visually and with DRC, then Save/Snapshot/Git_Save.

## CURRENT EXACT POINT — persistent Courtyard strategy corrected; do NOT use pad-envelope-only courtyard — 2026-09-23

- The transient PCB-script method for adding missing courtyards is NOT persistent after Save; do not use `T24_Courtyard_Step2A_Apply13_v2`, `T24_Courtyard_ESD12_Final_v1`, or the ESD visibility repair as a release solution.
- Recheck against project geometry shows the previous proposed `D_ESD1/D_ESD2` courtyard of **3.60 x 2.60 mm** was merely the PAD envelope, not a proper assembly courtyard. That proposal is **RETRACTED / DO NOT USE**.
- Existing validated project courtyards consistently extend beyond pad envelopes (examples: 0603 pad 2.20 x 0.90 mm -> courtyard about 2.65 x 1.45 mm; 0805 pad 4.30 x 1.70 mm -> courtyard about 4.75 x 2.25 mm; SOT23-3 family also has explicit margin beyond pads).
- ST official USBLC6-2SC6 documentation identifies the device as SOT23-6L with package dimensions up to about 3.05 mm x 3.00 mm and ST publishes an official Altium Symbol/Footprint archive. Prefer checking/importing the official ST CAD footprint instead of inventing a courtyard.
- The 16 missing-courtyard board instances collapse to 8 unique footprints in `Datalogger_RevA_Clean.PcbLib`; persistent correction should be made in the PcbLib footprints and then propagated to the PCB.
- For `ST_SOT23_6L_USBLC6_6P`, do NOT draw a 3.60 x 2.60 mm courtyard. First inspect the official ST Altium model and reconcile it with the project courtyard convention. A project-style inferred courtyard would be materially larger and would expose real spacing conflicts around `D_ESD1/D_ESD2` vs `C_SD_HF`, so shrinking the courtyard merely to pass 10 mil is not acceptable.
- Next action: obtain/open the official ST `USBLC6-2SC6` Altium footprint (ST product page CAD Resources) and compare its courtyard/assembly geometry with `ST_SOT23_6L_USBLC6_6P` before editing the project library. No PCB routing/placement change until that comparison is complete.

## CURRENT EXACT POINT — baseline mismatch discovered before final ESD courtyard apply — 2026-09-22

- Attempted `PreflightT24_Courtyard_ESD12_Final_v1` aborted safely with: `Expected 126/129 courtyard-covered baseline. Nothing changed.`
- This means the live PCB no longer matches the assumed post-Apply13 state.
- Double-check against the latest saved collision snapshot shows only **113 component refs with M2/M4 component-owned primitives**; `D_ESD1`, `D_ESD2`, and `J_SD` are still absent, and the 13 prior Apply13 additions are not represented as persisted component-owned courtyards in that snapshot.
- Therefore DO NOT run the ESD12 Apply yet.
- Correct recovery path: rerun existing `T24_Courtyard_Step2A_Apply13_v2.pas` preflight on the current PENDING board. If it PASSes, rerun Apply13, Save the PENDING PCB, close/reopen Altium, then verify persistence with the already-existing `AuditT24_Apply13_PostCrash_v1` checker. Only after a verified 126/129 persisted state should `T24_Courtyard_ESD12_Final_v1` be used.
- No new diagnostic script is needed for this recovery.

## CURRENT EXACT POINT — final courtyard completion split: D_ESD1/D_ESD2 ready, J_SD still deferred — 2026-09-22

- Current saved PENDING baseline after polygon closeout: 129 components / 126 courtyard-covered / full Batch DRC clean.
- Remaining courtyard components: `D_ESD1`, `D_ESD2`, `J_SD`.
- Geometry recheck shows a safe controlled solution for the two ESD devices without moving routing:
  - `D_ESD1` final OUTER courtyard = pad envelope `7173.858 / 5761.417 / 7315.591 / 5863.779 mil`; nearest critical existing courtyard `C_SD_HF` is about 10.905 mil away.
  - `D_ESD2` final OUTER courtyard = pad envelope `7178.858 / 5533.819 / 7320.591 / 5636.181 mil`; nearest critical existing courtyard `C_SD_HF` is exactly 10.000 mil and `C_SD_MID` is about 11.26 mil away.
- To avoid the previous half-track-width overgrowth, the new 0.05 mm courtyard tracks use centerlines inset by half the track width so final OUTER bounds equal the audited pad envelopes.
- Prepared controlled script: `AI_SCRIPTS/T24/T24_Courtyard_ESD12_Final_v1.pas`.
- Script commit: `61ba0038ef61b5660bf05c03455159ecca69c3d8`.
- Run order: first `PreflightT24_Courtyard_ESD12_Final_v1`; only after PASS run `ApplyT24_Courtyard_ESD12_Final_v1`; then Full Batch DRC; do not save before clean DRC.
- Expected post-Apply state: **128/129 components** with courtyard data; only `J_SD` remains.
- `J_SD` is confirmed as Shenzhen Atom Tech `MR01A-01245` / JLCPCB `C55094511`, but the accessible public pages do not expose a usable dimensional body drawing. Do not invent its courtyard from incomplete Mechanical3 geometry. Keep `J_SD` deferred until the exact drawing is obtained.
- After J_SD is resolved, proceed to the separate yellow silkscreen-outline cleanup.

## CURRENT EXACT POINT — Courtyard Apply13 + polygon audit PASS / SAVED / GIT — 2026-09-22 23:34

- Working PCB remains `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`; original `DATALOGER_RevA.PcbDoc` has not been promoted/replaced yet.
- Apply13 v2 is present and saved: **126/129 components** now have M2/M4 courtyard data.
- Deferred courtyard targets remain: `D_ESD1`, `D_ESD2`, `J_SD`.
- Top GND polygon was inspected in Polygon Pour Manager and corrected so `Remove Islands Less Than = 2500 sq.mil` (matching the validated Bottom polygon threshold).
- Top polygon keeps `Remove Necks Less Than = 10 mil`, `Remove Dead Copper = enabled`, solid pour, and same-net pour-over behavior.
- `Repour All Polygons` completed after the threshold correction.
- Fresh full Batch DRC completed with **0 violations**.
- Current DRC report records a dedicated exception rule for `Q_OLED` vs `R_OLED_GATE` with horizontal gap `-1 mil`; the general 10 mil Component Clearance rule remains represented in the rule set and the previously problematic collision is no longer reported.
- Snapshot Exporter and `Git_Save.cmd` were run by the user after DRC PASS.
- GitHub checkpoint: `a9ff311034c4bda8d5068a4634e0d25d8629b5dd` (`Auto checkpoint 2026-09-22 23:34:27 | 9 file(s)`).
- The checkpoint contains the updated PENDING PCB, fresh DRC outputs, and refreshed board collision snapshot.
- Polygon stage is now **PASS / SAVED / CLOSED** for the current PENDING board.
- Exact next engineering task: resolve the three remaining courtyard cases `D_ESD1`, `D_ESD2`, and `J_SD`; after those, perform the separate yellow silkscreen-outline cleanup.

## CURRENT EXACT POINT — abandon legacy CollisionCheckMode scripting; replace rule in UI — 2026-09-22

- Apply13 v2 is present on `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`: 126/129 components have courtyard data.
- Fresh Batch DRC still reports exactly one Component Clearance collision: `Q_OLED` vs `R_OLED_GATE`.
- Focused audits proved `BoundingRectangleForSelection` matches M2/M4 courtyard for both components and the courtyard X-gap is 51.418 mil while the rule gap is 10 mil.
- `Check clearance by component boundary` was enabled manually in the Rules dialog, but the single collision remained.
- Attempt to change legacy `CollisionCheckMode` from 3 to `eFullCheck` by script failed postcheck; **do not use that script again** and do not save any change from that failed attempt.
- Next approach is UI-only and simpler: create a NEW Component Clearance rule with All/All, 10 mil horizontal, Specified 10 mil vertical, `Check clearance by component boundary` enabled, `Do not check components without 3D body` disabled; then disable the old `ComponentClearance` rule in the Component Clearance summary list. Do not delete the old rule yet.
- Reset Error Markers and rerun full Batch DRC. If clean, save the PENDING PCB and checkpoint. No more diagnostic scripts for this issue.

## CURRENT EXACT POINT — Altium access violation during rule-mode change — 2026-09-22

- After Apply13 v2 PASS and one remaining Q_OLED/R_OLED_GATE Component Clearance marker, user attempted the next rule-mode step and Altium raised an access violation in `ADVPCB.DLL`.
- Apply13 had not yet been saved, so current live unsaved state must be treated as uncertain after the crash.
- Do not save from the crashed process.
- Recovery plan: close Altium, reopen `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, then run the read-only `AuditT24_Apply13_PostCrash_v1`.
- Recovery audit script: `AI_SCRIPTS/T24/T24_Apply13_PostCrash_Audit_v1.pas`.
- Script commit: `ffe8aab5fce8d6e6cc4882e2e3bda007759ae442`.
- If report says 126/129 covered with 4 courtyard primitives on all 13 Apply13 targets, Apply13 survived. If 113/129, reopen baseline and re-run Apply13 only after preflight. Mixed state must not be continued.
- Do not retry the Component Clearance mode change until the post-crash board state is verified.

## CURRENT EXACT POINT — final Q_OLED clearance root cause narrowed — 2026-09-22

- Focused audit v2 on the live post-Apply13 PENDING board shows `BoundingRectangleForSelection` exactly matches the M2/M4 Courtyard for both `Q_OLED` and `R_OLED_GATE`.
- Selection/Courtyard axis gap is **51.418 mil** while the ComponentClearance horizontal gap is **10 mil**; therefore the remaining DRC marker is not caused by actual courtyard separation.
- Rule state exported live: `CollisionCheckMode=3`, Scope1=All, Scope2=All, Gap=10 mil, VerticalGap=10 mil.
- Altium API documents collision mode 3 as **Component Body Mode**. Current project intent is courtyard/component-boundary clearance.
- Do not delete Q_OLED silk, move either component, shrink courtyards, or relax the 10 mil gap.
- Exact next action: in Design Rules -> Placement -> Component Clearance, enable **Check clearance by component boundary** while keeping 10 mil and All/All unchanged; then rerun full Batch DRC. Do not Save until DRC is clean.

## CURRENT EXACT POINT — Apply13 v2 PASS; one Component Clearance remains — 2026-09-22

- `PreflightT24_Courtyard_Step2A_Apply13_v2` passed on `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`.
- `ApplyT24_Courtyard_Step2A_Apply13_v2` then completed successfully: **13 courtyards / 52 tracks**, resulting in **126/129 components with courtyard data**.
- Deferred by design: `D_ESD1`, `D_ESD2`, `J_SD`.
- User ran a fresh full Batch DRC after Apply. Exactly **one Component Clearance violation** remains: `Q_OLED` vs `R_OLED_GATE`.
- Do not Save, move components, or relax Component Clearance yet.
- Prior geometry report shows the old component bounding boxes overlap because `Q_OLED` has a remote Top Overlay primitive, while the intended courtyard geometry is expected to be separated by more than 10 mil. This must now be verified on the live post-Apply board before any fix.
- Focused READ-ONLY audit prepared: `AI_SCRIPTS/T24/T24_QOLED_ROLEDGATE_Audit_v1.pas`.
- Audit script commit: `0697c203ce8328ff1342ffffee4e7cb786a7cb3a`.
- Exact next action: run only `AuditT24_QOLED_ROLEDGATE_v1` and return `T24_QOLED_ROLEDGATE_Audit_v1.txt`. No Save.

## Git checkpoint — 2026-09-22 20:38 +03:30

Git AutoSave recovery completed successfully.
- `Git_Save.ps1` / launcher upgraded to **v2.5.1** to avoid raw quoted filenames in native `git commit -m` arguments.
- recovery checkpoint: `e9957b8f3b56981deb7769282e02ef1ac30f8b95`;
- `HEAD`, `localbackup/main`, and `github/main` were user-confirmed aligned at the checkpoint;
- six current T24 working artifacts were committed, including `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, DRC outputs, and the existing Step2 preflight reports.
- This checkpoint records the current experimental PENDING PCB; it does **not** promote it over the original main PCB.
- Exact engineering next action is unchanged: run **only** `PreflightT24_Courtyard_Step2A_Apply13_v2`. Do not Apply and do not Save after that preflight until its report is reviewed.

## Git checkpoint — 2026-09-22

Registered in the private repository after the T24 Step2 parser recovery:
- current PCB remains `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`; no PCB Save is confirmed from the failed compile attempts;
- Step2A baseline and collision preflight reports are recorded;
- latest parser-compatible candidate is `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v2.pas` with commit `80a52260bc3dbd0ef661ef2c4e4e7c0aef335a6c`;
- concise new-chat handoff is `AI_CONTINUITY/PASTE_THIS_INTO_NEW_CHAT_T24_STEP2.txt` with commit `05da0e5fb3f7432f637ead19bd387bef2fc7d340`;
- next execution remains Preflight only: `PreflightT24_Courtyard_Step2A_Apply13_v2`.


## CURRENT EXACT POINT — Apply13 v2 second parser fix, 2026-09-22

User attempted `T24_Courtyard_Step2A_Apply13_v2.pas`. Altium then reported `Error in declaration block` at the postcheck function. Cause identified: local variable `OR` conflicts with the reserved DelphiScript logical operator `Or`. Renamed it to `ORight`.

Use the refreshed same-named v2 file from GitHub or the new download supplied by this session. New commit: `80a52260bc3dbd0ef661ef2c4e4e7c0aef335a6c`. The preflight entry remains `PreflightT24_Courtyard_Step2A_Apply13_v2`. No PCB modification or Save is confirmed from this parser-error attempt.


## CURRENT EXACT POINT — Apply13 parser fix, 2026-09-22

User attempted the first Apply13 script and Altium reported `Else expected` while compiling. Root cause identified: DelphiScript does not support Delphi `Exception.Create`; it requires textual `Raise('...')`. The corrected parser-compatible script is:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v2.pas`
- commit `1ad86ce5586c3d316604813ccf835a00ef583da4`
- entry `PreflightT24_Courtyard_Step2A_Apply13_v2`; Apply entry remains `ApplyT24_Courtyard_Step2A_Apply13_v2` and must wait for preflight review.
The prior v1 path was updated too, but use v2 to avoid stale local copies. No PCB change or Save is confirmed from the parser-error attempt.


## CURRENT EXACT POINT — Collision preflight complete; conservative 13-target plan, 2026-09-22

User ran `PreflightT24_Courtyard_Step2A_Collision_v1` on the PENDING board. Output reports 11 potential AABB hits under 10 mil. The report is read-only and is not DRC PASS. Confirmed pairs:
- candidate/candidate: Q_OLED/C_OLED_BULK = 3.464 mil; D_ESD2/C_SD_MID = overlap;
- candidate/existing: Q_SD with Q_SD_DRV and C_SD_BULK1/2; Q_OLED with Q_OLED_DRV; J_NAV with D_NAV1; D_ESD2/D_ESD1 with C_SD_HF; C_SENSOR_BULK with C_SENSOR_HF; C_OLED_BULK with C_OLED_HF.

Engineering disposition for the next controlled step: the previous `PAD/M1 union + 10 mil` candidate was overconservative because the ComponentClearance rule already enforces 10 mil between courtyard boundaries. A revised candidate uses the audited PAD/M1 union itself, with 0.05 mm track width, and rechecks all 13 non-border targets. Static screening with the line half-width leaves no <10 mil AABB hits for those 13. `D_ESD1` and `D_ESD2` remain deferred because both border C_SD_HF at/under the 10 mil limit; `J_SD` remains deferred pending exact MR01A-01245 body drawing. This is a geometry disposition for a controlled test, not a blanket approval.

Prepared script:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v1.pas`
- commit `5606ce0a174865fb13d5228c7079c061c2c1f323`
- entry `PreflightT24_Courtyard_Step2A_Apply13_v1`, then (only after separate confirmation) `ApplyT24_Courtyard_Step2A_Apply13_v1`;
- adds 13 rectangles / 52 tracks, union-only geometry; baseline guards 129 components / 113 courtyard-covered; expected post-state 126/129 covered.

NEXT: run only `PreflightT24_Courtyard_Step2A_Apply13_v1` on PENDING and return `T24_Courtyard_Step2A_Apply13_Preflight_v1.txt`. Do not Apply or Save yet. After PASS, run Apply, then full Batch DRC before any Save. Silk and D_ESD1/D_ESD2/J_SD remain pending.


## CURRENT EXACT POINT — Step2A baseline preflight PASS, collision gate pending, 2026-09-22

User ran `PreflightT24_Courtyard_Step2A_v2` on `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`. Result: **BASELINE PASS ONLY**; 129 components, 113 already courtyard-covered, 15 targets verified; no PCB change. Output: `T24_Courtyard_Step2A_Preflight_v2.txt`.

The report is not a clearance PASS. Static geometry screening found candidate rectangles that must be checked before Apply. Candidate/candidate pairs: `Q_OLED` / `C_OLED_BULK` gap about 3.464 mil; `D_ESD2` / `C_SD_MID` overlap. Candidate-to-existing courtyard AABB screening also finds several target bounds under 10 mil from existing courtyards, including Q_SD vs C_SD_BULK1/2, Q_OLED vs Q_OLED_DRV, J_NAV vs D_NAV1, D_ESD2/D_ESD1 vs C_SD_HF, and C_SENSOR_BULK vs C_SENSOR_HF. These are screening results, not final geometric DRC results, but they block a blind 15-target Apply.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Collision_Preflight_v1.pas`
- commit `42159f53090f958183f6275227c0f840398d7095`
- entry: `PreflightT24_Courtyard_Step2A_Collision_v1`
- output: `T24_Courtyard_Step2A_Collision_Preflight_v1.txt`
- checks the live PENDING board, M2/M4 pair, baseline counts, target-to-target candidate rectangles and target-to-existing courtyard AABB gaps; read-only.

NEXT: run only `PreflightT24_Courtyard_Step2A_Collision_v1` and return the TXT. Do not run any Step2A Apply script yet. No PCB Save. After the live collision report, disposition each hit as body/footprint geometry or real placement clearance before adding any courtyard. J_SD body geometry and yellow silkscreen remain pending.


## CURRENT EXACT POINT — Step2A parser recovery, 2026-09-22

User screenshot reports `Program name expected` while attempting Step2A v1. No successful preflight or Apply is confirmed. Exact parser cause is NOT established by the screenshot.
Use `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Preflight_v2.pas`, entry `PreflightT24_Courtyard_Step2A_v2`, on the PENDING PCB. This read-only rewrite removes arrays, prefixes helper names (including Near), and removes the Apply code from this diagnostic file. All 15 expected geometry tuples and baseline guards are preserved. Static checks passed; live Altium compile/execution is still unverified.
NEXT: user runs v2 preflight and returns `T24_Courtyard_Step2A_Preflight_v2.txt` or the exact error. Do not run v1 Apply. Candidate clearance conflicts, J_SD body drawing and yellow silkscreen outlines remain unresolved. No PCB change/save is requested by this recovery step.


Last continuity update: 2026-09-22 — Courtyard M2/M4 confirmed; By Layer active after restart; PENDING copy has one reported Component Clearance violation; Step2 read-only geometry preflight ready.


## Latest Step2 planning update — 2026-09-22
User supplied T24_Step2_Geometry_Preflight_v1.txt: 17/17 target measurements complete, on PENDING. This is data completeness, not DRC PASS.
Prepared AI_SCRIPTS/T24/T24_Courtyard_Step2A_v1.pas (not executed in Altium).
NEXT: run ONLY PreflightT24_Courtyard_Step2A_v1 and return T24_Courtyard_Step2A_Preflight_v1.txt. Do not Apply yet.
Candidate geometry: 15 missing courtyards, pad/M1 envelope union expanded by 10 mil each side; 60 component-owned tracks, 0.05 mm width, M4 for U_RTC and M2 for other 14. Engineering allowance, not a claim of IPC-certified envelopes.
J_SHIELD uses solder-land envelope; wire/strain-relief envelope still requires review.
J_SD deferred: no M1/body; M3 has two internal rectangles, cannot serve as full package courtyard. Exact MR01A-01245 drawing still needed. A web PDF found by search was a different manufacturer's drawing and was NOT used.
Known candidate issues: C_SD_MID / D_ESD2 rectangles overlap; C_OLED_BULK / Q_OLED gap about 3.464 mil (<10 mil rule). Existing neighbour courtyards also need checking. Do not shrink boundaries or relax rule merely to hide violations.
Q_OLED has remote Top Overlay fill at x=5580.444..5600.444 mil; its pad/M1 left bound is 5650.945 mil, while R_OLED_GATE courtyard right centerline is 5597.559 mil. This supports a fallback-boundary artifact explanation for current violation; it is not a final physical fit certification.
Silk inventory received for all 129 components. Silk repair remains pending and is not included in Step2A.
The candidate script has guards for PENDING filename, M2/M4 pair, 129 total/113 courtyard-bearing components, target positions/sides/rotations, pad and M1 counts/bounds, and no existing target courtyard. Postcheck expects 60 tracks/4 per target. Static checks only; live Altium execution remains unverified.

## Latest continuation — 2026-09-22 (supersedes older next-action blocks)

- User screenshot verified Top M2 / Bottom M4 pair has Layer Type Courtyard.
- PCB.ComponentSelection was 2 (By Graphic). User changed to 1 (By Layer).
- Altium required restart. User saved a separate copy:
  `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, then restarted and ran DRC on that copy.
- Latest screenshot shows one Component Clearance violation: Q_OLED versus R_OLED_GATE, collision <10 mil; previous list had 21.
- This is not final DRC PASS or fabrication acceptance. Sixteen components still lack courtyard geometry.
- PENDING is the current experimental candidate; original main PCB has not been replaced by this session.
- User uploaded PENDING for direct inspection. CFB parsing found 129 components, no ComponentBodies6 data, 440 M2 tracks and 12 M4 tracks. Q_OLED has M1 outline but no M2 tracks. J_SD has M3 geometry; J_SHIELD has no mechanical track outline.
- User also requests missing yellow silkscreen outlines. Audit Top/Bottom Overlay separately from courtyard; preserve RefDes/polarity and mask clearance. A full closed silk rectangle is not mandatory.
- Do not infer real body collision solely from the remaining message, or infer correct physical clearance solely from disappearing messages.

Exact next action:
1. Keep PENDING active in Altium.
2. Run `PreflightT24_Step2_Geometry_v1` from `AI_SCRIPTS/T24/T24_Step2_Geometry_Preflight_v1.pas`.
3. Upload `T24_Step2_Geometry_Preflight_v1.txt`.
4. Script is READ ONLY, derived from the previously used mechanical-envelope exporter; includes 16 missing components plus R_OLED_GATE, M1/M2/M3/M4, both overlays, individual primitive bounds, track centerlines, and board-wide silk track/arc inventory. Text is excluded from measured envelopes.
5. It has not been executed in Altium by the assistant. DATA COMPLETE means coverage only, not geometry approval or DRC PASS.
6. Use live report plus source package geometry to plan controlled courtyard additions and silk repairs. No Apply script is approved yet. Do not shrink courtyard or loosen 10 mil rule to silence errors.
7. Retain saved PENDING recovery copy; do not promote it over the original PCB until validated.

## Repository / backup state

- Authoritative repository: `mohammadhpp/Datalogger-RevA` (private), branch `main`.
- Local working repo: `C:\#MHP FILES\DataLoger`.
- Local bare backup remote: `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
- Online remote: `github` -> `https://github.com/mohammadhpp/Datalogger-RevA.git`.
- Standard save/sync workflow remains `Git_Save.cmd` / v2.5 discipline.
- Do not auto-merge Altium binary files if histories diverge.

## Authoritative final T23 checkpoint

Latest verified post-pour checkpoint:

- Git commit: `a1e4193edacf4f03da623616e470258cd1dc147e`
- Commit message:
  `Auto checkpoint 2026-09-20 21:12:25 | 2 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc`
- PCB file: `DATALOGER_RevA.PcbDoc`
- PCB blob: `14ab76655a6c750f09f39ef1157b04ccf58efcdd`
- Full collision snapshot: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`
- Snapshot blob: `4dbd82e0f34303c07a594904a92663cfe4926577`
- Snapshot exporter: `T23_AI_FullBoard_Snapshot_Exporter_v1_4_2`
- Snapshot generated: `2026-09-20 21:12:08`

## CURRENT EXACT POINT

### Major task

**T24 — Board release / manufacturing-prep refinements — ACTIVE**

**T24 Stage1 — Top silkscreen branding — PASS / SAVED**

**T24 Stage2A — Top GND polygon — PASS / SAVED / CLOSED**

**Current exact point: M2/M4 Courtyard type CONFIRMED; PCB.ComponentSelection=1 applied after restart; active candidate is DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc; Step2 geometry report received; run ONLY Step2A baseline preflight, Apply held for candidate-clearance review.**

T23 remains formally CLOSED / PASS and must not be casually reopened.

The 2-layer PCB major signal/power routing, GND fanout, final Bottom Layer GND polygon, and full post-pour DRC have been completed.

### Final routing / GND closeout

- All previously remaining Top-side GND groups were given deliberate Bottom-layer access before the polygon stage.
- Final custom NAV fix:
  - `D_NAV1.2` GND escape completed.
  - `NetD_NAV1_3` upper via moved to `(7159.842,6780)`.
  - Bottom reroute retained continuity through:
    - `(7210,6660) -> (7180,6690)`
    - `(7180,6690) -> (7180,6760)`
    - `(7180,6760) -> (7159.842,6780)`
  - Final GND via for `D_NAV1.2` at `(7210,6720)`.
- Before polygon creation, verified Top-only GND groups = **0**.

### Stage9A — Bottom GND polygon — PASS / SAVED

- One polygon created on **Bottom Layer**.
- Polygon net: **GND**.
- Polygon geometry copied from the live Altium `BoardOutline`, not from a guessed hard-coded rectangle.
- BoardOutline point count copied: **8**.
- Final snapshot polygon metadata:
  - polygon count = **1**
  - `NET = GND`
  - `LAYER = Bottom Layer`
  - `POURED = 1`
  - point count = **8**
  - bounding box:
    - left `3937.008 mil`
    - bottom `3937.008 mil`
    - right `7874.016 mil`
    - top `7086.614 mil`
- Final GND object counts:
  - **117 GND tracks**
  - **46 GND vias**
- Polygon creation did not change these track/via counts.

### Final validation

User ran a full Altium Design Rule Verification after the Bottom GND polygon was poured.

Final DRC result shown in Altium:
- **Warnings: 0**
- **Rule Violations: 0**

Therefore the old pre-polygon GND Net Antennae are no longer an accepted outstanding condition. The saved post-pour PCB is the new clean baseline.

## T24 Stage1 — Top silkscreen branding — PASS / SAVED

User approved adding a monochrome branding mark in the intentionally empty lower-left board area.

Final branding content:
- approved chibi portrait logo
- line 1: `SANAT NEGAR`
- line 2: `M.PAHLAVIAN`

Placement / physical implementation:
- Layer: **Top Overlay**
- nominal placement rectangle used by the script:
  - X = `4910 .. 5390 mil`
  - Y = `4360 .. 4820 mil`
- actual occupied artwork bounds in the saved snapshot:
  - left = `4934 mil`
  - bottom = `4364 mil`
  - right = `5362 mil`
  - top = `4816 mil`
- implementation: **964 Top Overlay fill runs**
- copper, pads, vias, routing, and GND polygon were not intentionally modified by the logo operation.

Validation:
- user visually approved the placed logo.
- user reported **DRC OK** after placement.
- final saved Git checkpoint containing the logo:
  - commit: `43306bfd199b10555d7fa2f5f45a8550b8363720`
  - message: `Auto checkpoint 2026-09-20 23:46:46 | 3 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc, DATALOGER_RevA_old.PcbDoc`
  - current PCB blob: `d0693aa37fb28879d4554db0c9037ccb7e666de2`
  - preserved pre-logo/old PCB copy added as `DATALOGER_RevA_old.PcbDoc`
    with blob `14ab76655a6c750f09f39ef1157b04ccf58efcdd`.

Logo-script history:
- v1.1 successfully created the logo, but its final `PCB:Zoom` redraw call left Altium with an active command, which blocked normal Save.
- the user safely preserved the modified PCB using Save Copy, closed Altium, restored the logo-bearing file as `DATALOGER_RevA.PcbDoc`, reopened it, and then saved normally.
- v1.2 is now the preferred script for any future reproduction:
  `AI_SCRIPTS/T24/T24_Stage1_TopSilk_Logo_v1_2.pas`
- v1.2 removes `RunProcess('PCB:Zoom')` entirely and must be preferred over v1.1.
- do **not** rerun the logo script on the current PCB; the logo already exists.

Current authoritative post-logo snapshot:
- exporter: **v1.4.2**
- Git commit: `c4d4ded070971ace30be2028eb9268d0daf515ca`
- snapshot blob: `67dd30455b10e159c27a4e68eaa3f9784a9f8735`
- generated: `2026-09-20 23:51:25`
- verified counts:
  - **117 GND tracks**
  - **46 GND vias**
  - **1 poured Bottom Layer GND polygon**
  - **964 Top Overlay logo fills**
- polygon metadata:
  - `NET = GND`
  - `LAYER = Bottom Layer`
  - `POURED = 1`
  - `POINT_COUNT = 8`
- saved logo occupied bounds remain:
  - X = `4934 .. 5362 mil`
  - Y = `4364 .. 4816 mil`

This v1.4.2 snapshot supersedes the temporary v1.3.2 post-logo snapshot caveat.

## T24 Stage2A — Top GND polygon — PASS / SAVED / CLOSED

A controlled solid **Top Layer GND polygon** was added after Stage1 branding.

Implementation:
- Script: `AI_SCRIPTS/T24/T24_Stage2A_Top_GND_Polygon_v1.pas`
- Script commit: `fb01c1fbdfe54c3a31568136ce8c4f10aa8a36ef`
- Polygon net: **GND**
- Layer: **Top Layer**
- Geometry copied from the live 8-point BoardOutline.
- Bottom GND polygon and completed T23 routing were not intentionally changed.
- No stitching vias were added in Stage2A.

Authoritative saved Stage2A checkpoint:
- Git commit: `c7c57171ca952ee28726ef206b83eb5daaae330e`
- Commit message:
  `Auto checkpoint 2026-09-21 00:18:04 | 2 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc`
- Snapshot exporter: **v1.4.2**
- Snapshot generated: **2026-09-21 00:17:46**
- Snapshot verifies:
  - **2 poured GND polygons total**
  - **1 Bottom Layer GND polygon**
  - **1 Top Layer GND polygon**
  - both polygons have **8 points**
  - both use the same board bounds
  - **117 GND tracks**
  - **46 GND vias**

Validation:
- User ran full Altium DRC on the saved post-Stage2A PCB.
- User reported **DRC OK** on 2026-09-21.
- Stage2A is therefore formally **PASS / SAVED / CLOSED**.

### Current exact continuation point

Proceed to **T24 Stage2B planning** from the post-Stage2A v1.4.2 snapshot.
Do not rerun Stage2A.
Do not move existing T23 copper merely for cosmetic reasons.
Any new GND stitching vias must be planned against the current Top/Bottom poured copper and the full obstacle snapshot, then followed by polygon repour, full DRC, snapshot refresh, and Git checkpoint.

## T24 Top GND polygon — TRIPLE EXPERT REVIEW COMPLETE / KEEP

Authoritative current review:
- `AI_CONTINUITY/T24_TOP_GND_TRIPLE_EXPERT_REVIEW.md`
- review commit: `d4ab8897ffce69440d39219af3d829ddc376b836`

Final decision:
- **KEEP the existing Top Layer GND polygon.**
- The earlier single-pass recommendation to remove it is superseded.
- `AI_SCRIPTS/T24/T24_Remove_Top_GND_Polygon_DFM_v1.pas` is **OBSOLETE / DO NOT RUN**.
- The prior audit `AI_CONTINUITY/T24_TOP_GND_POLYGON_DFM_AUDIT.md` is marked superseded.

Key corrected finding:
- the 20 Top REGION records do not by themselves mean 20 bad islands; Altium solid polygon pours are represented by REGION primitives;
- snapshot review did not identify a clearly unanchored Top copper region;
- every Top REGION bounding area overlaps at least one GND pad or GND via;
- Stage2A Top polygon remains DRC-clean by user confirmation.

Three independent votes:
1. EMC / SI / PI: KEEP — additional grounded surface copper is electrically useful on this routed 2-layer board and controlled stitching improves the vertical GND connection.
2. DFM / Arya Madar: KEEP — removing the polygon does not remove the pre-existing sub-0.2 mm copper geometries or 0.30 mm drills that dominate the manufacturer's cost class. Verify thermal-relief behavior for manually soldered GND pads before release.
3. Reliability / change control: KEEP — no concrete defect has been demonstrated in the already saved, DRC-clean Top polygon; late deletion would be an unnecessary regression risk.

Exact next gate:
- DO NOT run the removal script.
- Stage2B v2 is again eligible to proceed.
- First run only `PreflightT24_Stage2B_GND_Stitching_v2`.
- Apply only after live preflight PASS.
- After Apply: Repour All Polygons → FULL DRC → save/snapshot/Git only if clean.
- Before final fabrication release, audit Polygon Connect Style / thermal relief for manual solderability.

## T24 Polygon Connect / Thermal Relief — DIRECT PCBDOC AUDIT COMPLETE

Authoritative audit:
- `AI_CONTINUITY/T24_DIRECT_PCBDOC_THERMAL_AUDIT.md`
- audit commit: `e43655fd089042323f5de0ac2031c2c86c696c23`
- uploaded/current PcbDoc Git blob verified exactly: `16f5576c1882a60a69a03b55c5456104be938911`

Direct Rules6 result:
- exactly one enabled `PolygonConnect` rule;
- Scope: `All`;
- Connect style: **Relief**;
- **4 spokes**;
- spoke width **10 mil**;
- air gap **10 mil**;
- angle **90°**.

Direct PadViaLibraryCache result:
- 48 templates total = 46 pad + 2 via templates;
- all 48 use **Relief / 10 mil air gap / 10 mil conductor / 4 entries / 90°**;
- zero `Direct` and zero `No Connect` textual connect-style records were found in the current PcbDoc.

Direct Polygons6 result:
- exactly 2 polygons;
- both are net index 71 = **GND**;
- Bottom: Solid / PourOver / RemoveDead / RemoveIslands; RemoveNarrowNecks=FALSE;
- Top: Solid / PourOver / RemoveDead / RemoveIslands / RemoveNarrowNecks=TRUE at 10 mil;
- both IgnoreViolations=FALSE.

Final thermal decision:
- component pads: **KEEP Relief** for manual solderability;
- Top GND polygon: **KEEP**;
- Bottom GND polygon: **KEEP**;
- GND vias: current global rule also makes routed vias Relief; for deliberate plane stitching, use a more-specific higher-priority Direct Connect rule for GND vias.

Required rule before Stage2B:
- Plane » Polygon Connect Style
- Scope: `IsVia AND InNet('GND')`
- Connect Style: **Direct Connect**
- Priority above the general `PolygonConnect` Relief rule.

Validation after rule change:
1. Repour All Polygons.
2. FULL DRC.
3. Do not save on any new violation.
4. If DRC clean: save PCB -> Snapshot Exporter v1.4.2 -> Git_Save.cmd.
5. Then run Stage2B v2 preflight/apply.

The previously prepared read-only script remains optional because the current PcbDoc was parsed directly and the rule values are now known.

## T24 GND-via Direct PolygonConnect rule — SCRIPT READY / NOT YET APPLIED

v1 Apply attempt aborted safely because `PCBObjectFactory(eRuleObject,...)` returned Nil; no rule or geometry was added. v1 is superseded and MUST NOT be rerun.

Prepared corrected controlled script:
- `AI_SCRIPTS/T24/T24_GND_Via_Direct_Rule_v2.pas`
- v2 commit: `15a00556d25bdb03deb9c346862f62cbcc50fcd9`
- v2 blob: `b38bed03e7f0548f05be0362925a58c3bba21cab`

Entry points:
- `PreflightT24_GND_Via_Direct_Rule_v2`
- `ApplyT24_GND_Via_Direct_Rule_v2`

New rule:
- name: `PolygonConnect_GND_Via_Direct`
- type: Polygon Connect Style
- scope: `IsVia AND InNet('GND')`
- style: **Direct Connect**
- expected new-rule priority: **1** (highest)
- existing general `PolygonConnect` Relief rule remains present and moves to lower priority.

v2 fix:
- uses documented `PCBServer.PCBRuleFactory(eRule_PolygonConnectStyle)` instead of `PCBObjectFactory` for rule creation.

Safety / validation:
- preflight requires current exact baseline: 42 rules / 1 PolygonConnect / 180 total vias / 46 GND vias / 2 GND polygons;
- existing general rule must be enabled Relief / Scope All / 10mil spoke / 4 entries;
- Apply adds only one rule; no routing/via/polygon geometry changes;
- post-apply expects 43 total rules and exactly 2 PolygonConnect rules;
- verifies new rule priority=1 and general rule lower priority;
- tests scope against real board objects:
  - GND via MUST match;
  - non-GND via MUST NOT match;
  - GND pad MUST NOT match;
- if any post-check fails: **DO NOT SAVE; one Ctrl+Z rolls back**.

Exact next action:
1. sync local repo with normal `Git_Save.cmd`;
2. open `AI_SCRIPTS/T24/T24_GND_Via_Direct_Rule_v2.pas`;
3. run **only** `PreflightT24_GND_Via_Direct_Rule_v2`;
4. expected: `PREFLIGHT PASS - T24 GND VIA DIRECT RULE v2`;
5. report the result before Apply;
6. after Apply success: **Repour All Polygons → FULL DRC**;
7. do not save until DRC is clean;
8. after DRC PASS: save PCB → Snapshot Exporter v1.4.2 → `Git_Save.cmd`;
9. only then continue to Stage2B v2.

## T24 expanded Batch DRC — OLD BASELINE VIOLATIONS EXPOSED

After GND-via Direct rule Apply and polygon repour, the user enabled a broader Batch DRC set. Result:
- 2 `Routing Via Style Violation` entries;
- multiple `Component Clearance Constraint Violation` entries.

The two RoutingViaStyle violations are NOT caused by the new PolygonConnect rule:
- `VIN_MUX` via at `(4480,5950)`: 27.559 mil diameter / 11.811 mil hole;
- `VIN_MUX` via at `(5235,5830)`: 27.559 mil diameter / 11.811 mil hole.
Both are present in the saved pre-change snapshot and therefore pre-existing.

Direct current PcbDoc Rules6 audit shows:
- `RoutingVias` rule is Scope=All;
- Min/Preferred/Max diameter are all fixed at **23.622 mil**;
- Min/Preferred/Max hole are all fixed at **11.811 mil**.
Therefore the two existing 27.559-mil vias violate the old overly-narrow rule.

The same old rule would also reject the planned Stage2B vias at 31.496 / 17.717 mil.

Prepared controlled rule-range update:
- `AI_SCRIPTS/T24/T24_RoutingViaStyle_Range_v1.pas`
- commit: `be769502aa9f3ea4815f9dbc442443944a526233`
- changes RULE ONLY; no via geometry;
- new diameter allowed range: 23.622..31.496 mil (preferred 23.622);
- new hole allowed range: 11.811..17.717 mil (preferred 11.811).

Exact next action:
1. keep current PCB open; do not save yet;
2. run only `PreflightT24_RoutingViaStyle_Range_v1`;
3. if PASS, run `ApplyT24_RoutingViaStyle_Range_v1`;
4. rerun Batch DRC;
5. the ComponentClearance violations must then be audited separately before formal release acceptance.

ComponentClearance note:
- current PcbDoc rule is Scope All/All, Gap=10mil, CollisionCheckMode=3;
- these violations were hidden previously because Batch checking for Component Clearance had not been enabled;
- component placement was not changed by the GND-via Direct rule or polygon repour.

## T24 Expanded Batch DRC — ROOT-CAUSE STATUS

After GND-via Direct PolygonConnect v2 Apply + Repour, expanded Batch DRC showed:
- 2 × Routing Via Style violations;
- legacy Component Clearance violations that had not been part of the earlier Batch set.

The two Routing Via Style violations are both pre-existing VIN_MUX vias:
- (4480,5950) mil = 27.559 / 11.811 mil = 0.70 / 0.30 mm
- (5235,5830) mil = 27.559 / 11.811 mil = 0.70 / 0.30 mm

Snapshot comparison proves:
- 178/180 existing vias use the project standard 0.60 / 0.30 mm;
- all other audited power-net vias (BAT_FUSED, BAT_SW, USB_VBUS_PROT, 3V3_SYS) use 0.60 / 0.30 mm;
- the two VIN_MUX vias are the only 0.70 / 0.30 mm outliers;
- their drill remains 0.30 mm, so the barrel geometry is the same as the project standard.

Decision:
- DO NOT widen the generic RoutingVias rule merely to silence these violations.
- `T24_RoutingViaStyle_Range_v1.pas` is **OBSOLETE / DO NOT RUN**.
- Normalize the two actual via-pad outliers to the project standard.

Controlled fix:
- `AI_SCRIPTS/T24/T24_Normalize_VIN_MUX_Vias_v1.pas`
- commit: `72fda53b5a79b3fd994848f4ea467705a13c549c`
- entry points:
  - `PreflightT24_Normalize_VIN_MUX_Vias_v1`
  - `ApplyT24_Normalize_VIN_MUX_Vias_v1`
- target: change Size only from 27.559 mil to 23.622 mil on exactly the two VIN_MUX vias;
- HoleSize stays 11.811 mil;
- coordinates, net, layer span and routing stay unchanged.

After Apply:
- rerun Batch DRC;
- do not save until Component Clearance violations are separately dispositioned.

Stage2B remains paused. Its planned via geometry must be revisited after current DRC cleanup; the earlier 0.80/0.45 mm choice is not automatically carried forward.

## T24 Current DRC disposition — 21 Component Clearance only

Latest user-confirmed live sequence:
- `PolygonConnect_GND_Via_Direct` v2 Apply COMPLETE / scope self-test PASS.
- Repour All Polygons completed.
- First expanded Batch DRC exposed:
  - 2 pre-existing Routing Via Style violations on VIN_MUX;
  - old Component Clearance violations that had not previously been included in Batch DRC.
- The two VIN_MUX vias were normalized from 0.70/0.30 mm to the established project 0.60/0.30 mm standard using:
  - `AI_SCRIPTS/T24/T24_Normalize_VIN_MUX_Vias_v1.pas`
  - commit `72fda53b5a79b3fd994848f4ea467705a13c549c`
- User reran Batch DRC.
- Routing Via Style violations are now gone.
- Current Batch DRC shows exactly **21 Component Clearance Constraint Violations** and no Routing Via Style violations in the supplied result.
- Current candidate is therefore **NOT formal DRC PASS yet**.
- Do not save until these 21 placement/footprint-clearance items are dispositioned.

Root-cause discipline:
- `T24_RoutingViaStyle_Range_v1.pas` is **OBSOLETE / DO NOT RUN**; widening the rule is not the chosen solution.
- Do not disable or loosen Component Clearance merely to clear the report.
- Component Clearance rule currently found in the PcbDoc:
  - Scope1 = All
  - Scope2 = All
  - Gap = 10 mil
  - enabled
- Altium Component Clearance can use true 3D bodies; when those are absent or boundary checking is selected, component boundaries/selection geometry are used. Therefore each violation must be classified as real physical collision vs footprint/body-definition artifact before any fix.

Prepared read-only exporter:
- `AI_SCRIPTS/T24/T24_Component_Clearance_Violation_Audit_v1.pas`
- commit `df168d9c0c8217796f8e11e7d679adb7343851b5`
- entry: `AuditT24_Component_Clearance_Violations_v1`
- output: `T24_Component_Clearance_Violation_Audit.txt`
- reads current `eViolationObject` entries and exports full unclipped Altium descriptions and associated rule names;
- makes no PCB/rule/polygon/DRC changes.

Exact next action:
1. keep the current unsaved PCB open after the DRC;
2. run only `AuditT24_Component_Clearance_Violations_v1`;
3. send/upload `T24_Component_Clearance_Violation_Audit.txt`;
4. do not save, waive, move parts or edit Component Clearance yet;
5. then classify all 21 pairs and fix actual causes only.

## T24 Component Clearance pair resolution — 21/21 COMPLETE / BODY AUDIT NEXT

Latest v3 report:
- user report: `T24_Component_Clearance_Violation_Audit_v3.txt`
- all current violation objects = **21**
- Component Clearance violations = **21**
- resolved component/component pairs = **21**
- therefore pair identity is complete.

Current PcbDoc ComponentClearance rule was directly inspected:
- RuleKind = ComponentClearance
- Scope1 = All
- Scope2 = All
- Gap = 10 mil
- VerticalGap = 10 mil
- CollisionCheckMode = 3
- Altium API maps collision-check mode 3 to **Component Body Mode**.

Therefore do NOT move parts or relax the rule based only on generic component BoundingRectangle values.
Before any correction, inspect actual `eComponentBodyObject` geometry for every violating pair.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Component_Body_Clearance_Audit_v1.pas`
- commit `9d7c4eeec76712ceb8f87a3f238b47bf32e0b969`
- entry: `AuditT24_Component_Bodies_For_Clearance_v1`
- output: `T24_Component_Body_Clearance_Audit.txt`
- no PCB/rule/DRC/polygon modification.

Exact next action:
1. keep current unsaved PCB and current DRC markers;
2. run `AuditT24_Component_Bodies_For_Clearance_v1`;
3. upload `T24_Component_Body_Clearance_Audit.txt`;
4. classify each violation as real physical body collision vs bad/oversized footprint body;
5. only then make placement or footprint edits.

## T24 Footprint mechanical-layer audit — READY

Latest findings:
- all 21 current Component Clearance violations resolved to exact component/component pairs;
- every involved component has `Height=0` and `BodyCount=0`;
- therefore current Component Clearance is not checking real 3D/component bodies;
- all 12 representative footprint families do contain mechanical-layer primitives, but layer-name intent (body/assembly/courtyard) is not documented;
- do not move parts or relax Component Clearance yet.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Footprint_Mechanical_Envelope_Audit_v1.pas`
- commit `452eeb8eaade6f681897e4a0c276c8784f75149b`
- entry: `AuditT24_Footprint_Mechanical_Envelopes_v1`
- output: `T24_Footprint_Mechanical_Envelope_Audit.txt`

It measures separate envelopes for:
- pads;
- Mechanical Layer 1;
- Mechanical Layer 2;
- Top Overlay;
for the 12 representative footprint families.

Exact next action:
1. run the read-only envelope audit;
2. send `T24_Footprint_Mechanical_Envelope_Audit.txt`;
3. classify Mechanical1/2 as body/assembly/courtyard from geometry;
4. only then decide whether to use an existing mechanical envelope or add corrected courtyard/body geometry.

## T24 Component Clearance root-cause — MECHANICAL LAYER ROLE CONFIRMED

Latest read-only audits established:
- all 21 Component Clearance violations resolve to exact component pairs;
- all affected components have `Height=0` and `BodyCount=0`;
- therefore current Component Clearance is not checking real 3D bodies;
- for representative footprints, Mechanical 1 geometry matches package/body outline and Mechanical 2 geometry matches a buffered placement courtyard pattern;
- Mechanical 2 examples:
  - 0603: pad envelope about 2.20 x 0.90 mm; Mech2 about 2.65 x 1.45 mm;
  - 1206: pad envelope about 4.30 x 1.70 mm; Mech2 about 4.75 x 2.25 mm;
- `Q_OLED`, `J_NAV`, and `D_ESD1` have no Mechanical 2 primitives and will need explicit courtyard completion if Mechanical 2 is migrated to a true Courtyard role.

Authoritative mechanical-layer role audit:
- `T24_Mechanical_Layer_Role_Audit.txt`
- current board mechanical layer state:
  - Mechanical 1 name = `Mechanical 1`, used/enabled;
  - Mechanical 2 name = `Mechanical 2`, used/enabled;
  - no typed/component-layer-pair structure exists;
  - Mechanical pair count = 0;
  - Mechanical1 paired with Mechanical2 = FALSE.

Implication:
- Mechanical 2 currently behaves geometrically like courtyard but is NOT recognized by Altium as Courtyard Layer Type.
- Altium Component Clearance only treats geometry as courtyard when the mechanical layer/component layer pair has Layer Type=Courtyard.
- therefore the current 21 clearance markers are not a trustworthy physical-placement verdict.

Do NOT:
- loosen ComponentClearance just to clear DRC;
- move components based on these 21 markers;
- globally retag/migrate Mechanical 2 before proving it is used only as component courtyard data across the whole board.

Prepared global read-only audit:
- `AI_SCRIPTS/T24/T24_Global_Mech2_Usage_Audit_v1.pas`
- commit `93ae5543f5b14254e930dba0cb1429a8ae75141c`
- entry: `AuditT24_Global_Mech2_Usage_v1`
- output: `T24_Global_Mech2_Usage_Audit.txt`

Exact next action:
1. keep current unsaved PCB open;
2. run only `AuditT24_Global_Mech2_Usage_v1`;
3. send/upload `T24_Global_Mech2_Usage_Audit.txt`;
4. no Save / layer migration / component move / rule edit yet;
5. if Mechanical 2 is globally component-only courtyard-style data with zero loose board primitives, prepare controlled Courtyard component-layer-pair migration;
6. then add missing courtyard geometry only for footprints that currently lack Mech2.

## T24 Courtyard Migration Step1 — APPLIED / UNSAVED

Timestamp: 2026-09-21 23:21 +03:30

Authoritative user screenshot confirms:
- `ApplyT24_Courtyard_LayerPair_Step1_v3` completed successfully.
- Mechanical Layer Pair created: `Mechanical 2 <-> Mechanical 4`.
- Exactly 12 bottom-side mechanical primitives were moved from Mechanical 2 to Mechanical 4.
- No copper, routing, via, polygon, component position/rotation, or design rule was changed.
- User has NOT been instructed to save yet.

Current DRC state:
- Routing Via Style root-cause fix remains PASS.
- GND-via Direct rule remains valid.
- Top/Bottom GND polygons remain KEEP.
- Formal Batch DRC is NOT yet PASS because Component Clearance semantics are still being corrected.
- Existing 21 Component Clearance violations are not yet a trustworthy physical-placement verdict until Courtyard migration is completed and DRC is rerun.

Courtyard audit chain already completed:
- all 21 Component Clearance violation pairs resolved;
- affected components had `Height=0` and `BodyCount=0`;
- Mechanical 1 geometry behaves like body/assembly outline;
- Mechanical 2 geometry behaves like courtyard;
- global audit: 129 total components, 113 with Mech2, 16 without Mech2, zero loose board-level Mech2 primitives;
- migration preflight: 110 top-side components with Mech2, 3 bottom-side components with Mech2, 1 bottom-side component without Mech2;
- bottom components migrated in Step1: `R_RTC_INT_PU`, `C_RTC`, `BT2`.

Applied script:
- `AI_SCRIPTS/T24/T24_Courtyard_LayerPair_Migration_Step1_v3.pas`
- Git commit: `769741eef5e6d15d77be678c3c493c7393d1eacd`

CURRENT EXACT POINT:
1. DO NOT SAVE yet.
2. In Altium open View Configuration.
3. Go to Component Layer Pairs.
4. Edit the `Mechanical 2 / Mechanical 4` pair.
5. Set `Layer Type = Courtyard`.
6. Confirm/apply the dialog.
7. Return with screenshot of the Component Layer Pair showing Courtyard.
8. After that, prepare Step2 to add/fix courtyard geometry for the 16 components that currently have no Mech2/paired courtyard.
9. Only after Courtyard semantics are complete: rerun Component Clearance / full Batch DRC and classify any real remaining collisions.
10. Do not relax the global ComponentClearance rule merely to clear violations; fix root cause.

16 components currently without Mechanical 2 before Step1:
- `U_RTC` (Bottom)
- `Q_SD`
- `Q_OLED`
- `J_SWD`
- `J_SHIELD`
- `J_SD`
- `J_NAV`
- `D_EXT3`
- `D_EXT2`
- `D_EXT1`
- `D_ESD`
- `D_ESD2`
- `D_ESD1`
- `C_SENSOR_BULK`
- `C_SD_MID`
- `C_OLED_BULK`

Do not rerun obsolete scripts:
- `T24_RoutingViaStyle_Range_v1.pas`
- `T24_Component_Clearance_Violation_Audit_v1/v2`
- `T24_Courtyard_LayerPair_Migration_Step1_v1/v2`

## T24 Stage2B — controlled GND plane stitching — PAUSED UNTIL GND-VIA DIRECT RULE + DRC PASS

Manufacturer-specific DFM audit:
- completed against Arya Madar public pricing guidance on 2026-09-21;
- report: `AI_CONTINUITY/T24_ARYAMADAR_DFM_AUDIT.md`;
- report commit: `15d34b51f09023931fea003e8e1daa0f5eda5fa9`;
- current board already contains routing clearance below 0.2 mm and all 180 legacy vias use about 0.30 mm drill, so blindly resizing all vias would add routing risk without guaranteeing removal of the manufacturer's premium price class;
- bulk legacy-via enlargement is therefore NOT approved at this checkpoint.

Authoritative Stage2B script:
- USE: `AI_SCRIPTS/T24/T24_Stage2B_GND_Stitching_v2.pas`
- v2 script commit: `4ba9f97e16385eaaf07abc9ebda63980e29d0ae4`
- v2 script blob: `b10a61b26019d1ed7c512939e79f0c6805d912b0`
- DO NOT USE the older v1 script; v1 is superseded for execution.

v2 entry points:
- `PreflightT24_Stage2B_GND_Stitching_v2`
- `ApplyT24_Stage2B_GND_Stitching_v2`

Purpose:
- add 11 deliberate GND stitching vias between the already-poured Top and Bottom GND planes;
- do not reopen completed signal/power routing;
- use fabrication-friendly new stitching geometry where ample space exists.

New Stage2B via geometry:
- diameter: **31.496 mil = 0.80 mm**
- drill: **17.717 mil = 0.45 mm**
- annular ring: approximately **0.175 mm**
- Top-to-Bottom through via
- net: GND

Static DFM clearance audit of the 11 enlarged candidates:
- all 11 remain in large open-plane areas;
- worst estimated different-net obstacle margin with 0.80 mm via diameter is approximately **74.6 mil / 1.89 mm**;
- this is only a planning result; live Altium preflight remains mandatory.

Baseline safety:
- requires 117 GND tracks / 46 GND vias / 180 total vias / 2 polygons;
- requires one Top GND polygon and one Bottom GND polygon, each with 8 points;
- preflight checks candidates against live component bounds, pads, Top/Bottom tracks, existing vias, electrical/keepout objects, controlled interior limits, and Stage1 logo region;
- Apply repeats preflight before any PCB change;
- no routing moves and no polygon-outline changes are performed;
- no interactive PCB:Zoom call.

Expected state immediately after successful Apply:
- **11 new GND stitching vias**
- **57 GND vias total**
- **191 total vias**
- **117 GND tracks unchanged**
- **2 polygons unchanged**

Exact next action:
1. synchronize local repo with normal `Git_Save.cmd` v2.5 so the new remote commits are present locally;
2. open `AI_SCRIPTS/T24/T24_Stage2B_GND_Stitching_v2.pas` in Altium;
3. run **only** `PreflightT24_Stage2B_GND_Stitching_v2`;
4. expected result: **PREFLIGHT PASS** and **11/11 candidates passed live-board checks for 0.80/0.45 mm vias**;
5. only after that PASS, run `ApplyT24_Stage2B_GND_Stitching_v2`;
6. after Apply: **Repour All Polygons → FULL DRC**;
7. if DRC is not clean, do not save; if DRC PASS, save PCB → Snapshot Exporter v1.4.2 → `Git_Save.cmd`;
8. verify the refreshed Git/snapshot before formally closing Stage2B.

Stage2B remains **NOT PASS yet** until post-apply repour + full DRC + refreshed snapshot are verified.

## Locked project constraints still in force

- PCB remains **2-layer**.
- Manual assembly / rework readability remains a primary physical-design requirement.
- Every PCB-mounted component must retain a readable RefDes.
- Pin-1 / polarity / orientation marks must remain clear where applicable.
- Off-board devices must retain explicit PCB-side connectors/interfaces.
- Schematic controlled Snap Grid remains **100 mil**.
- Do not casually move or reroute completed T23 copper without a new reason and a new full DRC.
- If future edits affect Bottom copper or GND connectivity, repour the GND polygon and rerun full DRC before accepting the change.

## Continuity warning

Older continuity text that says:
- Bottom GND polygon has not yet been created, or
- only the historical 3 GND Net Antennae are expected,

is now obsolete and must not override this handoff or the newer Git/PcbDoc evidence.

## Next recommended action

T24 is now active. Stage1 branding is complete and saved.

Recommended next stage:
**T24 Stage2 — Manufacturing / release audit**, with no routing changes unless a concrete release-blocking issue is found.

Stage2 should verify:
- Gerber / ODB++ layer set and naming
- NC Drill outputs
- board outline / route layer
- Top/Bottom solder mask
- Top silkscreen readability, including the new logo
- test points and exposed pads
- connector pin labels / polarity / orientation marks
- fabrication notes / stackup for the required 2-layer board
- output-file completeness before sending to the PCB manufacturer

Rollback references:
- clean pre-logo T23 post-pour baseline:
  `a1e4193edacf4f03da623616e470258cd1dc147e`
- current saved post-logo PCB:
  `43306bfd199b10555d7fa2f5f45a8550b8363720`

Do not make additional copper edits merely for cosmetics. Any future copper/GND edit requires polygon repour and a new full DRC.
