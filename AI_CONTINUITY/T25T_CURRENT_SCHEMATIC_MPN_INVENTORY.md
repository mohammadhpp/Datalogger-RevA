# T25T — Current schematic MPN inventory for simulation inputs

Date: 2026-09-25. Read-only extraction from GitHub `main` at `5e2a4788d535137ae8381213ca6bec6c0c20022a`; no Altium design files edited. This inventory transcribes component `Designator`, `MPN`, `Manufacturer` fields directly from the seven current Altium SchDoc CFB `FileHeader` records. The user confirmed final BOM selected and purchased. This source inventory does not independently verify order receipts, shipment or module silicon identity.

## Authoritative schematic files

- `01_POWER.SchDoc` — Git blob `da2d005712c47000eb8c16157eca464d3fee4fe1`; 48 component symbols.
- `02_MCU_CORE.SchDoc` — Git blob `d74cd80f998e49d518facb99ec831587b9debbf6`; 6 component symbols.
- `03_MICROSD.SchDoc` — Git blob `0793ee4aeae92fc5737796ce4631dac9770619f3`; 18 component symbols.
- `04_NAVIGATION.SchDoc` — Git blob `2299b8b66829deb0c40a0849691ffbcf049beefd`; 18 component symbols.
- `05_RTC.SchDoc` — Git blob `544a58e3ca4ffc08faaf2385b77ad84777c6282d`; 6 component symbols.
- `06_OLED_SHT3X.SchDoc` — Git blob `9ea7bcd3219aca291eb9ae31838f3011ac3a937a`; 24 component symbols.
- `07_EXPANSION.SchDoc` — Git blob `8714da5cbc041923e25a1aa647002e88f5b4d9a3`; 13 component symbols.

Total: **133 uniquely designated schematic component symbols**, **55 distinct MPN strings**. This count includes **17 `PROJECT_LOGICAL` entries** (battery/panel logical interfaces and testpoints); it is **not** a manufacturing placement count or a purchased-line count. All 133 records contain an `MPN` field. A text field alone does not prove a matching physical purchased item.

## Critical source and switching parts

| Function / schematic reference | Current schematic MPN / actual scope |
| --- | --- |
| `U_PMUX` | `TPS2116DRLR` |
| `U_SYS` | `TPS631000DRLR` |
| `L1` | `DFE322512F-1R0M=P2` |
| `C_IN`, `C_USB1/2` | `C2012X5R1V226M125AC` |
| `C_OUT` | `C2012X5R1A476M125AC` |
| `Q_SD`, `Q_OLED` | `AO3401A` |
| `J_SD` | `MR01A-01245` **microSD socket**, not the 4 GB card |
| `J_OLED` | `PBS-2.54-1X4GF` **female PCB socket**, not the four-pin OLED carrier |
| `C_SD_BULK1/2`, `C_SD_MID` | `C2012X5R1E226M125AC` ×2, `GRM21BR61E106KA73L` ×1 |
| `C_OLED_BULK`, `C_OLED_HF` | `GRM21BR61E106KA73L`, `CL10B104KB8NNNC` |
| `BT1`, `J1`, `S1` | Logical off-board placeholders, not exact Camelion cell, charger/cable or switch order IDs |

## Complete grouped MPN transcription

