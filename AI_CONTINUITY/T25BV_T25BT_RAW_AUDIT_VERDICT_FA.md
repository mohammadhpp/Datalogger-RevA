# T25BV — independent raw audit of uploaded T25BT official-model run

Date: 2026-09-28 (Asia/Tehran).

## Evidence

- User result: `Datalogger_T25BT_v1_Result_20260928_220315.zip`
- ZIP SHA-256: `e85e8677543759a77e9e55ffb665914c00d83510d97eaf2cc9f0a40371c3b916`
- ZIP members: 14; both cases contain `.cir`, `.out`, `.dat`, console, stderr and `.mif`. `T25BT_v1_Manifest.txt` records TI SLVMDV2 model ZIP SHA-256 `F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946`.
- Both raw `.out` files show `JOB CONCLUDED`, zero counted warnings, zero counted error/fatal markers. Independent parser split `TIME V(VIN) V(VOUT) V(FB)` and `TIME I(V_TEST)` at their headers; each case has 4,001 monotonically timed rows per table, t=0..40us at 10ns.
- Fixture is SS=1, C_OUT IC=3.3V, L1 seeded, ideal fixed VIN, 19mA then TOTAL 280mA at 10us. This is an initialization experiment; it excludes AA/S1 resistance, mux, OVP, SD capacitor/card, OLED and effective-C under bias.

## Raw values

| VIN | 7..9.8us pre-step VOUT min..max | FB min..max | 10..40us VOUT min | 40us VOUT | raw source current observation |
|---|---:|---:|---:|---:|---|
| 1.80V | 1.614..2.268V, falling | 0.2365..0.3401V | 0.6657V | 0.6656V | mean I(V_TEST) +0.218mA in pre-window; source does not establish regulated load |
| 2.80V control | 2.652..2.662V, almost flat but below target | 0.3989..0.4017V | 2.668V | 3.456V | I(V_TEST) changes sign and has 4.533A absolute peak in pre-window; not a credible 19mA steady state |

The sign of I(V_TEST) follows PSpice voltage-source convention. A very large t=0 current artifact caused by the explicit capacitor initial condition is not interpreted as a physical current.

## Parser correction

The generated `T25BT_v1_Summary.txt` is **rejected as a numeric summary**. Its voltage-row regex uses `\s+`, which can cross line breaks; it reported 6,001 alleged voltage rows and nonsensical values such as `PRE_MIN=7E-06V` and `POST_END=4E-05V` because current-table times leaked into voltage columns. Separate raw-table parsing yields 4,001 voltage and 4,001 source-current rows in each case. The summary's `PRESTATE_INVALID` label happens to agree with the raw gate, but its supporting voltage statistics do not.

The follow-up `T25BU_Audit_T25BT_Result_v1.ps1` now constrains numeric row separators to horizontal spaces. Its Windows execution is no longer required for this decision; independent raw ZIP inspection has completed.

## Verdict and scope

`ACTUAL_TEST_WITH_RAW_EVIDENCE / OFFICIAL_MODEL_JOBS_COMPLETED / BOTH_PRESTATES_INVALID / POST_STEP_REJECTED / NO_HARDWARE_FAILURE_INFERRED / NO_BOARD_PASS / FABRICATION_HOLD`.

The 1.80V case is discharging from the artificial 3.3V capacitor seed before the load change; the 2.80V control has a stable-looking but unregulated pre-state. Thus T25BT cannot qualify 19mA→280mA delivery at either VIN. It cannot show that 280mA is excessive or that RevA hardware will fail.

The valid T25BD/T25BE conditional 12-case SD-charge sensitivity and T25BJ/T25BK official TPS22918 controlled-inrush sub-gate remain separate evidence. Next source gate needs a genuinely regulated 3.3V pre-event state with credible input current at 1.80V; avoid another short-window precharge/SS retry without a demonstrated model initialization fix. If the encrypted model cannot establish that state within a bounded runtime, close this simulation gate as blocked by model/runtime and use a clearly bounded, auditable source envelope plus the already recognized physical validation gate later. Do not proceed to partial purchase or CAD ECO.
