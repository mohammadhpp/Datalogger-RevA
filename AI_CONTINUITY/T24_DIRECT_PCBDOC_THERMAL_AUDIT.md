# T24 Direct PcbDoc Polygon / Thermal Relief Audit

Date: 2026-09-21
Source file audited: uploaded DATALOGER_RevA(20260921-171819).PcbDoc
Verified Git blob SHA: 16f5576c1882a60a69a03b55c5456104be938911
This exactly matches current repository DATALOGER_RevA.PcbDoc.

## Direct PcbDoc parsing

The Altium PcbDoc is a CFB/compound document. The audit read the live internal streams, including:
- Rules6
- Polygons6
- Nets6
- PadViaLibraryCache

No PCB modification was performed.

## Effective polygon connection rules

Rules6 contains 42 design rules.

Exactly one enabled Polygon Connect rule was found:
- RULEKIND = PolygonConnect
- NAME = PolygonConnect
- ENABLED = TRUE
- PRIORITY = 1
- SCOPE1 = All
- SCOPE2 = All
- CONNECTSTYLE = Relief
- RELIEFCONDUCTORWIDTH = 10 mil
- RELIEFENTRIES = 4
- POLYGONRELIEFANGLE = 90 degrees
- AIRGAPWIDTH = 10 mil

A PlaneConnect rule also exists:
- style = Relief
- 4 conductors
- conductor width = 10 mil
- air gap = 10 mil
- expansion = 20 mil

Because this board is a 2-layer signal-layer design using polygon pours, the PolygonConnect rule is the relevant rule for the Top/Bottom GND polygons.

## Pad / via template cross-check

PadViaLibraryCache contains exactly 48 cached templates:
- 46 pad templates
- 2 via templates

Every one of the 48 templates contains:
- CONNECTSTYLE = Relief
- AIRGAPWIDTH = 10 mil
- CONDUCTORWIDTH = 10 mil
- ENTRIES = 4
- rotation/angle = 90 degrees

Binary/text scan of the current PcbDoc found:
- Direct connect text occurrences: 0
- No Connect text occurrences: 0
- Relief connect occurrences: 50 (48 templates + 2 design rules)

No evidence of a pad/via template using Direct Connect or No Connect was found.

## Actual polygon definitions

Nets6 index 71 = GND.

Polygons6 contains exactly two polygons and both are on net 71 / GND.

Bottom GND polygon:
- Layer = Bottom
- Solid
- PourOver = TRUE
- RemoveDead = TRUE
- RemoveIslandsByArea = TRUE
- RemoveNarrowNecks = FALSE
- Grid = 20 mil
- TrackWidth = 8 mil
- IgnoreViolations = FALSE

Top GND polygon:
- Layer = Top
- Solid
- PourOver = TRUE
- RemoveDead = TRUE
- RemoveIslandsByArea = TRUE
- RemoveNarrowNecks = TRUE
- NeckWidthThreshold = 10 mil
- Grid = 20 mil
- TrackWidth = 8 mil
- IgnoreViolations = FALSE

The previously saved post-Stage2A board was user-confirmed full-DRC clean.

## Manual-assembly conclusion

For soldered component pads, the current relief geometry is appropriate:
- 4 thermal spokes
- 10 mil / 0.254 mm spoke width
- 10 mil / 0.254 mm air gap
- 90-degree relief

This reduces heat sinking into the large GND pour and is preferable to globally direct-connecting component pads for manual assembly.

Final decision for pads:
**KEEP Relief connection. Do not globally switch pads to Direct Connect.**

## GND-via / stitching conclusion

Important separate finding:
The current PolygonConnect rule is scoped to All, so routed vias also inherit Relief Connect unless locally overridden.

This means:
- the 46 existing GND vias connect to GND polygons using the Relief rule;
- the proposed 11 Stage2B stitching vias would also inherit Relief if applied now.

For ordinary routing this is electrically valid and DRC-safe, but for deliberate GND plane stitching the primary purpose is a low-impedance vertical connection between Top and Bottom GND copper. Direct connection is preferred for these non-soldered GND vias.

Recommended controlled rule architecture before Stage2B:
1. Keep the existing general PolygonConnect rule as Relief for component pads.
2. Add a more-specific, higher-priority Polygon Connect Style rule:
   - Scope: IsVia AND InNet('GND')
   - Connect Style: Direct Connect
3. Repour All Polygons.
4. Run FULL DRC.
5. Confirm no regression.
6. Then run Stage2B v2 live preflight / apply.

Alternative in Altium Advanced mode:
- Through-hole pads = Relief
- SMD pads = Relief
- Vias = Direct

The explicit scoped-rule approach is preferred for this project because it is easier to audit and limits the change to GND vias only.

## Final release decision

Top GND polygon: KEEP.
Bottom GND polygon: KEEP.
Component GND pads: KEEP Relief 4 x 10 mil, 10 mil air gap.
GND vias: change polygon connection to Direct before Stage2B.
Top-polygon removal script: OBSOLETE / DO NOT RUN.
Stage2B Apply: PAUSED until the GND-via Direct Connect rule is applied, polygons are repoured, and full DRC passes.
