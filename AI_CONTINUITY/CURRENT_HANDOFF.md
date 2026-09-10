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
- `PMUX_PR1`: routed.
- `PMUX_ST`: routed.
- `USB_CC1`: routed.
- `USB_CC2`: routed.
- Low-current `BAT_SW` test-point Bottom branch was moved to open a legal PMUX corridor; the accepted main BAT_SW power path was preserved.
- User confirmed DRC clean after Stage 4D except the same 3 expected GND Net Antennae.
- Saved PCB checkpoint containing Stage 4D: `aa285051dcfff95b6947ff4d2b7dc2b6e8c9707f`.

### Stage 4E — PMUX output + local rails — PASS

- Final accepted geometry came from `T23_Stage4E_v5_CollisionAware_PowerBundle.pas`; earlier v1-v4 were development attempts and must not be treated as accepted baselines.
- Completed `VIN_MUX` connection from `U_PMUX.2/U_PMUX.7` into the existing switcher/input-cap/testpoint VIN_MUX network.
- VIN_MUX uses controlled 8mil fine-pitch escape near `U_PMUX`, a 30mil Bottom power trunk, and two 0.70/0.30mm vias.
- Completed local `OLED_VDD` rail: `Q_OLED.3 -> C_OLED_BULK.2 -> C_OLED_HF.2 -> J_OLED.2`.
- Completed local `SENSOR_3V3` rail: `C_SENSOR_BULK.2 -> C_SENSOR_HF.2 -> J_SENSOR_PCB.1 -> FB_SENSOR.2`.
- Absolute Altium Track-object counts are NOT a reliable PASS criterion because Altium may split/merge track objects during connectivity normalization. Use `GAddedTracks/GAddedVias`, connectivity, collision preflight, and DRC instead.
- User confirmed DRC after Stage 4E: only the same 3 expected GND Net Antennae; zero new Clearance / Short / Width / Solder Mask Sliver violations.
- Saved PCB checkpoint containing Stage 4E: `3af60b028c6144610e0b09b13adc1f69448ee77a`.
- Fresh post-Stage-4E collision snapshot: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`, commit `1e87a57688429f27838305a01ddaf4900580b191`.

## Collision-aware routing method — MANDATORY FOR DENSE ROUTING

- Accepted exporter: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Treat Multi Layer pads as copper obstacles on both Top and Bottom.
- Include existing track width, via copper envelope, and required clearance.
- Protect via-to-pad solder-mask sliver, including same-net pads.
- Candidate routing must pass collision preflight before DRC.
- Full-stage preflight must occur before adding the first PCB object whenever practical.
- DRC is final verification only, not a route-finding tool.
- If preflight fails, abort instead of guessing another corridor.
- Preserve one-transaction / one-Ctrl+Z rollback for scripted routing stages.
- Do not create the Bottom GND polygon until major routing is complete.
- User prefers larger logical routing bundles where safe; collision safety overrides bundle size.
- Routing deliverables must be `.pas` only.
- Do not use absolute final Track-object count as the sole PASS/FAIL gate; Altium can split/merge track primitives.

## Current exact PCB state

Authoritative PCB checkpoint:

`3af60b028c6144610e0b09b13adc1f69448ee77a`

Fresh collision snapshot:

`1e87a57688429f27838305a01ddaf4900580b191`

Current accepted relevant state:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX` is now fully connected from PMUX to the accepted switcher-side network.
- `OLED_VDD` routed.
- `SENSOR_3V3` routed.
- `SD_VDD` remains unrouted.
- `VBAT` remains unrouted.
- `CC1_RD_RET` / `CC2_RD_RET` remain unrouted.
- Global `3V3_SYS` still needs later power-distribution completion.
- `USB_5V_AUX` / `R_EXP_PWR_EN` remains deferred to Expansion routing unless the baseline explicitly changes.

## Immediate next action

Continue **Stage 4F — remaining local power distribution** from post-Stage-4E collision snapshot `1e87a576...`.

Preferred next bundle:

1. `SD_VDD` local rail and SD-card power decoupling/distribution.
2. `VBAT` RTC/backup-battery/testpoint routing.
3. If collision preflight proves it trivially safe, `USB_5V_AUX` local expansion-power connection may be included; otherwise keep it deferred with Expansion.

Keep CC return wiring and global `3V3_SYS` for later dedicated bundles if needed. Use full-stage exact-geometry collision preflight before adding objects.

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
