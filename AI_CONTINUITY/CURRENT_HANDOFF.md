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


#### Stage 4H2 — MCU / SWD 3V3_SYS distribution — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4H2_3V3_MCU_SWD_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4H2 v1: 9 tracks / 1 via` on the live board.
- Connected `U_MCU.4`, `C_MCU_HF.2`, `C_MCU_BULK.2`, and `J_SWD.1` to the accepted `3V3_SYS` backbone.
- User explicitly confirmed DRC was correct after execution; Stage4H2 v1 is accepted as PASS. The supplied image shows the apply-complete message, while the DRC result is the user's direct confirmation.
- User completed save -> Git_Save.cmd -> collision snapshot export v1.3.2 -> Git_Save.cmd.
- Verified PCB checkpoint: `27b39afdaab9145585ab877021b0b266e5bbd967`; PCB blob `cb03de4a69426a8b14d9a14a367fe0b31d788935`, 1,679,872 bytes.
- Verified post-Stage4H2 snapshot: `fd2bd4ea6fac7ecda6467328d9be4749e55233cd`; snapshot blob `47af36e44cb1b463604cfe25e1c321e903b81bcb`.
- Snapshot delta shows the intended 9 added calls as 11 new track records and one removed/split prior 3V3 track record at the H1 junction, plus exactly one new 3V3 via at (6070,5925). Pads and other-net geometry are unchanged.
- Snapshot connectivity confirms all four H2 target pads join the C_OUT/U_SYS source. Connected 3V3 pads are now 15 of 34; 19 remain.
- Do not rerun or undo Stage4H2.

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

`27b39afdaab9145585ab877021b0b266e5bbd967`

Fresh collision snapshot:

`fd2bd4ea6fac7ecda6467328d9be4749e55233cd`

This saved state contains Stage4H1 and Stage4H2 PASS.

### Current LIVE Altium state

- User confirmed saving accepted Stage4H2 and exporting the fresh snapshot; both are verified on GitHub.
- No Stage4H3 routing has been applied yet. Stage4H3 is an issued candidate awaiting execution and DRC.
- Altium is operated by the user; the AI has no direct live-UI access.

Current accepted SAVED routing:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX`, `OLED_VDD`, `SENSOR_3V3` routed.
- `SD_VDD`, `VBAT`, `USB_5V_AUX` routed.
- `CC1_RD_RET`, `CC2_RD_RET` routed and DRC-clean.
- Stage4H1 north/upper `3V3_SYS` and Stage4H2 MCU/SWD supply are saved and PASS.
- Global `3V3_SYS` distribution remains the active task; Stage4H3 targets the SD subsystem.
- Expansion signal routing remains later work; `R_EXP_PWR_EN.1` is still on `USB_VBUS_PROT` and was intentionally not altered by Stage 4F.

## Immediate next action — EXACT

1. Run `Git_Save.cmd` once so the local repo safely fast-forwards to the new script/handoff commit.
2. Run `AI_SCRIPTS/T23/T23_Stage4H3_3V3_SD_ExternalPlan_v1.pas`, entry point `ApplyT23_Stage4H3_3V3_SD_v1`, exactly once.
3. Stage4H3 target scope: `C_BUF.2`, `U_SD_BUF.13`, `U_SD_BUF.14`, `Q_SD.2`, `R_GATE.2`, and `R_CD_PU.1` on `3V3_SYS`.
4. Proposed additions are exactly **11 tracks / 3 vias**. Bottom trunk is 20mil; C_BUF rise is 12mil; Top local branches are 10mil. Vias are 23.622/11.811mil.
5. The Bottom trunk joins the accepted H1 backbone at (5600,5350), feeds the SD buffer/capacitor rise at (6030,5223.307), the SD power-control branch via (6800,5350), and the card-detect pull-up via (7225,5350).
6. On preflight `ABORT`, nothing was added and no Undo is needed. On `BUILD INCOMPLETE`, use one Ctrl+Z and report the full message. On `APPLY COMPLETE`, do not rerun or save yet; run DRC and report the result.
7. Accept only zero new Clearance, Short-Circuit, Width, and Minimum Solder Mask Sliver violations. The same three pre-polygon GND Net Antennae remain the only accepted DRC entries.
8. After accepted DRC: save PCB -> Git_Save.cmd -> export collision snapshot v1.3.2 -> Git_Save.cmd; then verify Git and update handoff.
9. SD signal/GND routing and MCU/decoupling GND returns remain unfinished. No polygon yet.

### Stage4H3 validation completed outside Altium

- Exact baseline snapshot content verified against Git blob `47af36e44cb1b463604cfe25e1c321e903b81bcb`.
- Full snapshot collision audit reports zero proposed track/via conflicts with pads, Multi Layer pads, existing tracks or vias under the inherited 6mil electrical clearance and strengthened 8mil conservative via/pad mask allowance.
- Smallest proposed track-to-other-net conservative copper gap is 21.772mil. Smallest proposed via-to-other-pad conservative copper gap is 14.961mil at the SD control area.
- Proposed union connects all six H3 target pads to the C_OUT/U_SYS source; connected 3V3 pads would increase from 15 to 21, leaving 13. No proposed 3V3 track/via island remains.
- Preflight and static-apply geometry lists match mechanically; build calls are exactly 11 tracks / 3 vias.
- Top/Bottom proposed-routing view was inspected.
- **Altium compile, live execution and H3 DRC remain user-side gates.**

### Remaining 3V3_SYS inventory after Stage4H2

The fresh snapshot contains 34 `3V3_SYS` pads. Geometry analysis proves 15 connected to the source. The remaining 19 are:

- SD power/buffer: `U_SD_BUF.13`, `U_SD_BUF.14`, `C_BUF.2`, `R_GATE.2`, `Q_SD.2`, `R_CD_PU.1` — Stage4H3 candidate targets these six.
- RTC: `U_RTC.2`, `C_RTC.1`, `R_RTC_INT_PU.1`.
- Navigation pull-ups: `R_PULL1.2`, `R_PULL2.2`, `R_PULL3.2`, `R_PULL4.2`.
- Expansion: `J_EXP.1`, `R_EXT_REF.1`, `D_EXT1.5`, `D_EXT2.5`.
- Remaining local branches: `Q_OLED.2`, `R_ST_PU.1`.

This is snapshot-derived connectivity inventory, not the whole-board unrouted count.

## Physical-routing preferences

- PCB is 2-layer.
- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
