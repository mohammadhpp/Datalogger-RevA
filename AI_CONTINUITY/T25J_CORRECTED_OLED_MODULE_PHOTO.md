# T25J — Actual OLED photograph corrects T25I pinout conclusion

Date: 2026-09-24. Status: **T25I polarity blocker RETRACTED for the user-identified module; module current / physical mating OPEN**.

## Source correction

The user expressly stated the two earlier blue-board photos supplied for T25I were of the **wrong module**. The new in-hand photograph `1000072574.jpg`, SHA256 `0e92be2af1f0d28e52f1394d3be7abe9f1af1a7ad23d2a71fe9fb90d8f56039e`, is the **correct module**. In that photo, viewed from the display face with four through-holes along the top, silk under pads reads **VCC, GND, SCL, SDA** left-to-right. The first VCC pad is square. No header pins are visibly installed in this photo.

The live-project schematic `06_OLED_SHT3X.SchDoc`, audited in T25A/T25F, maps `J_OLED` electrical pins as **1 OLED_VDD (switched 3V3), 2 GND, 3 OLED_SCL, 4 OLED_SDA**. Thus the labels in the **correct** user photograph correspond to the same ordered signals on paper:

| Correct photo from display face | Project `J_OLED` electrical pin/net | Status |
| --- | --- | --- |
| first square-pad `VCC` | 1 `OLED_VDD` | Signal order matches, subject to physical mating and supply-voltage confirmation. |
| second `GND` | 2 GND | Signal order matches. |
| third `SCL` | 3 `OLED_SCL` | Signal order matches. |
| fourth `SDA` | 4 `OLED_SDA` | Signal order matches. |

**T25I's previous “reverse power on pin 1/2” conclusion does not apply to the user's correct module. Do not make a cross-wired cable or flip the project connector based on those wrong photos.** Keep T25I as explicitly marked historical evidence of an incorrect identification, not as an active safety gate. A first-pad square is a visual clue, not an independently verified electrical continuity/pad-number mapping of the PCB socket.

## What remains unverified

- The user WEO012864V PDF specifies the **bare 20-pin panel**, whereas the photographed device is a carrier PCB with four holes and visible FPC; no photo of its back/component side or exact carrier MPN/current curve has been provided. The PDF cannot establish actual carrier input current, startup spike, onboard boost implementation or the printed `VCC` voltage rating. Winstar WEA012864V (another 4-pin PCB assembly) may have the same label order but its current specification cannot be assigned to this unidentified carrier.
- Physical mating: this photo has **four empty through-holes**; the PCB `J_OLED` is a female 2.54 mm socket. Confirm whether a 2.54 mm male header will be installed, how front/back orientation presents the mating row, and continuity from PCB pad 1 to module VCC before power-on. Neither silk order nor schematic net labels alone proves 1:1 physical mating after installation.
- No actual OLED idle/50%-on/update/inrush current trace. The SD card is unbranded, USB sources unspecified; a system-level `3V3_SYS` transient PASS remains open.

## Next action

Proceed with independent bounded TPS631000 full-startup feasibility work and explicitly labeled SD/OLED current scenario sweeps once other source/passive assumptions are documented. Before actual assembly/power-on, confirm mounted header orientation, `VCC` operating range and electrical continuity; request a clear back-side photo or actual module listing/measurement only if those facts become necessary. No Altium schematic/PCB edits and no new DRC were done. Last physical DRC remains T24 0 warnings/0 violations, courtyard 129/129.
