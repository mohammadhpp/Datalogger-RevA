# T25I — OLED four-pin pinout conflict from supplied module photographs

> **RETRACTED / HISTORICAL — T25J supersedes this file.** The user stated the two photographs analyzed below were **not their module**. Their correct photograph `1000072574.jpg` SHA256 `0e92be2af1f0d28e52f1394d3be7abe9f1af1a7ad23d2a71fe9fb90d8f56039e` shows left-to-right **VCC, GND, SCL, SDA**, aligned with the schematic signal order. The reverse-polarity blocker, crossed harness proposal, and proposed connector pin swap below **do not apply**. Do not implement them. Current evidence and remaining checks: [`T25J_CORRECTED_OLED_MODULE_PHOTO.md`](T25J_CORRECTED_OLED_MODULE_PHOTO.md).


Date: 2026-09-24. Status at time of writing: **BLOCKER CLAIM RETRACTED**, because the pictured module was wrong; this document preserves the superseded analysis only. No Altium change.

## Evidence

The user supplied two photographs of a four-pin 0.96-inch OLED carrier PCB:

- Front, `Screenshot 2026-09-24 225103.png`, SHA256 `9eb51cbc3f31ea09f6eb84f5e692827b097191784a2cffdebdeb9cba3bda5085`: readable silk with pin 1 `GND`, pin 2 `VDD`, pin 3 `SCK`, pin 4 `SDA`, viewed from the front (display face) with header along the top and silk numerals 1/4. This is a photographed carrier variant; the photographs alone do not certify its manufacturer, controller, voltage/current limits, or whether the user physically holds that same assembly.
- Back, `Screenshot 2026-09-24 225044.png`, SHA256 `b4a33bbf43587f5eebbde0aaff7ce29d47db08f10ecd24a0689a2facfea1f73d`: visible four-pin male header, passive components and FPC attachment. No trustworthy MPN/complete module supply-current curve was established by this image.
- Canonical `06_OLED_SHT3X.SchDoc` as audited in T25A/T25F: `J_OLED` is a PBS-2.54-1X4GF four-pin female socket with pin 1 `OLED_VDD` (switched 3V3), pin 2 GND, pin 3 `OLED_SCL`, pin 4 `OLED_SDA`. The image silk `SCK` appears intended as serial clock but electrical protocol/controller should be checked with actual carrier.

| Number at interface | Canonical Datalogger `J_OLED` | Photographed OLED carrier |
| --- | --- | --- |
| 1 | `OLED_VDD` / switched 3.3 V | `GND` |
| 2 | `GND` | `VDD` |
| 3 | `OLED_SCL` | `SCK` |
| 4 | `OLED_SDA` | `SDA` |

**Direct same-number mating reverses power and ground on pins 1 and 2. Do not plug directly or power the carrier from this header.** The actual physical position/orientation of PCB socket pin 1 and any cable/mating connector still needs an unpowered pad-number/continuity check; the electrical pin-number mismatch alone suffices to block a same-number connection.

## Relationship to the uploaded WEO PDF

The earlier six-page user PDF is for the **20-pin bare WEO012864V panel** (logic 2.8–3.3 V and separate panel rail 7–8 V), not a four-pin carrier datasheet. The photos demonstrate a populated four-pin PCB carrier, but do **not** establish that its panel is WEO012864V or that its carrier input voltage/current equals the manufacturer WEA012864V. Indeed Winstar's [WEA012864V four-pin PDF](https://www.winstar.com.tw/uploads/files/3ba4968d7bfc3593e2ae029a21013ffc.pdf) uses **pin 1 VCC, pin 2 GND, pin 3 SCL, pin 4 SDA**, opposite to the photographed carrier's first two pins. Do not import WEA's 16.5/33 mA 50%-on current spec into this photographed carrier.

## Controlled correction paths

1. If a **four-wire, individually pinned harness** is intended, map electrical nets: board `OLED_VDD` → module `VDD`; board GND → module GND; board `OLED_SCL` → module `SCK`; board `OLED_SDA` → module `SDA`. By the printed numbering, this would be board 1→module 2, 2→1, 3→3, 4→4 **only after** checking the actual PCB socket pad numbering and viewing orientation. Verify every wire with power disconnected before connecting the module. Label and document the harness so it cannot be replaced with a straight-through lead.
2. If **direct mating** to this pictured carrier is required and the PCB is not yet fabricated, revise the canonical schematic connector pin-to-net map to 1=GND, 2=`OLED_VDD`, 3=`OLED_SCL`, 4=`OLED_SDA`, then propagate ECO, inspect physical pad numbering/orientation and routing/clearance and rerun complete design checks and Full Batch DRC. Existing T24 0/0 is a historical checkpoint, not validation of such a future edit. Do not change engineering binaries based only on a marketing photo without confirming the user's actual board and intended mating.
3. If selecting a **different exact module** with 1=VDD, 2=GND (e.g., verified WEA012864V), independently verify its physical connector geometry, supply/current limits and controller. Do not assume the depicted blue PCB is that part.

**NEXT EXACT ACTION:** identify whether these pictures show the exact carrier the user intends to use and whether a cable or direct plug is intended. Until then, hold the OLED branch unpowered, exclude a claimed actual-module OLED load-step PASS, and keep bounded converter feasibility work independent. T25G isolated mux behavior remains PASS, integrated power-tree behavior OPEN. No Altium change or new DRC; last T24 courtyard 129/129 and DRC 0/0.
