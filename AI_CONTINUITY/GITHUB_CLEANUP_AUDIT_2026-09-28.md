# GitHub Cleanup Audit — 2026-09-28

## Scope and safety rule

Non-destructive audit requested before continuing T25BG/T25BH. T23 and T24 are closed. No engineering source, evidence, rollback backup, or continuity archive is deleted by this audit unless independent evidence proves deletion safe.

Baseline before repair: `main=230ebdd0f52615127733859d0804aab059ef5429`.

## 1. Root T23/T24 material

The recursive `main` tree contains 32 root-level T23/T24-named files totaling **1,215,177 bytes**:

- T23-named root material: **1,039,466 bytes**.
- T24-named root material: **175,711 bytes**.
- This includes the T23 board/collision snapshots, T24 DRC output, courtyard/preflight/audit reports, and two T23 PcbLib builder reports.

Verdict: **KEEP / REORGANIZATION CANDIDATE, NOT DELETE**.

Reason: these are historical routing/manufacturing evidence and some are still referenced by continuity lessons and prior audit records. Moving them to an archive folder can be considered later only with a path-reference audit and a manifest. No file was moved or deleted in this cleanup pass.

## 2. Duplicate PcbLib

Two root PcbLib files are byte-identical:

- `DATALOGER_RevA.PcbLib` — 294,912 bytes — blob `f0a6f2ff01768d69fac595770efa8a8685bf91a7`
- `Datalogger_RevA_Clean.PcbLib` — 294,912 bytes — blob `f0a6f2ff01768d69fac595770efa8a8685bf91a7`

`AI_START_HERE.md` identifies `Datalogger_RevA_Clean.PcbLib` as canonical, and `DATALOGER_final.PrjPcb` references that canonical name.

Verdict: `DATALOGER_RevA.PcbLib` is a **strong redundant-file candidate**, but it is **not deleted yet**. Before deletion, confirm in the user's live Altium workspace that no free-document/project state or local workflow still depends on the alternate filename. Git history alone is not enough to prove that local dependency absent.

## 3. AI_CONTINUITY size

`AI_CONTINUITY/` contains 76 tracked files totaling **1,382,682 bytes**. Most apparent size comes from intentional evidence/source recovery rather than disposable chatter.

Largest files:

- `SOURCE_ARCHIVE_REGISTRY_2026-09-25.json`: 273,634 bytes
- `T25V_PURCHASE_BOM_V017_CELL_EXPORT.json`: 256,911 bytes
- `T25V_RECOVERED_BLOCK_DOCUMENT_TEXT.md`: 163,429 bytes
- `HANDOFF_ARCHIVE_THROUGH_T25T_2026-09-25.md`: 152,303 bytes

These four alone account for about **61.2%** of the directory.

Verdict: **NO DELETION**. The size is largely source registry, recovered design basis and historical handoff evidence. A future structural cleanup may move historical reports to an archive/evidence subtree, but only after updating every live reference and preserving the source-retention registry.

## 4. Broken SchLib project dependency

Before cleanup, the `main` tree contained no `.SchLib`, while `DATALOGER_final.PrjPcb` still contained both:

- `DocumentPath=Datalogger_RevA_Clean.SchLib`
- `ComponentLibraryIdentifier0=Datalogger_RevA_Clean.SchLib`

The engineering checkpoint commit `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8` removed that SchLib, whose last blob was `13cfb621487d7078a49562502bbc142f553a5834`, while leaving the project dependency alive.

Safe repair performed:

- exact historical bytes were recovered from pre-removal Git history;
- re-created blob SHA is exactly `13cfb621487d7078a49562502bbc142f553a5834`;
- therefore the restore is byte-identical, not a reconstructed library;
- repair commit: `4c1496497932f05cf8af4234936ba66468dc2c2a` — **Cleanup: restore missing canonical SchLib dependency**.

Verdict: **REPAIRED WITHOUT CAD REDESIGN**.

## Cleanup audit conclusion

- No T23/T24 evidence deleted.
- No continuity/source evidence deleted.
- No PcbLib deleted.
- Missing canonical SchLib dependency restored byte-identically from Git history.
- Fabrication Hold remains unchanged.
- T25BF is not rerun.
- The valid design continuation point remains **T25BG/T25BH**, followed by the source-backed controlled-inrush review specified by the live handoff.
