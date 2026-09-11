# CURRENT HANDOFF — Datalogger RevA

Last continuity update: 2026-09-11

## Repository / backup state

- Authoritative repository: `mohammadhpp/Datalogger-RevA` (private), branch `main`.
- Local working repo: `C:\#MHP FILES\DataLoger`.
- Local bare backup remote: `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
- Online remote: `github` -> `https://github.com/mohammadhpp/Datalogger-RevA.git`.
- `Git_Save.cmd` / `Git_Save.ps1` standard remains v2.5 one-click sync.
- Normal user workflow: run `Git_Save.cmd` only.
- Do not auto-merge Altium binary files if histories diverge.

## Chat continuity management

- Long-project chat threshold: approximately 70% of usable context.
- Before continuity degrades, update this handoff and continue in a fresh chat.
- New sessions must begin from `AI_START_HERE.md` and follow its required read order.

## CURRENT EXACT POINT

### Major task

**T23 — PCB routing / placement refinement**

### Stage 3 — OVP / protected USB routing

**FORMALLY CLOSED / PASS.**

- Final OVP audit PASS.
- Accepted nets include `USB_OVP_IN`, local `USB_VBUS_PROT`, `OVP_BASE`, `OVP_GATE`, `OVP_REF`, `OVP_K`, `NetR_K1_1`, `NetR_K2_1`.
- Bottom GND polygon has NOT yet been created.
- DRC baseline remains only the same 3 expected GND Net Antennae from pre-polygon GND vias.

## Stage 4 — Remaining Power / USB / power-distribution routing — IN PROGRESS

### Stage 4A — raw input nets — PASS

- `BAT_RAW`: `BT1.1 -> F1.2` plus `TP_BAT_RAW`.
- `USB_VBUS_RAW`: `J1.1 -> S1.3` plus `TP_USB_RAW`.
- Saved PCB checkpoint: `8ebe1e27866d6dd677c542ee0ac27950d9b35f3d`.

### Stage 4B — BAT_FUSED — PASS

- `F1.1 -> S1.1` plus `TP_BAT_FUSED`.
- Saved PCB checkpoint: `4b250d7e96431e2848664e4b8ac40e0a40009033`.

### Stage 4C — BAT_SW — PASS

- Final accepted implementation: `T23_BAT_SW_Route_Stage4C_v3`.
- `S1.2 -> C1.1 -> U_PMUX.6` plus `TP_BAT_SW`.
- Main input path uses 30mil; PMUX approach uses controlled 8mil neck-down.
- Saved PCB checkpoint: `98d7fbcd03e8a4711be81ac990098328ac35d0b0`.

### Stage 4D — PMUX / USB control bundle — PASS

- Final accepted implementation: `T23_Stage4D_v5_CollisionAware.pas`; v1-v4 rejected and never saved.
- Routed `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2`.
- Low-current `BAT_SW` test-point Bottom branch was moved to open a legal PMUX corridor; main BAT_SW power path preserved.
- DRC clean except the same 3 expected GND Net Antennae.
- Saved PCB checkpoint: `aa285051dcfff95b6947ff4d2b7dc2b6e8c9707f`.

### Stage 4E — PMUX output + local rails — PASS

- Final accepted geometry: `T23_Stage4E_v5_CollisionAware_PowerBundle.pas`.
- Completed `VIN_MUX` from `U_PMUX.2/U_PMUX.7` into switcher/input-cap/testpoint network.
- VIN_MUX uses controlled 8mil fine-pitch escape, 30mil Bottom power trunk, and two 0.70/0.30mm vias.
- Completed `OLED_VDD` and `SENSOR_3V3` local rails.
- DRC clean except the same 3 expected GND Net Antennae.
- Saved PCB checkpoint: `3af60b028c6144610e0b09b13adc1f69448ee77a`.
- Post-Stage-4E collision snapshot commit: `1e87a57688429f27838305a01ddaf4900580b191`.

### Stage 4F — remaining local power rails — PASS

- Final accepted implementation: `T23_Stage4F_v2_CollisionAware_RemainingPower.pas`.
- Completed `SD_VDD`, `VBAT`, and `USB_5V_AUX`.
- User confirmed DRC after Stage 4F: only the same 3 expected GND Net Antennae; zero new Clearance / Short / Width / Solder Mask Sliver violations.
- Saved PCB checkpoint: `f2a7e90127879cc40855345699ca847759019d09`.
- Post-Stage-4F collision snapshot: `b5c9aea39d413fb2ff877b608fbe41d2106da104`.

### Stage 4G — USB-C CC return completion — PASS

