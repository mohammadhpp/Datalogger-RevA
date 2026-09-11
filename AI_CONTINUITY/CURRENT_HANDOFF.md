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

## Stage 4 — Remaining Power / USB / power-distribution routing — FORMALLY CLOSED / PASS

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

### Stage 4H — global 3V3_SYS distribution — FORMALLY CLOSED / PASS

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


#### Stage 4H3 — SD subsystem 3V3_SYS distribution — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4H3_3V3_SD_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4H3 v1: 11 tracks / 3 vias` on the live board.
- Connected `C_BUF.2`, `U_SD_BUF.13`, `U_SD_BUF.14`, `Q_SD.2`, `R_GATE.2`, and `R_CD_PU.1` to `3V3_SYS`.
- User explicitly confirmed DRC was correct after execution; Stage4H3 v1 is accepted as PASS. The supplied image shows the apply-complete message; DRC acceptance is based on the user's direct confirmation.
- User completed save -> Git_Save.cmd -> collision snapshot export v1.3.2 -> Git_Save.cmd.
- Verified PCB checkpoint: `7b096e8ef5d6e0d2ddf991ed2f96cd90a7c11e23`; PCB blob `5bb285dfd6c3af4d3afa11dc98899a13bacff81b`, 1,681,408 bytes.
- Verified post-Stage4H3 snapshot: `ab3f6d9ea9f7f8e4bf71490257ad48637fd4157b`; snapshot blob `00f17ae9b72cbf6728d28dfca8e81c90fbacafe3`.
- Snapshot delta matches the intended H3 geometry: 13 added and one removed/split track record at the H1 junction, plus exactly 3 new 3V3 vias. Pad records and other-net geometry are unchanged.
- Snapshot connectivity confirms all six H3 targets join the C_OUT/U_SYS source. Connected 3V3 pads are now 21 of 34; 13 remain.
- Do not rerun or undo Stage4H3.

#### Stage 4H4 — RTC 3V3_SYS distribution — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4H4_3V3_RTC_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4H4 v1: 6 tracks / 0 vias` on the live board.
- Connected `U_RTC.2`, `C_RTC.1`, and `R_RTC_INT_PU.1` to `3V3_SYS`.
- User explicitly confirmed DRC was correct after execution; Stage4H4 v1 is accepted as PASS. The supplied image shows the apply-complete message; DRC acceptance is based on the user's direct confirmation.
- User completed save -> Git_Save.cmd -> collision snapshot export v1.3.2 -> Git_Save.cmd.
- Verified PCB checkpoint: `441ed94c303603ecf4486f66937b05a100b8c340`; PCB blob `68bbc9b27c7227982184fc54a2ad31758cadbc49`, 1,682,944 bytes.
- Verified post-Stage4H4 snapshot: `5cb4de007b2ce5e40169e059fc4b52d801af7bb0`; snapshot blob `86a5ff09bb7b14e332a432269a9582af2a2fbba2`.
- Snapshot delta contains seven new 3V3 track records for six requested calls because the branch junction split one primitive; zero new vias. Pad records and other-net geometry are unchanged.
- Snapshot connectivity confirms all three H4 targets join the C_OUT/U_SYS source. Connected 3V3 pads are now 24 of 34; 10 remain.
- Do not rerun or undo Stage4H4.


#### Stage 4H5 — Navigation pull-ups + OLED source 3V3_SYS — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4H5_3V3_Nav_OLED_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4H5 v1: 7 tracks / 2 vias` on the live board.
- Connected `R_PULL1.2`, `R_PULL2.2`, `R_PULL3.2`, `R_PULL4.2`, and `Q_OLED.2` to `3V3_SYS`.
- User explicitly confirmed DRC was correct after execution; Stage4H5 v1 is accepted as PASS. The supplied image shows the apply-complete message; DRC acceptance is based on the user's direct confirmation.
- User completed save -> Git_Save.cmd -> collision snapshot export v1.3.2 -> Git_Save.cmd.
- Verified PCB checkpoint: `2bb804d591ed18a178fc50937db1b76b1527f5fa`; PCB blob `19dc731cb31b51c8d2e7967e6290cae6f98a9b92`, 1,685,504 bytes.
- Verified post-Stage4H5 snapshot: `ad3a613e6c43ea490b45cda70877f0ec21badfed`; snapshot blob `589e0ba44b1702321eb8d369693c446137d2f330`.
- Snapshot contains exactly two new 3V3 vias. Altium re-segmented several existing paths and `R_PULL3` shifted by about (+1.575,-4.370)mil with its connected trace following it. Geometry partition analysis proves every affected non-3V3 net retained the same pad connectivity; all five H5 targets are connected and DRC is PASS.
- Connected 3V3 pads are now 29 of 34; five remain.
- Do not rerun or undo Stage4H5.


