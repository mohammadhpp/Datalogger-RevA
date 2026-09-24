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
- **T25E TPS2116 isolated vendor-model runtime PASS, limited scope**: PSpice 25.1.0 completed 7 ms standalone fixture cleanly in 0.83 s, with 701 voltage rows and raw DAT. Its 3.3 Ω fixture actually draws 1.498 A at the simulated 4.944 V final output, so this is not the TI example's 1 A condition or a board source-transfer test. T25E report/newest `CURRENT_HANDOFF.md` carry exact evidence. NEXT: source real battery/USB/SD/OLED data and build staged board-specific transient benches. Last physical DRC remains T24 0/0.
- Git AutoSave **v2.5** remains the one-click local sync workflow. It safely fast-forwards GitHub documentation updates, commits local changes and syncs `localbackup`, GitHub and tags. Never auto-merge diverged Altium binary histories.

## Continuity rule

At every meaningful milestone, update `AI_CONTINUITY/CURRENT_HANDOFF.md` in the same Git history as the engineering changes. Append durable decisions/lessons to the other continuity files when they become stable.

The chat-management threshold is approximately **70% of usable conversation context**. Before the chat becomes heavy or continuity degrades, proactively create/update the complete Git handoff and recommend migration to a fresh chat.

Do not rely on chat memory alone for project continuity.
