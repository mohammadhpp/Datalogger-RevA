# Decisions and Constraints — Datalogger RevA

This file contains durable project decisions. Change them only with an explicit new engineering decision and record the reason in Git history.

## PCB / manufacturing constraints

- PCB architecture: **2-layer** unless the project baseline is explicitly changed.
- Manual assembly is a primary design constraint.
- Every PCB-mounted component must have a clearly readable reference designator on the board.
- Silkscreen must avoid pads and remain useful after assembly; 90-degree rotation is acceptable where needed for readability.
- ICs/connectors/polarized parts must have clear Pin-1 / polarity / orientation marking where applicable.
- Dense routing must preserve practical soldering/rework space; do not optimize only for geometric compactness.

## Off-board / panel-device rule

Every off-board or panel-mounted device must have a deliberate PCB-side connection interface.

For each such interface verify:
- correct pin count,
- correct pin mapping,
- electrical ratings,
- polarity/keying where relevant,
- clear silkscreen labeling,
- explicit connection path in the schematic/PCB.

No off-board logical component may remain without a physical PCB connection path.

## Schematic workflow

- Controlled schematic Snap Grid: **100 mil**.
- Do not casually change the established schematic grid.
- Before ECO / footprint replacement, verify schematic Pin Designators against physical footprint Pad numbers.

## T20 locked decisions

### OLED

- `C_OLED_HF = 100 nF` on `OLED_VDD`.
- Approved part: `CL10B104KB8NNNC`.

### SHT3x internal connector

- PCB-mounted internal connector: 6-pin straight male, 2.54 mm pitch, 2510-style THT header/wafer.
- Physical pin numbering/orientation follows the selected connector drawing.
- Pin names should be printed/marked clearly enough to support continuity testing and manual wiring verification.

### External panel connector

- The metal/military-style external panel connector remains a distinct interface.
- Do not confuse or merge it with the internal 6-pin SHT3x connector.

## T21 / expansion architecture

- Expansion paths were considered for light, CO2, CO, city-gas/gas-detector and related external modules.
- IoT/SIM-type external modules may have their own power but require an intentional board-side control/interface path where part of the design.
- Relay/board external loads remain external unless explicitly redesigned.

## Routing constraints established in T23

- Maintain practical assembly/rework clearance around `U_SYS` and dense IC areas.
- High-current/wide tracks may neck down locally at IC-pad escape regions when electrically acceptable, then widen outside the pin field.
- Do not leave unnecessarily wide copper pressed tightly against IC pins merely because the rule permits it.
- Keep signal/power routing understandable enough for later debugging and continuity checks.
- Final Bottom Layer GND polygon should follow completion of the major signal/power routing, not precede it.

## Git / continuity architecture

- Live local repo: `C:\#MHP FILES\DataLoger`.
- Historical/master ZIP backups are rollback artifacts, not the live source.
- `localbackup` is the required local bare backup remote.
- `github` is the private online continuity remote.
- `main` should continue tracking `localbackup/main`; do not casually change upstream to GitHub.
- Git AutoSave v2.4 performs dual backup.
- AI continuity documents in `AI_CONTINUITY/` are part of the engineering history and should be committed at meaningful milestones.

## Pre-fabrication verification order (user-confirmed 2026-09-25)

- The **final BOM is selected, purchased and physically available**. Do not treat absence of an exported BOM file in GitHub as absence of ordered components or restart part selection without a demonstrated design/BOM mismatch.
- No RevA PCB has yet been fabricated. The agreed sequence is **functional/simulation risk review first**, then an explicit user decision about manufacturing outputs and factory submission. T26A is a deferred preflight, not a release authorization.
- Do not label an isolated PSpice engine smoke, hypothetical load waveform or DRC-clean PCB as validated integrated 3V3/SD/OLED behavior. Preserve explicit source and model limitations. Ask the user before commencing a new stage; independent read-only preparation within the already authorized simulation stage remains allowed.

## Continuous USB/battery operation (user-confirmed 2026-09-26)

