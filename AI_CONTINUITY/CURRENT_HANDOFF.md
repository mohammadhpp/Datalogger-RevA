# CURRENT HANDOFF — Datalogger RevA

## Git checkpoint — 2026-09-22 20:38 +03:30

Git AutoSave recovery completed successfully.
- `Git_Save.ps1` / launcher upgraded to **v2.5.1** to avoid raw quoted filenames in native `git commit -m` arguments.
- recovery checkpoint: `e9957b8f3b56981deb7769282e02ef1ac30f8b95`;
- `HEAD`, `localbackup/main`, and `github/main` were user-confirmed aligned at the checkpoint;
- six current T24 working artifacts were committed, including `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, DRC outputs, and the existing Step2 preflight reports.
- This checkpoint records the current experimental PENDING PCB; it does **not** promote it over the original main PCB.
- Exact engineering next action is unchanged: run **only** `PreflightT24_Courtyard_Step2A_Apply13_v2`. Do not Apply and do not Save after that preflight until its report is reviewed.

## Git checkpoint — 2026-09-22

Registered in the private repository after the T24 Step2 parser recovery:
- current PCB remains `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`; no PCB Save is confirmed from the failed compile attempts;
- Step2A baseline and collision preflight reports are recorded;
- latest parser-compatible candidate is `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v2.pas` with commit `80a52260bc3dbd0ef661ef2c4e4e7c0aef335a6c`;
- concise new-chat handoff is `AI_CONTINUITY/PASTE_THIS_INTO_NEW_CHAT_T24_STEP2.txt` with commit `05da0e5fb3f7432f637ead19bd387bef2fc7d340`;
- next execution remains Preflight only: `PreflightT24_Courtyard_Step2A_Apply13_v2`.


## CURRENT EXACT POINT — Apply13 v2 second parser fix, 2026-09-22

User attempted `T24_Courtyard_Step2A_Apply13_v2.pas`. Altium then reported `Error in declaration block` at the postcheck function. Cause identified: local variable `OR` conflicts with the reserved DelphiScript logical operator `Or`. Renamed it to `ORight`.

Use the refreshed same-named v2 file from GitHub or the new download supplied by this session. New commit: `80a52260bc3dbd0ef661ef2c4e4e7c0aef335a6c`. The preflight entry remains `PreflightT24_Courtyard_Step2A_Apply13_v2`. No PCB modification or Save is confirmed from this parser-error attempt.


## CURRENT EXACT POINT — Apply13 parser fix, 2026-09-22

User attempted the first Apply13 script and Altium reported `Else expected` while compiling. Root cause identified: DelphiScript does not support Delphi `Exception.Create`; it requires textual `Raise('...')`. The corrected parser-compatible script is:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v2.pas`
- commit `1ad86ce5586c3d316604813ccf835a00ef583da4`
- entry `PreflightT24_Courtyard_Step2A_Apply13_v2`; Apply entry remains `ApplyT24_Courtyard_Step2A_Apply13_v2` and must wait for preflight review.
The prior v1 path was updated too, but use v2 to avoid stale local copies. No PCB change or Save is confirmed from the parser-error attempt.


## CURRENT EXACT POINT — Collision preflight complete; conservative 13-target plan, 2026-09-22

User ran `PreflightT24_Courtyard_Step2A_Collision_v1` on the PENDING board. Output reports 11 potential AABB hits under 10 mil. The report is read-only and is not DRC PASS. Confirmed pairs:
- candidate/candidate: Q_OLED/C_OLED_BULK = 3.464 mil; D_ESD2/C_SD_MID = overlap;
- candidate/existing: Q_SD with Q_SD_DRV and C_SD_BULK1/2; Q_OLED with Q_OLED_DRV; J_NAV with D_NAV1; D_ESD2/D_ESD1 with C_SD_HF; C_SENSOR_BULK with C_SENSOR_HF; C_OLED_BULK with C_OLED_HF.

Engineering disposition for the next controlled step: the previous `PAD/M1 union + 10 mil` candidate was overconservative because the ComponentClearance rule already enforces 10 mil between courtyard boundaries. A revised candidate uses the audited PAD/M1 union itself, with 0.05 mm track width, and rechecks all 13 non-border targets. Static screening with the line half-width leaves no <10 mil AABB hits for those 13. `D_ESD1` and `D_ESD2` remain deferred because both border C_SD_HF at/under the 10 mil limit; `J_SD` remains deferred pending exact MR01A-01245 body drawing. This is a geometry disposition for a controlled test, not a blanket approval.

Prepared script:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Apply13_v1.pas`
- commit `5606ce0a174865fb13d5228c7079c061c2c1f323`
- entry `PreflightT24_Courtyard_Step2A_Apply13_v1`, then (only after separate confirmation) `ApplyT24_Courtyard_Step2A_Apply13_v1`;
- adds 13 rectangles / 52 tracks, union-only geometry; baseline guards 129 components / 113 courtyard-covered; expected post-state 126/129 covered.

NEXT: run only `PreflightT24_Courtyard_Step2A_Apply13_v1` on PENDING and return `T24_Courtyard_Step2A_Apply13_Preflight_v1.txt`. Do not Apply or Save yet. After PASS, run Apply, then full Batch DRC before any Save. Silk and D_ESD1/D_ESD2/J_SD remain pending.


## CURRENT EXACT POINT — Step2A baseline preflight PASS, collision gate pending, 2026-09-22

User ran `PreflightT24_Courtyard_Step2A_v2` on `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`. Result: **BASELINE PASS ONLY**; 129 components, 113 already courtyard-covered, 15 targets verified; no PCB change. Output: `T24_Courtyard_Step2A_Preflight_v2.txt`.

The report is not a clearance PASS. Static geometry screening found candidate rectangles that must be checked before Apply. Candidate/candidate pairs: `Q_OLED` / `C_OLED_BULK` gap about 3.464 mil; `D_ESD2` / `C_SD_MID` overlap. Candidate-to-existing courtyard AABB screening also finds several target bounds under 10 mil from existing courtyards, including Q_SD vs C_SD_BULK1/2, Q_OLED vs Q_OLED_DRV, J_NAV vs D_NAV1, D_ESD2/D_ESD1 vs C_SD_HF, and C_SENSOR_BULK vs C_SENSOR_HF. These are screening results, not final geometric DRC results, but they block a blind 15-target Apply.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Collision_Preflight_v1.pas`
- commit `42159f53090f958183f6275227c0f840398d7095`
- entry: `PreflightT24_Courtyard_Step2A_Collision_v1`
- output: `T24_Courtyard_Step2A_Collision_Preflight_v1.txt`
- checks the live PENDING board, M2/M4 pair, baseline counts, target-to-target candidate rectangles and target-to-existing courtyard AABB gaps; read-only.

