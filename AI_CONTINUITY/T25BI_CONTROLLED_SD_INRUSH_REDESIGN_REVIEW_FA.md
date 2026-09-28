# T25BI — Controlled SD inrush redesign review (proposal only)

Date: 2026-09-28. Continuation of T25BG/T25BH after the non-destructive GitHub cleanup audit. **No Altium CAD or purchased-BOM assumption is modified by this stage. Fabrication Hold remains active.**

## Problem carried from T25BH

The live SD rail uses `Q_SD=AO3401A` with `Q_SD_DRV=BC847B`, `R_SD_DRV_BASE=10k` and `R_GATE=100k`. The downstream nominal capacitance is 22+22+10+0.1 = **54.1 uF**. T25BH proved only that slowing the SD connection can remove the rail-collapse mechanism in a transparent sensitivity fixture; it could not map its artificial conductance time constant to the real AO3401A/BC847B gate network.

Therefore adding another guessed RC to the existing discrete gate is rejected as a qualification path. It would preserve the same uncontrolled threshold/Qg/model gap.

## Selected proposal for the next validation gate

**Initial candidate:** TI `TPS22918`, SOT-23-6 DBV, catalog device.

Manufacturer sources:
- Product page: https://www.ti.com/product/TPS22918
- Datasheet Rev C: https://www.ti.com/lit/pdf/slvsd76
- TI official unencrypted transient PSpice package: `SLVMBI6A.ZIP`, exposed on the product page.
- SD host power-up boundary used only as an interface requirement: SD Association Physical Layer Simplified Specification, power-supply ramp section.

Reasons this part is a better validation candidate than the current discrete SD switch:
- VIN range 1 V to 5.5 V, therefore compatible with the existing 3.3 V rail.
- 2 A maximum continuous switch current and 53 mOhm typical RON at VIN=3.3 V.
- Active-high ON input can be driven by the existing active-high `SD_PWR_CTL` logic without an inversion stage.
- CT pin gives a manufacturer-defined output slew relationship instead of inferring PMOS gate behavior from unrelated Qg test conditions.
- QOD provides deterministic discharge support for card power cycling.
- SOT-23-6 is leaded and visually inspectable, consistent with the project's manual-assembly constraint.
- TI provides an **unencrypted PSpice transient model**, so the next fixture can use a traceable vendor model rather than a guessed switch law.
- The part has **no adjustable current limit**. It addresses capacitive inrush through slew control; unknown microSD operating/startup current remains a separate open risk.

## Proposed electrical mapping — not yet an ECO

| TPS22918 pin/function | Proposed RevA connection |
|---|---|
| VIN | `3V3_SYS` |
| GND | GND |
| ON | `SD_PWR_CTL` (active high, must never float) |
| CT | `C_SD_CT = 4.7 nF` to GND |
| QOD | tie directly to VOUT to use internal RPD |
| VOUT | `SD_VDD` |

Additional proposal:
- add dedicated `C_SD_SW_IN = 1 uF`, X5R/X7R ceramic, immediately at VIN/GND as required by the datasheet;
- retain the existing four `SD_VDD` capacitors for the first simulation proposal;
- preferred CT capacitor construction for the first review: **4.7 nF, X7R, +/-10%, >=16 V**, 0603. A current Samsung catalog-compatible candidate is the 4.7 nF X7R 0603 family; exact procurement suffix is to be locked only if the redesign is approved.

The current `AO3401A + BC847B + gate resistors` shall not be deleted or altered in CAD until this proposal and its simulation result are explicitly approved.

## Why 4.7 nF is the initial CT target

TI Rev-C Table 2 gives typical 10%-90% rise time at VIN=3.3 V:

| CT | Typical tR | capacitor-only inrush for 54.1 uF nominal using I=C*dV/dt, dV=0.8*3.3 V |
|---:|---:|---:|
| 1.0 nF | 1.680 ms | 85.014 mA |
| 2.2 nF | 3.580 ms | 39.895 mA |
| **4.7 nF** | **7.980 ms** | **17.898 mA** |
| 10 nF | 17.505 ms | 8.159 mA |

