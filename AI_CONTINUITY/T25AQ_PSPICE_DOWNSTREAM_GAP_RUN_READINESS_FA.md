# T25AQ - PSpice switched SD/OLED and 3V3 rail-gap execution gate

2026-09-26; T25AP follow-up. This milestone ships a Windows PSpice 25.1 one-click simulation **fixture**, not a measured board or an integrated TI-model simulation. No PCB has been made. The user must execute the CMD and return its ZIP before any numerical waveform is claimed. **Execution: NOT YET RUN ON USER WINDOWS. NO FABRICATION PASS.**

## Verified design origin and fixture boundaries

- Actual `main:01_POWER.SchDoc` Git blob `da2d005712c47000eb8c16157eca464d3fee4fe1`: `C_IN` is on `VIN_MUX`, `C_OUT` on `3V3_SYS`, and the actual separate branches are `3V3_SYS -> Q_SD -> SD_VDD` and `3V3_SYS -> Q_OLED -> OLED_VDD`. T25A/T25T map `C_OUT=47uF` TDK nameplate, `SD_VDD=22+22+10+0.1uF` and `OLED_VDD=10+0.1uF` nameplates. Their installed DC-biased **effective capacitances are unknown**.
- Workbook v0.17 SHA256 `88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4`, `Power Calculations!B6=0.28A`, B8=1.80V loaded AA and B10 VIN startup >1.65V. This test uses the design-envelope 280mA, **not** the earlier 19mA prototype average and not a measured dynamic SD/OLED load.
- [TI TPS631000 datasheet Rev C](https://www.ti.com/lit/ds/symlink/tps631000.pdf) section 5.3 names **10.4uF minimum effective output capacitance** at 3.3V; one fixture scenario uses this as a *reference*, not proof the actual C_OUT meets it. Another uses unqualified 47uF *nameplate*. Branch capacitors use their nameplates too, so coupled output hold-up may be optimistic.
- The vendor TPS2116 PSpice traces are discrepant against TI physical behavior (T25AE); its Altium operating point failed (T25AN). No claim of vendor-model handoff, converter feedback, OVP or actual AA/USB transient validation is made here.

## Simulation circuit and scope

Files: `AI_SCRIPTS/T25/Run_T25AQ_Rail_Gap_v1.cmd` and `AI_SCRIPTS/T25/T25AQ_Rail_Gap_PSpice_v1.ps1`. The runner builds four `.cir` decks and calls installed `C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe` with `-r`, with 60-second wall timeout per case. The result ZIP in Documents contains `.out`, bounded `.dat`, stdout/stderr, input decks, manifest and result text, even when an error occurs. Decks and wrapper are ASCII.

An ideal regulator source ramps 0 to 3.3V over 100us. An illustrative 50mOhm series resistor and illustrative 50mOhm voltage switches feed `C_OUT` on `3V3_SYS`; separate switches feed the branch capacitors. SD enables at 0.31ms, OLED at 0.51ms; both are on before interruptions at 1ms and 2ms. Background resistor 23.571428571ohm takes 140mA at 3.3V; SD fixture 33ohm takes 100mA and OLED fixture 82.5ohm takes 40mA, yielding **280mA at 3.3V** when all enabled. These allocations, resistor load laws, on-resistances and switch times are illustrative; **no card/module current, FET RDSon or converter transient was measured as these values**. Resistive current falls with voltage, making some dips smaller than constant-current loading.

The ideal regulator disconnects for **10us or 50us** after each interruption, then instantly reconnects. These are two *unverified sensitivity settings*, not guaranteed TPS2116+TPS631000 timings. Four cases = {10.4uF TI effective reference, 47uF TDK nameplate} x {10us,50us}. At a 1us maximum PSpice step, `.PRINT` captures `3V3_SYS`, `SD_VDD`, `OLED_VDD` and control, with prestate and two gap minima. Real `VIN_MUX`, `C_IN`, `C_USB1`, AA source impedance, TPS2116, TPS631000, OVP, SD writes, NRST and firmware are outside this circuit. Separate branch capacitor paths prevent falsely adding upstream capacitors to C_OUT.

Reference voltage floors for **later interpretation only**: STM32G070KBT6 falling PDR max 2.04V on its VDD pin (ST DS12766 Rev3); conventional 3.3V SD VDD min 2.7V on card supply (SD Association), which does not ensure write integrity; WEO bare-panel 2.8V logic floor applies only if the user's four-pin module identity is verified (T25AP). A numerical voltage above a reference does **not** demonstrate no MCU reset or valid USB removal at BAT_SW=1.8V.

## Pre-run verification and next action

Static gate before submission: actual 01_POWER SchDoc Git blob matched live source; ASCII, embedded deck markers, distinct capacitor nets, four monotonic PWL schedules and zero unexpanded placeholders passed; 140+100+40=280mA at 3.3V calculated independently. **PSpice execution cannot be done in this Linux workspace because the user's Windows installation is not accessible.** Syntax/convergence still require a Windows run; diagnostics are packaged for iteration.

1. In Windows repo `C:\#MHP FILES\DataLoger`, run `Git_Save.cmd` to fetch the new files through established safe fast-forward and dual backup. If it reports a conflict, share its message and do not run the script.
2. Double-click `AI_SCRIPTS\T25\Run_T25AQ_Rail_Gap_v1.cmd`; wait for `RESULT ZIP:`. No Altium or parameter editing. Four 60-second per-case timeout bounds apply, plus startup overhead.
3. Upload `Datalogger_T25AQ_v1_Result_*.zip` from Documents. Inspect `.out`/`.dat`; fix any parser/solver error using a newly versioned filename and repeat the run.
4. Even all four completed numerical fixtures do **not** close the no-reset/SD-write fabrication gate. Actual transition and converter response require qualified models or physical evidence, qualified effective capacitors and bounded gap. Do not produce factory files or substitute purchased BOM parts.

CAD/BOM unchanged; no new DRC run. Last T24 Full Batch DRC was 0 warnings/0 violations at checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
