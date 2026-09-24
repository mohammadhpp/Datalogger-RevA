# T25P — Final T25 power-tree simulation audit verdict

Date: 2026-09-24. Scope: **final verdict for the source/model audit to date, not a board simulation or electrical sign-off**. Source: private GitHub `main` canonical Altium files and continuity reports T25A–T25O. The Sept 8 T23 ZIP is historical rollback only.

## Direct answer

**The RevA power tree is traceable and the two key TI macromodels can execute in the user's OrCAD X/PSpice 25.1. The complete Datalogger startup, transient response, and switched SD/OLED power integrity are NOT VERIFIED and must NOT be labeled PASS or release-ready from this evidence.** The missing data cannot be replaced with invented numerical profiles. Nominal passive matching to the TI typical application is not effective-capacitance compliance.

## Source-derived electrical path

`2×AA Camelion Digi Alkaline → BAT_RAW → fuse/switch → BAT_SW → TPS2116 VIN2`.

`USB-C / generic charger or power bank → USB_VBUS_RAW → switch → discrete OVP → USB_VBUS_PROT → TPS2116 VIN1`.

`TPS2116 VIN_MUX → TPS631000 VIN=EN → L1 / C_IN / C_OUT / FB 510kΩ+91kΩ → 3V3_SYS → MCU/RTC/buffer/sensors/expansion, Q_SD→SD_VDD→unbranded 4GB card socket, Q_OLED→OLED_VDD→four-pad display carrier`.

Detailed pin mapping/verified schematic blob hashes: T25A and T25F. Correct OLED photo has **VCC/GND/SCL/SDA**, matching the ordered electrical `J_OLED` signals on paper. The supplied WEO bare-panel PDF does not characterize the actual photographed carrier's 3.3 V input current or prove physical mating. The earlier reversed-polarity assertion from wrong-module photos is **retracted**.

## Final evidence and verdict by claim

| Claim or component | Evidence actually obtained | Verdict |
| --- | --- | --- |
| T23 PCB routing, T24 courtyard/DRC | Previously accepted routing PASS; 129/129 persistent courtyard; last Full Batch DRC 0 warnings / 0 violations at physical checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`. | **PASS for that physical checkpoint only.** No later schematic/PCB/PcbLib engineering edit or fresh DRC in T25. |
| TPS631000 encrypted model engine | Official TI model archive SHA `f55c75639ad5b62c5437ec114301905fe6c63408cdb689825eb542c095ecd946`; isolated PSpice 25.1 10 µs run finished in 30.98 s and printed voltages. Output ~0.1182 V at 10 µs. | **PASS: model/engine smoke only.** The output at 10 µs is an incomplete startup; no 3.3 V regulation verdict. |
| TPS2116 model and selection | Official model, verified pin order; isolated 7 ms model smoke and 8 ms VIN1 priority ramp both finished with inspected voltage traces. Fixture load 330 Ω and independent supply; actual OVP/load/source dynamics excluded. | **PASS: isolated model/priority fixtures.** Board source-transfer and `3V3_SYS` dip UNVERIFIED. |
| Inductor `DFE322512F-1R0M=P2` | Exact Murata 1 µH ±20%, max DCR 32 mΩ, 4.8 A DC at 30% L decrease, 3.8 A DC for +40°C on vendor six-layer test PCB. TI Eq. 3 illustrative VIN 2.7V, IOUT 1.5A, η0.9, initial L0.8µH/f1.8MHz: peak 2.208A, TI +20% saturation target 2.649A. | **PASS: identity/ratings and bounded static arithmetic.** In-circuit L(I,T), switch-limit behavior and thermal/transient PASS OPEN. |
| Exact `C_OUT` / `C_IN` | TDK 47µF±20% X5R/10V and 22µF±20% X5R/35V. TI minimum **effective** values 10.4µF at VOUT 3.3V and 4.2µF input. T25O's *illustrative* separate tolerance×temperature screen yields required additional retention ≥32.54%/28.07% before unresolved aging/bias. TDK numeric C(V,T)/PSpice payload unqualified. | **OPEN:** no actual min effective-C values at operating voltage/temperature/age; no TI passive compliance verdict. |
| Sources/load behavior | User identifies 2 AA Camelion Digi, generic USB sources, unbranded 4GB card and photographed four-contact OLED carrier. No verified cell pulse ESR/SOC, cable/adapter/OVP dynamic, firmware loads, card write/inrush or actual carrier startup/update current waveforms. | **OPEN:** quantitative battery/USB transfer, SD/OLED switched loads and worst-case power budget. |
| Full `3V3_SYS` startup and load-step | TI Rev C EN delay ~0.87ms typ/1.5ms max plus 6.42/7.55/8.68ms ramp min/typ/max under stated table conditions. A 0.6ms earlier run was stopped after ~30min; a finished ≥multi-ms converter transient and complete board load integration are absent. | **NO PASS / OPEN.** No valid voltage droop, overshoot, settling, cold battery, switchover or simultaneously switched-load conclusion. |

## Decision and next executable gate

**T25A simulation-model audit is complete; T25 system simulation/sign-off is not complete.** Reject any statement that the PCB is electrically validated merely because DRC is 0/0 or two isolated device fixtures run.

To change this verdict, require **both**: (1) numerical vendor/bench effective C of exact `C_OUT` and `C_IN` at relevant DC bias and temperatures, with tolerances/aging handled; (2) a **completed** PSpice TPS631000 startup over the TI millisecond startup time, with recorded `VIN_MUX`, `3V3_SYS`, `FB` and `I(L1)`. A fully integrated board PASS additionally requires real or explicitly bounded source impedances and selected card/carrier/firmware current vs time, matched acceptance limits and validated OVP/source handoff. Until those inputs exist, transparent scenario sweeps are development tools, not product certification. No hardware redesign is ordered on insufficient evidence.

The original T25D v4 process watchdog is 180 seconds, while the observed 0.6ms attempt ran about 30 minutes before stopping; a blind 10ms rerun or an automatic PASS from a shorter truncated trace would be technically misleading. This report therefore supplies the final **current evidence verdict**, not a fabricated waveform or an unsafe long-running PSpice job.

## Source links and unchanged files

- [TI TPS631000 Rev C](https://www.ti.com/lit/ds/symlink/tps631000.pdf), §§5.3/5.5/6.3.2/7.2; [TI TPS2116](https://www.ti.com/lit/ds/symlink/tps2116.pdf).
- [TDK C_OUT](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1A476M125AC), [TDK C_IN](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1V226M125AC), [Murata L1 reference specification](https://pim.murata.com/asset/pim4/inductor/J(E)TE243A-0019_PDF_INDUCTOR).
- Detailed evidence: `AI_CONTINUITY/T25A_POWER_TREE_SIMULATION_MODEL_AUDIT.md`, `T25D_PSPICE_25P1_INSTALL_AND_CONVERTER_SMOKE.md`, `T25F_POWER_SOURCE_LOAD_REQUIREMENTS_MATRIX.md`, `T25G_TPS2116_PRIORITY_FIXTURE.md`, `T25M_STARTUP_ACCOUNTING_AND_TDK_BIAS_STATUS.md`, `T25N_MURATA_INDUCTOR_SOURCE_AUDIT.md`, `T25O_TDK_EFFECTIVE_C_SCREENING_GATES.md`.
- Canonical `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc`, `Datalogger_RevA_Clean.PcbLib` unchanged. No fresh DRC is claimed.
