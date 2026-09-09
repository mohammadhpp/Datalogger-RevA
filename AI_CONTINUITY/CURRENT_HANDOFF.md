# CURRENT HANDOFF — Datalogger RevA

Last continuity update: 2026-09-09

## Repository / backup state

- Authoritative repository: `mohammadhpp/Datalogger-RevA` (private), branch `main`.
- Local working repo: `C:\#MHP FILES\DataLoger`.
- Local bare backup remote: `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
- Online remote: `github` -> `https://github.com/mohammadhpp/Datalogger-RevA.git`.
- `main` remains upstream-tracked to `localbackup/main`; GitHub is intentionally a second remote, not the upstream replacement.
- `Git_Save.cmd` / `Git_Save.ps1` standard is **v2.5 one-click sync**.
- Normal user workflow: run `Git_Save.cmd` only. It checks/fetches GitHub, safely fast-forwards incoming non-diverged updates, checkpoints local changes if present, then synchronizes `localbackup`, GitHub, and tags.
- If local and GitHub histories truly diverge, the script must stop rather than auto-merge Altium/binary project files.

## Chat continuity management

- Long-project chat threshold: approximately **70% of usable conversation context**.
- Before the chat becomes heavy or continuity degrades, proactively warn the user, update Git handoff/continuity files, and recommend continuing in a fresh chat.
- New sessions must begin from `AI_START_HERE.md` and follow its required read order.

## CURRENT EXACT POINT

### Major task

**T23 — PCB routing / placement refinement**

### Completed baseline routing

- Routing Stage 1: completed.
- Routing Stage 2 v3: completed.
- Controlled routing count before Stage 3: **48 tracks + 3 GND vias**.
- Earlier routed/control nets include `NetL1_1`, `NetL1_2`, `VIN_MUX`, `MODE_PFM`, `FB_3V3`, `3V3_SYS`, and GND-related vias.
- Bottom GND polygon has not yet been created as the final ground-plane solution.

### DRC checkpoint baseline

- DRC after Stage 1 + Stage 2 v3: **PASS except 3 expected GND Net Antennae**.
- No Clearance, Short-Circuit, Width or other unexpected routing violations were reported.
- The 3 Net Antennae are the existing GND vias before the final GND polygon.

### Stage 3A — USB_OVP_IN — PASS

- Script: `T23_USB_OVP_IN_Route_v1`.
- Result: **21 Top-Layer tracks, 0 vias**.
- Main power path 30mil; fine/sensing branches 8mil.
- Post-stage DRC: only the same 3 GND Net Antennae.

### Stage 3B — USB_VBUS_PROT local routing — PASS

- Final accepted implementation: `T23_USB_VBUS_PROT_Route_v4`.
- Seven local USB_VBUS_PROT pads are connected.
- `R_EXP_PWR_EN.1` is intentionally deferred to the Expansion routing stage because it is a remote low-current branch.
- TP_USB_PROT branch uses **2 controlled vias** and Bottom Layer rather than a long Top-layer detour.
- Main protected USB power path remains on Top Layer.
- Post-stage DRC: no new Clearance/Short/Width violations; only the same 3 GND Net Antennae.
- Saved/checkpointed on GitHub in commit `84a5121c25ae00802ceb3ef701ca888dbf3c9ea3`.

### Stage 3C1 — OVP_BASE — PASS after manual correction

- Initial scripted route created an OVP_BASE crossing that produced a Clearance violation and a Short-Circuit with the existing USB_OVP_IN route.
- User manually corrected the OVP_BASE geometry so it crosses the USB_OVP_IN trunk on Bottom Layer instead of intersecting it on Top.
- Final DRC after manual correction returned to **only the same 3 GND Net Antennae**.
- Therefore OVP_BASE is **PASS**.
- Final accepted OVP_BASE geometry is the user's manually corrected route, not the original Stage3C1 scripted geometry.
- Saved/checkpointed on GitHub in commit `41c59d98698a30f89cbb873a607a72ee97c585dc`.

### Snapshot discipline

- Machine-readable board snapshots are generated from the live Altium PCB object model with `T23_AI_Board_Snapshot_Exporter_v1_2`.
- Existing snapshot `AI_BOARD_SNAPSHOT_T23_20260909_163016.tsv` predates the user's final manual OVP_BASE correction.
- **Before building Stage 3C2 OVP_GATE, generate and sync a fresh snapshot so routing scripts use the current accepted geometry.**
- Do not build new dense routing scripts from stale snapshots.

### Remaining OVP work

Next controlled substage:

- **Stage 3C2 — OVP_GATE**

Then:

- **Stage 3D — OVP_REF / OVP_K / NetR_K1_1 / NetR_K2_1 and associated K-chain / divider routing**
- OVP block audit + DRC.

### High-level continuation order

1. Complete OVP Stage 3C2 and 3D.
2. Finish remaining Power / USB / OVP and power-distribution routing.
3. MCU core and local decoupling.
4. microSD.
5. RTC.
6. OLED / SHT3x.
7. Navigation / Expansion / connectors and remaining miscellaneous nets.
8. Only after major signal/power routing is complete: create/pour Bottom Layer GND polygon.
9. Repour, inspect return paths/islands, add GND stitching vias only where justified.
10. Final DRC / manufacturing-readiness audit.

## Current physical-routing preference

- Give `U_SYS` and dense IC areas more assembly/rework space.
- Do not let thick tracks crowd fine-pitch IC pads; use controlled neck-down near pins where electrically acceptable.
- Preserve clear component reference designators and orientation/polarity marks for manual assembly.

## DRC interpretation note

The three existing GND vias currently appear as `Net Antennae` before the final GND polygon is present. Do not force an early polygon solely to silence those warnings.

## Next AI action

Wait for a fresh live-board snapshot generated after commit `41c59d9`. Then inspect the current OVP_BASE / USB power / nearby Top+Bottom track geometry and build the controlled **Stage 3C2 OVP_GATE** routing script from that fresh snapshot. Keep exact pad/net verification, no component movement, no polygon, no auto-save, one-transaction undo, visual inspection and DRC before checkpointing.
