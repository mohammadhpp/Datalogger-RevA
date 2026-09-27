# Chat Management / Continuity Rule v1.0

This rule is mandatory for long Datalogger conversations.

## Trigger threshold

When the active conversation is estimated to have reached about **70% of usable context capacity**, the AI must proactively warn the user before the chat becomes heavy, inconsistent, or difficult to continue.

Do not wait for the user to notice degraded continuity.

## Required action at the threshold

Before moving to a new chat, the AI must prepare and persist a complete handoff/continuity checkpoint containing at least:

- current exact project/task/stage,
- authoritative branch and engineering files,
- work completed in the current chat,
- unfinished work and exact next step,
- durable design decisions and constraints,
- important project lessons and known failure modes,
- current compile/DRC/validation status,
- important counts, dimensions, hashes, tags or checkpoints when useful,
- warnings and items that the next AI must not change or repeat.

The relevant files under `AI_CONTINUITY/` must be updated in Git before the chat migration whenever possible.

## Migration procedure

1. Update `CURRENT_HANDOFF.md` and any other continuity files that became stale.
2. Commit continuity changes to Git.
3. Ensure project changes and continuity notes are synchronized through the established Git workflow.
4. Recommend continuing in a fresh chat.
5. In the new chat, start from `AI_START_HERE.md` and follow its required read order before making new project decisions.

## Quality rule

A new AI/session must be able to resume the project correctly from Git even if the old chat is unavailable.

Chat memory is supplementary only; Git continuity is the durable source.