#### Stage 4H6 — final 3V3_SYS branches — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4H6_3V3_Final_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4H6 v1: 16 tracks / 2 vias` on the live board.
- Connected the final five `3V3_SYS` pads: `R_ST_PU.1`, `R_EXT_REF.1`, `J_EXP.1`, `D_EXT1.5`, and `D_EXT2.5`.
- User explicitly confirmed DRC was correct after execution; Stage4H6 v1 is accepted as PASS.
- User completed save -> `Git_Save.cmd` -> collision snapshot export v1.3.2 -> `Git_Save.cmd`.
- Verified PCB checkpoint: `d16238e9d98c551ff47964f9e0752a8d0cb2ccc4`; PCB blob `cd6f5737cc0fad3eb435135a3b68c056738fbddd`, 1,687,552 bytes.
- Verified post-Stage4H6 snapshot: `4f08a9598ea36dbc1ccab495345a3229c2525eec`; snapshot blob `398927e37c8606837eeaa4786b491e94123bea06`.
- Snapshot comparison against post-H5 keeps all 418 pads unchanged and adds exactly two 3V3 vias at (4400,5840) and (6400,4680). Altium re-segmented joined copper, producing 19 added and 4 removed 3V3 track records for the 16 script calls; SD_VDD record re-segmentation preserved connectivity.
- Geometry analysis confirms all 34 of 34 `3V3_SYS` pads are connected. Global Stage4H 3V3 distribution is formally closed.
- Do not rerun or undo Stage4H6.

### Stage 4I — final USB_VBUS_PROT expansion-enable branch — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage4I_USB_VBUS_PROT_EXP_PWR_EN_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage4I v1: 5 tracks / 0 vias` on the live board.
- Connected the final Stage4 power-distribution pad, `R_EXP_PWR_EN.1`, to `USB_VBUS_PROT`.
- User explicitly confirmed DRC was correct after execution; Stage4I v1 is accepted as PASS.
- User completed save -> `Git_Save.cmd` -> collision snapshot export v1.3.2 -> `Git_Save.cmd`.
- Verified PCB checkpoint: `5205a902577784c061c5db5fcf529707a8ea2752`; PCB blob `78f01044643b792c443bd7545eafefe23bf34471`, 1,687,552 bytes.
- Verified post-Stage4I snapshot: `f798bdd34bd316866b4fb8102c6ddbba3e3989a6`; snapshot blob `3ced992e3d97ec92fd6bcc977d31638b94c35852`.
- Snapshot delta against post-H6 is exactly five added 8mil Top-layer `USB_VBUS_PROT` tracks and zero removals. All 418 pads, 49 vias, fills, regions and arcs are unchanged.
- Geometry analysis confirms all 8 of 8 `USB_VBUS_PROT` pads are connected.
- Stage 4 Remaining Power / USB / power-distribution routing is formally closed. Do not rerun Stage4I.

## Stage 5 — signal routing — IN PROGRESS

### Stage 5A — SWD debug pair — PASS / SAVED

