# T24 Triple Independent Expert Review — Top GND Polygon

Date: 2026-09-21
Board state: post-T24 Stage2A / pre-Stage2B
Question: Keep or remove the Top Layer GND polygon before fabrication at Arya Madar?

This review supersedes the earlier single-pass recommendation to remove the Top polygon.

## Corrected interpretation of snapshot REGION objects

Important correction:
Altium solid polygon pours are internally represented using REGION primitives, with a separate region for each contiguous poured copper area. Therefore the presence of 20 Top Layer REGION records after Stage2A does NOT by itself prove 20 undesirable or floating copper islands.

Snapshot audit also shows every one of the 20 Top REGION bounding areas overlaps at least one existing GND pad or GND via. No clearly unanchored Top copper island was identified from the authoritative snapshot.

The Top polygon itself was configured with:
- solid pour;
- Pour Over Same Net;
- Remove Dead Copper = enabled;
- Remove Islands by Area = enabled;
- Remove Narrow Necks = enabled;
- neck threshold = 10 mil;
- acute-corner clipping = enabled;
- mitred corners = enabled.

The saved post-Stage2A PCB subsequently passed full Altium DRC according to the user.

---

## Expert 1 — EMC / Signal Integrity / Power Integrity

Independent question:
Does the Top GND polygon provide a useful electrical function on this 2-layer board?

Finding:
KEEP.

Reasoning:
- A 2-layer board benefits from additional grounded surface copper when it is connected to the primary GND system.
- The Bottom GND polygon is the primary return plane, but it is perforated by routing and clearances; the snapshot shows many openings in the Bottom poured region.
- The board contains MCU, SPI/SD, I2C and switching-power circuitry with fast edge content even if nominal bus frequencies are moderate.
- A grounded Top pour can shorten local return loops, reduce local ground impedance and provide some electric-field shielding.
- Removing the Top pour would remove these benefits without fixing a demonstrated electrical problem.
- Via stitching improves the usefulness of overlapping Top/Bottom GND copper by creating lower-impedance vertical connections and shorter return loops.

Expert 1 vote:
**KEEP Top GND polygon.**
Controlled Stage2B stitching remains technically beneficial if live preflight and full DRC pass.

---

## Expert 2 — PCB DFM / Fabrication / Arya Madar Cost

Independent question:
Does the Top GND polygon materially increase manufacturing risk or move the board into a more expensive fabrication class?

Finding:
KEEP, with one assembly-rule check.

Manufacturer-specific facts from Arya Madar:
- price depends on track width / spacing, hole count and hole size, copper thickness, finish, printing, electrical test and complexity;
- spacing or track width below 0.2 mm has a large price impact;
- holes below 0.4 mm are more expensive and electrical test becomes mandatory;
- green solder mask / white legend is the economical color combination.

Board-specific facts:
- minimum routed track width = 8 mil = 0.203 mm;
- several existing different-net copper clearances are about 6 mil = 0.152 mm;
- fine-pitch package pad spacing reaches about 4 mil = 0.102 mm;
- all 180 current vias use about 0.30 mm drill;
- therefore the board is already outside Arya Madar's simple economy geometry because of pre-existing spacing and drill requirements.

Consequently:
- removing the Top polygon does NOT remove the existing sub-0.2 mm features;
- removing the Top polygon does NOT remove the existing 0.30 mm drills;
- the Top polygon itself adds no drill operations;
- solid REGION-based polygon output is a normal supported Gerber/ODB++ construction;
- 10 mil narrow-neck removal, dead-copper removal and successful DRC are favorable DFM controls.

Assembly check:
Because the user intends manual assembly, large GND copper can make some grounded pads harder to solder if the Polygon Connect Style uses Direct Connect. Before release, verify thermal relief policy for hand-soldered THT and appropriate SMD GND pads. This is a connection-style audit, not a reason to remove the entire Top pour.

Expert 2 vote:
**KEEP Top GND polygon.**
Do not remove it for cost reasons; it will not materially change the pricing class of this board.

---

## Expert 3 — Reliability / Change Control / Release Risk

Independent question:
Which path carries less regression risk at this late stage: keeping the existing validated Top polygon or deleting it?

Finding:
KEEP.

Evidence:
- T23 routing and Bottom GND polygon were validated.
- T24 Stage2A added exactly one Top GND polygon without intentionally changing routing.
- The post-Stage2A board was saved and the user reported full DRC OK.
- No demonstrated short, clearance violation, solder-mask violation, unrouted net or fabrication failure has been attributed to the Top polygon.
- Deleting a validated copper object now is a new design change requiring repour, DRC, snapshot and another release checkpoint.
- A late-stage deletion should require a concrete defect or measurable cost benefit; neither has been demonstrated.

Expert 3 vote:
**KEEP Top GND polygon.**
Do not reopen a DRC-clean layout based only on visual concern about poured-region count.

---

# Final consensus

Final decision:
**KEEP the Top Layer GND polygon. DO NOT run the Top-polygon removal script.**

Confidence:
High, based on three independent criteria:
1. electrical / EMC benefit favors keeping;
2. fabrication/cost analysis does not show a meaningful price-class benefit from removal;
3. change-control risk favors preserving the already DRC-clean state.

## Required controlled next steps

1. Mark `T24_Remove_Top_GND_Polygon_DFM_v1.pas` as OBSOLETE / DO NOT RUN.
2. Keep Stage2A Top GND polygon exactly as currently saved.
3. Before final fabrication output, audit Polygon Connect Style / thermal relief behavior for GND pads, especially manually soldered through-hole and small SMD parts.
4. Stage2B controlled GND stitching v2 may proceed:
   - 11 planned GND stitching vias;
   - 0.80 mm diameter / 0.45 mm drill;
   - live preflight first;
   - Apply only after preflight PASS;
   - Repour All Polygons;
   - FULL DRC;
   - save/snapshot/Git only after clean DRC.
5. Final manufacturing audit should still check solder mask slivers, test points, exposed pads, edge clearance, drill table and Gerber/NC Drill outputs.

## Note on the earlier removal recommendation

The earlier recommendation over-weighted the observation that Stage2A produced 20 REGION records. This was not sufficient evidence of 20 problematic copper islands. Altium uses REGION primitives as the normal internal representation of a solid polygon pour, and the current snapshot does not show a clearly unanchored Top copper region. The corrected final decision is therefore to keep the Top polygon.
