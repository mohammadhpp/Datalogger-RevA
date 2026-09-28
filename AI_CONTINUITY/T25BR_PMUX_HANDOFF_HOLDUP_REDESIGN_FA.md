> **CONTINUITY CORRECTION — 2026-09-28:** This document is an exploratory proposal only and is **NOT an active/selected RevA architecture**. It was produced after continuity drift before the 19mA/280mA TPS631000 simulation path was properly re-established. Do not execute its CAD/BOM/procurement actions. The authoritative point is CURRENT_HANDOFF.md.

# T25BR — TPS2116 handoff / VIN_MUX hold-up redesign screen

Date: 2026-09-28.

Status: bounded architecture screen complete; final P3 PASS waits on TPS54202 vendor-model collapse waveform and post-ECO validation. CAD unchanged.

## Inputs

Locked:
- battery corner = 1.80 V at pack terminals under load;
- design output envelope = 3.3 V / 280 mA;
- zero-reset USB<->battery requirement.

Selected P2 starting architecture:
- regulated USB VIN1 target ~3.576 V from TPS54202;
- TPS2116 PR divider candidate 20 kOhm / 10 kOhm;
- static PR selection boundary about 2.733..3.273 V.

TI TPS2116:
- switchover at 1.8 V is 17.7 us typical under TI's 10-ohm / 10-uF fixture;
- this is not a guaranteed maximum;
- RCB falling threshold is 17 mV typical / 40 mV maximum;
- when RCB is expected, TI recommends clamping the output or using high output capacitance about 100 uF;
- if the powering input collapses faster than 1 V / 10 us and the other source is below 2.5 V, the mux may reset.

## Why the front buck helps the weak-battery handoff

A threshold-only OVP exposes TPS2116 VIN1 to the source/cable collapse. The proposed TPS54202 instead leaves local output capacitance on VIN1. With the initial 44-uF nominal output bank, a constant-power sensitivity at 0.924 W output and eta=0.75 gives input power ~1.232 W.

Near VIN1=3.0 V:
- with 44 uF effective, |dV/dt| ~9.33 V/ms = 0.00933 V/us;
- even with only 10 uF effective, |dV/dt| ~41.1 V/ms = 0.0411 V/us.

TI's collapse warning boundary is 1 V/10 us = 0.1 V/us. Therefore a few microfarads of actual effective output capacitance can, under this bounded constant-power discharge model, materially slow the VIN1 collapse. The official TPS54202 model must verify that the synchronous buck does not actively pull the output down in a way that invalidates this simple energy model.

## Required VIN_MUX hold-up capacitance

At the lowest calculated PR command boundary ~2.7325 V, assume:
- downstream load consumes Pout/eta with eta=0.75;
- battery path is not yet conducting;
- hold-up ends near 1.80 V.

Required effective VIN_MUX capacitance from energy balance:

| Hold-up target | Required effective C |
|---:|---:|
| 17.7 us | 10.32 uF |
| 25 us | 14.57 uF |
| 35 us | 20.40 uF |
| 50 us | 29.15 uF |
| 100 us | 58.30 uF |
| 200 us | 116.60 uF |

Using 1.84 V instead of 1.80 V for a conservative RCB-falling endpoint changes the 100-us figure to about 60.38 uF.

Because 17.7 us is only a TI typical number and the RevA load/source differs from the fixture, designing only to ~10 uF is not adequate margin.

## Preferred hold-up population for consolidated ECO

Use a nominal **~110 uF VIN_MUX ceramic bank**:
- five x existing exact TDK `C2012X5R1V226M125AC` 22 uF / 35 V / X5R / 0805 in parallel on VIN_MUX;
- one of the five is the present C_IN position; four additional footprints are added close to TPS2116 VOUT / TPS631000 VIN.

Rationale:
- nominal 110 uF aligns with TI's about-100-uF recommendation where RCB can occur;
- if the assembled bank retained 55% effective capacitance under the relevant bias/tolerance/temperature combination, it would still be ~60.5 uF, approximately the bounded 100-us requirement above;
- the part is already used in the project and the historic purchase workbook records 10 units purchased for the power block, reducing unique procurement.

**55% retention is a design-screen threshold, not a guaranteed TDK minimum.** The TDK product page publishes DC-bias characterization/model tools but does not convert the graph into a project-guaranteed Cmin. Post-ECO hardware validation is still required.

## R_ST_PU decision

Populate the existing `R_ST_PU` 10 kOhm footprint to 3V3_SYS.

TI states ST is open-drain and should be pulled up to an external voltage for proper operation. This uses the existing board part/footprint and creates a reliable status signal for firmware/test logging during source transitions.

## Handoff behavior expected from the redesigned architecture

USB insertion:
1. TPS54202 soft-starts its ~3.576 V output over about 5 ms.
2. VIN1 crosses the 20k/10k PR threshold only after it is well above the 1.8-V weak battery.
3. TPS2116 changes from VIN2 to VIN1; VIN_MUX hold-up bank reduces the break-before-make dip.
4. TPS631000 remains enabled and regulated.

USB removal:
1. TPS54202 input disappears.
2. Local buck output capacitance slows VIN1 fall.
3. PR1 crosses ~2.7..3.27 V and requests VIN2.
4. VIN_MUX bank carries the converter while TPS2116 waits through break-before-make / any RCB condition.
5. VIN_MUX reaches the battery rail and TPS2116 VIN2 conducts.
6. TPS631000 remains above its operating/startup boundary if P1 path resistance target is met.

This sequence is an engineering target, not yet a waveform PASS.

## P3 interim verdict

`P3_ARCHITECTURE_SELECTED / PR1_20K_10K / VIN_MUX_NOMINAL_110UF_TARGET / R_ST_PU_POP / TPS54202_COLLAPSE_MODEL_PENDING / CAD_UNCHANGED`.

The final consolidated ECO must not be applied until T25BQ/T25BS vendor-model evidence closes the front buck behavior.
