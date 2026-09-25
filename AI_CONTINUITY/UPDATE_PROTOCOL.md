# AI Continuity Update Protocol

Purpose: keep project continuity inside Git so a new AI/session can resume accurately without relying on chat memory.

## At the start of a new AI/session

1. Read `AI_START_HERE.md`.
2. Read `AI_CONTINUITY/CURRENT_HANDOFF.md`.
3. Read durable decisions and lessons.
4. Read `AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md`.
5. Inspect latest Git commits.
6. Inspect the current engineering files relevant to the requested task. For BOM and SD/OLED claims inspect current SchDocs and matching T25/T23 records; distinguish the connector MPN from an off-board card/module. Look up already provided PDF/photo evidence in stored project files; an absent Git-tracked PDF is not evidence that the user never supplied it.
7. If any handoff statement conflicts with newer Git/file evidence, newer Git/file evidence wins and the handoff must be corrected.
8. Read `AI_CONTINUITY/SOURCE_REGISTRY_AND_RETENTION_RULE_FA.md` and the machine-readable source archive registry before declaring a historical PDF/BOM or ZIP unavailable or safe to delete. The Git exports of workbook cells and PDF text are accessible evidence but cannot substitute for the original binary/ZIP.
9. Before making a quantitative claim, keep **measured prototype value / historical design envelope / current-board verified value** separate. User's final correction: 19 mA old DMM reading, 280 mA basis for *all power calculations and part selections*, no accepted 85 mA reading.

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

Keep exactly one active `CURRENT EXACT POINT` in the live handoff. Replace the previous current status instead of appending dated copies; archive detailed old snapshots in a separate file linked from the live handoff. Aim to keep the live entry short enough to read in full before working. Never move/delete historic content without preserving an exact copy. Then commit the handoff update together with, or immediately after, the engineering checkpoint.

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

## Archive deletion and automated continuity guard (T25V)

- Full T22 and stage T23 binary ZIPs, plus the curated ZIP, live in stored project files and are indexed by SHA256 in `SOURCE_ARCHIVE_REGISTRY_2026-09-25.json`. None of the three full ZIP payloads is committed to GitHub. A manifest, PDF text extraction, Excel-cell export or GitHub Actions PASS **does not** authorize deleting an original archive; first restore its full bytes from an independently verified replacement and compare whole-file SHA256 and ZIP integrity.
- `.github/workflows/continuity_guard.yml` runs `AI_SCRIPTS/Continuity/check_source_continuity.py` at pushes to main and on request. It verifies required live continuity/CAD paths, the single exact-point heading, presence of the source registry, hashes of known external archives, the 14-tab workbook export and `B6=0.28 A`. Its PASS concerns **Git-readable continuity only**, never storage of absent ZIPs, physical DRC or functional simulation.
- At each new session read `AI_START_HERE.md`, its linked archive registry, recovered source text/workbook cell export, then current relevant SchDocs. If any evidence is only in an archived ZIP/Library, use its registry path and hash. Never mistake stale historical blocks for the current circuit.
