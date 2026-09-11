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

- Final accepted implementation: `T23_Stage4F_v2_CollisionAware_RemainingPower.pas`; v1 preflight-aborted before adding objects because the first SD_VDD corridor crossed `R_MISO.2`.
- v2 corrected the SD_VDD main vertical rail to `X=7002.5mil`, centered in the legal gap between `R_MISO_PD.1` and `R_MISO.2`.
- Completed `SD_VDD` distribution including Q_SD, bulk/mid/HF capacitors, SD ESD arrays, J_SD.4, and R_CS_PU.2.
- Completed `VBAT`: U_RTC.14 -> BT2.1 -> TP_VBAT, using Bottom trunk plus Top test-point branch.
- Completed `USB_5V_AUX`: R_EXP_PWR_EN.2 -> J_EXP_PWR.1/J_EXP_PWR.2.
- Script requested 24 tracks / 0 vias and PASSed full-stage exact collision preflight.
- User confirmed DRC after Stage 4F: only the same 3 expected GND Net Antennae; zero new Clearance / Short / Width / Solder Mask Sliver violations.
- Saved PCB checkpoint containing Stage 4F: `f2a7e90127879cc40855345699ca847759019d09`.
- Fresh post-Stage-4F collision snapshot: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`, commit `b5c9aea39d413fb2ff877b608fbe41d2106da104`.

## Collision-aware routing method — MANDATORY FOR DENSE ROUTING

- Accepted exporter: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Treat Multi Layer pads as copper obstacles on both Top and Bottom.
- Include existing track width, via copper envelope, and required clearance.
- Protect via-to-pad solder-mask sliver, including same-net pads.
- Full-stage preflight must occur before adding the first PCB object whenever practical.
- DRC is final verification only, not a route-finding tool.
- If preflight fails, abort instead of applying a guessed route.
- Preserve one-transaction / one-Ctrl+Z rollback for scripted routing stages.
- Do not create the Bottom GND polygon until major routing is complete.
- User prefers larger logical routing bundles where safe; collision safety overrides bundle size.
- Routing deliverables must be `.pas` only.
- Do not use absolute final Track-object count as the sole PASS/FAIL gate; Altium may split/merge track primitives. Use script-added object counts, connectivity analysis, preflight, and DRC.

## Current exact PCB state

Authoritative PCB checkpoint:

`f2a7e90127879cc40855345699ca847759019d09`

Fresh collision snapshot:

`b5c9aea39d413fb2ff877b608fbe41d2106da104`

Current accepted relevant state:

- `BAT_RAW`, `USB_VBUS_RAW`, `BAT_FUSED`, `BAT_SW` routed.
- `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, `USB_CC2` routed.
- `VIN_MUX`, `OLED_VDD`, `SENSOR_3V3` routed.
- `SD_VDD`, `VBAT`, `USB_5V_AUX` routed.
- `CC1_RD_RET` / `CC2_RD_RET` remain unrouted.
- Global `3V3_SYS` still requires power-distribution completion.
- Expansion signal routing remains later work; `R_EXP_PWR_EN.1` is still on `USB_VBUS_PROT` and was intentionally not altered by Stage 4F.

## Immediate next action

Continue **Stage 4G — USB-C CC return completion** from post-Stage-4F collision snapshot `b5c9aea3...`.

- Route `CC1_RD_RET`: `R_CC1.2 -> S1.5`.
- Route `CC2_RD_RET`: `R_CC2.2 -> S1.7`.
- Prefer Bottom-layer long runs with controlled vias near the SMD resistors to avoid the dense OVP/PMUX Top copper.
- Full-stage exact collision preflight must PASS before adding anything.
- Keep the global `3V3_SYS` for the following dedicated power-distribution stage; it is physically broad and should not be mixed into the CC-return geometry merely to inflate route count.

After script PASS:

1. Do NOT save immediately.
2. Run DRC.
3. Accept only with zero new Clearance / Short / Width / Solder Mask Sliver violations.
4. The only expected remaining violations are the same 3 pre-existing GND Net Antennae.
5. If DRC passes, save PCB and run `Git_Save.cmd`.
6. Generate a fresh collision snapshot before the next dense routing bundle.

## Physical-routing preferences

- PCB is 2-layer.
- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
