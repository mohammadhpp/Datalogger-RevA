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
- `R_EXP_PWR_EN.1` remains intentionally deferred to Expansion routing.
- Bottom GND polygon has NOT yet been created.
- DRC baseline remains only the same 3 expected GND Net Antennae from pre-polygon GND vias.

## Stage 4 — Remaining Power / USB / power-distribution routing — IN PROGRESS

### Stage 4A — raw input nets — PASS

- `BAT_RAW`: `BT1.1 -> F1.2` plus `TP_BAT_RAW`.
- `USB_VBUS_RAW`: `J1.1 -> S1.3` plus `TP_USB_RAW`.
- Accepted count: `BAT_RAW=3 tracks / 0 vias`, `USB_VBUS_RAW=6 tracks / 0 vias`.
- Saved PCB checkpoint: `8ebe1e27866d6dd677c542ee0ac27950d9b35f3d`.

### Stage 4B — BAT_FUSED — PASS

- `F1.1 -> S1.1` plus `TP_BAT_FUSED`.
- Accepted count: `BAT_FUSED=10 tracks / 2 vias`.
- Saved PCB checkpoint: `4b250d7e96431e2848664e4b8ac40e0a40009033`.

### Stage 4C — BAT_SW — PASS

- Final accepted implementation: `T23_BAT_SW_Route_Stage4C_v3`.
- `S1.2 -> C1.1 -> U_PMUX.6` plus `TP_BAT_SW`.
- Initial accepted count was `BAT_SW=9 tracks / 3 vias`.
- Main input path uses 30mil; PMUX approach uses controlled 8mil neck-down.
- Saved PCB checkpoint: `98d7fbcd03e8a4711be81ac990098328ac35d0b0`.

### Stage 4D — PMUX / USB control bundle — PASS

- v1-v4 were rejected and never saved; do not use them.
- Final accepted implementation: `T23_Stage4D_v5_CollisionAware.pas`.
- Collision-aware live-board preflight was used before route acceptance.
- `PMUX_PR1`: routed, accepted count `5 tracks / 2 vias`.
- `PMUX_ST`: routed, accepted count `3 tracks / 0 vias`.
- `USB_CC1`: routed, accepted count `5 tracks / 2 vias`.
- `USB_CC2`: routed, accepted count `5 tracks / 0 vias`.
- Low-current `BAT_SW` test-point Bottom branch was surgically moved to open a legal PMUX corridor; the accepted main BAT_SW power path was preserved.
- Current `BAT_SW` count after Stage 4D is `10 tracks / 3 vias`.
- User confirmed DRC clean after Stage 4D except the same 3 expected GND Net Antennae.
- Fresh collision snapshot after Stage 4D: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`, commit `04ffe57a7ca4aea755a06e56b80a6448c05f2d08`.
- Saved PCB checkpoint containing Stage 4D: `aa285051dcfff95b6947ff4d2b7dc2b6e8c9707f`.

## Collision-aware routing method — MANDATORY FOR DENSE ROUTING

- Accepted exporter: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Treat Multi Layer pads as copper obstacles on both Top and Bottom.
- Include existing track width, via copper envelope, and required clearance.
- Protect via-to-pad solder-mask sliver, including same-net pads.
- Candidate routing must pass collision preflight before DRC.
- DRC is final verification only, not a route-finding tool.
- If preflight fails, abort instead of guessing another corridor.
- Preserve one-transaction / one-Ctrl+Z rollback for scripted routing stages.
- Do not create the Bottom GND polygon until major routing is complete.
- User prefers larger logical routing bundles where safe; collision safety overrides bundle size.
- Routing deliverables must be `.pas` only.

## Current exact PCB state

Authoritative PCB checkpoint:

`aa285051dcfff95b6947ff4d2b7dc2b6e8c9707f`

Fresh collision snapshot:

`04ffe57a7ca4aea755a06e56b80a6448c05f2d08`

Current accepted relevant counts:

- `BAT_RAW = 3 tracks / 0 vias`
- `USB_VBUS_RAW = 6 tracks / 0 vias`
- `BAT_FUSED = 10 tracks / 2 vias`
- `BAT_SW = 10 tracks / 3 vias`
- `PMUX_PR1 = 5 tracks / 2 vias`
- `PMUX_ST = 3 tracks / 0 vias`
- `USB_CC1 = 5 tracks / 2 vias`
- `USB_CC2 = 5 tracks / 0 vias`
- `VIN_MUX` remains only partially routed: the switcher/input-cap/testpoint side exists, but the PMUX VIN_MUX output pins still need connection into that accepted VIN_MUX network.
- `OLED_VDD`, `SENSOR_3V3`, `SD_VDD`, and `VBAT` remain later power-distribution work; `USB_5V_AUX` / `R_EXP_PWR_EN` remains deferred to Expansion routing unless the baseline explicitly changes.

## Immediate next action

Continue **Stage 4E** using the fresh collision snapshot and the collision-aware live-board preflight method.

Priority is to finish the remaining PMUX-to-switcher `VIN_MUX` connection with controlled fine-pitch neck-down near `U_PMUX`, while allowing a larger bundle of spatially separated local power rails where preflight can prove them safe. Good candidates for the same bundle are local `OLED_VDD` and `SENSOR_3V3`; keep more complex `SD_VDD`, `VBAT`, global `3V3_SYS`, CC return wiring, and Expansion power for later dedicated bundles unless preflight demonstrates an obviously safe path.

After script PASS:

1. Do NOT save immediately.
2. Run DRC.
3. Accept only with zero new Clearance / Short / Width / Solder Mask Sliver violations.
4. The only expected remaining violations are the same 3 pre-existing GND Net Antennae.
5. If DRC passes, save PCB and run `Git_Save.cmd`.
6. Generate a fresh collision snapshot before the next dense routing bundle when geometry changes materially.

## Physical-routing preferences

- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down near pins where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
