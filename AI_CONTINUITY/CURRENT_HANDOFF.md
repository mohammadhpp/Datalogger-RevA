# CURRENT HANDOFF — Datalogger RevA

Last continuity update: 2026-09-09

## Repository / backup state

- Authoritative repository: `mohammadhpp/Datalogger-RevA` (private), branch `main`.
- Local working repo: `C:\#MHP FILES\DataLoger`.
- Local bare backup remote: `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
- Online remote: `github` -> `https://github.com/mohammadhpp/Datalogger-RevA.git`.
- `main` remains upstream-tracked to `localbackup/main`; GitHub is intentionally a second remote, not the upstream replacement.
- `Git_Save.cmd` / `Git_Save.ps1` standard is now **v2.5 one-click sync**.
- Normal user workflow: run `Git_Save.cmd` only. It checks/fetches GitHub, safely fast-forwards incoming non-diverged updates, checkpoints local changes if present, then synchronizes `localbackup`, GitHub, and tags.
- If local and GitHub histories truly diverge, the script must stop rather than auto-merge Altium/binary project files.
- Local backup remains the required safety path; GitHub is the online continuity/secondary backup path.

## Chat continuity management

- Long-project chat threshold: approximately **70% of usable conversation context**.
- Before the chat becomes heavy or continuity degrades, proactively warn the user, update the Git handoff/continuity files, and recommend continuing in a fresh chat.
- Do not wait for the user to detect degraded context quality.
- New sessions must begin from `AI_START_HERE.md` and follow its required read order.

## CURRENT EXACT POINT

### Major task

**T23 — PCB routing / placement refinement**

### Completed routing state carried forward

- Routing Stage 1: completed.
- Routing Stage 2 v3: completed.
- Controlled routing count recorded in the handoff lineage: **48 tracks + 3 GND vias**.
- Known routed/control nets in this phase include: `NetL1_1`, `NetL1_2`, `VIN_MUX`, `MODE_PFM`, `FB_3V3`, `3V3_SYS`, and GND-related vias.
- Bottom GND polygon has not been created/poured as the final ground-plane solution yet.

### Important correction to prior sequence

Do **not** proceed directly from Stage 2 to the Bottom Layer GND Polygon.

The board still has additional signal/power blocks to complete. Pouring the final polygon too early would create unnecessary repours, obscure ratsnest visibility, complicate routing decisions, and can hide return-path problems until later.

### Correct next sequence

1. Run a checkpoint DRC to confirm Stage 1 + Stage 2 routing did not introduce real clearance/short/width errors.
2. Treat unrouted-net violations from untouched blocks as expected at this stage.
3. Complete remaining signal and power routing block-by-block.
4. Recommended priority:
   - Remaining Power / USB / OVP and power-distribution routing.
   - MCU core and local decoupling routing.
   - microSD.
   - RTC.
   - OLED / SHT3x.
   - Navigation / Expansion / connectors and remaining miscellaneous nets.
5. Only after major signal/power routing is complete: create/pour Bottom Layer GND polygon.
6. Repour, inspect return paths/islands, add GND stitching vias only where justified.
7. Final DRC / manufacturing-readiness audit.

## Current physical-routing preference

- Give `U_SYS` and dense IC areas more assembly/rework space.
- Do not let very thick tracks visually/mechanically crowd IC pads. Use controlled neck-down near IC pins where current/thermal requirements allow, then widen after leaving the pad escape region.
- Preserve clear component reference designators and orientation/polarity marks for manual assembly.

## DRC interpretation note

The three existing GND vias may appear as `Net Antennae` before the final GND polygon is present. Do not force an early polygon solely to silence those warnings.

## Next AI action

Before instructing new routing, inspect the latest `DATALOGER_RevA.PcbDoc` / project state and identify the next unfinished block. Continue block-by-block and record completion here at each meaningful checkpoint.
