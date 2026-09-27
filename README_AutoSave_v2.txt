Datalogger ONE-CLICK Git AutoSave v2
=====================================

Project:
  C:\#MHP FILES\DataLoger

Local Git backup:
  C:\#MHP FILES\GitRepos\DataLoger.git

USAGE
-----
Double-click:
  Git_Save.cmd

There are NO questions and NO confirmation prompts.

The script automatically:
  1. Checks repository, branch main, and localbackup.
  2. Detects changed files.
  3. Creates a commit message from date/time + changed file names.
  4. Runs git add -A.
  5. Creates the commit.
  6. Pushes main to localbackup.
  7. Pushes existing tags.
  8. Shows PASS/FAIL.

If there are no changes, it only synchronizes localbackup and exits.

Example automatic commit:
  Auto checkpoint 2026-08-26 19:30:42 | 2 file(s): 05_RTC.SchDoc, DATALOGER_final.PrjPcb

IMPORTANT
---------
This is intentionally fast and non-interactive. Do not run it while Altium is
in the middle of writing/saving project files. Save/close active edits first,
then double-click Git_Save.cmd.

Milestone tags such as validation PASS are still created separately when
needed; AutoSave does not invent engineering PASS status.
