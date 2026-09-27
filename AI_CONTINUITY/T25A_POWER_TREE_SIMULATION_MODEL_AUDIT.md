# T25A — Power Tree / Simulation Model Audit

Date: 2026-09-23. Status: **source/model audit complete; simulation setup and measured transient results pending**.

## Source and validation boundary

- Repository: private `mohammadhpp/Datalogger-RevA`, `main` at `c89b9b6a7cb1d0d730c371a28418f1161f532020`. Last engineering checkpoint: `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
- Binary source inspected directly: `01_POWER.SchDoc` (Git blob `da2d005712c47000eb8c16157eca464d3fee4fe1`), `02_MCU_CORE.SchDoc` (`d74cd80f998e49d518facb99ec831587b9debbf6`), `03_MICROSD.SchDoc` (`0793ee4aeae92fc5737796ce4631dac9770619f3`), `05_RTC.SchDoc` (`544a58e3ca4ffc08faaf2385b77ad84777c6282d`), `06_OLED_SHT3X.SchDoc` (`9ea7bcd3219aca291eb9ae31838f3011ac3a937a`), `07_EXPANSION.SchDoc` (`8714da5cbc041923e25a1aa647002e88f5b4d9a3`) and `DATALOGER_final.PrjPcb` (`35d9fb5922e0602779d8aa358769e5ccc4ee52be`). Each downloaded binary was verified against its Git blob SHA.
- Method: decode each Altium CFB `FileHeader` record stream; inspect component parameters, model records, pin names/numbers, wires, labels and power ports. Reconstruct electrical pin endpoints from pin orientation/length and trace wire connectivity. This is a source audit, **not an Altium compile, electrical simulation or fresh DRC run**. The last confirmed board DRC remains T24's 0 warnings / 0 violations.
- The tree does not contain the referenced `Datalogger_RevA_Clean.SchLib` or a standalone simulation model/deck. The `PrjPcb` has simulator output types configured, but that alone is not an assigned simulation model or a simulation result. The six inspected sheets contain 48 + 6 + 18 + 6 + 24 + 13 = **115 components**, each with only a `PCBLIB` model record; no `SPICE`/`SIM` model record was found among these. `04_NAVIGATION.SchDoc` was not part of this first power-path census, so this is not a whole-project model count.

## Extracted power tree

```text
BT1 (off-board 2×AA) → BAT_RAW → F1 → BAT_FUSED → S1.A → BAT_SW ─────────────┐
J1 (off-board USB-C) → USB_VBUS_RAW → S1.B → USB_OVP_IN                      │
                                          → Q_OVP / reference protection     │
                                          → USB_VBUS_PROT ───────────────────┤
                                                                             ↓
                                            U_PMUX TPS2116 (VIN1=USB, VIN2=battery)
                                                                             ↓
                                                VIN_MUX → U_SYS TPS631000 → 3V3_SYS
                                                                            ├→ MCU / RTC / buffer / expansion
                                                                            ├→ FB_SENSOR → SENSOR_3V3
                                                                            ├→ Q_SD → SD_VDD → J_SD
                                                                            └→ Q_OLED → OLED_VDD → J_OLED
