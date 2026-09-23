# Lessons Learned — Datalogger RevA

These are project-specific lessons intended to prevent repeated mistakes across AI sessions.

## PCB routing / physical design

1. **Do not pour the final GND polygon too early.**
   - Finish the major signal/power routing first.
   - Early polygon pours cause repeated repours, hide ratsnest clarity, and can mask return-path planning problems.

2. **Wide tracks need controlled pad escape.**
   - A rule-compliant wide track can still be a poor physical design if it crowds IC pins.
   - Use a short, electrically justified neck-down at dense IC pads, then widen outside the escape zone.
   - Preserve soldering/rework room, especially around `U_SYS`.

3. **Manual assembly readability is a real engineering requirement.**
   - Never sacrifice all RefDes/orientation markings merely to compact placement.
   - Silkscreen should help a human assemble, inspect, and debug the board.

4. **Route in functional blocks and checkpoint with DRC.**
   - Complete a coherent block, run DRC, then continue.
   - Do not wait until the entire board is routed to discover a systematic width/clearance mistake.

5. **Interpret DRC in context.**
   - Unrouted nets are expected while untouched blocks remain.
   - GND vias may appear as Net Antennae before the intended GND polygon exists.
   - Do not distort the routing sequence only to make an intermediate DRC report cosmetically clean.

6. **Do not equate pad-center endpoints with electrical connectivity.**
   - A routed track may legitimately terminate on the copper edge of a pad instead of its geometric center.
   - Stage 3 Final OVP Audit v1 false-failed `R_TOP_B.1` because it required an endpoint at the pad center `(4895,5090)` even though the same-net track validly entered the pad at approximately `(4865,5090)`.
   - Future audit scripts should prefer actual Altium connectivity/geometry-overlap evidence, or explicitly support verified pad-edge entry, instead of using center-coordinate equality as the only connectivity test.
   - DRC plus live-board connectivity should outrank brittle coordinate heuristics.

7. **Collision checking is not route planning.**
   - Repeatedly guessing coordinates and then asking a preflight checker whether they collide is still trial-and-error.
   - Dense routing should be planned from the full obstacle field first; preflight is the independent verifier, not the pathfinder.

8. **Do not run heavy route-search algorithms inside Altium PascalScript.**
   - A live-board A* experiment during T23 Stage 4G blocked the Altium UI and made the application appear hung.
   - Altium scripts for this project must stay lightweight: baseline checks, exact geometry preflight, static apply, connectivity analysis.
   - Heavy search/planning belongs outside Altium.

9. **For dense scripted routing, plan externally from the latest collision snapshot.**
   - Use `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv` as the external planning geometry source.
   - Model Top/Bottom obstacles, Multi Layer pads, existing track widths, vias, electrical clearance, and via-to-pad mask sliver.
   - When two target nets compete for the same corridor, plan them as a pair rather than independently.
   - The accepted Stage 4G solution (`CC1_RD_RET` / `CC2_RD_RET`) used this method successfully.

10. **Do not use absolute Altium Track-object count as the sole route PASS gate.**
    - Altium can split or merge primitives when new copper joins existing copper.
    - Prefer script-added object count, geometry/connectivity checks, exact preflight, and final DRC.

11. **Audit expected object counts against the actual final build block before shipping a script.**
    - Stage4H1 v3 passed exact preflight and applied successfully, then falsely reported FAIL because the script expected `25 tracks / 8 vias` while its build block actually contained exactly `24 AddTrackMil` calls and `8 AddViaMil` calls.
    - `GAddedTracks/GAddedVias` are useful only if the expected values were mechanically verified against the final apply code.
    - A count-audit mismatch must be diagnosed before discarding geometry that already passed exact preflight; do not reflexively treat it as a routing failure.

12. **External collision math must mirror Altium's exact conservative primitive.**
   - Stage5B v1 passed an external Euclidean corner-distance check but correctly failed the live Altium preflight because the diagonal intersected the axis-expanded pad bounding rectangle of `C_MCU_HF.1`.
   - For scripted dense routing, external track-to-pad verification must use the same axis-expanded `BoundingRectangle` intersection semantics as the Pascal preflight; Euclidean distance to the unexpanded rectangle is not equivalent at corners.
   - A clean external result is trustworthy only when its geometry model reproduces known live preflight failures as well as accepted routes.

## Schematic / library / ECO

13. **Pad numbers must match schematic pin designators.**
   - Before assigning/replacing footprints, verify physical pad numbering against the schematic pins and selected connector/part drawing.
   - A visually correct footprint with wrong pad numbering is unacceptable.

14. **Do not move schematic architecture merely to solve a footprint-management problem.**
   - Prefer deliberate footprint assignment and mapping verification over unnecessary schematic rearrangement.

15. **Off-board symbols still require explicit PCB hardware.**
   - A logical off-board device without a deliberate board-side connector is an incomplete design.

## Git / AI continuity

16. **Chat history is not a reliable project database.**
   - Stable design decisions, exact current point, and lessons must live in Git.

17. **A ZIP handoff alone is insufficient for day-to-day continuity.**
   - Git history plus a concise current handoff is superior for identifying what changed and why.
   - Full offline ZIPs remain valuable for disaster recovery and migration.

18. **Do not replace the known-good local backup architecture when adding cloud backup.**
   - Preserve `localbackup` as the required upstream/rollback path.
   - Add GitHub as a second remote.

19. **Online failure must not invalidate a valid local checkpoint.**
   - AutoSave treats local backup as required and GitHub sync as secondary.
   - Loss of internet should produce a warning, not destroy local continuity.

20. **Before continuing from a new AI/session, verify the repo itself.**
   - Read `AI_START_HERE.md` and continuity files.
   - Inspect latest commits and the current engineering file state instead of trusting an old chat summary blindly.

## Collaboration workflow

21. **Routine screenshots are not mandatory.**
   - Proceed from verified files and known state for ordinary steps.
   - Ask/use screenshots when the user is unsure, when visual placement/routing verification is needed, or when the file state cannot answer the question reliably.

22. **When a sequence recommendation is found to be suboptimal, correct it explicitly in the handoff.**
   - Do not silently carry a bad next-step recommendation into future sessions.


23. **Do not mutate PcbLib footprints through DelphiScript on the current Altium build.**
   - T24 PcbLib courtyard repair attempts v2/v3/v4 all produced the same native null-read Access Violation in `ScriptingSystem.DLL`, even after removing iterator mutation, component navigation, state rebuilds, and exception flow.
   - The same PCBServer object-creation transaction pattern is proven on PcbDoc in T23, while Altium's documented PcbLib interfaces still crash natively in this environment.
   - Treat this as an Altium scripting-engine/PcbLib implementation defect or build regression until proven otherwise. Use native PcbLib UI editing for persistent footprint changes, and never save the library after such a crash.