- Start on battery; when a standard USB adapter or power bank is connected, automatically use USB as the priority load source while the battery stops delivering the main load; when disconnected, return to battery automatically.
- In both directions the device must keep operating **without MCU reset**, including source changes during normal SD/OLED activity. Battery disconnect means power-path standby, not a promise of absolute zero leakage or physical isolation.
- Existing historical procurement workbook v0.17 already locks the **battery minimum to 1.80V at pack terminals under load** and **3V3_SYS design load to 280mA** (Power Calculations B8/B6/B18), and specifies **no nuisance cutoff at USB 5.50V** (OVP Calc B5). P9 Gates P9-F01, P9-O01, P9-C01/C02/C03 explicitly require path/startup margin, no nuisance at 5.50V, zero MCU resets in both USB handoff directions and no intentional AA backfeed; all were PENDING. These are previously selected design/acceptance requirements, **not validated PASS**. The user reconfirmed uninterrupted operation on 2026-09-26. Do not ask them to select these numbers again or silently lower the original target. Preserve status/provenance from [workbook export](T25V_PURCHASE_BOM_V017_CELL_EXPORT.json). Permitted rail dip and SD integrity thresholds still need manufacturer/firmware evidence.
- TI TPS2116 priority mode uses break-before-make. TI warns VIN2≥2.5V is needed to prevent internal reset if the selected supply collapses faster than 1V/10µs; this condition must be addressed if USB is removed with a weak two-AA pack. Read [T25AG](T25AG_CONTINUOUS_USB_BATTERY_HANDOFF_REQUIREMENT_FA.md) before any no-reset claim. Do not issue fabrication PASS while this requirement remains unverified.


## Iran-local procurement constraint — LOCKED 2026-09-28

- Every **newly proposed component or replacement** for Datalogger RevA must have evidence of practical availability from an Iranian seller/supplier before it can enter an executable ECO/BOM change.
- Global DigiKey/Mouser/LCSC availability alone is **not sufficient**.
- Prefer an exact MPN with an Iranian stock/product listing. If only a generic value/package is locally available, the exact electrical minimums and package constraints must be stated and verified before approval.
- A component that is technically attractive but not verified available in Iran may be used only as a simulation/reference candidate; it must not be presented as the final RevA procurement choice.
- Existing already-purchased BOM parts are not invalidated by this rule.


## Consolidated power-block closure and one-shot purchase — LOCKED 2026-09-28

- Do **not** place staged purchases for T25 power changes.
- Do **not** apply partial power ECOs to Altium while another power gate remains open.
- Close the whole RevA power block first: (1) battery path at 1.80V under load, (2) USB/OVP input conditioning, (3) USB<->battery no-reset handoff, (4) TPS631000 / 3V3 source margin including controlled SD startup.
- After all required power changes are technically defined, produce **one consolidated procurement list** containing exact MPN, quantity, package, Iranian seller/source evidence, and `TECHNICAL PASS + IRAN AVAILABILITY PASS` for every newly introduced/replacement part.
- Existing purchased parts that remain electrically valid should be reused rather than repurchased.
- Only after the user explicitly approves the consolidated design and purchase list may the power schematic/PCB ECO be applied.
- Fabrication Hold remains until the post-ECO compile/DRC/layout/power-validation gates are complete.

## Final hand assembly package constraint — LOCKED 2026-10-09

- User explicitly requires manual final PCB population. New IC choices must have visible accessible solder pads/leads. Favor SOIC/SOT23 and THT, use TSSOP only with inspection and manual solder proficiency, MSOP only after a solder trial. Avoid QFN/DFN/BGA/WLCSP/hidden-pad devices and ultraminiature SOT-5x3 for final power.
- Supersede the T25CY proposal of TPS2121RUXR QFN and retention of TPS631000DRLR ultraminiature for final manual assembly. Preliminary replacement candidates are TI TPS2113APW TSSOP-8 and TLV61070ADBVR SOT-23-6; not finalized, exact Iran source and AA1.80V at280mA/transfer proof required. Keep TI TPS54202DDCR/TPS22918DBVT SOT23-6 for USB/SD as qualified leaded-format candidates.
- Preserve all other existing engineering limits, two-layer, no-reset, low-power, exact Iran sourced parts, one consolidated BOM/ECO, new DRC and no speculative hardware PASS. See T25CZ report.
