# T25BO — Gate P1 battery-path closure screen

Date: 2026-09-28.

Goal: close the weak-pack 1.80V battery-path gate far enough to decide whether the existing fuse / mux / panel-switch architecture needs redesign before the one-shot purchase.

## Locked requirements

- 2xAA pack terminal minimum under load: 1.80V.
- RevA output design envelope: 280mA at 3.3V = 0.924W.
- TPS631000 start-up requires VIN >1.65V; normal recommended input range extends down to 1.6V.
- No staged purchase and no partial CAD ECO.

## Fresh manufacturer evidence

### TPS631000

TI Rev C (Aug 2026) states:
- VIN operating range 1.6..5.5V;
- device VIN >1.65V for start-up;
- switch current limit 2.9A typical;
- Figure 8-2 Typical Output Current Capability vs Input Voltage, VOUT=3.3V, shows approximately 0.8..0.9A output capability around VIN=1.8V;
- PFM efficiency curve at VIN=1.6V and IOUT around 0.28A is roughly around 90% typical by graph.

Therefore the 280mA design envelope is well below the **typical current-capability curve** at the low-input corner. This does not create a guaranteed minimum output-current spec, but it strongly shifts Gate P1 attention from converter current capability to series path drop.

### TPS2116 VIN2 path

TI TPS2116 Rev A gives RON at VINx=1.8V:
- 41mOhm typical / 51mOhm max at 25C;
- 61mOhm max through -40..85C;
- **66mOhm max through -40..105C**.

Use 66mOhm for the conservative battery-path budget.

### F1

Current design F1 is JDT JFC2410-1200FS, 2A fast-acting.
Current JDT datasheet table gives nominal cold resistance **38mOhm** for the 2A version.
This is a nominal cold value, not a guaranteed hot maximum; hardware validation must still measure loaded drop.

### S1 panel switch

Earlier project decision superseded the unsuitable MSS23D19G20-B and favored a direct off-board **DPST maintained panel rocker**, one isolated pole for BAT and one for USB; CC1/CC2 are not to be routed through this power switch.

Iranian market evidence currently shows a 4-pin 2-position 15x21mm rocker as available, and ECA lists KCD1-104 4-pin ON/OFF. Manufacturer-family data for KCD1-104 DPST gives initial contact resistance <=50mOhm (some qualified variants <=30mOhm initial).

Because illuminated 4-pin variants may contain internal lamp wiring, the final purchase item must be a **non-illuminated / electrically isolated DPST** version or its four terminals must be verified as two isolated contact pairs. Do not use an internal-lamp variant that electrically couples the USB and BAT poles.

## Conservative path calculation

At the exact start-up floor 1.65V, input current required for 0.924W output is:

`IIN = 0.924 / (eta * 1.65)`.

Sensitivity:
- eta=0.92 -> IIN=0.609A, total R path must be <246mOhm.
- eta=0.90 -> IIN=0.622A, total R path must be <241mOhm.
- **eta=0.85 -> IIN=0.659A, total R path must be <228mOhm.**
- eta=0.80 -> IIN=0.700A, total R path must be <214mOhm.

Use eta=0.85 as the design-screen value. It is deliberately below the approximate TI typical graph near this operating point, but is not claimed as a guaranteed worst-case converter efficiency.

Known conservative series elements:
- F1 nominal cold: 38mOhm
- S1 qualification ceiling: 50mOhm initial
- TPS2116 VIN2 RON max at -40..105C: 66mOhm

Subtotal = **154mOhm**.

At eta=0.85 the remaining resistance budget is:

`228mOhm - 154mOhm = 74mOhm`

for:
- complete 2xAA holder contacts,
- holder leads,
- board connector/solder joints,
- PCB copper before TPS2116,
- any additional contact resistance.

At eta=0.90 the remaining budget is about 87mOhm.

## Gate P1 decision

The **architecture can be retained** without changing TPS2116 or the 2A fuse, provided final mechanics satisfy all of:

1. S1 is isolated DPST maintained, no internal electrical coupling between USB and BAT poles.
2. S1 initial contact resistance <=50mOhm per used pole.
3. Measured/qualified holder + lead + connector + PCB contribution is <=**60mOhm target**, leaving about 14mOhm engineering reserve under the eta=0.85 screen.
4. Loaded BAT terminal is truly 1.80V at the defined corner; do not use nominal open-circuit cell voltage.
5. Post-build P9 measures BAT terminal, BAT_SW, VIN_MUX and 3V3 during cold start and steady 280mA-equivalent load.

The target of 60mOhm for holder+wiring+copper is a **design target**, not a present measurement.

No evidence supports replacing TPS2116 with TPS2117 merely for Gate P1. The 66mOhm worst-temperature RON still leaves workable series-resistance budget.

## Procurement implication

No new IC/fuse purchase is created by Gate P1.

The one-shot purchase list must eventually contain:
- one exact non-illuminated isolated DPST panel rocker meeting <=50mOhm initial contact resistance and Iran availability;
- one complete wired 2xAA holder whose construction/wiring can meet the <=60mOhm holder+lead+connector+copper target when integrated.

Exact mechanical purchase variants remain to be locked after enclosure fit review; this does **not** reopen the electrical architecture.

Status:
`P1_ARCHITECTURE_PASS_WITH_SERIES_R_REQUIREMENT / TPS2116_KEEP / F1_KEEP / S1_DPST_REQUIRED / HOLDER_PATH_TARGET_LE_60mOHM / CAD_UNCHANGED / NO_PURCHASE_YET`.
