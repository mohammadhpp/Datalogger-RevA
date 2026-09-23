# T25D — OrCAD X 25.1 installation and isolated TPS631000 runtime gate

Date: 2026-09-23. Status: **test prepared; user runtime result pending**.

## Observed user installation

- Screenshot `Screenshot 2026-09-23 234405.png` shows **Capture CIS, OrCAD X Professional_Plus, 25.1 S050 (459063), Windows SPB 64-bit Edition**. The screenshot does not prove that `psp_cmd.exe` is installed, that PSpice has a usable license, or that the encrypted TI model converges.
- Current source of truth remains the private GitHub `main` and the user's live Windows Altium project. The attached 2026-09-08 T23 ZIP is historical and is not a source for this test.
- This task is an **isolated simulator/model test**, not a change to `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc` or the canonical PcbLib. The last Full Batch DRC is still the T24 user-confirmed 0 warnings / 0 rule violations.

## Correction to T25B archive audit

Reinspection of official `SLVMDV2.ZIP`, SHA256 `f55c75639ad5b62c5437ec114301905fe6c63408cdb689825eb542c095ecd946`:

- `Soft_Start/Soft_Start/Soft_Start.cir` refers to `../../../tps631000.lib`, absent under that filename in the archive; its archived `.out` contains **two ORPSIM-15142 floating-node ERRORs**.
- The archive also contains `Soft_Start/TEST/TEST.cir` referring to the present `../../../tps631000_symbol.lib` and digital support libraries. Its archived `TEST.out` contains no `ERROR(` marker but ends with **JOB ABORTED**. No TI-supplied `.out` from these two profiles proves a successful transient.
- `TPS631000_SYMBOL.lib` exposes `.SUBCKT TPS631000_STARTUP VOUT LX2 LX1 VIN EN MODE GND FB PARAMS: SS=0` followed by encrypted `$CDNENCSTART_ADV2` content. We do not inspect or alter the encrypted internals. The archive's historical output logs are evidence about those prior runs, **not a verdict on the new user's OrCAD X 25.1 installation**.

## Ready-to-run isolated smoke test

- `AI_SCRIPTS/T25/Run_T25D_PSpice_Smoke.cmd` launches `T25D_PSpice_Converter_Smoke_v1.ps1` from the local synced Git repo. User action: double-click the CMD, then upload the generated `Documents/Datalogger_T25D_Result_*.zip`.
- The script locates the Cadence `psp_cmd.exe`, obtains TI's original official ZIP (or uses an already downloaded matching ZIP from `Downloads`), verifies its exact SHA256, extracts only into a timestamped folder under `Documents`, and includes the intact TI model and its shipped digital dependencies.
- It creates a separate PSpice `.cir` with exact Datalogger `U_SYS` pin order, `EN=VIN_MUX`, `MODE=GND`, 1 µH ideal L, 22 µF nominal input C, 47 µF nominal output C, and 510 kΩ / 91 kΩ feedback. **Only for the runtime smoke**, it uses the 2.8 V test input and 3.3 Ω test load shown in TI's supplied example. These stimulus values are **TI-example conditions and not the user's AA cells, USB source or real SD/OLED draw**. Parasitics, bias derating and branch loads remain unmodeled.
- It runs a 0.6 ms transient through `psp_cmd.exe -r`, then collects `.out`, console text and input deck in a ZIP. `MODEL_RUNTIME_SMOKE_PASS` requires process exit 0, an `.out` with job time, and no ERROR/FATAL/JOB ABORTED markers. Warnings are counted but do not constitute project verification; all warnings must be reviewed before the model can be accepted.
- If the PSpice engine is not found, the download fails, hash differs, or the simulator returns an error, the result is `NO_PASS`, with the reason saved. In case of failed direct TI download, download [SLVMDV2.ZIP from TI](https://www.ti.com/lit/zip/SLVMDV2) into Windows `Downloads` and rerun the CMD; the exact SHA check still applies.

## Evidence limits and next gate

The `.ps1` and `.cmd` were inspected statically against the actual TI `.SUBCKT` header and the actual Datalogger nominal values; there is **no Windows PowerShell or licensed PSpice runtime in the AI environment**, so the script has not been executed here. A `MODEL_RUNTIME_SMOKE_PASS` would prove only that the model loads and completes *this isolated example*. It would not validate the board's 3V3 startup, power-source transfer, ripple, SD/OLED load steps, acceptance thresholds or the last T24 DRC. After the user sends the ZIP, audit logs and waveforms, then qualify TPS2116 and construct project-level tests using sourced stimulus and load data.

## First Windows result and expanded discovery — 2026-09-24

- User returned `Datalogger_T25D_Result_20260924_000020.zip`. Its only member is `T25D_Result.txt`, reporting `T25D STATUS: NO_PASS`, blank `PSPICE:`, and `psp_cmd.exe not found in the Cadence installation` at 00:00:20 +03:30. The original v1 discovery checks only selected standard paths and PATH. **No model deck was generated and no simulation ran**. This does not demonstrate a model, convergence, license or project failure, nor conclusively prove PSpice is uninstalled.
- New one-click `AI_SCRIPTS/T25/Run_T25D_PSpice_Smoke_v2.cmd` runs `T25D_PSpice_Converter_Smoke_v2.ps1`. It inspects existing FileSystem Cadence/SPB/OrCAD roots, registered installed products, Cadence Start shortcuts, a running Capture executable path and PATH. It searches those installation roots for `psp_cmd.exe` and reports presence of an alternative `pspice.exe`; it records only whether Cadence environment variables exist, never license values. Its output ZIP includes `T25D_Install_Diagnostic.txt`. If `psp_cmd.exe` is located, the same isolated TI model smoke runs; otherwise it stops without altering the engineering project.
- The v2 script was statically inspected in the AI Linux environment; **it has not run under the user's Windows/PSpice installation**. User action: close any stale result confusion, run `Git_Save.cmd` once to fetch the new scripts, then double-click **the v2 CMD**, and upload the newest `Documents/Datalogger_T25D_Result_*.zip`. If still absent, inspect its diagnostic report before recommending a reinstall or a license change. No new Full Batch DRC was run; T24 remains 0/0.