- Accepted implementation: `AI_SCRIPTS/T23/T23_Stage5A_SWD_Debug_ExternalPlan_v1.pas`.
- Script reported `APPLY COMPLETE Stage5A v1: 3 tracks / 0 vias` on the live board.
- Connected `SWDIO: U_MCU.24 -> J_SWD.2` with two Top-layer 8mil tracks and `SWCLK: U_MCU.25 -> J_SWD.4` with one Top-layer 8mil track.
- User explicitly confirmed DRC was correct after execution; Stage5A v1 is accepted as PASS.
- User completed save / snapshot exporter v1.3.2 / `Git_Save.cmd`.
- Verified PCB checkpoint: `77fed8e2f76d5eed73fb5d3d81b96ce2d1ec7888`; PCB blob `d0cbc4235497ca70b9e7892393e4f65ec972ff35`, 1,687,552 bytes.
- Verified post-Stage5A snapshot: `a067fc546e8a9ea8fe3dcbda82ac7a13fd932479`; snapshot blob `6f94abb49147c55e99795558dc3fb1cc00dc3c01`.
- Snapshot delta is exactly two added SWDIO tracks and one added SWCLK track; all 418 pads, 49 vias, fills, regions and arcs are unchanged.
- Do not rerun Stage5A.

### Stage 5B — NRST / reset distribution — PASS / SAVED

- `T23_Stage5B_NRST_ExternalPlan_v1.pas` preflight-aborted before adding any object.
- Exact live abort: v1 track T02 `(6245,5840) -> (6190,5780)` touched the conservative expanded bounding rectangle of `C_MCU_HF.1` (`GND`). No Undo was required and the saved/live PCB baseline remained unchanged.
- Accepted replacement: `AI_SCRIPTS/T23/T23_Stage5B_NRST_ExternalPlan_v2.pas`.
- Targets all five NRST pads: `U_MCU.6`, `C_NRST.1`, `SW_RESET.1/.2`, and `J_SWD.5`.
- Script reported `APPLY COMPLETE Stage5B v2: 12 tracks / 2 vias`; user explicitly confirmed DRC was correct.
- User completed PCB save -> `Git_Save.cmd` -> collision snapshot export v1.3.2 -> `Git_Save.cmd`.
- Verified final PCB checkpoint: `747622fd0cccd34f6636183d5b56aecf16a708f9`; PCB blob `272fa765aca61cdaac2083e307ed564139702ac2`, 1,689,600 bytes.
- Verified post-Stage5B snapshot: `956ee7ef5a7b14fcf63326d331e5cc708a2eef76`; snapshot blob `2e551070ce84d75c401be7d081ef8311e5fe18b5`, 160,726 bytes.
- Snapshot contains exactly 12 NRST track records and two NRST vias at (6030,5970) and (6500,6150). All 418 pads are unchanged; fills, regions and arcs are unchanged.
- Snapshot connectivity proves all five NRST pads are in one connected component. Unrelated 3V3_SYS serialization changed by 11 added / 5 removed track records around its existing OLED/via junction, but all 34 of 34 3V3_SYS pads remain connected and DRC is PASS.
- Fresh geometry inventory now finds 48 incomplete non-GND signal nets; NRST is no longer incomplete.
- v2 replaces the rejected diagonal with `(6245,5840) -> (6245,5810) -> (6190,5780)`.
- The cross-board trunk is on Bottom between vias at (6030,5970) and (6500,6150), preserving Top-layer north-side MCU fanout.
- Do not rerun Stage5B.

### Stage 5C — RTC interrupt distribution — CANDIDATE ISSUED / DRC PENDING

- Candidate: `AI_SCRIPTS/T23/T23_Stage5C_RTC_INT_ExternalPlan_v1.pas`.
- Targets all four RTC_INT_N pads: `U_RTC.3`, `R_RTC_INT_PU.2`, `TP_RTC_INT.1`, and `U_MCU.27`.
- Proposed additions: 8 tracks / 3 vias, 8mil throughout.
- The RTC/pull-up branch starts on Bottom, rises to the test point and left-side Top corridor, then crosses the final MCU approach on Bottom at Y=6110. Only the short U_MCU.27 escape remains on Top, preserving north-side MCU fanout.

## Collision-aware routing method — MANDATORY FOR DENSE ROUTING

- Accepted exporter: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Treat Multi Layer pads as copper obstacles on both Top and Bottom.
- Include existing track width, via copper envelope, and required clearance.
- Protect via-to-pad solder-mask sliver, including same-net pads.
- DRC is final verification only, not a route-finding tool.
- If preflight fails, abort instead of applying a guessed route.
- External pad-collision checks must mirror Altium's conservative axis-expanded `BoundingRectangle` test. A Euclidean corner-distance check is insufficient and caused the Stage5B v1 false-clear result.
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

