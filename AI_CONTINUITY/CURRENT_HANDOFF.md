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

#### Stage 4H1 — north / upper 3V3_SYS backbone — LIVE UNSAVED CANDIDATE, DRC PENDING

- Baseline for all Stage4H1 attempts is the saved Stage4G PCB checkpoint `4b3fdd50...` plus collision snapshot `7840d80a...`.
- `T23_Stage4H1_3V3_North_ExternalPlan_v1.pas` preflight-aborted before adding objects: horizontal Bottom backbone at `Y=5750` collided with existing `USB_VBUS_PROT` Bottom wall at `X=5290`.
- `T23_Stage4H1_3V3_North_ExternalPlan_v2.pas` preflight-aborted before adding objects: attempted detour down from `(5035,5750)` collided with existing `OVP_K` Bottom geometry.
- `T23_Stage4H1_3V3_North_ExternalPlan_v3.pas` then passed full exact preflight and STATIC APPLY executed.
- v3 live result message: `AddedTracks=24, AddedVias=8`; script incorrectly expected `25 tracks / 8 vias`, therefore it displayed a FALSE object-audit FAIL.
- Verified after the fact: the v3 build block actually contains exactly **24 `AddTrackMil` calls and 8 `AddViaMil` calls**. The mismatch is arithmetic in the audit expectation, not evidence of a missing build object.
- **No DRC has yet been run on the live Stage4H1 v3 candidate.**
- **Do not save Stage4H1 yet.**
- At chat handoff time, the Altium working board may still contain the unsaved v3 geometry. Do NOT automatically discard it merely because of the false count FAIL.

Stage4H1 v3 intended scope:

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

`4b3fdd50c4fe619e312c0d59d6a2fae5d386c131`

Fresh collision snapshot:

`7840d80a223e2bee4b294b8d1e744a2d4469f0cf`

This saved state contains Stage4G PASS but **does not yet contain Stage4H1**.

### Current LIVE Altium state at handoff

- Likely contains unsaved `Stage4H1 v3` geometry because the script applied 24 tracks / 8 vias before reporting the false count-audit FAIL.
- No Stage4H1 DRC result exists yet.
- If Altium was closed, the board was undone, or the unsaved geometry was otherwise discarded before the new chat starts, fall back to the saved Stage4G checkpoint above.

Current accepted SAVED routing:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX`, `OLED_VDD`, `SENSOR_3V3` routed.
- `SD_VDD`, `VBAT`, `USB_5V_AUX` routed.
- `CC1_RD_RET`, `CC2_RD_RET` routed and DRC-clean.
- Global `3V3_SYS` is the active current task.
- Expansion signal routing remains later work; `R_EXP_PWR_EN.1` is still on `USB_VBUS_PROT` and was intentionally not altered by Stage 4F.

## Immediate next action — EXACT

New chat must start by reading `AI_START_HERE.md`, then `AI_CONTINUITY/CURRENT_HANDOFF.md`, `DECISIONS_AND_CONSTRAINTS.md`, and `LESSONS_LEARNED.md`.

Then determine whether the unsaved Stage4H1 v3 geometry is still present in Altium:

### If the v3 geometry is STILL present

1. **Do not Ctrl+Z yet.** The displayed FAIL was caused by a wrong expected count; the actual build block is 24 tracks / 8 vias and all exact preflight checks had already passed.
2. Run DRC on the current unsaved board.
3. Accept only if there are zero new `Clearance`, `Short-Circuit`, `Width`, and `Minimum Solder Mask Sliver` violations.
4. The only acceptable remaining DRC entries are the same 3 pre-existing GND Net Antennae.
5. If DRC is clean, formally mark Stage4H1 v3 PASS, save the PCB, run `Git_Save.cmd`, generate a fresh collision snapshot, then run `Git_Save.cmd` again.
6. Correct the v3/v4 script audit expectation to 24 tracks / 8 vias for continuity, but do not rerun the route merely to make the message pretty if the live geometry already passes DRC.

### If the v3 geometry is NOT present

1. Stay on authoritative Stage4G checkpoint `4b3fdd50...` / snapshot `7840d80a...`.
2. Produce a corrected lightweight Stage4H1 static-apply script whose object audit expects exactly **24 tracks / 8 vias**.
3. Do not change the accepted v3 geometry unless the latest snapshot/preflight proves a collision problem.
4. Run script -> DRC -> save only after clean DRC.

## Physical-routing preferences

- PCB is 2-layer.
- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
