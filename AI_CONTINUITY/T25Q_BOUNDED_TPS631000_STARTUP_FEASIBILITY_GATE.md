# T25Q — One-click bounded TPS631000 startup feasibility gate

Date: 2026-09-24. Status: **v1 runner prepared, code/static checks executed; Windows run NOT YET EXECUTED; startup and integrated T25 sign-off OPEN**.

## Why the runtime gate precedes a full transient

Re-read uploaded T25D v4 `.out`: the 10 µs encrypted TI model fixture printed the final 10 µs voltage row (`VOUT≈0.1182V`), ended in `JOB CONCLUDED` and reported **30.98 s** PSpice job time. The v4 wrapper's `NO_PASS` status was a parsing false negative; it does not invalidate the independently inspected 10 µs engine smoke. Earlier 0.6 ms attempt was stopped after roughly 30 minutes (T25F). Extending the 30.98s/10µs observed ratio linearly to 12 ms gives approximately **10.33 hours**, only a **feasibility warning/heuristic**, not a forecast guarantee. Therefore launch the exact-model 12 ms test only after a bounded pilot demonstrates reasonable throughput. TI TPS631000 Rev C typical enable delay 0.87 ms, ramp typical 7.55 ms, max + max 10.18 ms under its table conditions; 12 ms is a fixture duration, not a guaranteed board startup limit.

## Files and behavior

- `AI_SCRIPTS/T25/Run_T25Q_Bounded_Startup_v1.cmd` (double-click after normal `Git_Save.cmd` sync) calls `T25Q_Bounded_Startup_v1.ps1`.
- The script finds the user's previously evidenced `C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe` or PATH executable, verifies official [TI archive SLVMDV2](https://www.ti.com/lit/zip/SLVMDV2) against SHA256 `f55c75639ad5b62c5437ec114301905fe6c63408cdb689825eb542c095ecd946`, checks the `TPS631000_STARTUP` ordered pin header, and works **only under a unique Documents folder**. TI archive can already be in Downloads or downloaded from TI. It never edits any Altium source, changes license settings or packages the encrypted vendor model into the result ZIP.
- Fixture inputs are declared: **ideal VIN=2.8 V and 3.3 Ω RLOAD from TI's sample**, `L1=1 µH`, `C_IN=22 µF nominal`, `C_OUT=47 µF nominal`, FB 510k/91k from current project; `MODE=0`, `EN=VIN`. The project TDK capacitors' *effective biased* values are still unknown; this fixture cannot prove their compliance or battery/card/carrier board behavior.
- First run: 10 µs pilot, **90-second wall-time cap**, 5-second progress. Must have complete `.out` / `JOB CONCLUDED`, PSpice job-time marker, zero warnings/errors, final printed row at 10 µs. The wrapper matches actual v4 log's `JOB CONCLUDED` with whitespace robustly, avoiding the known false negative.
- After a clean pilot, the script computes a simple **linear runtime heuristic**. If projected 12 ms exceeds **600 s**, it records `FULL_RUN_SKIPPED_SLOW_MODEL`, preserving pilot trace/log. Otherwise it attempts a 12 ms transient with **600-second cap**, checks completion/final time, and records either `VENDOR_MODEL_FIXTURE_COMPLETED` (requires independent trace review) or `NO_PASS`. Pilot failure or any error also yields `NO_PASS`.
- In every case, `Documents/Datalogger_T25Q_v1_Result_<timestamp>.zip` contains the report, available deck/logs and small raw DAT. It prints the exact ZIP path, then opens Documents. Upload only that ZIP for independent adjudication. No GUI PSpice configuration is required.

## Verification and limits

Static source checks performed locally: launcher/script path, SHA, 8-pin subcircuit instance, 90s/600s caps, ZIP-in-finally, explicit fixture-only status, and extrapolation arithmetic passed. **This Linux workspace has neither Windows PowerShell nor PSpice**, so no Windows syntax/runtime PASS and no new waveform is claimed. Any bug in the wrapper or failed installer/network access must be diagnosed from its packaged logs rather than silently asserting a model failure.

If the pilot predicts an impractical full startup, stop exact-switching simulation at this gate; perform a *separately labeled* averaged behavioral/system analysis with sourced C_eff and load waveforms, and validate final behavior on physical hardware when available. Do not substitute an invented smooth ramp for actual SD/OLED load-step PASS. If a 12ms isolated fixture completes, it still does not verify battery/USB OVP, true C_eff, actual OLED or SD loads.

Canonical `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc`, `Datalogger_RevA_Clean.PcbLib` unchanged. No new DRC; T24 129/129 and Full Batch DRC 0 warnings / 0 violations remain the physical gate.