- Final accepted implementation: `T23_Stage4G_ExternalPlan_v1.pas`.
- Earlier manually guessed Stage4G v1-v4 corridors were rejected by preflight and never saved.
- An in-Altium A* experiment was abandoned because PascalScript route search blocked the Altium UI; no route from that experiment was saved.
- Final method: route planning performed externally from the collision snapshot; Altium script performs only lightweight exact live-board preflight and static apply.
- Routed `CC1_RD_RET`: `R_CC1.2 -> S1.5`, accepted geometry = 7 tracks / 1 via.
- Routed `CC2_RD_RET`: `R_CC2.2 -> S1.7`, accepted geometry = 5 tracks / 2 vias.
- Total Stage4G requested objects = 12 tracks / 3 vias.
- User confirmed DRC after Stage 4G: only the same 3 expected GND Net Antennae; zero new Clearance / Short / Width / Solder Mask Sliver violations.
- Saved PCB checkpoint containing Stage 4G: `4b3fdd50c4fe619e312c0d59d6a2fae5d386c131`.
- Fresh post-Stage-4G collision snapshot: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`, commit `7840d80a223e2bee4b294b8d1e744a2d4469f0cf`.

### Stage 4H — global 3V3_SYS distribution — IN PROGRESS

#### Stage 4H1 — north / upper 3V3_SYS backbone — PASS / SAVED

- Baseline for all Stage4H1 attempts is the saved Stage4G PCB checkpoint `4b3fdd50...` plus collision snapshot `7840d80a...`.
- `T23_Stage4H1_3V3_North_ExternalPlan_v1.pas` preflight-aborted before adding objects: horizontal Bottom backbone at `Y=5750` collided with existing `USB_VBUS_PROT` Bottom wall at `X=5290`.
- `T23_Stage4H1_3V3_North_ExternalPlan_v2.pas` preflight-aborted before adding objects: attempted detour down from `(5035,5750)` collided with existing `OVP_K` Bottom geometry.
- `T23_Stage4H1_3V3_North_ExternalPlan_v3.pas` then passed full exact preflight and STATIC APPLY executed.
- v3 live result message: `AddedTracks=24, AddedVias=8`; script incorrectly expected `25 tracks / 8 vias`, therefore it displayed a FALSE object-audit FAIL.
- Verified after the fact: the v3 build block actually contains exactly **24 `AddTrackMil` calls and 8 `AddViaMil` calls**. The mismatch is arithmetic in the audit expectation, not evidence of a missing build object.
- User supplied the post-v3 DRC screenshot dated 2026-09-11, 11:58:19 Altium local time. It shows only the same three GND Net Antennae at (5040,5802.835), (5215,5980), and (5395,5860) mil; no new violations displayed.
- Stage4H1 v3 was accepted as DRC PASS in this session.
- User then confirmed PCB save -> Git_Save.cmd -> collision snapshot export v1.3.2 -> Git_Save.cmd.
- Verified PCB save commit: `3f5563775ca5735eb0f73cdb863d489184f9a517`; PCB blob `5f4c48d39cd25bda48a2455848e5976069c0f18d`, 1,678,848 bytes.
- Verified post-Stage4H1 snapshot commit: `cc1721a8d01d11704ccebe731dce0b767fa20b92`; snapshot blob `9be4ebdbcd580bd6158a022c55cd68df5b7737e9`.
- Snapshot comparison against post-Stage4G: same 418 pad records and unchanged other-net geometry; 8 added 3V3_SYS vias. Track-record net increase is 28, with junction splitting visible, so this is not a 24-call audit failure.
- All eight intended upper consumers are connected to the C_OUT/U_SYS 3V3_SYS source in snapshot geometry.
- Do not rerun or undo the accepted Stage4H1 route.

Stage4H1 v3 accepted scope:

- Root from already-routed `3V3_SYS` near `(5035,5750)`.
- Bottom-layer north/upper distribution backbone routed around the Stage3 OVP / protected-USB obstacle maze.
- Connects upper `3V3_SYS` consumers including:
  - `TP_3V3_SYS`
  - `R_SCL_PU.2`
  - `R_SDA_PU.2`
  - `D_ESD.5`
  - `FB_SENSOR.1`
  - `R_OLED_GATE.2`
  - `U_OLED_SW.14`
  - `C_4066.1`
- v3 build count should be treated as **24 tracks / 8 vias**, not 25/8.

## Collision-aware routing method — MANDATORY FOR DENSE ROUTING

- Accepted exporter: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Treat Multi Layer pads as copper obstacles on both Top and Bottom.
- Include existing track width, via copper envelope, and required clearance.
- Protect via-to-pad solder-mask sliver, including same-net pads.
- DRC is final verification only, not a route-finding tool.
- If preflight fails, abort instead of applying a guessed route.
- Preserve one-transaction / one-Ctrl+Z rollback for scripted routing stages.
- Do not create the Bottom GND polygon until major routing is complete.
- User prefers larger logical routing bundles where safe; collision safety overrides bundle size.
- Routing deliverables must be `.pas` only.
- Do not use absolute final Altium Track-object count as the sole PASS/FAIL gate; Altium may split/merge track primitives.
- Dense route planning must be done outside Altium from the latest collision snapshot.
- Do not run heavy A*/grid-search/route-planning loops inside Altium PascalScript. Altium is single-UI-thread sensitive and can appear hung.
- The Altium `.pas` stage should be lightweight: baseline checks -> exact preflight -> static apply -> connectivity analysis -> DRC by user.
- Before hard-coding `GAddedTracks/GAddedVias` PASS counts, verify them against the actual `AddTrackMil` / `AddViaMil` calls in the final build block. A false audit FAIL must not be treated as a routing failure.

## Current exact PCB state

### Authoritative SAVED Git state

PCB checkpoint:

`3f5563775ca5735eb0f73cdb863d489184f9a517`

Fresh collision snapshot:

`cc1721a8d01d11704ccebe731dce0b767fa20b92`

This saved state contains Stage4H1 v3 PASS, including the north/upper 3V3_SYS backbone.

### Current LIVE Altium state

- User confirmed saving the accepted v3 geometry and exporting the fresh snapshot; both changes are verified on GitHub.
- No newer routing was applied in this session. Altium is operated by the user; the AI does not have direct live-UI access.
- Stage4G PCB `4b3fdd50...` / snapshot `7840d80a...` are now rollback references only.

Current accepted SAVED routing:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX`, `OLED_VDD`, `SENSOR_3V3` routed.
- `SD_VDD`, `VBAT`, `USB_5V_AUX` routed.
- `CC1_RD_RET`, `CC2_RD_RET` routed and DRC-clean.
- North/upper `3V3_SYS` Stage4H1 is saved and PASS; remaining global distribution is the active task.
- Expansion signal routing remains later work; `R_EXP_PWR_EN.1` is still on `USB_VBUS_PROT` and was intentionally not altered by Stage 4F.

