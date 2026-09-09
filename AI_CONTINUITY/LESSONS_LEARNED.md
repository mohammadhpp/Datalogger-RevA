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

## Schematic / library / ECO

6. **Pad numbers must match schematic pin designators.**
   - Before assigning/replacing footprints, verify physical pad numbering against the schematic pins and selected connector/part drawing.
   - A visually correct footprint with wrong pad numbering is unacceptable.

7. **Do not move schematic architecture merely to solve a footprint-management problem.**
   - Prefer deliberate footprint assignment and mapping verification over unnecessary schematic rearrangement.

8. **Off-board symbols still require explicit PCB hardware.**
   - A logical off-board device without a deliberate board-side connector is an incomplete design.

## Git / AI continuity

9. **Chat history is not a reliable project database.**
   - Stable design decisions, exact current point, and lessons must live in Git.

10. **A ZIP handoff alone is insufficient for day-to-day continuity.**
    - Git history plus a concise current handoff is superior for identifying what changed and why.
    - Full offline ZIPs remain valuable for disaster recovery and migration.

11. **Do not replace the known-good local backup architecture when adding cloud backup.**
    - Preserve `localbackup` as the required upstream/rollback path.
    - Add GitHub as a second remote.

12. **Online failure must not invalidate a valid local checkpoint.**
    - AutoSave v2.4 treats local backup as required and GitHub sync as secondary.
    - Loss of internet should produce a warning, not destroy local continuity.

13. **Before continuing from a new AI/session, verify the repo itself.**
    - Read `AI_START_HERE.md` and continuity files.
    - Inspect latest commits and the current engineering file state instead of trusting an old chat summary blindly.

## Collaboration workflow

14. **Routine screenshots are not mandatory.**
    - Proceed from verified files and known state for ordinary steps.
    - Ask/use screenshots when the user is unsure, when visual placement/routing verification is needed, or when the file state cannot answer the question reliably.

15. **When a sequence recommendation is found to be suboptimal, correct it explicitly in the handoff.**
    - Do not silently carry a bad next-step recommendation into future sessions.
