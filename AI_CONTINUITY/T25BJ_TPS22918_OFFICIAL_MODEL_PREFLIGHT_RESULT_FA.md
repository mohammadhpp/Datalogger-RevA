# T25BJ v1 result — official TPS22918 model package verified

Date: 2026-09-28.

User returned `Datalogger_T25BJ_Model_Preflight_v1_Result_20260928_115306.zip`.

## Provenance

- Outer result ZIP SHA256: `45d5ffcb8a0ab08118d2c0a0f8aac074668392a0f64a5e80904ac897621387a1`.
- Acquisition source recorded by the Windows preflight: `DIRECT_TI_HTTPS=https://www.ti.com/lit/zip/SLVMBI6`.
- Nested TI ZIP size: 52,748 bytes.
- Nested TI ZIP SHA256: `C3CFE13A6AA72AFE2FCA9DEC791A6DD4D9B591B6C136C16FAC910F74E153CF00`.
- Expanded file count: 7.
- Official model file: `SLVMBI6/TPS22918_TRANS.LIB`, 11,485 bytes.
- Model file SHA256: `DE4D6521D9E6AE4C6352D52FE26BFFC16A9B5AD91C3CFAC6E75E9EF5B1545FBA`.

## Exact model interface

The official library declares:

`.SUBCKT TPS22918_TRANS VIN ON CT VOUT QOD GND`

This confirms the T25BI proposed pin mapping.

## Model capability boundary from TI library comments

The model itself states that it includes:
- switching characteristics for VIN 1.05 V to 5.5 V;
- RON variation with VIN;
- adjustable output rise time;
- adjustable quick output discharge;
- quiescent current versus VIN at room temperature;
- shutdown current versus VIN at room temperature.

The same model explicitly states that **temperature effects are not modeled**.

This is an unencrypted transient model and is suitable for a bounded load-switch fixture. It is still a device model, not a complete RevA power-tree model.

## Next executable fixture

Proceed directly to the official-model sweep:
- VIN source fixture 3.3 V through 0.1 ohm;
- local VIN bypass 1 uF;
- CT = 2.2 / 4.7 / 10 nF;
- nominal CSD = 54.1 uF for all CT/load combinations;
- additional 27.05 uF CSD sensitivity at the preferred 4.7 nF CT;
- equivalent resistive card-load stimuli corresponding to 0 / 100 / 200 / 400 mA at 3.3 V;
- ON at 0.1 ms, OFF at 25.1 ms, total run 35 ms;
- record VIN, VOUT, CT, ON and source current;
- compute 10%-90% rise, time to 2.7 V, minimum VIN, peak absolute source current, pre-off VOUT and QOD time below 0.5 V.

The source is deliberately not current-limited in this fixture. Peak demand will be compared afterward to the prior 0.5/1.0/1.5 A T25BH sensitivity ceilings. A stiff-source result cannot prove TPS631000 behavior at 1.80 V.

Status: `OFFICIAL_TPS22918_MODEL_VERIFIED / PIN_ORDER_VERIFIED / T25BJ_SWEEP_READY / CAD_UNCHANGED / FABRICATION_HOLD`.
