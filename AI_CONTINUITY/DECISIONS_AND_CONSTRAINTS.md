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
