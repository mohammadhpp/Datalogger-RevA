# T25BT — Official TPS631000 SS=1 19mA -> 280mA load-step gate

Date: 2026-09-28.

Purpose: resume the correct continuity after T25BF. T25BF used the official encrypted TPS631000 model but had no regulated pre-event state because the model was still in its millisecond startup sequence.

The official TPS631000 subcircuit exposes `PARAMS: SS=0`. TI support documentation for multiple official converter PSpice models describes this convention as:
- SS=0: normal startup;
- SS=1: faster steady-state operation, provided external inductor/capacitor initial conditions are set correctly.

This is a model-method experiment, not proof that TPS631000 documentation specifically guarantees identical SS initialization behavior. Therefore T25BT has a hard pre-state gate: if 3.3V is not regulated and stable before the 19mA->280mA event, the load-step is rejected.

Cases:
- VIN=1.80V project corner; initial inductor-current seed 43.54mA.
- VIN=2.80V control; initial inductor-current seed 27.99mA.

The current seeds are only initialization aids derived from the initial 19mA output load using eta=0.80. They are not measured or guaranteed currents.

Fixture:
- official TI SLVMDV2 encrypted model, same audited package as T25BF;
- instance SS=1;
- 510k/91k feedback;
- COUT 47uF with IC=3.3V;
- CIN 22uF;
- L=1uH plus 32mOhm series DCR;
- load 19mA initially, stepping to TOTAL 280mA at 10us;
- short post-step observation;
- no TPS2116, AA path, OVP, SD-capacitor event, card or OLED.

The generated summary must parse voltage separately from source current; raw current-table audit remains mandatory to avoid repeating the T25BJ split-PRINT parser error.

Interpretation:
- PRESTATE_VALID: raw official-model load-step may be audited.
- PRESTATE_INVALID: do not interpret post-step behavior.

No result authorizes fabrication.

Status:
`OFFICIAL_MODEL_SS1_LOADSTEP_PREPARED / 19mA_TO_TOTAL_280mA / HARD_PRESTATE_GATE / CAD_UNCHANGED / FABRICATION_HOLD`.
