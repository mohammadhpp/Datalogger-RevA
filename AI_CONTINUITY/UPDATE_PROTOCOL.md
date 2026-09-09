# AI Continuity Update Protocol

Purpose: keep project continuity inside Git so a new AI/session can resume accurately without relying on chat memory.

## At the start of a new AI/session

1. Read `AI_START_HERE.md`.
2. Read `AI_CONTINUITY/CURRENT_HANDOFF.md`.
3. Read durable decisions and lessons.
4. Read `AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md`.
5. Inspect latest Git commits.
6. Inspect the current engineering files relevant to the requested task.
7. If any handoff statement conflicts with newer Git/file evidence, newer Git/file evidence wins and the handoff must be corrected.

## At every meaningful milestone

Update `AI_CONTINUITY/CURRENT_HANDOFF.md` with:

- current task ID/stage,
- exact completed work,
- exact unfinished work,
- current authoritative file(s),
- known DRC/compile status,
- important counts/measurements when useful,
- next recommended step,
- any warning that must not be forgotten.

Then commit the handoff update together with, or immediately after, the engineering checkpoint.

## When to update other continuity files

### `DECISIONS_AND_CONSTRAINTS.md`
Update only when a design/workflow decision becomes durable and approved.

Examples:
- connector selection,
- PCB layer count,
- component/BOM substitution,
- routing constraint,
- manufacturing requirement.

### `LESSONS_LEARNED.md`
Append when a mistake, failure mode, or successful practice is likely to matter again.

### `HISTORY.md`
Append only major milestone summaries. Do not duplicate every Git commit.

### `CHAT_MANAGEMENT_RULE.md`
Treat the approximately 70% chat-capacity threshold and pre-migration handoff procedure as a durable project rule. Do not allow a long conversation to become degraded before preparing the handoff.

## Handoff quality standard

A good handoff must answer all of these without needing the old chat:

1. What exact file/branch is authoritative?
2. What was just completed?
3. What is still incomplete?
4. What decisions are locked?
5. What known errors/warnings are acceptable at this intermediate stage?
6. What should happen next?
7. What must the next AI avoid changing?

## Git discipline

- Never rewrite shared history merely to make continuity notes prettier.
- Prefer normal commits.
- Keep `main` tracking `localbackup/main` unless explicitly redesigned.
- `github` remains the online secondary remote and AI continuity access point.
- **Normal user workflow is one click only:** run `Git_Save.cmd`.
- Git AutoSave v2.5 first fetches GitHub, safely fast-forwards incoming non-diverged updates, checkpoints local changes, then synchronizes `localbackup`, GitHub, and tags.
- If local and GitHub histories truly diverge, automatic merge must stop rather than risk corrupting or incorrectly merging Altium/binary project files.
- No routine extra `git pull` or manual push command should be required after v2.5 is installed locally.

## Full offline continuity backup

Git continuity does not eliminate the value of periodic full offline backups.

At major release/milestone boundaries, preserve a complete offline continuity package containing source, state/handoff, decisions, validation status, roadmap, relevant history/checkpoints, and hashes where practical. Treat it as disaster recovery; normal day-to-day continuation should use the Git repo.