NEXT: run only `PreflightT24_Courtyard_Step2A_Collision_v1` and return the TXT. Do not run any Step2A Apply script yet. No PCB Save. After the live collision report, disposition each hit as body/footprint geometry or real placement clearance before adding any courtyard. J_SD body geometry and yellow silkscreen remain pending.


## CURRENT EXACT POINT — Step2A parser recovery, 2026-09-22

User screenshot reports `Program name expected` while attempting Step2A v1. No successful preflight or Apply is confirmed. Exact parser cause is NOT established by the screenshot.
Use `AI_SCRIPTS/T24/T24_Courtyard_Step2A_Preflight_v2.pas`, entry `PreflightT24_Courtyard_Step2A_v2`, on the PENDING PCB. This read-only rewrite removes arrays, prefixes helper names (including Near), and removes the Apply code from this diagnostic file. All 15 expected geometry tuples and baseline guards are preserved. Static checks passed; live Altium compile/execution is still unverified.
NEXT: user runs v2 preflight and returns `T24_Courtyard_Step2A_Preflight_v2.txt` or the exact error. Do not run v1 Apply. Candidate clearance conflicts, J_SD body drawing and yellow silkscreen outlines remain unresolved. No PCB change/save is requested by this recovery step.


Last continuity update: 2026-09-22 — Courtyard M2/M4 confirmed; By Layer active after restart; PENDING copy has one reported Component Clearance violation; Step2 read-only geometry preflight ready.


## Latest Step2 planning update — 2026-09-22
User supplied T24_Step2_Geometry_Preflight_v1.txt: 17/17 target measurements complete, on PENDING. This is data completeness, not DRC PASS.
Prepared AI_SCRIPTS/T24/T24_Courtyard_Step2A_v1.pas (not executed in Altium).
NEXT: run ONLY PreflightT24_Courtyard_Step2A_v1 and return T24_Courtyard_Step2A_Preflight_v1.txt. Do not Apply yet.
Candidate geometry: 15 missing courtyards, pad/M1 envelope union expanded by 10 mil each side; 60 component-owned tracks, 0.05 mm width, M4 for U_RTC and M2 for other 14. Engineering allowance, not a claim of IPC-certified envelopes.
J_SHIELD uses solder-land envelope; wire/strain-relief envelope still requires review.
J_SD deferred: no M1/body; M3 has two internal rectangles, cannot serve as full package courtyard. Exact MR01A-01245 drawing still needed. A web PDF found by search was a different manufacturer's drawing and was NOT used.
Known candidate issues: C_SD_MID / D_ESD2 rectangles overlap; C_OLED_BULK / Q_OLED gap about 3.464 mil (<10 mil rule). Existing neighbour courtyards also need checking. Do not shrink boundaries or relax rule merely to hide violations.
Q_OLED has remote Top Overlay fill at x=5580.444..5600.444 mil; its pad/M1 left bound is 5650.945 mil, while R_OLED_GATE courtyard right centerline is 5597.559 mil. This supports a fallback-boundary artifact explanation for current violation; it is not a final physical fit certification.
Silk inventory received for all 129 components. Silk repair remains pending and is not included in Step2A.
The candidate script has guards for PENDING filename, M2/M4 pair, 129 total/113 courtyard-bearing components, target positions/sides/rotations, pad and M1 counts/bounds, and no existing target courtyard. Postcheck expects 60 tracks/4 per target. Static checks only; live Altium execution remains unverified.

## Latest continuation — 2026-09-22 (supersedes older next-action blocks)

- User screenshot verified Top M2 / Bottom M4 pair has Layer Type Courtyard.
- PCB.ComponentSelection was 2 (By Graphic). User changed to 1 (By Layer).
- Altium required restart. User saved a separate copy:
  `DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc`, then restarted and ran DRC on that copy.
- Latest screenshot shows one Component Clearance violation: Q_OLED versus R_OLED_GATE, collision <10 mil; previous list had 21.
- This is not final DRC PASS or fabrication acceptance. Sixteen components still lack courtyard geometry.
- PENDING is the current experimental candidate; original main PCB has not been replaced by this session.
- User uploaded PENDING for direct inspection. CFB parsing found 129 components, no ComponentBodies6 data, 440 M2 tracks and 12 M4 tracks. Q_OLED has M1 outline but no M2 tracks. J_SD has M3 geometry; J_SHIELD has no mechanical track outline.
- User also requests missing yellow silkscreen outlines. Audit Top/Bottom Overlay separately from courtyard; preserve RefDes/polarity and mask clearance. A full closed silk rectangle is not mandatory.
- Do not infer real body collision solely from the remaining message, or infer correct physical clearance solely from disappearing messages.

Exact next action:
1. Keep PENDING active in Altium.
2. Run `PreflightT24_Step2_Geometry_v1` from `AI_SCRIPTS/T24/T24_Step2_Geometry_Preflight_v1.pas`.
3. Upload `T24_Step2_Geometry_Preflight_v1.txt`.
4. Script is READ ONLY, derived from the previously used mechanical-envelope exporter; includes 16 missing components plus R_OLED_GATE, M1/M2/M3/M4, both overlays, individual primitive bounds, track centerlines, and board-wide silk track/arc inventory. Text is excluded from measured envelopes.
5. It has not been executed in Altium by the assistant. DATA COMPLETE means coverage only, not geometry approval or DRC PASS.
6. Use live report plus source package geometry to plan controlled courtyard additions and silk repairs. No Apply script is approved yet. Do not shrink courtyard or loosen 10 mil rule to silence errors.
7. Retain saved PENDING recovery copy; do not promote it over the original PCB until validated.