`747622fd0cccd34f6636183d5b56aecf16a708f9`

Fresh collision snapshot:

`956ee7ef5a7b14fcf63326d331e5cc708a2eef76`

This saved state contains Stage4A through Stage4I and Stage5A through Stage5B PASS.

### Current LIVE Altium state

- User confirmed accepted Stage5B v2 DRC, PCB save and fresh snapshot export; both files are verified on GitHub.
- No Stage5C routing has been applied. Stage5C v1 is an issued candidate awaiting execution and DRC.
- Altium is operated by the user; the AI has no direct live-UI access.

Current accepted SAVED routing:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX`, `OLED_VDD`, `SENSOR_3V3` routed.
- `SD_VDD`, `VBAT`, `USB_5V_AUX` routed.
- `CC1_RD_RET`, `CC2_RD_RET` routed and DRC-clean.
- Stage4H1 through Stage4H6 global `3V3_SYS` distribution is saved, DRC-PASS and closed.
- Stage4I final `USB_VBUS_PROT` branch is saved and DRC-PASS; all 8 pads are connected.
- Stage 4 Remaining Power / USB / power-distribution is closed.
- Stage5A `SWDIO` and `SWCLK` are saved and DRC-PASS.
- Stage5B `NRST` is saved and DRC-PASS; all five NRST pads are connected.
- Fresh geometry inventory now finds 48 incomplete non-GND signal nets; Stage 5 signal routing is active.

## Immediate next action — EXACT

1. Run `Git_Save.cmd` once to receive the new Stage5C script and this handoff.
2. Run `AI_SCRIPTS/T23/T23_Stage5C_RTC_INT_ExternalPlan_v1.pas`, entry point `ApplyT23_Stage5C_RTC_INT_v1`, exactly once.
3. Stage5C connects all four `RTC_INT_N` pads across RTC, pull-up, test point and MCU.
4. Proposed additions: exactly **8 tracks / 3 vias**, all tracks at 8mil; vias are 0.60/0.30mm.
5. On preflight `ABORT`, nothing was added and no Undo is needed. On `BUILD INCOMPLETE`, one Ctrl+Z rolls back the transaction. On `APPLY COMPLETE`, do not rerun or save; run DRC and report the result.
6. Accept only zero new Clearance, Short-Circuit, Width and Minimum Solder Mask Sliver violations. The same three pre-polygon GND Net Antennae remain the only accepted entries.
7. After accepted DRC: save PCB -> `Git_Save.cmd` -> export collision snapshot v1.3.2 -> `Git_Save.cmd`; verify Git and update handoff.
8. Continue Stage 5 in coordinated functional bundles. No polygon yet.

### Stage5C validation completed outside Altium

- Exact post-Stage5B snapshot content is Git blob `2e551070ce84d75c401be7d081ef8311e5fe18b5`.
- Full candidate audit reports zero pad/track/via conflicts using the same axis-expanded pad-bbox semantics as the Altium preflight.
- The tightest conservative guard headroom is 8.063mil at the final via-to-own-pad mask check near `U_MCU.27`; all checks remain above their required limits.
- Proposed union connects all four RTC_INT_N pads and every candidate track/via into one component.
- The long final approach is deliberately on Bottom rather than across the Top side of U_MCU, so later north-side MCU signal fanout is not blocked.
- Preflight and static-apply argument lists match mechanically; build count is 8 tracks / 3 vias.
- Baseline guards require zero existing RTC_INT_N tracks/vias, no polygon, exact saved Stage5B NRST anchors and exact target pad net/layer/coordinates.
- **Altium compile, live execution and Stage5C DRC remain user-side gates.**

### Remaining 3V3_SYS inventory after Stage4H5

The fresh snapshot contains 34 `3V3_SYS` pads. Geometry analysis proves 29 connected. The five remaining pads are exactly:

- `R_ST_PU.1`
- `R_EXT_REF.1`
- `J_EXP.1`
- `D_EXT1.5`
- `D_EXT2.5`

Stage4H6 targeted all five and the accepted post-H6 snapshot proves 34 of 34 connected. This historical inventory is snapshot-derived, not the whole-board unrouted count.


## Physical-routing preferences

- PCB is 2-layer.
- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
