# T24 Arya Madar DFM Audit

Date: 2026-09-21
Project: Datalogger RevA
Board state audited: post-T24 Stage2A / pre-Stage2B
Authoritative PCB checkpoint: c7c57171ca952ee28726ef206b83eb5daaae330e
Authoritative collision snapshot: Snapshot Exporter v1.4.2 generated 2026-09-21 00:17:46

## Manufacturer-specific source

Arya Madar public pricing guidance:
- https://www.aryamadar.com/محاسبه-قیمت-برد-مدار-چاپی/
- https://www.aryamadar.com/محاسبه-ابعاد-و-قیمت-pcb/

Published guidance used in this audit:
- PCB price depends on layer count, copper thickness, hole count/size, finish, track width/spacing, silkscreen/solder-mask choices, electrical test, quantity, and design complexity.
- For optimized pricing, hole size should be above 0.4 mm; holes below 0.4 mm are stated to cost more and make electrical test mandatory.
- Track width / spacing below 0.2 mm is stated to have a very large price impact.
- Green solder mask + white legend is the economical color combination.
- Copper / hot-air finish is stated as no-extra-cost while gold finish is charged according to use.
- Thicker copper is stated to increase price and imposes tighter design constraints.

## Current board findings from the authoritative snapshot

Board bounding box is approximately 100 mm x 80 mm.

Copper / routing:
- Minimum routed track width found: 8 mil = 0.2032 mm.
- Routed widths present: 8 / 10 / 12 / 15 / 20 / 30 / 40 mil.
- The 8 mil minimum is just above Arya Madar's public 0.2 mm economic threshold.
- Several real different-net routing clearances are approximately 6 mil = 0.1524 mm, therefore the board already falls below the public 0.2 mm spacing threshold in multiple places.
- Fine-pitch package pad-to-pad copper spacing reaches about 4 mil = 0.1016 mm around U_SYS / U_PMUX and other compact packages. These are package-driven, not created by the GND polygon.

Existing vias:
- Total vias: 180.
- 178 vias are 23.622 mil / 11.811 mil = approximately 0.60 / 0.30 mm.
- 2 vias are 27.559 mil / 11.811 mil = approximately 0.70 / 0.30 mm.
- Therefore all 180 existing vias currently use approximately 0.30 mm drill, below Arya Madar's public 0.4 mm economic guidance.

Through-hole component pads:
- Smallest PTH component hole found in snapshot: approximately 0.80 mm.
- No concern for ordinary component-hole manufacturability from this audit.

GND polygons:
- 2 poured GND polygons: one Top and one Bottom.
- Top polygon is solid.
- Top polygon removes dead copper and islands.
- Top polygon removes narrow necks below 10 mil = 0.254 mm.
- This is a manufacturing-friendly setting and should not be loosened just to fill visually empty top-layer regions.

## Via enlargement study

A conservative geometry study was run against the current snapshot.

Candidate conversion of the 178 existing 0.60/0.30 mm vias to 0.70/0.40 mm:
- 162 / 178 retain at least 6 mil estimated different-net copper clearance.
- 16 / 178 fall into approximately 4 to 6 mil estimated clearance.
- 0 / 178 fall below 4 mil in this conservative model.

Candidate conversion to 0.75/0.45 mm:
- 147 / 178 retain at least 6 mil.
- 24 / 178 fall into 4 to 6 mil.
- 7 / 178 fall below 4 mil.

Candidate conversion to 0.80/0.45 mm:
- 127 / 178 retain at least 6 mil.
- 35 / 178 fall into 4 to 6 mil.
- 16 / 178 fall below 4 mil.

Conclusion:
- Bulk enlargement of every existing via is NOT approved from the offline snapshot.
- Do not blindly convert all existing vias.
- The existing routing is already DRC-clean and should not be reopened merely to chase a lower PCB price unless the actual quote shows the savings justify the reroute risk.
- Because the board already has sub-0.2 mm routing clearances and package-driven fine pitch, changing only via drills cannot guarantee moving the whole board into Arya Madar's cheaper design class.

## Stage2B manufacturing decision

The 11 planned GND stitching locations have very large obstacle margins.

With a proposed 0.80 mm via diameter:
- worst estimated different-net obstacle clearance among the 11 locations is approximately 74.6 mil (about 1.89 mm);
- therefore all 11 planned stitching locations have ample room for a larger manufacturer-friendly via.

Recommended Stage2B geometry:
- via pad diameter: 0.80 mm = 31.496 mil
- drill: 0.45 mm = 17.717 mil
- annular ring: approximately 0.175 mm
- Top-to-Bottom through via
- net: GND

This drill is intentionally above 0.4 mm and is much more comfortable for fabrication than the legacy 0.30 mm drill.

## Recommended order specification for Arya Madar

- 2-layer FR-4
- nominal board thickness 1.6 mm
- 35 um / 1 oz copper
- green solder mask
- white component legend
- HASL / hot-air finish unless ENIG is specifically desired for assembly reasons
- electrical test: YES
- do not select thicker copper without a separate DFM re-check
- send Gerber + NC Drill after final release audit

## Release decision

Current board is not rejected for fabrication.
However, it is NOT an "economy geometry" board under Arya Madar's published pricing guidance because:
1. several copper clearances are below 0.2 mm;
2. all current vias use a 0.30 mm drill.

For reliability and schedule, the recommended path is:
- keep the already validated routing and existing vias unchanged for now;
- use larger 0.80/0.45 mm GND stitching vias in Stage2B;
- perform Repour All Polygons + FULL DRC after Stage2B;
- obtain the actual Arya Madar quote from the final Gerber;
- only if the price premium is unacceptable, open a separate controlled cost-reduction reroute for legacy vias / sub-0.2 mm clearances.

This avoids sacrificing a validated routing state for a price reduction that may not remove the premium class anyway.