## Repository / backup state

- Authoritative repository: `mohammadhpp/Datalogger-RevA` (private), branch `main`.
- Local working repo: `C:\#MHP FILES\DataLoger`.
- Local bare backup remote: `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
- Online remote: `github` -> `https://github.com/mohammadhpp/Datalogger-RevA.git`.
- Standard save/sync workflow remains `Git_Save.cmd` / v2.5 discipline.
- Do not auto-merge Altium binary files if histories diverge.

## Authoritative final T23 checkpoint

Latest verified post-pour checkpoint:

- Git commit: `a1e4193edacf4f03da623616e470258cd1dc147e`
- Commit message:
  `Auto checkpoint 2026-09-20 21:12:25 | 2 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc`
- PCB file: `DATALOGER_RevA.PcbDoc`
- PCB blob: `14ab76655a6c750f09f39ef1157b04ccf58efcdd`
- Full collision snapshot: `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv`
- Snapshot blob: `4dbd82e0f34303c07a594904a92663cfe4926577`
- Snapshot exporter: `T23_AI_FullBoard_Snapshot_Exporter_v1_4_2`
- Snapshot generated: `2026-09-20 21:12:08`

## CURRENT EXACT POINT

### Major task

**T24 — Board release / manufacturing-prep refinements — ACTIVE**

**T24 Stage1 — Top silkscreen branding — PASS / SAVED**

**T24 Stage2A — Top GND polygon — PASS / SAVED / CLOSED**

**Current exact point: M2/M4 Courtyard type CONFIRMED; PCB.ComponentSelection=1 applied after restart; active candidate is DATALOGER_RevA_T24_Courtyard_PENDING.PcbDoc; Step2 geometry report received; run ONLY Step2A baseline preflight, Apply held for candidate-clearance review.**

T23 remains formally CLOSED / PASS and must not be casually reopened.

The 2-layer PCB major signal/power routing, GND fanout, final Bottom Layer GND polygon, and full post-pour DRC have been completed.

### Final routing / GND closeout

- All previously remaining Top-side GND groups were given deliberate Bottom-layer access before the polygon stage.
- Final custom NAV fix:
  - `D_NAV1.2` GND escape completed.
  - `NetD_NAV1_3` upper via moved to `(7159.842,6780)`.
  - Bottom reroute retained continuity through:
    - `(7210,6660) -> (7180,6690)`
    - `(7180,6690) -> (7180,6760)`
    - `(7180,6760) -> (7159.842,6780)`
  - Final GND via for `D_NAV1.2` at `(7210,6720)`.
- Before polygon creation, verified Top-only GND groups = **0**.

### Stage9A — Bottom GND polygon — PASS / SAVED

- One polygon created on **Bottom Layer**.
- Polygon net: **GND**.
- Polygon geometry copied from the live Altium `BoardOutline`, not from a guessed hard-coded rectangle.
- BoardOutline point count copied: **8**.
- Final snapshot polygon metadata:
  - polygon count = **1**
  - `NET = GND`
  - `LAYER = Bottom Layer`
  - `POURED = 1`
  - point count = **8**
  - bounding box:
    - left `3937.008 mil`
    - bottom `3937.008 mil`
    - right `7874.016 mil`
    - top `7086.614 mil`
- Final GND object counts:
  - **117 GND tracks**
  - **46 GND vias**
- Polygon creation did not change these track/via counts.

### Final validation

User ran a full Altium Design Rule Verification after the Bottom GND polygon was poured.

Final DRC result shown in Altium:
- **Warnings: 0**
- **Rule Violations: 0**

Therefore the old pre-polygon GND Net Antennae are no longer an accepted outstanding condition. The saved post-pour PCB is the new clean baseline.

## T24 Stage1 — Top silkscreen branding — PASS / SAVED

User approved adding a monochrome branding mark in the intentionally empty lower-left board area.

Final branding content:
- approved chibi portrait logo
- line 1: `SANAT NEGAR`
- line 2: `M.PAHLAVIAN`

Placement / physical implementation:
- Layer: **Top Overlay**
- nominal placement rectangle used by the script:
  - X = `4910 .. 5390 mil`
  - Y = `4360 .. 4820 mil`
- actual occupied artwork bounds in the saved snapshot:
  - left = `4934 mil`
  - bottom = `4364 mil`
  - right = `5362 mil`
  - top = `4816 mil`
- implementation: **964 Top Overlay fill runs**
- copper, pads, vias, routing, and GND polygon were not intentionally modified by the logo operation.

Validation:
- user visually approved the placed logo.
- user reported **DRC OK** after placement.
- final saved Git checkpoint containing the logo:
  - commit: `43306bfd199b10555d7fa2f5f45a8550b8363720`
  - message: `Auto checkpoint 2026-09-20 23:46:46 | 3 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc, DATALOGER_RevA_old.PcbDoc`
  - current PCB blob: `d0693aa37fb28879d4554db0c9037ccb7e666de2`
  - preserved pre-logo/old PCB copy added as `DATALOGER_RevA_old.PcbDoc`
    with blob `14ab76655a6c750f09f39ef1157b04ccf58efcdd`.

Logo-script history:
- v1.1 successfully created the logo, but its final `PCB:Zoom` redraw call left Altium with an active command, which blocked normal Save.
- the user safely preserved the modified PCB using Save Copy, closed Altium, restored the logo-bearing file as `DATALOGER_RevA.PcbDoc`, reopened it, and then saved normally.
- v1.2 is now the preferred script for any future reproduction:
  `AI_SCRIPTS/T24/T24_Stage1_TopSilk_Logo_v1_2.pas`
- v1.2 removes `RunProcess('PCB:Zoom')` entirely and must be preferred over v1.1.
- do **not** rerun the logo script on the current PCB; the logo already exists.

