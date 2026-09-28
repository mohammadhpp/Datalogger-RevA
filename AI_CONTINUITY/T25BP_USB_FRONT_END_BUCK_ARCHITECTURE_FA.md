# T25BP — Preferred USB front-end architecture replacing threshold-only OVP

Date: 2026-09-28.

Status: preferred architecture selected for official-model qualification; CAD unchanged; no purchase yet.

## Why the current discrete OVP cannot close the requirement cleanly

Locked project requirements:
- normal USB must not nuisance-cut through 5.50 V;
- TPS2116 recommended VIN maximum is 5.50 V.

Historical discrete OVP trip analysis spans about 5.600692..5.915721 V. A tolerance-based pass switch cannot simultaneously guarantee no trip at exactly 5.50 V and guarantee the downstream TPS2116 VIN never exceeds 5.50 V for every slowly rising source. The upper historical trip also leaves only about 84.279 mV static margin to the 6.0 V absolute maximum, before transient delay.

Therefore retuning only the existing TS431/PNP/PMOS threshold network is not the preferred solution.

## Preferred architecture

Replace the discrete threshold-only OVP power path with a wide-input synchronous buck preregulator:

`USB_VBUS_RAW -> TPS54202 buck -> USB_VBUS_PROT -> TPS2116 VIN1`.

Target preregulator output: approximately **3.576 V nominal**.

Advantages:
- TPS54202 input range 4.5..28 V covers standard 5/5.5 V USB and the project's historical accidental 12 V fault scenario.
- TPS2116 VIN1 is then regulated far below its 5.5 V recommended maximum.
- The regulator output capacitance supplies controlled energy during USB removal rather than presenting an uncontrolled cable step directly to TPS2116.
- The complex FSS2301S + BC857 + TS431 + zener OVP threshold network can potentially be removed after model qualification.
- TPS54202 has an official unencrypted TI PSpice transient model package, SLVMBJ5C.

TI current Rev-C data:
- 4.5..28 V input;
- 2 A continuous output;
- fixed 500 kHz;
- internal 5 ms soft start;
- VFB = 0.596 V typical, 0.581..0.611 V electrical range;
- SOT-23-THIN DDC-6;
- active production status.

## Initial output set point

Use:
- RFB_TOP = 100 kOhm;
- RFB_BOTTOM = 20 kOhm.

Nominal:
`VOUT = 0.596*(1+100/20) = 3.576 V`.

Using VFB=0.581..0.611 V and +/-1% feedback resistors gives an approximate static corner of about **3.43..3.73 V**. Exact model/corner validation remains required.

This target is deliberately above 3.3 V to give TPS2116 priority-threshold and hold-up margin while remaining well below 5.5 V.

## TPS2116 PR1 update

The current 30k/10k divider (typical threshold 4.0 V) cannot select a ~3.576 V VIN1 rail.

Proposed starting point:
- PR top = 20 kOhm +/-1%;
- PR bottom = existing 10 kOhm +/-0.5%.

With TPS2116 VREF=0.92..1.08 V, first-order VIN1 selection boundary is approximately **2.733..3.273 V**, typical 3.0 V.

The estimated minimum preregulator output corner (~3.43 V) remains above the estimated maximum PR1 boundary (~3.273 V). Dynamic margin will be checked with the official model.

## Starting passive network for simulation

TI Table 7-2 gives the following starting values for a 3.3 V output design:
- L = 10 uH;
- COUT = 44 uF;
- Rtop = 100 kOhm;
- Rbottom = 22.1 kOhm;
- feed-forward C = 56 pF.
TI also requires 0.1 uF BOOT-to-SW ceramic and input bypassing.

For the 3.576 V RevA target, the first model fixture will use:
- L = 10 uH;
- input C = existing exact TDK C2012X5R1V226M125AC, 22 uF nominal;
- output C = two of the same 22 uF capacitors in parallel, 44 uF nominal;
- Rtop = 100 kOhm;
- Rbottom = 20 kOhm;
- Cff = 56 pF starting point;
- Cboot = 0.1 uF.

These are **model starting values**, not final BOM until stability/transient and Iran procurement checks close.

## Procurement status

TPS54202DDCR:
- TI status ACTIVE / production.
- Iran-local evidence currently exists from SkyTech Iran indexed stock lists and historical/current Lion Electronic availability posts.
- Exact purchase-page stock quantity must be rechecked at order time.

Current status:
`TPS54202DDCR = IRAN_AVAILABILITY_PASS / TECHNICAL_MODEL_GATE_PENDING`.

A generic Iranian 10 uH SMD power inductor is easy to find, but the project requires an exact traceable MPN. Do not freeze a generic CDRH104R part without DCR/saturation/manufacturer data. Exact 10 uH MPN selection remains open.

## Next executable gate

Use TI official package `SLVMBJ5C` and verify:
- package hash/inventory;
- exact .SUBCKT and pin order;
- 5.0 V and 5.5 V startup into the RevA target network;
- 12 V input fault scenario while regulating;
- 0 / 0.3 / 0.5 A load fixtures;
- hard removal of USB and output-collapse slope through the TPS2116 PR1 boundary;
- overshoot, source current and output regulation.

Only after raw vendor-model audit can the preregulator receive TECHNICAL PASS.

Status:
`P2_WIDE_INPUT_BUCK_ARCHITECTURE_SELECTED / TPS54202DDCR_PREFERRED / OFFICIAL_MODEL_GATE_PENDING / CAD_UNCHANGED / ONE_SHOT_PURCHASE_RULE`.