```

- `S1` is four independent off-board maintained contacts. A routes `BAT_FUSED → BAT_SW`; B routes `USB_VBUS_RAW → USB_OVP_IN`; C/D route `CC1_RD_RET` and `CC2_RD_RET` to GND. It must be an explicit multi-contact source stimulus in the testbench.
- USB protection network: `Q_OVP` FSS2301S has S=`USB_OVP_IN`, D=`USB_VBUS_PROT`, G=`OVP_GATE`; `Q_OVP_DRV` BC857B and `U_OVP_REF` TS431 with `Z_OVP` BZT52C6V2 and resistive divider/hysteresis control its gate. A generic ideal switch would miss the actual turn-on and overvoltage behavior.
- `U_PMUX` TPS2116DRLR: VIN1=`USB_VBUS_PROT`, VIN2=`BAT_SW`, VOUT pins 2/7=`VIN_MUX`, MODE=`USB_VBUS_PROT`, PR1=`PMUX_PR1` (30k to protected USB, 10k to GND), ST=`PMUX_ST` (10k pull-up to `3V3_SYS`). TI specifies that MODE tied to VIN1 selects priority mode. Source-transfer timing must include both rail histories and the downstream load.
- `U_SYS` TPS631000DRLR: VIN pin 4 and EN pin 5 are **both on `VIN_MUX`**; MODE pin 6 is pulled to GND through `R_MODE` 0 Ω, hence auto PFM; LX1 pin 3 and LX2 pin 2 connect through `L1` nominal 1 µH; VOUT pin 1=`3V3_SYS`; FB pin 8=`FB_3V3`; GND pin 7=GND. `C_IN` nominal 22 µF between `VIN_MUX` and GND, `C_OUT` nominal 47 µF between `3V3_SYS` and GND. `R_FB_TOP` 510 kΩ (`3V3_SYS → FB_3V3`) and `R_FB_BOTTOM` 91 kΩ (`FB_3V3 → GND`). Ideal divider calculation at TI's nominal 0.500 V reference gives 3.302 V; this is **not** a simulated or tolerance-bounded output value.
- `03_MICROSD`: `Q_SD` AO3401A is the high-side path `3V3_SYS → SD_VDD`, driven through `Q_SD_DRV` BC847B by MCU net `SD_PWR_CTL`. A 74HC125 buffer is powered from `3V3_SYS` and its output-enable network uses `SD_GATE`. `SD_VDD` has `C_SD_HF` 0.1 µF, `C_SD_MID` 10 µF, and `C_SD_BULK1/2` 22 µF each: nominal sum **54.1 µF** before voltage bias, tolerance, ESR and layout. The card's dynamic current is unspecified in this repository.
- `06_OLED_SHT3X`: `Q_OLED` AO3401A is the high-side path `3V3_SYS → OLED_VDD`, with `Q_OLED_DRV` BC847B and `R_DELAY` 47 kΩ / `D_DELAY` 1N4148WS / `C_DELAY` 0.1 µF affecting `OLED_BUS_EN`; `U_OLED_SW` 74HC4066 gates I²C. `OLED_VDD` has `C_OLED_BULK` 10 µF and `C_OLED_HF` 0.1 µF: nominal **10.1 µF** before derating. OLED module startup and dynamic current are unspecified. The sensor path is separately fed through `FB_SENSOR` to `SENSOR_3V3` with 10 µF + 0.1 µF; it is not switched by `Q_OLED`.
- Other `3V3_SYS` sinks visible in inspected sheets include `U_MCU`, `U_RTC`, `U_SD_BUF`, `U_OLED_SW`, pull-ups, ESD rails and the expansion connector. The RTC also has `VBAT` from `BT2`. These loads must be included as specified background current in a bench, not silently treated as zero.

## Simulation model disposition

| Circuit element | Model evidence in current repository | T25 simulation disposition |
| --- | --- | --- |
| `U_SYS` TPS631000DRLR | Only `PCBLIB` footprint attached. TI publishes an **encrypted PSpice model** `SLVMDV2.ZIP` on its [TPS631000 product page](https://www.ti.com/product/TPS631000). | Exact-part candidate for a supported PSpice environment. Download, inspect pin order, license and simulator compatibility, then run a baseline example before claiming validity. Encrypted format means interoperability with Altium's simulator or another SPICE engine is **unverified**. An averaged behavioral regulator may be used for system-level sweeps, explicitly marked as approximate; it cannot establish true switching ripple, current limit, startup or loop transient. |
| `U_PMUX` TPS2116DRLR | Only `PCBLIB` attached. TI publishes an **unencrypted transient PSpice model** `SLVMDI4A.ZIP` on its [TPS2116 product page](https://www.ti.com/product/TPS2116). | Exact-part candidate after pin-map, mode, PR1 and simulator smoke test. Otherwise a stateful priority-mux model must preserve handoff, slew and reverse blocking limits from the [TI datasheet](https://www.ti.com/lit/gpn/TPS2116). |
| `L1`, R network, C network | Values and MPNs in the embedded schematic parameters; no fitted dynamic/parasitic models. | Ideal L/R/C are immediately representable for topology checks. Replace nominal capacitance with **effective** capacitance under DC bias and resistor/inductor parasitics only after vendor data for these exact MPNs is obtained. Check L1 saturation/DCR and capacitor ESR rather than inferring them from value labels. |
| Battery, USB source, `S1`, fuse | Logical off-board symbols/footprints and nominal markings; no battery discharge/ESR, cable droop, contact bounce or fuse I²t model. | Use explicit source/contact test stimuli with parameters sourced from selected cells, cable/adapter and switch/fuse data. Until then, report a family of scenarios without claiming one “real” startup waveform. |
| USB OVP discrete network | Only footprints on Q/diodes/TS431. R values are specified. | Locate exact manufacturer models and validate pin maps; use generic devices only with disclosed limits. An ideal pass switch is suitable solely for isolating downstream power-path behavior, not OVP threshold/hysteresis qualification. |
| `Q_SD`, `Q_OLED` AO3401A and BC847B drivers | Only footprints; [AOS AO3401A product data](https://www.aosmd.com/products/mosfets/p-channel-mosfets-8v-60v/ao3401a) exists, but no AO3401A SPICE subcircuit is present in the project. | Obtain exact compatible FET/BJT models or validate a controlled-switch approximation against threshold, RDS(on), gate charge and enable timing. Keep branch capacitances explicit. |
| microSD card and OLED module | Connectors and local passive network present; **no chosen card/display module current waveform** or functional SPICE model in source. | Use measured or manufacturer-bounded current-vs-time loads for insertion/power-up/write/display update; run sensitivity sweeps until loads are measured. Do not invent peaks or acceptance thresholds. |
| `U_MCU`, `U_SD_BUF`, `U_OLED_SW`, SHT3x interface, RTC | Only footprints in the inspected source. Firmware sequence and dynamic consumption unavailable. | Represent their supply draw and logic enables behaviorally; test timing/isolation separately. Whole-firmware SPICE simulation is out of scope. |

## T25B preparation: testbench and evidence gates

1. **Qualified converter bench**: obtain `SLVMDV2.ZIP`; check exact `.SUBCKT` pin mapping vs `U_SYS` 1–8; confirm its supported simulator and ability to complete TI's example transient. Obtain `SLVMDI4A.ZIP` and repeat for `U_PMUX`. Keep downloaded vendor assets separate from canonical schematic/PCB until validated. No model substitution into `main` by guesswork.
2. **Power-source startup matrix**: (a) battery source via `S1`, (b) USB via `S1` and OVP, (c) USB-to-battery and battery-to-USB transfers, (d) slow-ramp/brownout and prebiased `3V3_SYS`. Probe `BAT_SW`, `USB_OVP_IN`, `USB_VBUS_PROT`, `PMUX_PR1`, `VIN_MUX`, `U_SYS.EN`, `3V3_SYS` and inductor current. The [TPS631000 datasheet](https://www.ti.com/lit/ds/symlink/tps631000.pdf) gives an input range of 1.6–5.5 V, startup above 1.65 V and integrated soft start; use its conditions, not an invented battery waveform or guaranteed pass limit.
3. **Load-step matrix**: keep MCU/RTC/buffer background loads explicit; toggle `SD_PWR_CTL` and `OLED_CTL` separately and together; apply SD write and OLED update current profiles only after part/module evidence is available. Capture `3V3_SYS`, `SD_VDD`, `OLED_VDD`, `VIN_MUX`, inductor current, gate and `OLED_BUS_EN`; compare dip, overshoot, settling and power sequencing across source conditions.
4. **Parameter corners**: input source impedance, converter mode (as actually tied, auto PFM), effective `C_IN/C_OUT` and branch C at bias, L1 tolerance/saturation/DCR, FET on-resistance and load slew. Nominal labels are insufficient to certify transient margin. TI calls out capacitance derating and recommends 22 µF input, 47 µF output and 1 µH in its [design procedure](https://www.ti.com/lit/ds/symlink/tps631000.pdf).
5. **Acceptance gate**: set rail minimum/maximum and startup-time requirements from the actual MCU, SD card, OLED module and system specification; compare measured board captures to a validated model. No numerical PASS, simulation waveform, power integrity verdict or new DRC verdict is asserted in T25A.

## Continuity / change control

This audit is read-only. The canonical `DATALOGER_RevA.PcbDoc` and `Datalogger_RevA_Clean.PcbLib` remain at the T24 engineering checkpoint, 129/129 courtyard PASS and last reported Full Batch DRC 0/0. A fresh DRC is only required if a future engineering change touches the PCB; source/model attachment to schematics requires compile/ECO review and relevant checks before acceptance. After fetching these GitHub documentation commits locally, run the established `Git_Save.cmd` v2.5 to safely fast-forward and synchronize `localbackup` and `github`.