Current authoritative post-logo snapshot:
- exporter: **v1.4.2**
- Git commit: `c4d4ded070971ace30be2028eb9268d0daf515ca`
- snapshot blob: `67dd30455b10e159c27a4e68eaa3f9784a9f8735`
- generated: `2026-09-20 23:51:25`
- verified counts:
  - **117 GND tracks**
  - **46 GND vias**
  - **1 poured Bottom Layer GND polygon**
  - **964 Top Overlay logo fills**
- polygon metadata:
  - `NET = GND`
  - `LAYER = Bottom Layer`
  - `POURED = 1`
  - `POINT_COUNT = 8`
- saved logo occupied bounds remain:
  - X = `4934 .. 5362 mil`
  - Y = `4364 .. 4816 mil`

This v1.4.2 snapshot supersedes the temporary v1.3.2 post-logo snapshot caveat.

## T24 Stage2A — Top GND polygon — PASS / SAVED / CLOSED

A controlled solid **Top Layer GND polygon** was added after Stage1 branding.

Implementation:
- Script: `AI_SCRIPTS/T24/T24_Stage2A_Top_GND_Polygon_v1.pas`
- Script commit: `fb01c1fbdfe54c3a31568136ce8c4f10aa8a36ef`
- Polygon net: **GND**
- Layer: **Top Layer**
- Geometry copied from the live 8-point BoardOutline.
- Bottom GND polygon and completed T23 routing were not intentionally changed.
- No stitching vias were added in Stage2A.

Authoritative saved Stage2A checkpoint:
- Git commit: `c7c57171ca952ee28726ef206b83eb5daaae330e`
- Commit message:
  `Auto checkpoint 2026-09-21 00:18:04 | 2 file(s): AI_BOARD_COLLISION_SNAPSHOT_T23.tsv, DATALOGER_RevA.PcbDoc`
- Snapshot exporter: **v1.4.2**
- Snapshot generated: **2026-09-21 00:17:46**
- Snapshot verifies:
  - **2 poured GND polygons total**
  - **1 Bottom Layer GND polygon**
  - **1 Top Layer GND polygon**
  - both polygons have **8 points**
  - both use the same board bounds
  - **117 GND tracks**
  - **46 GND vias**

Validation:
- User ran full Altium DRC on the saved post-Stage2A PCB.
- User reported **DRC OK** on 2026-09-21.
- Stage2A is therefore formally **PASS / SAVED / CLOSED**.

### Current exact continuation point

Proceed to **T24 Stage2B planning** from the post-Stage2A v1.4.2 snapshot.
Do not rerun Stage2A.
Do not move existing T23 copper merely for cosmetic reasons.
Any new GND stitching vias must be planned against the current Top/Bottom poured copper and the full obstacle snapshot, then followed by polygon repour, full DRC, snapshot refresh, and Git checkpoint.

## T24 Top GND polygon — TRIPLE EXPERT REVIEW COMPLETE / KEEP

Authoritative current review:
- `AI_CONTINUITY/T24_TOP_GND_TRIPLE_EXPERT_REVIEW.md`
- review commit: `d4ab8897ffce69440d39219af3d829ddc376b836`

Final decision:
- **KEEP the existing Top Layer GND polygon.**
- The earlier single-pass recommendation to remove it is superseded.
- `AI_SCRIPTS/T24/T24_Remove_Top_GND_Polygon_DFM_v1.pas` is **OBSOLETE / DO NOT RUN**.
- The prior audit `AI_CONTINUITY/T24_TOP_GND_POLYGON_DFM_AUDIT.md` is marked superseded.

Key corrected finding:
- the 20 Top REGION records do not by themselves mean 20 bad islands; Altium solid polygon pours are represented by REGION primitives;
- snapshot review did not identify a clearly unanchored Top copper region;
- every Top REGION bounding area overlaps at least one GND pad or GND via;
- Stage2A Top polygon remains DRC-clean by user confirmation.

Three independent votes:
1. EMC / SI / PI: KEEP — additional grounded surface copper is electrically useful on this routed 2-layer board and controlled stitching improves the vertical GND connection.
2. DFM / Arya Madar: KEEP — removing the polygon does not remove the pre-existing sub-0.2 mm copper geometries or 0.30 mm drills that dominate the manufacturer's cost class. Verify thermal-relief behavior for manually soldered GND pads before release.
3. Reliability / change control: KEEP — no concrete defect has been demonstrated in the already saved, DRC-clean Top polygon; late deletion would be an unnecessary regression risk.

Exact next gate:
- DO NOT run the removal script.
- Stage2B v2 is again eligible to proceed.
- First run only `PreflightT24_Stage2B_GND_Stitching_v2`.
- Apply only after live preflight PASS.
- After Apply: Repour All Polygons → FULL DRC → save/snapshot/Git only if clean.
- Before final fabrication release, audit Polygon Connect Style / thermal relief for manual solderability.

## T24 Polygon Connect / Thermal Relief — DIRECT PCBDOC AUDIT COMPLETE

Authoritative audit:
- `AI_CONTINUITY/T24_DIRECT_PCBDOC_THERMAL_AUDIT.md`
- audit commit: `e43655fd089042323f5de0ac2031c2c86c696c23`
- uploaded/current PcbDoc Git blob verified exactly: `16f5576c1882a60a69a03b55c5456104be938911`

Direct Rules6 result:
- exactly one enabled `PolygonConnect` rule;
- Scope: `All`;
- Connect style: **Relief**;
- **4 spokes**;
- spoke width **10 mil**;
- air gap **10 mil**;
- angle **90°**.

Direct PadViaLibraryCache result:
- 48 templates total = 46 pad + 2 via templates;
- all 48 use **Relief / 10 mil air gap / 10 mil conductor / 4 entries / 90°**;
- zero `Direct` and zero `No Connect` textual connect-style records were found in the current PcbDoc.

