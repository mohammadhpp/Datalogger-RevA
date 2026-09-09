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
5. `AI_CONTINUITY/UPDATE_PROTOCOL.md`

Then inspect the latest Git commits and the current engineering files relevant to the task.

## Current high-level state

- Project: Datalogger RevA, Altium, 2-layer PCB.
- Current major task: **T23 PCB routing**.
- Routing Stage 1 and Stage 2 v3 have been completed as controlled routing work.
- Bottom-layer GND polygon is intentionally **not yet the next construction step**; remaining signal/power blocks should be completed first.
- The project uses Git AutoSave v2.4 dual backup: local backup is required; GitHub is the online secondary backup.

## Continuity rule

At every meaningful milestone, update `AI_CONTINUITY/CURRENT_HANDOFF.md` in the same Git history as the engineering changes. Append durable decisions/lessons to the other continuity files when they become stable.

Do not rely on chat memory alone for project continuity.
