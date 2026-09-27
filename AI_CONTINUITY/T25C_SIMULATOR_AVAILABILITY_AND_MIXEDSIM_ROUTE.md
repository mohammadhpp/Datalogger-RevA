# T25C — Simulator Availability and MixedSim Route

Date: 2026-09-23. Status: **simulator route selected; runtime and project transients pending**.

## Observed availability and decisive compatibility

- User checked Windows Installed apps for PSpice / OrCAD / Cadence and reported no result. Treat full PSpice as **not currently available**; this is not an exhaustive search of every executable or license.
- The official TI TPS631000 archive inspected in T25B contains an encrypted Cadence PSpice subcircuit `TPS631000_STARTUP` (`$CDNENCSTART_ADV2`). Altium [states explicitly](https://www.altium.com/documentation/knowledge-base/altium-designer/understand-spice-models-supported-in-altium) that encrypted PSpice models run only in their designated simulator. Therefore the supplied TPS631000 vendor model **cannot be run in Altium MixedSim**. Do not attach it to the canonical schematic or claim an Altium converter transient.
- The TI TPS2116 `TPS2116_TRANS.LIB` is unencrypted PSpice. Altium MixedSim supports a range, **not all**, of PSpice models. Its compatibility remains **unverified until an isolated runtime smoke test succeeds**. The explicit eight-position map in T25B must be used; pin-number order is wrong.
- The project does not yet have simulation model links on any of the 115 components in the six inspected power-related sheets. Altium [requires linked models](https://www.altium.com/documentation/altium-designer/circuit-simulation/verifying-preparing-project) for the circuit in simulation scope. Do not press Run Simulation on the canonical whole project expecting a valid power-tree result.
- Altium documents [standalone AdvancedSim netlists](https://www.altium.com/documentation/altium-designer/circuit-simulation/working-with-spice-netlist) and [running an external `.nsx` as a free document](https://www.altium.com/documentation/knowledge-base/altium-designer/run-mixed-signal-simulation-off-of-netlist-generated-externally-to-compare-the-results-from-other-engines-directly). This is the isolated testbench path, without ECO or schematic/library edits.

## Model plan for the actual power tree

| Element | Available evidence | Isolated bench treatment | Validity gate |
| --- | --- | --- | --- |
| `TPS2116` on `USB_VBUS_PROT` / `BAT_SW` → `VIN_MUX` | Exact unencrypted TI `TPS2116_TRANS.LIB`; physical/positional map in T25B | First run a minimal vendor-model source-transfer netlist in MixedSim if installed. Use project MODE/PR1/ST/VOUT wiring. | Syntax, convergence, source handoff, state and reverse-current behavior must be checked against TI description before use. |
| `TPS631000` `VIN_MUX` → `3V3_SYS` | Exact TI model encrypted for PSpice | Represent as an explicitly labeled **behavioral** regulator only for power-tree sensitivity studies; nominal 1 µH / 22 µF / 47 µF / 510 kΩ / 91 kΩ from real schematic may be carried over. | No claimed switching ripple, current limit, loop response, soft start duration or startup PASS. Full Cadence-compatible vendor simulation or board measurements are required for these. |
| SD/OLED switched branches | `Q_SD`, `Q_OLED` high-side AO3401A; schematic nominal `SD_VDD` 54.1 µF and `OLED_VDD` 10.1 µF | Explicit branch capacitances and controlled switch; current waveforms as **unfilled measured/manufacturer inputs**, independently and concurrently switched. | Source actual module/card current profiles, effective C at DC bias, FET dynamic parameters and sequence timing before interpreting numeric rail dips. |
| Battery/USB, S1, OVP, MCU/background | Topology known; impedance/droop/consumption and USB OVP device models unresolved | Explicit source/mux/background parameters and recorded provenance; keep OVP idealization clearly outside OVP validation. | Evidence for real AA cells, cable/adapter, fixed background loads and acceptance rail window. |

The capacitor-only charge-balance relation `ΔV ≈ ΔI·Δt/C_eff` can be used as an **unregulated limiting sensitivity**, not a prediction of actual TPS631000 control response; `C_eff`, `ΔI` and duration need external evidence. No synthetic current or time value has been inserted.

## Next exact action, without installing PSpice

1. In the user's Altium Designer, open the project's `01_POWER.SchDoc` and check whether the **Simulate** menu / **Simulation Dashboard** is available, or inspect **Extensions and Updates → Installed → Mixed Simulation**. Altium's [extension setup guidance](https://www.altium.com/documentation/knowledge-base/altium-designer/setup-mixed-sim-in-altium-designer) gives the installation route if absent. Opening a project schematic is only a feature check; **do not run/modify the canonical power sheet**.
2. Once Mixed Simulation availability is confirmed, create a **separate** standalone `.nsx` bench for the unencrypted TPS2116. Import the locally downloaded TI archive's `TPS2116_TRANS.LIB` from its own isolated folder, map the two VOUT terminals to `VIN_MUX`, and run a source-transfer smoke test. Capture exact Altium version, log, and waveforms. If it fails, record the parser/runtime failure, then isolate a behavioral mux as an explicit approximation.
3. Prepare converter and SD/OLED load experiments with parameters kept unfilled until provided by manufacturer data or measurements. Bench `3V3_SYS` startup, isolated/joint branch enable, and source handoff; keep the distinction between mathematical sensitivity and physically validated transient response.
4. If exact TPS631000 dynamic qualification is required, use a supported full PSpice installation when available or measure the assembled board. TI WEBENCH examples or datasheet plots may guide **datasheet-condition** reasoning but are not a simulation of this Datalogger topology.
5. Check the present **local** `Datalogger_RevA_Clean.SchLib` before future model attachment. The GitHub tree lacks that referenced file. Do not start any schematic ECO from an old backup.

No new PCB/PcbLib changes or DRC. The prior T24 129/129 courtyard and Full Batch DRC 0/0 remain the last accepted board evidence.
