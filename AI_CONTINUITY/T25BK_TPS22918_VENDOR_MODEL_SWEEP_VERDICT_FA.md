# T25BK — Independent raw audit of T25BJ TPS22918 sweep

Date: 2026-09-28.

Input: user result `Datalogger_T25BJ_Sweep_v2_Result_20260928_120158.zip`.

## Integrity and parser finding

- Result ZIP SHA256: `0addb80d7255dad9101b128f1d1cc36fdab867afb25349d6f6b4b61c9cc9ea76`.
- 16/16 PSpice cases contain `JOB CONCLUDED`.
- 16/16 have zero counted PSpice warnings and zero counted errors/fatals.
- Every raw voltage table contains 7,001 rows and every raw `I(V_SRC)` table contains 7,001 rows.

**Important correction:** `T25BJ_v2_Summary.csv` is not valid for VIN/current/pre-off interpretation. PSpice emitted the six voltage traces and `I(V_SRC)` as two separate PRINT tables. The v2 PowerShell regex accidentally consumed the next timestamp as a seventh field, producing physically impossible summary entries such as `VIN_min=0.000105V` and `I_source_peak=0.0251A`.

The PSpice simulations themselves are valid. This report ignores the bad CSV metrics and independently parses the raw `.out` tables with:
`AI_SCRIPTS/T25/T25BK_Audit_T25BJ_Raw_v1.py`.

## Corrected raw metrics — nominal CSD = 54.1uF

| CT | Load stimulus at 3.3V | 10-90% rise | time to 2.7V | VIN minimum | source peak | VOUT before OFF | QOD to 0.5V |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 2.2nF | 0mA | 3.340ms | 4.205ms | 3.296V | 42.79mA | 3.300V | 2.72ms |
| 2.2nF | 100mA | 3.445ms | 4.315ms | 3.287V | 134.8mA | 3.285V | 1.51ms |
| 2.2nF | 200mA | 3.515ms | 4.395ms | 3.278V | 223.1mA | 3.270V | 1.04ms |
| 2.2nF | 400mA | 3.625ms | 4.510ms | 3.261V | 392.8mA | 3.240V | 0.64ms |
| **4.7nF** | 0mA | **7.060ms** | **8.745ms** | **3.298V** | **20.24mA** | **3.300V** | **2.72ms** |
| **4.7nF** | 100mA | **7.320ms** | **9.025ms** | **3.289V** | **113.4mA** | **3.284V** | **1.51ms** |
| **4.7nF** | 200mA | **7.470ms** | **9.200ms** | **3.280V** | **202.5mA** | **3.268V** | **1.04ms** |
| **4.7nF** | 400mA | **7.690ms** | **9.455ms** | **3.261V** | **392.5mA** | **3.238V** | **0.64ms** |
| 10nF | 0mA | 14.950ms | 18.330ms | 3.299V | 9.566mA | 3.300V | 2.72ms |
| 10nF | 100mA | 15.550ms | 19.010ms | 3.290V | 103.3mA | 3.257V | 1.50ms |
| 10nF | 200mA | 15.845ms | 19.390ms | 3.280V | 196.2mA | 3.217V | 1.03ms |
| 10nF | 400mA | 16.295ms | 19.940ms | 3.262V | 384.2mA | 3.147V | 0.64ms |

The 10nF/400mA fixture is still settling at the chosen 25.1ms OFF event, hence its lower pre-off VOUT. That makes 10nF less attractive than 4.7nF for this design even though its pure capacitive inrush is lower.

## Corrected raw metrics — CSD sensitivity 27.05uF, CT=4.7nF

| Load stimulus | 10-90% rise | time to 2.7V | VIN minimum | source peak | VOUT before OFF | QOD to 0.5V |
|---:|---:|---:|---:|---:|---:|---:|
| 0mA | 7.060ms | 8.680ms | 3.299V | 10.13mA | 3.300V | 1.36ms |
| 100mA | 7.345ms | 9.000ms | 3.290V | 103.9mA | 3.284V | 0.76ms |
| 200mA | 7.490ms | 9.180ms | 3.280V | 198.1mA | 3.268V | 0.53ms |
| 400mA | 7.700ms | 9.445ms | 3.261V | 392.5mA | 3.238V | 0.33ms |

The near-identical 400mA peak for 27.05uF and 54.1uF shows that, with 4.7nF CT in this fixture, the steady card-load stimulus dominates the source peak rather than capacitor charging.

## Relationship to T25BH source-ceiling sensitivities

Do **not** silently add the historical 280mA design envelope to a 400mA card stimulus as if both were independent measured loads. The 280mA workbook value is the total design-load envelope, while the historical 400mA value was a PMOS-drop sizing point rather than a measured microSD current.

For sensitivity only:
- CT=4.7nF, CSD=54.1uF, 400mA card-load fixture draws 392.5mA peak from this isolated 3.3V source.
- Adding the old 19mA prototype background gives a hypothetical total of about 411.5mA, below the T25BH 0.5A sensitivity ceiling.
- Adding a full independent 280mA background would give about 672.5mA, above 0.5A but below 1.0A. This is a deliberate stress combination, not a documented RevA operating load.

Therefore T25BJ does **not** establish the required TPS631000 source capability at VIN=1.80V. It does show that the selected load switch no longer causes a large uncontrolled capacitive current step.

## Device-level verdict

For the bounded 27C official TI model fixture:
- TPS22918 with **CT=4.7nF** gives a controlled ~7.1-7.7ms 10-90% ramp.
- With nominal 54.1uF local capacitance, no-load peak input demand is only 20.24mA.
- The 400mA load fixture reaches 2.7V in 9.455ms and settles near 3.238V before OFF with the explicit 0.1ohm source resistance.
- QOD reaches 0.5V within 2.72ms in the slowest no-load case.
- CT=2.2nF also works in this fixture but doubles the no-load capacitive peak versus 4.7nF.
- CT=10nF is unnecessarily slow for the chosen 25ms powered window under heavy load.

TI's model itself does not include temperature effects. The result is therefore a **device-model design gate**, not full environmental qualification.

Status:
`TPS22918_CT_4P7NF_VENDOR_MODEL_GATE_PASS / T25BJ_SUMMARY_PARSER_REJECTED / RAW_OUT_AUDIT_PASS / TPS631000_SOURCE_GATE_STILL_OPEN / NO_BOARD_PASS / FABRICATION_HOLD`.
