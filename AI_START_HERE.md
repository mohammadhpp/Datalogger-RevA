# Datalogger RevA — AI Continuity Entry Point

This repository is the authoritative project source for AI-assisted continuation of Datalogger RevA.

## Source of truth

1. **Live engineering source:** `main` branch of this repository and the user's local working repo at `C:\#MHP FILES\DataLoger`.
2. **Local rollback remote:** `localbackup` -> `C:\#MHP FILES\GitRepos\DataLoger.git`.
3. **Online continuity remote:** `github` -> `mohammadhpp/Datalogger-RevA` (private).
4. Historical ZIP backups and old handoffs are rollback/continuity artifacts only; they must not override newer Git history.

## Required read order for any new AI/session

Read these files before making project decisions:

1. `AI_CONTINUITY/CURRENT_HANDOFF.md`
2. `AI_CONTINUITY/DECISIONS_AND_CONSTRAINTS.md`
3. `AI_CONTINUITY/LESSONS_LEARNED.md`
4. `AI_CONTINUITY/HISTORY.md`
5. `AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md`
6. `AI_CONTINUITY/UPDATE_PROTOCOL.md`

Then inspect the latest Git commits and the current engineering files relevant to the task.

## Current high-level state

- Project: Datalogger RevA, Altium, **2-layer PCB**.
- T23 routing: **CLOSED / PASS**.
- T24 courtyard/manufacturing-prep: **CLOSED / PASS**, 129/129 persistent courtyards, last Full Batch DRC **0 warnings / 0 violations**.
- Canonical PCB: `DATALOGER_RevA.PcbDoc`; canonical library: `Datalogger_RevA_Clean.PcbLib`; final engineering checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
- T25A power-tree/simulation-model evidence audit: **COMPLETE**, report `AI_CONTINUITY/T25A_POWER_TREE_SIMULATION_MODEL_AUDIT.md`. No transient simulation or fresh DRC is claimed.
- **T25D 10 µs PSpice encrypted TPS631000 model smoke PASS, limited scope**: PSpice 25.1.0 finished in 30.98 s with voltage data; original v4 wrapper `NO_PASS` was a false negative. See T25D report. No 3V3 startup/SD/OLED load-step PASS.
- **T25E TPS2116 isolated vendor-model runtime PASS, limited scope**: PSpice 25.1.0 completed a 7 ms fixture cleanly in 0.83 s with 701 voltage rows and DAT; its 3.3 Ω load actually drew 1.498 A at final VOUT=4.944 V. The 30 kΩ/10 kΩ PR1 divider and TI reference explain VIN2 selection at VIN1=3.3 V; no actual transfer was simulated.
- **T25K PDF-grounded OLED load audit:** Original user WEO012864V PDF provides SSD1315 panel logic 2.8–3.3 V, panel 7–8 V and 6/12 mA typical/max at 50%-on **panel rail**. At 7.5 V that is conditional 45/90 mW, not a four-pin 3V3 module current profile. Actual blue carrier supply/current and startup remain unknown. See `AI_CONTINUITY/T25K_OLED_PDF_GROUNDED_LOAD_BOUNDARY.md`; no integrated waveform PASS.
- **T25J OLED user correction:** Earlier T25I photos were of the wrong module; **retract polarity blocker and proposed pin swap/cross-wiring**. Correct user photo has four holes silked **VCC, GND, SCL, SDA**, matching `J_OLED` ordered electrical nets **OLED_VDD, GND, OLED_SCL, OLED_SDA** on paper. The photo does not prove physical header mating, supply voltage rating or module input current; see `AI_CONTINUITY/T25J_CORRECTED_OLED_MODULE_PHOTO.md` and top CURRENT EXACT POINT. No new DRC or integrated startup/load-step PASS.
- **T25H selected sources documented; OLED identity unresolved:** Camelion Digi Alkaline LR6, unbranded 4 GB microSD, generic USB sources. User-uploaded WEO012864V PDF is for a bare 20-pin OLED with separate 7.5 V display rail, while schematic `J_OLED` is a switched-3V3 four-pin header. Related WEA012864V four-pin PCB module is a candidate only; verify actual physical assembly before assigning a load or changing the board. See `AI_CONTINUITY/T25H_SELECTED_SOURCE_EVIDENCE_AND_OLED_IDENTITY_GATE.md`. Integrated startup and SD/OLED transient are OPEN; next independent work is a bounded TPS631000 full-startup feasibility fixture.
- **T25F source/load matrix COMPLETE; T25G isolated TPS2116 priority-state fixture PASS**: PSpice 25.1.0 completed the 8 ms 5→3.3→5 V VIN1 ramp with fixed VIN2=3 V in 1.11 s (801 points, no errors/warnings). ST and VOUT traces show both selection directions; explicit fixture load 330 Ω and static source do not represent board transfer. NEXT: obtain exact battery/USB/card/OLED load and capacitor bias data, assess bounded TPS631000 full-startup feasibility, then build integrated power-tree tests. Last physical DRC remains T24 0/0.
- Git AutoSave **v2.5** remains the one-click local sync workflow. It safely fast-forwards GitHub documentation updates, commits local changes and syncs `localbackup`, GitHub and tags. Never auto-merge diverged Altium binary histories.

## Continuity rule

At every meaningful milestone, update `AI_CONTINUITY/CURRENT_HANDOFF.md` in the same Git history as the engineering changes. Append durable decisions/lessons to the other continuity files when they become stable.

The chat-management threshold is approximately **70% of usable conversation context**. Before the chat becomes heavy or continuity degrades, proactively create/update the complete Git handoff and recommend migration to a fresh chat.

Do not rely on chat memory alone for project continuity.
