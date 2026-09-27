# T25N — Murata L1 manufacturer audit and bounded boost-current screen

Date: 2026-09-24. Status: **exact selected inductor manufacturer specification QUALIFIED for static ratings; example steady-state arithmetic EXECUTED; actual in-circuit transient and thermal PASS OPEN**.

## Exact sources and identity

- Actual `01_POWER.SchDoc` project inventory (T25F verified live Git blob) identifies `L1 = DFE322512F-1R0M=P2` between TPS631000 LX1/LX2, and the `3V3_SYS` nominal target is 3.3 V. The existing T25F matrix records the part and nets.
- Murata [DFE322512F reference specification J(E)TE243A-0019E-01](https://pim.murata.com/asset/pim4/inductor/J(E)TE243A-0019_PDF_INDUCTOR), PDF page 2 table, **the exact `-1R0M=P2` row**: initial nominal inductance **1.00 µH ±20%**, DCR **32 mΩ maximum**, DC current at **30% decrease from initial L = 4.8 A**, DC current for **40°C rise on Murata's six-layer test board = 3.8 A**. Murata defines rated DC current as the *smaller* of the inductance-change and temperature-rise ratings; hence the controlling published DC rating is **3.8 A in the stated test setup**. These currents are characterized in DC tests; they are not the project's measured pulse/thermal limits.
- [TI TPS631000 Rev. C](https://www.ti.com/lit/ds/symlink/tps631000.pdf), §§5.3, 5.5, 7.2.2.2: recommended L **0.7–1.3 µH**; TI's Eq. 3 estimates **steady-state boost-mode peak inductor current** and recommends **20% more inductor saturation rating**. At zero current the nominal tolerance interval **0.8–1.2 µH** lies within TI's 0.7–1.3 µH. This alone does **not** qualify L after current-dependent reduction.
- TI's switch peak limit **2.6 / 3.0 / 3.35 A** min/typ/max is a **DC production test**; TI states that its operating current limit can be somewhat higher depending on propagation delay/external components. It is a different number from either Murata rating. The TI part feature says **1.5 A output for VIN ≥2.7 V and VOUT=3.3 V**; no claim of 1.5 A output at 1.6 V is made.

## Executed, explicit illustrative cases

Implemented `AI_SCRIPTS/T25/T25N_Inductor_Boost_Current_Screen_v1.py` and executed its 2.7 V / 1.5 A / 0.9 efficiency / 0.8 µH / 1.8 MHz case. The 2.7 V and 1.5 A match TI's *typical application design requirements*, **not** a measured board load or minimum VIN at the converter input. Efficiency 0.9 is TI's allowed *estimate*, not characterized project efficiency. 0.8 µH is initial lower part tolerance without DC-bias reduction; 1.8 MHz is TI's specified minimum switching frequency. Also computed the nominal 1.0 µH / 2.2 MHz sensitivity case; 2.2 MHz is TI's upper switching-frequency table value, not its typical 2.0 MHz.

TI Eq. 2–3 as rendered on datasheet page 11: `D=(VOUT−VIN)/VOUT`; `Ipeak=IOUT/[η(1−D)] + VIN·D/(2·L·f)`. Units V, A, µH, MHz yield A for the ripple term. The arithmetic is a static ideal-duty design screen; it omits cold cells, mux drop, switching losses outside the assumed η, source sag, load pulses and actual inductance-vs-current.

| Illustrative case | Calculated Ipeak | TI 1.2× saturation target | Murata published 4.8 A / target |
| --- | ---: | ---: | ---: |
| 2.7 V, 1.5 A, η=0.9, initial L=1.0 µH, f=2.2 MHz | 2.149 A | 2.578 A | 1.862 |
| 2.7 V, 1.5 A, η=0.9, initial L=0.8 µH, f=1.8 MHz | **2.208 A** | **2.649 A** | **1.812** |
| **Counterexample only:** 1.65 V, 1.5 A, η=0.9, initial L=0.8 µH, f=1.8 MHz | 3.620 A | 4.344 A | 1.105 |

The last row is **not** a supported rated output-current claim: it exceeds TI's quoted 1.5 A-at-≥2.7 V input condition and its calculated peak exceeds TI's 3.35 A *DC test maximum* (which is itself not the operating limit). It demonstrates why comparing the two published inductor amperage ratings to “3 A” cannot certify weak-battery full-load operation. The 2.7 V illustration has an apparent static saturation-current margin, **not** a device, board, startup, thermal or SD/OLED load-step PASS.

## Modeling disposition and next gate

- An ideal **1 µH inductor** is a declared first-order fixture. A fixed 32 mΩ winding resistor is an optional **upper specified room/test-condition DCR scenario**, not an exact part resistance at actual temperature. A proper transient-quality inductor substitute needs manufacturer or measured **L(I,T)** / loss data and board thermal characterization. At the Murata DC 4.8 A characterization point the inductance is already **30% below its own initial value**; starting from the 0.8 µH initial tolerance edge would conditionally give 0.56 µH, below TI's 0.7 µH recommendation. This is an illustrative conjunction, **not** a guaranteed corner or a claim that 4.8 A flows in the board. No exact vendor PSpice macromodel for this inductor was qualified.
- The board's 2×AA Camelion supply, TPS2116/OVP losses and switching of a real unbranded SD or photographed OLED carrier still lack source/step waveforms. Do **not** use TI's 2.7 V fixture input as guaranteed `VIN_MUX` under depleted batteries, and do **not** use static peak arithmetic as the startup waveform.
- **Next actionable gate:** obtain DC-bias effective-C model/value for exact TDK `C_OUT` and `C_IN`; independently characterize or source L(I,T) if modeling high current; bound the real converter input and operating loads. Then finish an actual multi-ms TPS631000 PSpice startup and eventually SD/OLED load-step with sourced module/card currents. T25D's 10 µs smoke remains only a model runtime check.
- Canonical Altium schematic, PCB and library are unchanged, hence **no new DRC**. Last accepted physical evidence remains T24 129/129 courtyards and Full Batch DRC 0 warnings / 0 violations.