Direct Polygons6 result:
- exactly 2 polygons;
- both are net index 71 = **GND**;
- Bottom: Solid / PourOver / RemoveDead / RemoveIslands; RemoveNarrowNecks=FALSE;
- Top: Solid / PourOver / RemoveDead / RemoveIslands / RemoveNarrowNecks=TRUE at 10 mil;
- both IgnoreViolations=FALSE.

Final thermal decision:
- component pads: **KEEP Relief** for manual solderability;
- Top GND polygon: **KEEP**;
- Bottom GND polygon: **KEEP**;
- GND vias: current global rule also makes routed vias Relief; for deliberate plane stitching, use a more-specific higher-priority Direct Connect rule for GND vias.

Required rule before Stage2B:
- Plane » Polygon Connect Style
- Scope: `IsVia AND InNet('GND')`
- Connect Style: **Direct Connect**
- Priority above the general `PolygonConnect` Relief rule.

Validation after rule change:
1. Repour All Polygons.
2. FULL DRC.
3. Do not save on any new violation.
4. If DRC clean: save PCB -> Snapshot Exporter v1.4.2 -> Git_Save.cmd.
5. Then run Stage2B v2 preflight/apply.

The previously prepared read-only script remains optional because the current PcbDoc was parsed directly and the rule values are now known.

## T24 GND-via Direct PolygonConnect rule — SCRIPT READY / NOT YET APPLIED

v1 Apply attempt aborted safely because `PCBObjectFactory(eRuleObject,...)` returned Nil; no rule or geometry was added. v1 is superseded and MUST NOT be rerun.

Prepared corrected controlled script:
- `AI_SCRIPTS/T24/T24_GND_Via_Direct_Rule_v2.pas`
- v2 commit: `15a00556d25bdb03deb9c346862f62cbcc50fcd9`
- v2 blob: `b38bed03e7f0548f05be0362925a58c3bba21cab`

Entry points:
- `PreflightT24_GND_Via_Direct_Rule_v2`
- `ApplyT24_GND_Via_Direct_Rule_v2`

New rule:
- name: `PolygonConnect_GND_Via_Direct`
- type: Polygon Connect Style
- scope: `IsVia AND InNet('GND')`
- style: **Direct Connect**
- expected new-rule priority: **1** (highest)
- existing general `PolygonConnect` Relief rule remains present and moves to lower priority.

v2 fix:
- uses documented `PCBServer.PCBRuleFactory(eRule_PolygonConnectStyle)` instead of `PCBObjectFactory` for rule creation.

Safety / validation:
- preflight requires current exact baseline: 42 rules / 1 PolygonConnect / 180 total vias / 46 GND vias / 2 GND polygons;
- existing general rule must be enabled Relief / Scope All / 10mil spoke / 4 entries;
- Apply adds only one rule; no routing/via/polygon geometry changes;
- post-apply expects 43 total rules and exactly 2 PolygonConnect rules;
- verifies new rule priority=1 and general rule lower priority;
- tests scope against real board objects:
  - GND via MUST match;
  - non-GND via MUST NOT match;
  - GND pad MUST NOT match;
- if any post-check fails: **DO NOT SAVE; one Ctrl+Z rolls back**.

Exact next action:
1. sync local repo with normal `Git_Save.cmd`;
2. open `AI_SCRIPTS/T24/T24_GND_Via_Direct_Rule_v2.pas`;
3. run **only** `PreflightT24_GND_Via_Direct_Rule_v2`;
4. expected: `PREFLIGHT PASS - T24 GND VIA DIRECT RULE v2`;
5. report the result before Apply;
6. after Apply success: **Repour All Polygons → FULL DRC**;
7. do not save until DRC is clean;
8. after DRC PASS: save PCB → Snapshot Exporter v1.4.2 → `Git_Save.cmd`;
9. only then continue to Stage2B v2.

## T24 expanded Batch DRC — OLD BASELINE VIOLATIONS EXPOSED

After GND-via Direct rule Apply and polygon repour, the user enabled a broader Batch DRC set. Result:
- 2 `Routing Via Style Violation` entries;
- multiple `Component Clearance Constraint Violation` entries.

The two RoutingViaStyle violations are NOT caused by the new PolygonConnect rule:
- `VIN_MUX` via at `(4480,5950)`: 27.559 mil diameter / 11.811 mil hole;
- `VIN_MUX` via at `(5235,5830)`: 27.559 mil diameter / 11.811 mil hole.
Both are present in the saved pre-change snapshot and therefore pre-existing.

Direct current PcbDoc Rules6 audit shows:
- `RoutingVias` rule is Scope=All;
- Min/Preferred/Max diameter are all fixed at **23.622 mil**;
- Min/Preferred/Max hole are all fixed at **11.811 mil**.
Therefore the two existing 27.559-mil vias violate the old overly-narrow rule.

The same old rule would also reject the planned Stage2B vias at 31.496 / 17.717 mil.

Prepared controlled rule-range update:
- `AI_SCRIPTS/T24/T24_RoutingViaStyle_Range_v1.pas`
- commit: `be769502aa9f3ea4815f9dbc442443944a526233`
- changes RULE ONLY; no via geometry;
- new diameter allowed range: 23.622..31.496 mil (preferred 23.622);
- new hole allowed range: 11.811..17.717 mil (preferred 11.811).

Exact next action:
1. keep current PCB open; do not save yet;
2. run only `PreflightT24_RoutingViaStyle_Range_v1`;
3. if PASS, run `ApplyT24_RoutingViaStyle_Range_v1`;
4. rerun Batch DRC;
5. the ComponentClearance violations must then be audited separately before formal release acceptance.

ComponentClearance note:
- current PcbDoc rule is Scope All/All, Gap=10mil, CollisionCheckMode=3;
- these violations were hidden previously because Batch checking for Component Clearance had not been enabled;
- component placement was not changed by the GND-via Direct rule or polygon repour.

## T24 Expanded Batch DRC — ROOT-CAUSE STATUS

After GND-via Direct PolygonConnect v2 Apply + Repour, expanded Batch DRC showed:
- 2 × Routing Via Style violations;
- legacy Component Clearance violations that had not been part of the earlier Batch set.

