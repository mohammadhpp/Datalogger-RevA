# T25BO — Weak-battery path closure architecture

Date: 2026-09-28.

Status: architecture selected for consolidated power ECO; CAD unchanged; no purchase yet.

## Locked corner

- 2xAA pack minimum: 1.80 V **at pack terminals under load**.
- TPS631000 startup requires VIN > 1.65 V.
- RevA design-output envelope: 3.3 V x 0.280 A = 0.924 W.
- Therefore only 150 mV of startup-path drop exists between the locked pack requirement and the converter startup boundary.

## Conservative path arithmetic

At VIN=1.65 V and full design output:
Iin = 0.924 / (1.65 * eta) = 0.56/eta A.
Maximum total series path resistance allowed by 150 mV is:
Rpath,max = 0.150 / Iin = 0.267857*eta ohm.

Using current exact parts:
- F1 JFC2410-1200FS: latest JDT table gives about 38 mOhm cold resistance (nominal table value, not a guaranteed hot maximum).
- TPS2116 VIN2 path: TI maximum RON at VIN=1.8 V is 66 mOhm over -40..105 C at the specified 200 mA test condition.

Sensitivity:

| eta | Iin | total Rpath max | residual after 38m fuse + 66m mux |
|---:|---:|---:|---:|
| 0.70 | 0.800 A | 187.5 mOhm | 83.5 mOhm |
| 0.75 | 0.7467 A | 200.9 mOhm | 96.9 mOhm |
| 0.80 | 0.700 A | 214.3 mOhm | 110.3 mOhm |
| 0.85 | 0.6588 A | 227.7 mOhm | 123.7 mOhm |
| 0.90 | 0.6222 A | 241.1 mOhm | 137.1 mOhm |

This is a startup/path sensitivity, not a measured board drop.

## Existing PCB path

Current PCB has:
- BAT_RAW main trunk approximately 30 mil.
- BAT_FUSED main corridor approximately 30 mil with two parallel layer-change vias.
- BAT_SW main trunk approximately 30 mil, with a short 8 mil neck-down at the TPS2116 pad.
- The off-board S1 contact and its harness are presently in series with the battery power path.

The unknown panel-switch contact plus off-board wire/harness is the largest avoidable unqualified element in the remaining resistance budget.

## Selected P1 architecture for the consolidated ECO

1. **Remove the panel S1 contact from the battery high-current path.**
2. Route F1 output directly to the TPS2116 VIN2 / BAT_SW node.
3. Remove S1 from the USB high-current path as well.
4. Tie the USB-C CC1/CC2 Rd return paths permanently to GND rather than switching them with S1.
5. Separate TPS631000 EN from VIN_MUX; it is currently tied directly to VIN_MUX.
6. Use a simple off-board SPST maintained switch only as a low-current ON/OFF control:
   - OFF: TPS631000 EN is held at GND with 100 kOhm.
   - ON: switch connects TPS631000 EN to VIN_MUX.
7. TPS631000 true shutdown/load-disconnect then becomes the system power switch. TPS2116 remains connected to sources but draws only its microamp-scale quiescent/standby current.
8. No battery charging path is introduced; TPS2116 reverse-current blocking remains part of the source isolation.

## PCB routing target after consolidated approval

- BAT_FUSED -> TPS2116 VIN2: >=50 mil where geometry permits.
- Any fine-pitch neck-down should be only the shortest practical pad escape.
- If a layer change is needed, use two parallel vias as already practiced.
- Exact finished-copper thickness and final route length must be included in post-ECO resistance audit.

Illustrative copper only: around 42 mm of 1 oz copper at 50 mil width is roughly 16 mOhm before vias/pads/neck-down; 0.5 oz approximately doubles it. This is a planning estimate, not a fabrication guarantee.

## TPS631000 / inductor current screen

At VIN=1.65 V, VOUT=3.3 V, IOUT=0.280 A, Lmin=0.8 uH, fmin=1.8 MHz, boost duty about 0.5:
- eta=0.90: estimated peak inductor current ~0.909 A; +20% margin ~1.09 A.
- eta=0.75: ~1.033 A; +20% ~1.24 A.
- eta=0.70: ~1.086 A; +20% ~1.30 A.

The current L1 DFE322512F-1R0M=P2 was previously source-qualified at 1 uH +/-20%, DCR max 32 mOhm, 4.8 A at 30% inductance reduction, so the steady current screen is not the limiting concern. TI lists TPS631000 typical peak switch-current limit about 2.9 A. Startup/source voltage margin remains the real open gate.

## P1 verdict

`P1_ARCHITECTURE_SELECTED / REMOVE_S1_FROM_POWER_PATH / DIRECT_FUSE_TO_PMUX_VIN2 / SWITCH_TPS631000_EN_ONLY / CAD_UNCHANGED / ONE_SHOT_PURCHASE_RULE`.

P1 physical PASS still requires post-ECO layout resistance review and eventually hardware verification; no fabrication release is implied.
