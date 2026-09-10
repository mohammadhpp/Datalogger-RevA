# CURRENT HANDOFF — Datalogger RevA

Last continuity update: 2026-09-10

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
- Final accepted count: `BAT_SW=9 tracks / 3 vias`.
- Main input path uses 30mil; PMUX approach uses controlled 8mil neck-down.
- User confirmed DRC clean except the same 3 expected GND Net Antennae.
- Saved PCB checkpoint: `98d7fbcd03e8a4711be81ac990098328ac35d0b0`.
- Fresh legacy snapshot after Stage 4C: `AI_BOARD_SNAPSHOT_T23_20260909_224523.tsv`, commit `5f0b439b3974bf44394882b689390efbfddc62fc`.

### Stage 4D — PMUX / USB control bundle — PREVIOUS v1-v4 REJECTED / NOT SAVED

- Attempts v1 through v4 were deliberately rejected after DRC exposed different collisions.
- These failed attempts are NOT part of the authoritative PCB baseline.
- User correctly stopped the trial-and-error workflow.
- Root cause: routing was being generated from point coordinates without treating full pad copper, multilayer pads, existing track widths and via envelopes as explicit obstacles.
- Key lesson: DRC must be final confirmation, not the route-finding mechanism.

## Collision-aware routing method — NOW REQUIRED

The project has switched to a collision-aware route-planning workflow for dense routing blocks.

### Collision snapshot

- Exporter accepted: `T23_AI_Board_Collision_Snapshot_Exporter_v1_3_2.pas`.
- Output: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`.
- Snapshot commit: `ff49c9bd0f52460a858f1f04dcb69c328c354c98`.
- Snapshot source PCB is the accepted Stage 4C v3 board.
- Snapshot includes conservative pad bounding rectangles, all tracks with width/bounding rectangles, vias with diameter/hole/bounding rectangles, plus fill/region/arc sections.
- No Bottom GND polygon exists yet.

### Mandatory dense-routing discipline

1. Use the collision snapshot and/or live PCB object model as the obstacle model.
2. Treat Multi Layer pads as copper obstacles on both Top and Bottom.
3. Include existing track width, via copper envelope, and required clearance in route planning.
4. Include via-to-pad solder-mask-sliver protection, including same-net pads.
5. Candidate routing must pass collision preflight BEFORE it is accepted for DRC.
6. DRC is final verification only.
7. If collision preflight fails, abort the stage rather than trying a guessed corridor.
8. Preserve one-transaction / one-Ctrl+Z rollback for scripted routing stages.
9. Continue without Bottom GND polygon until major routing is complete.
10. User prefers larger logical routing bundles where safe, but safety/collision validation overrides stage size.
11. For routing deliverables, provide only `.pas` files, not ZIP/PrjScr bundles.

## Current exact PCB state

Authoritative PCB checkpoint remains:

`98d7fbcd03e8a4711be81ac990098328ac35d0b0`

Collision snapshot baseline:

`ff49c9bd0f52460a858f1f04dcb69c328c354c98`

Current relevant accepted counts:

- `BAT_RAW = 3 tracks / 0 vias`
- `USB_VBUS_RAW = 6 tracks / 0 vias`
- `BAT_FUSED = 10 tracks / 2 vias`
- `BAT_SW = 9 tracks / 3 vias`
- `PMUX_PR1 = 0 tracks / 0 vias`
- `PMUX_ST = 0 tracks / 0 vias`
- `USB_CC1 = 0 tracks / 0 vias`
- `USB_CC2 = 0 tracks / 0 vias`

## Immediate next action

Run the new collision-aware coordinated Stage 4D script only after its internal live-board preflight passes.

The new Stage 4D strategy is allowed to surgically move only the low-current `BAT_SW` test-point Bottom branch if required to open a legal PMUX corridor, while preserving the accepted main BAT_SW power path. Then route a larger logical bundle including `PMUX_PR1`, `PMUX_ST`, `USB_CC1`, and `USB_CC2`.

After script PASS:

1. Do NOT save immediately.
2. Run DRC.
3. Accept only with zero new Clearance / Short / Width / Solder Mask Sliver violations.
4. The only expected remaining violations are the same 3 pre-existing GND Net Antennae.
5. If DRC passes, save PCB and run `Git_Save.cmd`.
6. Generate a fresh collision snapshot before the next dense power-distribution block if geometry changes materially.

## Physical-routing preferences

- Give `U_SYS` and dense IC areas enough assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down near pins where electrically acceptable.
- Preserve readable RefDes and orientation/polarity marks for manual assembly.
- Every off-board/panel device must have a deliberate PCB-side connector/termination path.

## DRC / audit notes

- The 3 existing GND vias appear as Net Antennae until the final Bottom GND polygon exists. Do not create an early polygon just to silence them.
- Valid pad connectivity does not require track endpoints to coincide with pad centers; edge-entry into pad copper is valid and audit tools must account for that.