The two Routing Via Style violations are both pre-existing VIN_MUX vias:
- (4480,5950) mil = 27.559 / 11.811 mil = 0.70 / 0.30 mm
- (5235,5830) mil = 27.559 / 11.811 mil = 0.70 / 0.30 mm

Snapshot comparison proves:
- 178/180 existing vias use the project standard 0.60 / 0.30 mm;
- all other audited power-net vias (BAT_FUSED, BAT_SW, USB_VBUS_PROT, 3V3_SYS) use 0.60 / 0.30 mm;
- the two VIN_MUX vias are the only 0.70 / 0.30 mm outliers;
- their drill remains 0.30 mm, so the barrel geometry is the same as the project standard.

Decision:
- DO NOT widen the generic RoutingVias rule merely to silence these violations.
- `T24_RoutingViaStyle_Range_v1.pas` is **OBSOLETE / DO NOT RUN**.
- Normalize the two actual via-pad outliers to the project standard.

Controlled fix:
- `AI_SCRIPTS/T24/T24_Normalize_VIN_MUX_Vias_v1.pas`
- commit: `72fda53b5a79b3fd994848f4ea467705a13c549c`
- entry points:
  - `PreflightT24_Normalize_VIN_MUX_Vias_v1`
  - `ApplyT24_Normalize_VIN_MUX_Vias_v1`
- target: change Size only from 27.559 mil to 23.622 mil on exactly the two VIN_MUX vias;
- HoleSize stays 11.811 mil;
- coordinates, net, layer span and routing stay unchanged.

After Apply:
- rerun Batch DRC;
- do not save until Component Clearance violations are separately dispositioned.

Stage2B remains paused. Its planned via geometry must be revisited after current DRC cleanup; the earlier 0.80/0.45 mm choice is not automatically carried forward.

## T24 Current DRC disposition — 21 Component Clearance only

Latest user-confirmed live sequence:
- `PolygonConnect_GND_Via_Direct` v2 Apply COMPLETE / scope self-test PASS.
- Repour All Polygons completed.
- First expanded Batch DRC exposed:
  - 2 pre-existing Routing Via Style violations on VIN_MUX;
  - old Component Clearance violations that had not previously been included in Batch DRC.
- The two VIN_MUX vias were normalized from 0.70/0.30 mm to the established project 0.60/0.30 mm standard using:
  - `AI_SCRIPTS/T24/T24_Normalize_VIN_MUX_Vias_v1.pas`
  - commit `72fda53b5a79b3fd994848f4ea467705a13c549c`
- User reran Batch DRC.
- Routing Via Style violations are now gone.
- Current Batch DRC shows exactly **21 Component Clearance Constraint Violations** and no Routing Via Style violations in the supplied result.
- Current candidate is therefore **NOT formal DRC PASS yet**.
- Do not save until these 21 placement/footprint-clearance items are dispositioned.

Root-cause discipline:
- `T24_RoutingViaStyle_Range_v1.pas` is **OBSOLETE / DO NOT RUN**; widening the rule is not the chosen solution.
- Do not disable or loosen Component Clearance merely to clear the report.
- Component Clearance rule currently found in the PcbDoc:
  - Scope1 = All
  - Scope2 = All
  - Gap = 10 mil
  - enabled
- Altium Component Clearance can use true 3D bodies; when those are absent or boundary checking is selected, component boundaries/selection geometry are used. Therefore each violation must be classified as real physical collision vs footprint/body-definition artifact before any fix.

Prepared read-only exporter:
- `AI_SCRIPTS/T24/T24_Component_Clearance_Violation_Audit_v1.pas`
- commit `df168d9c0c8217796f8e11e7d679adb7343851b5`
- entry: `AuditT24_Component_Clearance_Violations_v1`
- output: `T24_Component_Clearance_Violation_Audit.txt`
- reads current `eViolationObject` entries and exports full unclipped Altium descriptions and associated rule names;
- makes no PCB/rule/polygon/DRC changes.

Exact next action:
1. keep the current unsaved PCB open after the DRC;
2. run only `AuditT24_Component_Clearance_Violations_v1`;
3. send/upload `T24_Component_Clearance_Violation_Audit.txt`;
4. do not save, waive, move parts or edit Component Clearance yet;
5. then classify all 21 pairs and fix actual causes only.

## T24 Component Clearance pair resolution — 21/21 COMPLETE / BODY AUDIT NEXT

Latest v3 report:
- user report: `T24_Component_Clearance_Violation_Audit_v3.txt`
- all current violation objects = **21**
- Component Clearance violations = **21**
- resolved component/component pairs = **21**
- therefore pair identity is complete.

Current PcbDoc ComponentClearance rule was directly inspected:
- RuleKind = ComponentClearance
- Scope1 = All
- Scope2 = All
- Gap = 10 mil
- VerticalGap = 10 mil
- CollisionCheckMode = 3
- Altium API maps collision-check mode 3 to **Component Body Mode**.

