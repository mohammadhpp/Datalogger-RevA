# T25E — TPS2116 isolated vendor-model smoke

Date: 2026-09-24. Status: **script READY / Windows PSpice execution PENDING**. No TPS2116 runtime PASS is claimed yet.

## Direct source evidence

- Official TI `https://www.ti.com/lit/zip/SLVMDI4` archive was rechecked against audited SHA256 `730dd922475b68183cb2d3ecac3259c8f5637e6458764ced7f3fbc0c89da80a7`; ZIP integrity passes. Model `TPS2116_PSPICE_TRANS/TPS2116_TRANS.LIB` declares `.SUBCKT TPS2116_TRANS GND MODE PR1 ST VIN1 VIN2 VOUT_0 VOUT_1`; model header labels itself PSpice transient Final 1.10 (05 May 2021) and says temperature behavior is not modeled.
- The TI-provided `TPS2116_TRANS.DSN` application note states the supplied STARTUP example uses VIN1=3.3 V, VIN2=5 V, IOUT=1 A, and runs for 7 ms. Its original fully netlisted `.cir` and successful `.out` are **not** present in the archive; the new deck is a separately constructed smoke fixture, not a verbatim TI example. One ampere at 3.3 V motivated an explicitly selected **3.3 Ω resistor fixture** by Ohm's law; the source does not establish that TI used that exact resistor.
- Real `01_POWER.SchDoc`, as decoded in T25A/T25B: physical TPS2116 pins 1 GND, 5 MODE=`USB_VBUS_PROT`, 4 PR1=`PMUX_PR1`, 8 ST=`PMUX_ST`, 3 VIN1=`USB_VBUS_PROT`, 6 VIN2=`BAT_SW`, 2/7 VOUT=`VIN_MUX`. The subcircuit positional order differs from physical numbering. MODE is tied to VIN1 and PR1 uses 30 kΩ from VIN1 and 10 kΩ to GND. The mux output has downstream nominal 22 µF `C_IN` to GND. On the real board ST has a 10 kΩ pull-up to `3V3_SYS`, which this isolated bench does not contain.

## Versioned one-click run

- `AI_SCRIPTS/T25/Run_T25E_TPS2116_Model_Smoke_v1.cmd` launches `T25E_TPS2116_Model_Smoke_v1.ps1` in the user's observed PSpice 25.1 installation. It takes a matching archive from Downloads or downloads the TI original, verifies SHA256 before extraction, checks the exact `.SUBCKT` interface, and builds a detached test deck under Windows Documents. Vendor assets and output stay outside Git and away from canonical Altium files.
- Source rails **3.3 V on VIN1 and 5 V on VIN2** reproduce the documented TI example levels, **not actual board USB/AA voltages**. Fixture uses project MODE/PR1 mapping and nominal 22 µF mux-side capacitor; the model's two VOUT interface pins join the same VOUT node. ST's pull-up is supplied from an explicit isolated 3.3 V bench rail instead of the unmodeled converter `3V3_SYS`. The chosen 3.3 Ω load is a test resistor only. No USB OVP, battery ESR, downstream TPS631000, SD/OLED branch, source-ramp profile, or physical transfer requirement is modeled.
- Transient `.TRAN 0 7m 0 10u SKIPBP` uses the TI example's 7 ms duration. PSpice subprocess is capped at 180 seconds with ten-second heartbeat; timeout terminates only that child and still packages logs. Named-node `.PROBE64` and `.PRINT TRAN` use the voltage syntax proven by T25D v4. The wrapper emits **`Documents/Datalogger_T25E_v1_Result_<timestamp>.zip`** and opens Documents.
- `MODEL_RUNTIME_SMOKE_PASS` requires a concluded PSpice job, reported job time, no error/fatal/abort markers, zero warnings, at least two printed numeric voltage rows and a nonempty raw `.dat`; a known nonzero process exit fails, while unavailable exit status is adjudicated through simulator evidence. Review ZIP `.out` and voltages independently before accepting. Even a clean runtime result would qualify only this isolated fixture and does not prove power-source transfer or `3V3_SYS` startup/load steps.

## Preflight and next action

- Linux static checks passed exact archive SHA, extracted header/order and generated `X_U_PMUX` positional mapping; no Windows PowerShell or PSpice runtime is available here. No actual T25E waveform, success or failure exists yet.
- User: run existing `Git_Save.cmd` **once** to fetch this v1 pair, then double-click **`AI_SCRIPTS/T25/Run_T25E_TPS2116_Model_Smoke_v1.cmd`**, wait for its ZIP path, and send the **new `Datalogger_T25E_v1_Result_*.zip`**. If direct TI download is unavailable, place original `SLVMDI4A.ZIP` in Windows Downloads and repeat the same CMD; the hash check still applies.
- Canonical schematic, PCB and PcbLib remain unchanged. Last physical evidence remains T24 courtyard 129/129 and Full Batch DRC 0 warnings / 0 violations. Longer TPS631000 startup and board-specific loads remain pending.
