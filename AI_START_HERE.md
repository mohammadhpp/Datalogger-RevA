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

- Project: Datalogger RevA, Altium, 2-layer PCB.
- Current major task: **T23 PCB routing**.
- Routing Stage 1 and Stage 2 v3 have been completed as controlled routing work.
- Bottom-layer GND polygon is intentionally **not yet the next construction step**; remaining signal/power blocks should be completed first.
- Git AutoSave **v2.5** is the standard one-click workflow: `Git_Save.cmd` safely checks/fetches GitHub, fast-forwards safe incoming updates, creates a checkpoint when needed, then synchronizes `localbackup`, GitHub, and tags.
- Unsafe/diverged Git histories must not be auto-merged because Altium project files include binary formats.

## Continuity rule

At every meaningful milestone, update `AI_CONTINUITY/CURRENT_HANDOFF.md` in the same Git history as the engineering changes. Append durable decisions/lessons to the other continuity files when they become stable.

The chat-management threshold is approximately **70% of usable conversation context**. Before the chat becomes heavy or continuity degrades, proactively create/update the complete Git handoff and recommend migration to a fresh chat.

Do not rely on chat memory alone for project continuity.