## Immediate next action — EXACT

1. Continue from the saved Stage4H1 PCB and snapshot above. Do not repeat Stage4H1 and do not use the older Stage4G snapshot for new planning.
2. Stage4H2 is in planning only: no route script was applied and no Stage4H2 DRC result exists.
3. The Stage4H1 v3 .pas source is not present in the current Git tree. Obtain the user's actual `T23_Stage4H1_3V3_North_ExternalPlan_v3.pas` to correct its audit expectation (24 tracks / 8 vias), preserve its known working lightweight exact-preflight framework, and retain routing-script source in Git. Do not claim the source has been fixed until it is available and edited. The accepted board does not need a rerun.
4. Plan the next coherent distribution bundle externally from snapshot `cc1721a8...`, with MCU power/decoupling and its nearby distribution as the next candidate scope. Choose final scope only after obstacle and return-path review.
5. Keep the remaining OLED source branch `Q_OLED.2` and PMUX status pull-up supply `R_ST_PU.1` explicitly on the unfinished list; Stage4H1 did not route them.
6. For every new stage: exact live preflight -> one static-apply transaction -> connectivity analysis -> user DRC -> save and Git_Save only after acceptance -> fresh collision snapshot -> Git_Save.
7. The user needs only Git_Save.cmd to receive this continuity update; no separate manual pull is required.

### Remaining 3V3_SYS inventory after Stage4H1

The fresh snapshot contains 34 3V3_SYS pads. Geometry analysis proves 11 connected to the source: the three existing local pads (`U_SYS.1`, `C_OUT.1`, `R_FB_TOP.1`) and all eight Stage4H1 targets listed above. The other 23 pads remain outside that connected copper network:

- MCU/debug: `U_MCU.4`, `C_MCU_HF.2`, `C_MCU_BULK.2`, `J_SWD.1`.
- SD power/buffer: `U_SD_BUF.13`, `U_SD_BUF.14`, `C_BUF.2`, `R_GATE.2`, `Q_SD.2`, `R_CD_PU.1`.
- RTC: `U_RTC.2`, `C_RTC.1`, `R_RTC_INT_PU.1`.
- Navigation pull-ups: `R_PULL1.2`, `R_PULL2.2`, `R_PULL3.2`, `R_PULL4.2`.
- Expansion: `J_EXP.1`, `R_EXT_REF.1`, `D_EXT1.5`, `D_EXT2.5`.
- Remaining local branches: `Q_OLED.2`, `R_ST_PU.1`.

This inventory is snapshot-derived engineering analysis, not a claim that Altium's whole-board unrouted count is 23. GND polygon and other signal-net routing remain later work.

## Physical-routing preferences

- PCB is 2-layer.
- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