| Schematic MPN field | Count | Designators |
| --- | ---: | --- |
| `0603WAF1003T5E` | 8 | `R_BE_PU`, `R_GATE`, `R_BASE_PD`, `R_CS_PU`, `R_MISO_PD`, `R_CD_PU`, `R_OLED_GATE`, `R_OLED_BASE_PD` |
| `0603WAF2401T5E` | 2 | `R_SCL_PU`, `R_SDA_PU` |
| `0603WAF3002T5E` | 2 | `R_BASE`, `R_PR_TOP` |
| `0603WAF3300T5E` | 3 | `R_EXT_SCL`, `R_EXT_SDA`, `R_EXT_CTRL` |
| `0603WAF4702T5E` | 2 | `R_BOTTOM_B`, `R_DELAY` |
| `0603WAF470JT5E` | 2 | `R_SCL_SER`, `R_SDA_SER` |
| `0805W8F1001T5E` | 9 | `R_K1`, `R_K2`, `R_K3`, `R_SER1`, `R_SER2`, `R_SER3`, `R_SER4`, `R_EXT_IN`, `R_EXT_REF` |
| `0805W8F9102T5E` | 2 | `R_HYST`, `R_FB_BOTTOM` |
| `1206W4F5103T5E` | 2 | `R_TOP_B`, `R_FB_TOP` |
| `1N4148WS` | 1 | `D_DELAY` |
| `2.54mm-5P ZZ-MS` | 1 | `J_NAV` |
| `2510-1X6-MALE-THT` | 1 | `J_SENSOR_PCB` |
| `2X2-MALE-P2P54-THT` | 1 | `J_EXP_PWR` |
| `2X8-MALE-P2P54-THT` | 1 | `J_EXP` |
| `74HC125D,653` | 1 | `U_SD_BUF` |
| `74HC4066D,653` | 1 | `U_OLED_SW` |
| `AO3401A` | 2 | `Q_SD`, `Q_OLED` |
| `ARG05DTC1002` | 10 | `R_GATE_PD`, `R_BOTTOM_A`, `R_TOP_A`, `R_PR_BOTTOM`, `R_ST_PU`, `R_PULL1`, `R_PULL2`, `R_PULL3`, `R_PULL4`, `R_RTC_INT_PU` |
| `B06B-PASK-1N` | 1 | `J_EXT` |
| `BATTERY_2XAA_OFFBOARD` | 1 | `BT1` |
| `BC847B` | 2 | `Q_SD_DRV`, `Q_OLED_DRV` |
| `BC857BLT1G` | 1 | `Q_OVP_DRV` |
| `BLM21PG221SN1D` | 1 | `FB_SENSOR` |
| `BZT52C6V2-7-F` | 1 | `Z_OVP` |
| `C2012X5R1A476M125AC` | 1 | `C_OUT` |
| `C2012X5R1E226M125AC` | 2 | `C_SD_BULK1`, `C_SD_BULK2` |
| `C2012X5R1E475K125AB` | 1 | `C_MCU_BULK` |
| `C2012X5R1H475K125AB` | 1 | `C1` |
| `C2012X5R1V226M125AC` | 3 | `C_USB1`, `C_USB2`, `C_IN` |
| `CL10B104KB8NNNC` | 14 | `C_MCU_HF`, `C_NRST`, `C_BUF`, `C_SD_HF`, `C_FIL1`, `C_FIL2`, `C_FIL3`, `C_FIL4`, `C_RTC`, `C_SENSOR_HF`, `C_DELAY`, `C_4066`, `C_OLED_HF`, `C_EXT_REF` |
| `CR0603FA1002G` | 2 | `R_SD_DRV_BASE`, `R_OLED_BASE` |
| `DFE322512F-1R0M=P2` | 1 | `L1` |
| `DS-316` | 4 | `SW_NAV1`, `SW_NAV2`, `SW_NAV3`, `SW_NAV4` |
| `DS3231SN#` | 1 | `U_RTC` |
| `FRC0603F5101TS` | 2 | `R_CC1`, `R_CC2` |
| `FSS2301S` | 1 | `Q_OVP` |
| `GRM21BR61E106KA73L` | 3 | `C_SD_MID`, `C_SENSOR_BULK`, `C_OLED_BULK` |
| `JFC2410-1200FS` | 1 | `F1` |
| `MR01A-01245` | 1 | `J_SD` |
| `PBS-2.54-1X4GF` | 1 | `J_OLED` |
| `PLS-2.54-1X40GF` | 1 | `J_SWD` |
| `S1_4POLE_MAINTAINED_OFFBOARD` | 1 | `S1` |
| `SER0603F22R` | 1 | `R_MISO` |
| `SER0603J0R` | 3 | `R_MODE`, `R_SHIELD`, `R_EXP_PWR_EN` |
| `SMF05C.TCT` | 2 | `D1`, `D_NAV1` |
| `STM32G070KBT6` | 1 | `U_MCU` |
| `TESTPOINT_GENERIC` | 14 | `TP_BAT_RAW`, `TP_BAT_SW`, `TP_3V3_SYS`, `TP_USB_RAW`, `TP_BAT_FUSED`, `TP_OVP_REF`, `TP_VIN_MUX`, `TP_USB_OVP_IN`, `TP_PR1`, `TP_QG`, `TP_OVP_K`, `TP_USB_PROT`, `TP_VBAT`, `TP_RTC_INT` |
| `TP-1101A_COMPATIBLE_6X6X5` | 1 | `SW_RESET` |
| `TPS2116DRLR` | 1 | `U_PMUX` |
| `TPS631000DRLR` | 1 | `U_SYS` |
| `TS431BCX RFG` | 1 | `U_OVP_REF` |
| `UNKNOWN - USER DRAWING` | 1 | `BT2` |
| `USB_C_PANEL_LOGICAL` | 1 | `J1` |
| `USBLC6-2SC6` | 6 | `D_ESD1`, `D_ESD2`, `D_ESD`, `D_EXT1`, `D_EXT2`, `D_EXT3` |
| `WIRE_DRAIN_1P_THT` | 1 | `J_SHIELD` |

## Simulation boundary after source reconciliation

- The schematic's exact device MPNs and passives above are usable inputs for the existing T25 source/model audit. No need to request the whole BOM again solely to learn these identifiers.
- The SD *card* and OLED *carrier* are external modules: the actual unbranded 4 GB card and photographed four-pin blue OLED module have no numeric transient-current profile or independently established controller/carrier part number in these seven schematic symbol records. The user's WEO PDF describes a bare panel and is not a verified carrier input-current model.
- `BATTERY_2XAA_OFFBOARD` and `USB_C_PANEL_LOGICAL` specify interfaces. Camelion Digi Alkaline cells and standard charger/power-bank names do not supply exact ESR and source/current-limit versus state-of-charge/temperature/time. Treat any selected values as explicit sensitivity fixtures, never measured actual loads.
- Bench/physical prototype work is deferred by the user's pre-fabrication simulation sequence. TPS631000 full millisecond startup, integrated source switching and SD/OLED switched-load transients remain OPEN / NO PASS; short isolated vendor-model smokes are limited evidence.
- The existing root `DATALOGER_RevA.txt` and `.html` are a 2026-08-30 **empty-board information report** (`Components on board, 0`), not a BOM. The `.PrjPcb` lists the seven schematic source sheets; the current Git tree contains no separately exported purchased BOM. These facts do not imply the user's final selected BOM is unfinished.
- Next within authorized T25: use these exact parts and traceable manufacturer data to build bounded pre-fabrication startup and source-switching screening; represent the external card, OLED carrier and AA/USB source by prominently labeled sensitivity ranges until specific numeric sources are available. Do not assign a PASS to the real card/carrier from a sweep alone.