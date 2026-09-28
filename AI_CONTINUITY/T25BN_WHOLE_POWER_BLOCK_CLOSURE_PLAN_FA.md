# T25BN — Whole power-block closure plan before one-shot procurement

Date: 2026-09-28.

User decision: **do not buy new parts and do not apply partial CAD ECO until the entire RevA power block is closed.** The purchase order must be issued once, from one consolidated list.

## Locked execution rule

A new/replacement part enters the final purchase list only after both:
1. **TECHNICAL PASS**
2. **IRAN AVAILABILITY PASS**

No partial T25BL purchase. No partial power ECO.

## Power closure sequence

### Gate P1 — battery path / weak-pack corner

Requirement:
- 2xAA pack minimum: **1.80 V at pack terminals under load**.
- TPS631000 startup/input boundary must remain valid after fuse, S1, holder/contact and PCB-path drops.

Known concern:
- TPS631000 startup is specified above about 1.65 V.
- Therefore only about 150 mV remains between the locked 1.80 V pack terminal requirement and the converter startup boundary before path losses.
- At the 280 mA design-output envelope, source current can be materially higher than 280 mA because of step-up conversion.
- Existing T25W arithmetic shows even an ideal-efficiency full-load boundary requires total path resistance below about 0.268 ohm; real efficiency tightens this.

Closure output:
- determine whether existing F1/S1/path architecture can be retained;
- if S1 or another path element must change, identify exact Iran-available MPN before purchase freeze.

### Gate P2 — USB input protection / OVP

Locked requirements:
- no nuisance cutoff through **5.50 V** normal USB;
- TPS2116 recommended VIN max is **5.50 V** and absolute max is 6.0 V.

Known concern:
- historical discrete OVP trip envelope is about **5.600692..5.915721 V**.
- highest trip leaves only **84.279 mV** static margin to 6.0 V absolute max and is above the TPS2116 recommended range.
- dynamic cutoff time/source impedance/Ceff are not qualified.

Closure output:
- either prove a revised safe OVP architecture or replace the current discrete OVP with a design that can satisfy the locked 5.50 V no-nuisance requirement while protecting TPS2116;
- every new OVP part must pass Iran procurement.

### Gate P3 — USB <-> battery handoff

Locked requirement:
- continuous battery->USB->battery operation with **no MCU reset**.

Known concern:
- current TPS2116 vendor model shows behavior inconsistent with TI physical/EVM evidence for some unplug stimuli and is not trusted for final PASS/FAIL.
- existing PR1 divider has a static transfer boundary around 3.64..4.37 V.
- weak battery and hard USB unplug remain a real physical-risk case.

Closure output:
- retain or revise TPS2116 configuration only after bounded source/hold-up analysis;
- decide final population for `R_ST_PU` and any hold-up/capacitance changes;
- new parts must be Iran-qualified.

### Gate P4 — TPS631000 3V3 source margin

Locked requirements:
- 3V3 rail must support the RevA design envelope without violating MCU rail floor/reset constraints.
- 280 mA is the design envelope, **not a measured RevA current**.
- 19 mA is old-prototype evidence only.

Known concern:
- encrypted official model cannot reach a valid regulated pre-state in feasible short-window runs.
- full multi-ms startup execution is impractical with that model.
- real source margin at VIN=1.80 V remains unqualified.

Closure output:
- use transparent/bounded source arithmetic and all available datasheet limits to establish whether the existing TPS631000/L/C network is acceptable or requires changes;
- do not interpret the marketing 1.5 A output figure as guaranteed at VIN=1.80 V.

### Gate P5 — switched branches

#### microSD
Current candidate:
- TPS22918DBVT
- CT: TDK C1608NP01H472J080AA, 4.7 nF NP0 50 V 0603
- VIN bypass: TDK C2012X7R1H105K125AB, 1 uF X7R 50 V 0805
- existing 100 k resistor reused as ON pulldown

Status:
- technical device-model PASS;
- Iran availability PASS;
- hold from purchase/ECO until P1..P4 close.

#### OLED / sensor
- verify whether their switched-capacitance/startup behavior creates any additional required power ECO;
- do not invent current transients for the unknown four-pin OLED carrier.

## Final deliverable before user buys anything

One consolidated table:
- reference/function;
- current part;
- keep / remove / replace / add;
- exact final MPN;
- quantity;
- package;
- technical reason;
- simulation/calculation evidence;
- Iranian seller/source;
- local availability status;
- purchase-time stock check;
- whether already owned or newly required.

Then issue **one consolidated power ECO** for explicit user approval.

## Current decision

`WHOLE_POWER_BLOCK_CLOSURE_ACTIVE / ONE_SHOT_PURCHASE_ONLY / NO_PARTIAL_ECO / FABRICATION_HOLD`.

No T25BF rerun.