Therefore do NOT move parts or relax the rule based only on generic component BoundingRectangle values.
Before any correction, inspect actual `eComponentBodyObject` geometry for every violating pair.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Component_Body_Clearance_Audit_v1.pas`
- commit `9d7c4eeec76712ceb8f87a3f238b47bf32e0b969`
- entry: `AuditT24_Component_Bodies_For_Clearance_v1`
- output: `T24_Component_Body_Clearance_Audit.txt`
- no PCB/rule/DRC/polygon modification.

Exact next action:
1. keep current unsaved PCB and current DRC markers;
2. run `AuditT24_Component_Bodies_For_Clearance_v1`;
3. upload `T24_Component_Body_Clearance_Audit.txt`;
4. classify each violation as real physical body collision vs bad/oversized footprint body;
5. only then make placement or footprint edits.

## T24 Footprint mechanical-layer audit — READY

Latest findings:
- all 21 current Component Clearance violations resolved to exact component/component pairs;
- every involved component has `Height=0` and `BodyCount=0`;
- therefore current Component Clearance is not checking real 3D/component bodies;
- all 12 representative footprint families do contain mechanical-layer primitives, but layer-name intent (body/assembly/courtyard) is not documented;
- do not move parts or relax Component Clearance yet.

Prepared read-only script:
- `AI_SCRIPTS/T24/T24_Footprint_Mechanical_Envelope_Audit_v1.pas`
- commit `452eeb8eaade6f681897e4a0c276c8784f75149b`
- entry: `AuditT24_Footprint_Mechanical_Envelopes_v1`
- output: `T24_Footprint_Mechanical_Envelope_Audit.txt`

It measures separate envelopes for:
- pads;
- Mechanical Layer 1;
- Mechanical Layer 2;
- Top Overlay;
for the 12 representative footprint families.

Exact next action:
1. run the read-only envelope audit;
2. send `T24_Footprint_Mechanical_Envelope_Audit.txt`;
3. classify Mechanical1/2 as body/assembly/courtyard from geometry;
4. only then decide whether to use an existing mechanical envelope or add corrected courtyard/body geometry.

## T24 Component Clearance root-cause — MECHANICAL LAYER ROLE CONFIRMED

Latest read-only audits established:
- all 21 Component Clearance violations resolve to exact component pairs;
- all affected components have `Height=0` and `BodyCount=0`;
- therefore current Component Clearance is not checking real 3D bodies;
- for representative footprints, Mechanical 1 geometry matches package/body outline and Mechanical 2 geometry matches a buffered placement courtyard pattern;
- Mechanical 2 examples:
  - 0603: pad envelope about 2.20 x 0.90 mm; Mech2 about 2.65 x 1.45 mm;
  - 1206: pad envelope about 4.30 x 1.70 mm; Mech2 about 4.75 x 2.25 mm;
- `Q_OLED`, `J_NAV`, and `D_ESD1` have no Mechanical 2 primitives and will need explicit courtyard completion if Mechanical 2 is migrated to a true Courtyard role.

Authoritative mechanical-layer role audit:
- `T24_Mechanical_Layer_Role_Audit.txt`
- current board mechanical layer state:
  - Mechanical 1 name = `Mechanical 1`, used/enabled;
  - Mechanical 2 name = `Mechanical 2`, used/enabled;
  - no typed/component-layer-pair structure exists;
  - Mechanical pair count = 0;
  - Mechanical1 paired with Mechanical2 = FALSE.

Implication:
- Mechanical 2 currently behaves geometrically like courtyard but is NOT recognized by Altium as Courtyard Layer Type.
- Altium Component Clearance only treats geometry as courtyard when the mechanical layer/component layer pair has Layer Type=Courtyard.
- therefore the current 21 clearance markers are not a trustworthy physical-placement verdict.

Do NOT:
- loosen ComponentClearance just to clear DRC;
- move components based on these 21 markers;
- globally retag/migrate Mechanical 2 before proving it is used only as component courtyard data across the whole board.

Prepared global read-only audit:
- `AI_SCRIPTS/T24/T24_Global_Mech2_Usage_Audit_v1.pas`
- commit `93ae5543f5b14254e930dba0cb1429a8ae75141c`
- entry: `AuditT24_Global_Mech2_Usage_v1`
- output: `T24_Global_Mech2_Usage_Audit.txt`

Exact next action:
1. keep current unsaved PCB open;
2. run only `AuditT24_Global_Mech2_Usage_v1`;
3. send/upload `T24_Global_Mech2_Usage_Audit.txt`;
4. no Save / layer migration / component move / rule edit yet;
5. if Mechanical 2 is globally component-only courtyard-style data with zero loose board primitives, prepare controlled Courtyard component-layer-pair migration;
6. then add missing courtyard geometry only for footprints that currently lack Mech2.

## T24 Courtyard Migration Step1 — APPLIED / UNSAVED

Timestamp: 2026-09-21 23:21 +03:30

Authoritative user screenshot confirms:
- `ApplyT24_Courtyard_LayerPair_Step1_v3` completed successfully.
- Mechanical Layer Pair created: `Mechanical 2 <-> Mechanical 4`.
- Exactly 12 bottom-side mechanical primitives were moved from Mechanical 2 to Mechanical 4.
- No copper, routing, via, polygon, component position/rotation, or design rule was changed.
- User has NOT been instructed to save yet.

Current DRC state:
- Routing Via Style root-cause fix remains PASS.
- GND-via Direct rule remains valid.
- Top/Bottom GND polygons remain KEEP.
- Formal Batch DRC is NOT yet PASS because Component Clearance semantics are still being corrected.
- Existing 21 Component Clearance violations are not yet a trustworthy physical-placement verdict until Courtyard migration is completed and DRC is rerun.

Courtyard audit chain already completed:
- all 21 Component Clearance violation pairs resolved;
- affected components had `Height=0` and `BodyCount=0`;
- Mechanical 1 geometry behaves like body/assembly outline;
- Mechanical 2 geometry behaves like courtyard;
- global audit: 129 total components, 113 with Mech2, 16 without Mech2, zero loose board-level Mech2 primitives;
- migration preflight: 110 top-side components with Mech2, 3 bottom-side components with Mech2, 1 bottom-side component without Mech2;
- bottom components migrated in Step1: `R_RTC_INT_PU`, `C_RTC`, `BT2`.

Applied script:
- `AI_SCRIPTS/T24/T24_Courtyard_LayerPair_Migration_Step1_v3.pas`
- Git commit: `769741eef5e6d15d77be678c3c493c7393d1eacd`

CURRENT EXACT POINT:
1. DO NOT SAVE yet.
2. In Altium open View Configuration.
3. Go to Component Layer Pairs.
4. Edit the `Mechanical 2 / Mechanical 4` pair.
5. Set `Layer Type = Courtyard`.
6. Confirm/apply the dialog.
7. Return with screenshot of the Component Layer Pair showing Courtyard.
8. After that, prepare Step2 to add/fix courtyard geometry for the 16 components that currently have no Mech2/paired courtyard.
9. Only after Courtyard semantics are complete: rerun Component Clearance / full Batch DRC and classify any real remaining collisions.
10. Do not relax the global ComponentClearance rule merely to clear violations; fix root cause.

16 components currently without Mechanical 2 before Step1:
- `U_RTC` (Bottom)
- `Q_SD`
- `Q_OLED`
- `J_SWD`
- `J_SHIELD`
- `J_SD`
- `J_NAV`
- `D_EXT3`
- `D_EXT2`
- `D_EXT1`
- `D_ESD`
- `D_ESD2`
- `D_ESD1`
- `C_SENSOR_BULK`
- `C_SD_MID`
- `C_OLED_BULK`

Do not rerun obsolete scripts:
- `T24_RoutingViaStyle_Range_v1.pas`
- `T24_Component_Clearance_Violation_Audit_v1/v2`
- `T24_Courtyard_LayerPair_Migration_Step1_v1/v2`

## T24 Stage2B — controlled GND plane stitching — PAUSED UNTIL GND-VIA DIRECT RULE + DRC PASS

Manufacturer-specific DFM audit:
- completed against Arya Madar public pricing guidance on 2026-09-21;
- report: `AI_CONTINUITY/T24_ARYAMADAR_DFM_AUDIT.md`;
- report commit: `15d34b51f09023931fea003e8e1daa0f5eda5fa9`;
- current board already contains routing clearance below 0.2 mm and all 180 legacy vias use about 0.30 mm drill, so blindly resizing all vias would add routing risk without guaranteeing removal of the manufacturer's premium price class;
- bulk legacy-via enlargement is therefore NOT approved at this checkpoint.

Authoritative Stage2B script:
- USE: `AI_SCRIPTS/T24/T24_Stage2B_GND_Stitching_v2.pas`
- v2 script commit: `4ba9f97e16385eaaf07abc9ebda63980e29d0ae4`
- v2 script blob: `b10a61b26019d1ed7c512939e79f0c6805d912b0`
- DO NOT USE the older v1 script; v1 is superseded for execution.

v2 entry points:
- `PreflightT24_Stage2B_GND_Stitching_v2`
- `ApplyT24_Stage2B_GND_Stitching_v2`

Purpose:
- add 11 deliberate GND stitching vias between the already-poured Top and Bottom GND planes;
- do not reopen completed signal/power routing;
- use fabrication-friendly new stitching geometry where ample space exists.

New Stage2B via geometry:
- diameter: **31.496 mil = 0.80 mm**
- drill: **17.717 mil = 0.45 mm**
- annular ring: approximately **0.175 mm**
- Top-to-Bottom through via
- net: GND

Static DFM clearance audit of the 11 enlarged candidates:
- all 11 remain in large open-plane areas;
- worst estimated different-net obstacle margin with 0.80 mm via diameter is approximately **74.6 mil / 1.89 mm**;
- this is only a planning result; live Altium preflight remains mandatory.

Baseline safety:
- requires 117 GND tracks / 46 GND vias / 180 total vias / 2 polygons;
- requires one Top GND polygon and one Bottom GND polygon, each with 8 points;
- preflight checks candidates against live component bounds, pads, Top/Bottom tracks, existing vias, electrical/keepout objects, controlled interior limits, and Stage1 logo region;
- Apply repeats preflight before any PCB change;
- no routing moves and no polygon-outline changes are performed;
- no interactive PCB:Zoom call.

Expected state immediately after successful Apply:
- **11 new GND stitching vias**
- **57 GND vias total**
- **191 total vias**
- **117 GND tracks unchanged**
- **2 polygons unchanged**

Exact next action:
1. synchronize local repo with normal `Git_Save.cmd` v2.5 so the new remote commits are present locally;
2. open `AI_SCRIPTS/T24/T24_Stage2B_GND_Stitching_v2.pas` in Altium;
3. run **only** `PreflightT24_Stage2B_GND_Stitching_v2`;
4. expected result: **PREFLIGHT PASS** and **11/11 candidates passed live-board checks for 0.80/0.45 mm vias**;
5. only after that PASS, run `ApplyT24_Stage2B_GND_Stitching_v2`;
6. after Apply: **Repour All Polygons → FULL DRC**;
7. if DRC is not clean, do not save; if DRC PASS, save PCB → Snapshot Exporter v1.4.2 → `Git_Save.cmd`;
8. verify the refreshed Git/snapshot before formally closing Stage2B.

Stage2B remains **NOT PASS yet** until post-apply repour + full DRC + refreshed snapshot are verified.

## Locked project constraints still in force

- PCB remains **2-layer**.
- Manual assembly / rework readability remains a primary physical-design requirement.
- Every PCB-mounted component must retain a readable RefDes.
- Pin-1 / polarity / orientation marks must remain clear where applicable.
- Off-board devices must retain explicit PCB-side connectors/interfaces.
- Schematic controlled Snap Grid remains **100 mil**.
- Do not casually move or reroute completed T23 copper without a new reason and a new full DRC.
- If future edits affect Bottom copper or GND connectivity, repour the GND polygon and rerun full DRC before accepting the change.

## Continuity warning

Older continuity text that says:
- Bottom GND polygon has not yet been created, or
- only the historical 3 GND Net Antennae are expected,

is now obsolete and must not override this handoff or the newer Git/PcbDoc evidence.

## Next recommended action

T24 is now active. Stage1 branding is complete and saved.

Recommended next stage:
**T24 Stage2 — Manufacturing / release audit**, with no routing changes unless a concrete release-blocking issue is found.

Stage2 should verify:
- Gerber / ODB++ layer set and naming
- NC Drill outputs
- board outline / route layer
- Top/Bottom solder mask
- Top silkscreen readability, including the new logo
- test points and exposed pads
- connector pin labels / polarity / orientation marks
- fabrication notes / stackup for the required 2-layer board
- output-file completeness before sending to the PCB manufacturer

Rollback references:
- clean pre-logo T23 post-pour baseline:
  `a1e4193edacf4f03da623616e470258cd1dc147e`
- current saved post-logo PCB:
  `43306bfd199b10555d7fa2f5f45a8550b8363720`

Do not make additional copper edits merely for cosmetics. Any future copper/GND edit requires polygon repour and a new full DRC.