The same TI table is explicitly **typical at 25 C** and was measured with CL=0.1 uF, CIN=1 uF and RL=10 ohm. It is not a guaranteed RevA rise-time tolerance. The 4.7 nF value is selected as an initial validation target because it cuts the nominal capacitor-only demand to roughly 18 mA while preserving large timing margin to the SD Association's 0.1 ms to 35 ms recommended 2.7-3.6 V host power-ramp window. It is not yet a final BOM value.

The TI inrush relation used here is exactly `I_INRUSH = C_L * dVOUT/dt`; no converter current capability is inferred from this arithmetic.

## Relation to the T25BH source-ceiling sensitivities

With the **hypothetical** T25BH source ceilings, 4.7 nF CT leaves the following simple current headroom after background + nominal capacitive inrush:

| background | source ceiling | residual for card/startup and modeling error |
|---:|---:|---:|
| 19 mA | 0.5 A | 463.102 mA |
| 19 mA | 1.0 A | 963.102 mA |
| 19 mA | 1.5 A | 1463.102 mA |
| 280 mA | 0.5 A | **202.102 mA** |
| 280 mA | 1.0 A | 702.102 mA |
| 280 mA | 1.5 A | 1202.102 mA |

These are bookkeeping margins, **not TPS631000 ratings** and not a rail-voltage simulation. The hardest sensitivity corner still has only about 202 mA left for actual card startup and model error. Therefore the card-current gap is still real.

## QOD / power-cycle boundary

At VIN=3.3 V, the TPS22918 datasheet specifies RPD up to 35 ohm over temperature. With the nominal 54.1 uF and VIN held at 3.3 V, the simple RC time from 3.3 V to 0.5 V is about **3.573 ms**. The datasheet also permits internal-QOD use for capacitive loads up to 200 uF, so the nominal SD bank is inside that device-level condition.

This RC result is only for a commanded SD-off event while the TPS22918 input rail remains present. It is not an unexpected total-system-power-loss model. Firmware must keep the SD interface signals low/disconnected while the card is unpowered and must respect the SD power-cycle requirement of VDD below 0.5 V for at least 1 ms before another ramp. A conservative firmware guard interval may be added after model/bench confirmation; it is not locked by this stage.

## Rejected alternatives in this gate

- **Add an RC to the existing AO3401A/BC847B gate:** rejected as the primary qualification route because the real transfer from RC to drain-current slew still depends on unqualified MOSFET threshold/Qg, driver saturation and Ceff.
- **TPS22946:** current-limit values top out at a few hundred milliamps and the package is DSBGA; this is a poor fit for the manual-assembly constraint and unknown real SD burst current.
- **TPS22950-Q1:** has adjustable current limit and a leaded package, but its fixed turn-on/current-limit interaction with an uncharacterized card adds a second acceptance variable. It remains a possible protection alternative, not the first controlled-slew candidate.

## Reproducible screen

Tool committed with this report:

`AI_SCRIPTS/T25/T25BI_TPS22918_Controlled_Inrush_Screen_v1.py`

It reproduces the CT/inrush table, the T25BH bookkeeping margins, and the nominal QOD decay estimate. It is deliberately unable to issue a hardware PASS.

## Next executable gate — T25BJ

Build and run a bounded fixture around TI's **official unencrypted TPS22918 transient PSpice model**:
1. VIN=3.3 V with the existing T25 sensitivity source impedances/ceilings clearly labeled as fixtures, not converter guarantees.
2. Dedicated 1 uF input bypass.
3. CT sweep: 2.2 nF / **4.7 nF** / 10 nF.
4. Existing nominal SD bank 54.1 uF plus a capacitance sensitivity sweep.
5. Card load sensitivity separate from capacitance: 0 / 100 / 200 / 400 mA, with every value labeled as a stimulus rather than measured card behavior.
6. Record `I(VIN)`, `SD_VDD`, source rail, rise time, peak input current and time to 2.7 V.
7. Do not claim integrated RevA PASS from this fixture; the TPS631000 1.80 V source behavior and the actual card transient remain separate gates.

If T25BJ confirms the intended slew without pathological vendor-model behavior, present the exact schematic ECO and footprint/pin mapping to the user **before** modifying any Altium file or purchased BOM assumption.

Status: `CONTROLLED_INRUSH_TOPOLOGY_SELECTED_FOR_SIMULATION / CT_4P7NF_INITIAL / OFFICIAL_PSPICE_MODEL_AVAILABLE / CAD_UNCHANGED / FABRICATION_HOLD`.
