# T25BS — Continuity correction: 19mA / 280mA analysis and simulator chain

Date: 2026-09-28.

This record corrects continuity drift that incorrectly advanced into T25BO/T25BP/T25BR/T25BQ architecture changes before re-establishing the already-executed 19mA/280mA simulation chain.

## Meaning of the two currents

- **19mA** = older prototype observation with unknown measurement bandwidth. It is NOT the RevA background current and NOT a guaranteed peak.
- **280mA** = purchased workbook RevA maximum design-load envelope at 3.3V. It is NOT a measured RevA peak.

Never add them together as independent simultaneous measured loads.

## Stage 1 — transparent numerical analysis: T25AZ

The deterministic transparent solver explicitly compared both 19mA and 280mA backgrounds, source-ceiling sensitivities 0.5/1.0/1.5A and SD-switch conductance ramps 0/100us.

This was a conditional source/inrush study, not a TPS631000 model.

## Stage 2 — actual PSpice cross-check: T25BD/T25BE

User executed `Datalogger_T25BD_v1_Result_20260928_100019.zip`.

Independent audit:
- SHA256 `9258c18c9c0ab4b9edc9809e4a69f68eb9e16f53a1062dfa59fc1436d284c628`
- 12/12 PSpice jobs valid;
- 0 invalid pre-states;
- no pseudo-transient corruption;
- 12,501 waveform rows per case;
- agreement with the independent T25AZ solver within 2.321mV on rail minimum and 0.55us on SD-to-2.7V timing.

Corrected PSpice rail minima:

| background | source ceiling | tau | min 3V3_SYS |
|---:|---:|---:|---:|
| 19mA | 0.5A | 0us | 1.580V |
| 19mA | 0.5A | 100us | 1.741V |
| 19mA | 1.0A | 0us | 1.620V |
| 19mA | 1.0A | 100us | 1.922V |
| 19mA | 1.5A | 0us | 1.656V |
| 19mA | 1.5A | 100us | 2.087V |
| 280mA | 0.5A | 0us | 1.545V |
| 280mA | 0.5A | 100us | 1.623V |
| 280mA | 1.0A | 0us | 1.587V |
| 280mA | 1.0A | 100us | 1.818V |
| 280mA | 1.5A | 0us | 1.625V |
| 280mA | 1.5A | 100us | 1.990V |

Interpretation: reducing the assumed background from 280mA to 19mA does **not** by itself eliminate the uncontrolled SD-capacitor inrush problem. In 11/12 conditional cases the rail falls below the 2.04V PDR screening level; only the 19mA / 1.5A / 100us case reaches 2.087V.

## Stage 3 — official TPS631000 model: T25BF/T25BG

T25BF then did exactly the requested official-model load change:
- load = 19mA initially;
- load steps to **TOTAL 280mA** at 10us;
- official encrypted TI TPS631000 model;
- VIN=1.80V project corner plus VIN=2.80V control.

Both simulations completed, but their pre-event states were invalid:
- VIN=1.80V pre-event VOUT only 1.485..1.950V;
- VIN=2.80V control pre-event VOUT only 2.632..2.635V.

TI's internal model requires millisecond-scale startup (enable delay plus ~7.55ms soft-start). Precharging COUT to 3.3V did not initialize the encrypted internal controller state. Therefore the post-10us step is **not valid regulated 19mA->280mA load-step evidence**.

T25BF must not be rerun in the same short/precharge form.

## Stage 4 — what was correctly learned afterward

T25BH computed how much SD turn-on slew is required under both 19mA and 280mA assumptions. T25BI/BJ/BK then qualified TPS22918 + 4.7nF CT with TI's official vendor model as a controlled-inrush solution for the SD branch.

This later SD work remains valid. It does not close the TPS631000 1.80V source/startup gate.

## Steady-load sanity screen

At 3.3V:
- 19mA = 62.7mW output.
- 280mA = 924mW output.

At VIN=1.80V, required idealized input current for 280mA is approximately:
- 0.733A at eta=70%;
- 0.684A at eta=75%;
- 0.642A at eta=80%;
- 0.604A at eta=85%;
- 0.570A at eta=90%.

For 19mA it is only about 39..50mA over the same efficiency range.

TI specifies a 2.6A minimum / ~3A typical switch peak-current limit under its stated test conditions, and the selected 1uH Murata inductor has much larger published current capability than the ~1A class screening currents previously calculated. Thus **280mA is not obviously excessive as a steady-state converter load**. The real unresolved risk is the 1.80V startup/path margin and simultaneous transient demand, not the arithmetic steady 280mA value.

This is a screen, not a guaranteed output-current specification at VIN=1.80V.

## Continuity correction

The later T25BO/T25BP/T25BR/T25BQ architecture branch is **inactive exploratory work**. Do not execute its CAD/BOM/procurement actions unless it is re-derived after the current source/load gate is closed.

Authoritative next point:
1. retain T25BE as the valid 19mA/280mA PSpice conditional comparison;
2. retain T25BG verdict that the short-window official TPS631000 load-step is invalid;
3. do not rerun T25BF;
4. next close the TPS631000 1.80V startup/source gate with a startup-valid method before selecting any new whole-power architecture;
5. preserve the already-qualified TPS22918 SD result as a completed sub-gate;
6. keep one-shot procurement and Iran-availability rules.

Status:
`CONTINUITY_RESTORED / 19mA_280mA_ANALYSIS_COMPLETE / CONDITIONAL_PSPICE_COMPLETE / OFFICIAL_SHORT_LOADSTEP_INVALID / TPS631000_1P8V_STARTUP_GATE_ACTIVE / PREMATURE_POWER_REDESIGN_INACTIVE / FABRICATION_HOLD`.
