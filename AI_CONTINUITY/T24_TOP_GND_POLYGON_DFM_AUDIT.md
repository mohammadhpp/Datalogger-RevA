# SUPERSEDED — DO NOT USE AS CURRENT DECISION

This single-pass audit was superseded on 2026-09-21 by `AI_CONTINUITY/T24_TOP_GND_TRIPLE_EXPERT_REVIEW.md`. Final decision: KEEP the validated Top GND polygon; do not run the removal script.

# T24 Top GND Polygon Risk / Necessity Audit

Date: 2026-09-21
Scope: post-Stage2A, pre-Stage2B
Decision: REMOVE the optional Top Layer GND polygon; KEEP the Bottom Layer GND polygon.

## Evidence

Authoritative bottom-only baseline:
- PCB checkpoint: `a1e4193edacf4f03da623616e470258cd1dc147e`
- T23 routing / GND closeout was formally PASS.
- Before polygon creation, Top-only GND groups = 0.
- Bottom GND polygon: 1, GND, poured, 8-point live BoardOutline.
- GND routing: 117 tracks / 46 vias.
- Full post-pour Altium DRC: 0 warnings / 0 rule violations.

Therefore the board does not require a Top GND polygon for electrical GND completion.

## Before/after Stage2A snapshot comparison

Before Top GND polygon:
- Top Layer polygon count: 0
- Top Layer poured REGION count from the polygon system: 0

After Stage2A Top GND polygon:
- Top Layer polygon count: 1
- Top Layer pour-generated REGION count: 20
- one large board-scale region plus 19 additional smaller fragmented sub-regions around dense routing / components.

Examples of very small generated Top regions:
- about 0.60 x 0.99 mm near U_PMUX GND
- about 0.69 x 1.00 mm near Q_SD_DRV GND
- about 1.38 x 1.55 mm around several ESD / external-interface GND pads
- multiple 1.5–2.5 mm-scale regions in the SD / pull-up / fine-routing areas

These regions are not necessarily DRC violations, but they are additional copper features created only by the optional Top pour.

## DFM reasoning

For this 2-layer board:
- the Bottom GND plane is the required primary plane and already passed full DRC;
- all Top-side GND groups already have deliberate Bottom-layer access;
- the Top pour does not solve an unrouted GND requirement;
- the Top pour adds fragmented copper geometry near fine-pitch / dense routing;
- the board already contains manufacturer-sensitive sub-0.2 mm geometries, so adding optional fragmented copper is not useful for cost reduction;
- selective Top copper could be redesigned later for a specific EMC reason, but the current full-board Top pour is not needed for release.

## Controlled decision

REMOVE:
- exactly one Top Layer GND polygon introduced by T24 Stage2A.

KEEP:
- Bottom Layer GND polygon.
- all 117 GND tracks.
- all 46 existing GND vias.
- all existing signal/power routing.
- all component placement and silkscreen.

DO NOT:
- delete individual poured REGION primitives manually;
- move existing T23 copper;
- run Stage2B GND plane stitching while the Top polygon is removed.

After controlled removal:
1. Repour All Polygons.
2. Run FULL DRC.
3. Do not save if DRC is not clean.
4. On DRC PASS: save PCB, run Snapshot Exporter v1.4.2, then Git_Save.cmd.
5. Verify final snapshot shows exactly one Bottom GND polygon and zero Top polygons.

## Stage2B impact

`T24_Stage2B_GND_Stitching_v2.pas` is now ON HOLD / superseded by this DFM decision.
The 11 stitching vias were intended to tie Top and Bottom GND planes. With the Top plane removed, those 11 vias are not required and must not be applied.
