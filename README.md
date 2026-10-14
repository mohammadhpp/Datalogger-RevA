# Datalogger RevA — Battery-Powered Embedded Data Logger

**Altium Designer hardware development project** for a compact, battery-powered data logger with environmental sensing, microSD storage, a real-time clock, and a local display.

> **Project status (October 2026): Engineering work in progress.** The RevA board is **not validated for manufacturing or production use**. Circuit changes, power-source transition behavior, sourcing, and hardware tests remain open. Do not treat archived simulation or DRC reports as proof of a working assembled device.

## What this project aims to provide

- Environmental measurements using an **SHT3x temperature and humidity sensor**.
- An **STM32 microcontroller** and a user interface with **OLED display** and navigation keys.
- **microSD data logging** with timestamps supported by an **RTC**.
- **USB and battery power** with an intended seamless source-transfer behavior (not yet verified in hardware).
- A cost-conscious, **two-layer PCB** designed in **Altium Designer**, with attention to manual assembly and sourcing constraints.

## Repository contents

| Location | Purpose |
| --- | --- |
| `01_POWER.SchDoc` ... `07_EXPANSION.SchDoc` | Altium schematic sheets |
| `DATALOGER_RevA.PcbDoc` | Current tracked PCB design |
| `DATALOGER_RevA.PcbLib` | PCB footprint library |
| `AI_START_HERE.md` | Guide for continuing engineering work |
| `AI_CONTINUITY/CURRENT_HANDOFF.md` | Current project decisions, exact engineering checkpoint, and unresolved work |
| `AI_EVIDENCE/` | Validation outputs and experiment evidence |
| `AI_SCRIPTS/` | Project maintenance and engineering scripts |

## Current verification status

The repository includes PCB layout/design-rule-check evidence and multiple analytical power-system investigations. **A clean design-rule check is not equivalent to successful electrical operation, functional testing, or manufacturing approval.** The latest engineering handoff documents the actual acceptance gates and the fabrication hold.

Before using any files for component orders, PCB production, or assembly, read **[CURRENT_HANDOFF.md](AI_CONTINUITY/CURRENT_HANDOFF.md)** and verify the latest commit. Old experimental BOMs and historical designs must not be assumed current.

## Hardware development workflow

1. Review the current schematic and PCB state in Altium Designer.
2. Follow the current decision log and engineering handoff.
3. Close outstanding electrical and parts-availability gates.
4. Validate power behavior, source switching, data integrity, and board-level operation.
5. Generate production outputs only after the required evidence passes.

## Public project website

The [GitHub Pages site](https://mohammadhpp.github.io/Datalogger-RevA/) provides search-friendly, curated engineering summaries:

- [Hardware architecture and single-layer laser coupon concept](https://mohammadhpp.github.io/Datalogger-RevA/hardware.html)
- [Validation and fabrication-readiness status](https://mohammadhpp.github.io/Datalogger-RevA/validation.html)
- [Documentation and authoritative handoff guide](https://mohammadhpp.github.io/Datalogger-RevA/documentation.html)

These pages summarize the published records and do **not** replace the live engineering handoff or authorize fabrication.

## Project resources

- [Source repository](https://github.com/mohammadhpp/Datalogger-RevA)
- [Engineering handoff](AI_CONTINUITY/CURRENT_HANDOFF.md)
- [Start here](AI_START_HERE.md)

**Keywords:** embedded data logger, STM32, SHT3x, temperature and humidity logger, microSD, RTC, OLED, Altium Designer, PCB design, battery power, USB power switching.

_Public visibility does not by itself grant permission to reuse the design under an open-source license. Check the repository for licensing terms before reuse._
