# T25CV — loaded 1.80V AA path, current-conserving bounded input-pin gate

**Date:** 2026-10-09. Continues T25CU, no invalid prior PSpice fixture rerun. **ACTUAL_TEST_WITH_RAW_EVIDENCE / CONDITIONAL_DC_POWER_BALANCE_ONLY**, NOT a TPS631000 vendor simulator run or assembled system PASS.

TI [TPS631000 Rev C](https://www.ti.com/lit/ds/symlink/tps631000.pdf) states recommended VIN 1.6..5.5V and **device-pin VIN >1.65V for start-up**; it does not certify 280mA at 1.80V via product summary load ratings measured at higher VIN. Project minimum 1.80V is **loaded pack-terminal voltage**, so the series resistance of holder, S1 BAT contact, wires, PCB copper/vias between terminals and the converter VIN pin matters. Do not count AA internal ESR twice when loaded pack voltage is given.

With Pout=3.3*0.280=0.924W and illustrative constant efficiency eta, P_in=Pout/eta. Solve Vpin=1.80-Rpath*Iin, Iin=Pout/(eta*Vpin) on high-voltage branch. At Vpin1.65V exactly, Rpath=(0.15*1.65*eta)/0.924. Executed Python **35 physically current-conserving DC scenario cases**, independently checked KCL identities.

| assumed eta | R threshold where Vpin reaches 1.65V | estimated Iin at boundary |
|---|---:|---:|
| 0.70 | 0.1875Ω | 0.800A |
| 0.75 | 0.20089Ω | 0.74667A |
| 0.80 | 0.21429Ω | 0.700A |
| 0.85 | 0.22768Ω | 0.65882A |
| 0.90 | 0.24107Ω | 0.62222A |

**These are conditional equalities without engineering safety reserve, NOT allowed maximum resistances in a final BOM.** Real eta at VIN1.8V/temperature/load is not established. Pulsed current, capacitor ESR/DC bias, inductor L(I,T), actual S1/holder, cold-start waveform and source mux reset/write timing remain OPEN. If the converter is already operating while USB is present, its cold-start condition is distinct from an actual switchover; no hardware FAIL is inferred. Battery must remain ready to supply while USB buck starts; real current-conserving mux waveform still needed.

Full 35-row executable results with checksums are packaged as local T25CV result ZIP; compact Python reproducer + evidence summary in Git. No device model acquired or simulated in this stage. Existing TPS631000/L1 1uH maintained, SD subgate left screened, S1 exact sourcing deferred.

**NEXT EXECUTABLE ACTION:** qualify path R with physical part-specific source data and prepare non-synthetic voltage/current probes BAT1.80/USB5/5.50/3V3_SYS/MCU.NRST/SD writes. **BLOCKER REQUIRING USER:** none for independent analysis; full procurement/ECO needs a single explicit decision. **FABRICATION HOLD**.
