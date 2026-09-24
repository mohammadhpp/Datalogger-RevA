# T25G — Controlled TPS2116 priority-selection fixture

Date: 2026-09-24. Status: **versioned PSpice test READY / Windows runtime PENDING**. This is an isolated model characterization, not a board transfer result.

## Evidence and design

- `AI_CONTINUITY/T25F_POWER_SOURCE_LOAD_REQUIREMENTS_MATRIX.md` established the exact `01_POWER.SchDoc` source/mux nets and PR1 divider: 30 kΩ top ±1%, 10 kΩ bottom ±0.5%; MODE=`VIN1`; VOUT pins 2/7 tied to `VIN_MUX`; `C_IN` 22 µF nominal; ST pull-up to the board's downstream 3V3 rail. The official [TPS2116 datasheet Rev. A](https://www.ti.com/lit/ds/symlink/tps2116.pdf) says VIN1 is selected above PR1 reference 0.92–1.08 V and VIN2 when below; resistor-derived static typical boundary is **4.000 V** (calculated range 3.639–4.369 V with resistor tolerances). The preceding T25E static-source run selected VIN2 at VIN1=3.3 V and PR1=0.825 V, consistent with the truth table; it had **no crossing event**.
- New one-click `Run_T25G_TPS2116_Priority_Fixture_v1.cmd` calls `T25G_TPS2116_Priority_Fixture_v1.ps1`. It uses the verified original TI archive SHA256 `730dd922475b68183cb2d3ecac3259c8f5637e6458764ced7f3fbc0c89da80a7`, exact official subcircuit positional pin order, and only a separate Documents working folder. It never opens or edits the canonical Altium project.
- Explicit **test fixture**: VIN1 PWL starts at 5 V, ramps to 3.3 V between 1 and 2 ms, stays to 4 ms, returns to 5 V at 5 ms; VIN2 is a fixed **3 V fixture**; 330 Ω output resistor yields load current depending on simulated VOUT, **not actual board draw**; 22 µF nominal mux capacitor; ST pulled up through the schematic 10 kΩ to an **independent 3.3 V fixture supply**, not the real `3V3_SYS`. No AA-cell ESR, USB supply/cable/OVP, switch contact dynamics, exact effective C, TPS631000, SD/OLED or MCU load is represented. PWL times and 330 Ω are controlled stimulus choices, never product requirements or measurements.
- `.TRAN 0 8m 0 10u SKIPBP` prints VIN1, VIN2, PR1, VOUT (`VIN_MUX` fixture), ST and raw DAT. Process is capped at 180 seconds with ten-second progress. Unique output: **`Documents/Datalogger_T25G_v1_Result_<timestamp>.zip`**. A script status `FIXTURE_TRACE_CAPTURE_PASS` means clean simulator completion/data only; the next AI must inspect waveform transitions, selection and ST behavior before any **model-level priority-selection PASS**. A known nonzero process exit, simulator failure markers, warnings or missing data yields `NO_PASS`.

## Next exact action

1. User runs `Git_Save.cmd` once to fetch the new versioned pair. Double-click **`AI_SCRIPTS/T25/Run_T25G_TPS2116_Priority_Fixture_v1.cmd`**, wait for the ZIP path, send fresh `Datalogger_T25G_v1_Result_*.zip`.
2. Independently inspect `.out` and actual PRINT rows to locate PR1 crossing, VOUT channel handoff, ST state and any dip; compare only to the isolated fixture and official model expectations. The status of an integrated USB/AA/`3V3_SYS` transient remains **OPEN** regardless of this fixture outcome.
3. For the board case, first fill the T25F missing source/load/capacitance evidence and qualify longer bounded TPS631000 startup; no invented AA ESR or SD/OLED pulses may be promoted to board PASS.

Source files untouched. No fresh DRC; T24 courtyard 129/129 and Full Batch DRC 0 warnings / 0 violations remain the last confirmed physical-board results.
