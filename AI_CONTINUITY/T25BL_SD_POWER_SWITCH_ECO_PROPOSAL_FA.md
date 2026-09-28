# T25BL — Exact proposed Altium ECO for SD controlled-inrush switch

Date: 2026-09-28. **Proposal only. Do not modify CAD until user approval.**

Authoritative live schematic check:
`03_MICROSD.SchDoc` Git blob remains `0793ee4aeae92fc5737796ce4631dac9770619f3`.

T25BK has passed the bounded vendor-model gate for TPS22918 with CT=4.7nF. This ECO replaces the uncontrolled discrete PMOS/NPN SD power switch only; existing SD signal architecture and downstream capacitors remain unchanged.

## Remove from active SD power-switch circuit

- `Q_SD` — AO3401A
- `Q_SD_DRV` — BC847B
- `R_SD_DRV_BASE` — 10k, MPN `CR0603F5101TS`
- `R_GATE` — existing 100k PMOS gate pull-up, MPN `0603WAF1003T5E`

The purchased parts are not erased from historical BOM evidence; they simply become unused by the proposed RevA ECO.

## Add / replace

### U_SD_SW — TPS22918

Proposed orderable MPN: **TPS22918DBVT**.
`TPS22918DBVR` is electrically the same DBV-6 device with larger reel quantity and is an acceptable sourcing equivalent.

Package: TI DBV, SOT-23-6, 0.95mm pitch.

**Physical pad mapping must be exactly:**

| Pad | TPS22918 pin | RevA net |
|---:|---|---|
| 1 | VIN | `3V3_SYS` |
| 2 | GND | GND |
| 3 | ON | `SD_PWR_CTL` |
| 4 | CT | `SD_CT` |
| 5 | QOD | `SD_VDD` |
| 6 | VOUT | `SD_VDD` |

Pin 5 QOD is intentionally tied directly to pin 6/VOUT to enable the internal discharge resistor.

### C_SD_CT — 4.7nF

- Value: **4.7nF**
- Dielectric: X7R
- Tolerance: +/-10%
- Voltage rating: >=16V
- Footprint: 0603 metric 1608
- Proposed exact MPN: **Samsung CL10B472KB8NNNC**, 4.7nF +/-10%, 50V, X7R, 0603.
- Connection: `SD_CT` to GND.
- Place immediately adjacent to U_SD_SW pin 4 and pin 2 return.

### C_SD_SW_IN — 1uF

- Value: **1uF**
- X5R or X7R
- +/-10%
- >=10V
- Footprint: 0603 metric 1608
- Proposed exact MPN: **Samsung CL10A105KP8NNNC**, 1uF +/-10%, 10V, X5R, 0603.
- Connection: `3V3_SYS` to GND.
- Place immediately at U_SD_SW VIN/GND pins.

### R_SD_ON_PD — 100k

- Value: **100k**
- Existing project resistor MPN: `0603WAF1003T5E`.
- Connection: `SD_PWR_CTL` to GND.
- Purpose: guarantee TPS22918 ON low while the MCU GPIO is high impedance/reset. TI requires ON not to float.
- This replaces the quantity of the removed 100k `R_GATE`; no net increase in the project's 100k resistor count is required.

## Nets after ECO

- `3V3_SYS` -> U_SD_SW.1 VIN and C_SD_SW_IN.
- `SD_PWR_CTL` -> U_SD_SW.3 ON and R_SD_ON_PD.
- `SD_CT` exists only between U_SD_SW.4 and C_SD_CT.
- U_SD_SW.5 QOD and U_SD_SW.6 VOUT -> existing `SD_VDD`.
- Existing `C_SD_BULK1`, `C_SD_BULK2`, `C_SD_MID`, `C_SD_HF`, J_SD and all SD signal circuitry remain on `SD_VDD` exactly as before.
- Old net `SD_GATE` is deleted if it has no remaining consumers after Q_SD/Q_SD_DRV removal.

## PCB / footprint rules

- Create or verify a DBV/SOT-23-6 footprint against the TI mechanical drawing; do not reuse an unverified generic SOT-23-6.
- Pin-1 marking must be visible on Top Overlay.
- Keep VIN bypass loop U_SD_SW.1 -> C_SD_SW_IN -> GND as short as practical.
- Keep CT routing away from SD_CLK and other fast digital tracks.
- QOD-to-VOUT connection should be local and short.
- Preserve manual soldering/rework clearance.
- Reuse the area freed by Q_SD + Q_SD_DRV + R_SD_DRV_BASE + R_GATE before moving unrelated blocks.

## Firmware/interface requirement

- `SD_PWR_CTL=HIGH` means SD power ON.
- `SD_PWR_CTL=LOW` means SD power OFF.
- SD bus outputs must not actively drive an unpowered card.
- Based on the vendor-model no-load QOD case, VOUT reaches 0.5V in about 2.72ms at 27C. Use a conservative **minimum 5ms OFF guard** before re-enabling SD power until hardware validation provides a final firmware number.

## Validation after CAD approval

1. Apply schematic ECO only.
2. Compile/ERC and verify no `SD_GATE` orphan net.
3. Verify exact DBV pad mapping against TI: 1 VIN, 2 GND, 3 ON, 4 CT, 5 QOD, 6 VOUT.
4. ECO to PCB; place in the existing SD power-switch area.
5. Route/repour.
6. Full Batch DRC; target remains 0 warnings / 0 violations.
7. Run footprint/courtyard audit and verify RefDes/Pin-1 visibility.
8. Export fresh snapshot and Git checkpoint.
9. Continue T25 power validation; **do not release fabrication** solely because this ECO passes DRC.

## Decision boundary

T25BL is now ready for user approval. Applying it changes the final purchased-BOM assumptions by introducing one TPS22918 and two capacitor values not in the existing purchased set, while keeping the 100k resistor quantity neutral.

Status:
`EXACT_SD_SWITCH_ECO_PROPOSED / AWAITING_USER_APPROVAL / CAD_UNCHANGED / FABRICATION_HOLD`.


## Procurement status update — 2026-09-28

User locked a new constraint: every newly proposed RevA component must be practically available in Iran before it can enter an executable ECO/BOM change.

Current web procurement check:
- `TPS22918DBVT/DBVR`: **Iran-local stock not verified** in the searched Iranian sellers/indexes. Therefore the TPS22918 implementation in this document is now a **technical reference only**, not an executable procurement-approved ECO.
- `C_SD_SW_IN=1uF 0603 X5R`: an Iranian seller (Digikapart) lists `06035C105KAT2A`, 1uF, 0603, X5R, +/-10%, 50V as **موجود**.
- Exact 4.7nF 0603 X7R Iranian stock was not verified in the current search; an Iranian listing for 4.7nF SMD 0805 exists, but changing package/spec requires review.
- `SY6280` appears in recent Iranian SkyTech stock/replenishment lists and is therefore an Iran-available candidate for a new technical evaluation. It is **not** pin/function equivalent to TPS22918: it uses programmable current limit, SOT23-5, automatic output discharge, and has no adjustable CT slew pin in the available preliminary datasheet.

Accordingly:
`T25BL_TPS22918_ECO = PROCUREMENT_BLOCKED / TECHNICAL_REFERENCE_ONLY`.

Do not apply this ECO to CAD. Next design work must evaluate an Iran-available load-switch solution and then issue a replacement ECO only after technical and procurement qualification.
