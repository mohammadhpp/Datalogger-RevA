# T22 PDF and baseline text extraction — provenance indexed
Historical PDF text transcribed with pdftotext -layout, not a replacement for the original layout/figures. The source PDFs are in the T22 archive and T25V recovery bundle. The exact source member and PDF SHA256 appear at each heading; seven current Git SchDocs and later T16/T20/T22 decisions are authoritative on conflicts. OCR was not applied to scanned documents.

## POWER_SCHEMATIC_ENTRY_BASELINE_v0.17_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/POWER_SCHEMATIC_ENTRY_BASELINE_v0.17_FA.txt`  
PDF/source SHA256: `0cc2635d7c542111ac6b812d4bf02b6f9f6c9a04539b8a827c62342b21c85aa1`

```text
DATALOGGER REV-A - POWER SCHEMATIC ENTRY BASELINE v0.17
Date: 2026-08-16
CAD target: Altium Designer 26.8.1 Build 31
Status: CONTROLLED FOR MANUAL SCHEMATIC ENTRY / P9 PENDING / NOT PRODUCTION RELEASE

DESIGN CONSTRAINTS
- Battery: 2xAA alkaline series; V_BAT_PACK_MIN_LOADED=1.80V.
- No intentional battery charging or USB/capacitor backfeed into AA pack.
- Output: 3V3_SYS, target approximately 3.302V from 510k/91k feedback.
- Design load maximum: 280mA.
- Ambient qualification range: 0..50C.
- TPS631000 startup requirement: VIN >1.65V. Therefore total startup drop from loaded 1.80V pack
  through holder + wiring + F_BAT + S1-A + TPS2116 + copper must remain <150mV in actual hardware.

CONTROLLED POWER PATH
BATTERY:
  2xAA holder + -> BAT_RAW -> F_BAT=JFC2410-1200FS -> BAT_FUSED -> S1-A -> BAT_SW
  -> TPS2116 pin6 VIN2.
  C_BAT_LOCAL=C2012X5R1H475K125AB 4.7uF/50V from BAT_SW to GND.

USB VBUS:
  USB-C VBUS -> USB_VBUS_RAW -> S1-B -> USB_OVP_IN -> Q_OVP=FSS2301S -> USB_VBUS_PROT
  -> TPS2116 pin3 VIN1.
  TPS2116 pin5 MODE is tied to USB_VBUS_PROT (VIN1 Priority mode).
  C_USB1=C2012X5R1V226M125AC 22uF/35V POP at USB_VBUS_PROT.
  C_USB2=same MPN, DNP initially.

USB CC:
  USB_CC1 -> dedicated SMF05C.TCT channel + R_CC1=FRC0603F5101TS 5.1k -> CC1_RD_RET -> S1-C -> GND.
  USB_CC2 -> dedicated SMF05C.TCT channel + R_CC2=FRC0603F5101TS 5.1k -> CC2_RD_RET -> S1-D -> GND.
  CC1/CC2 return paths remain independent before S1-C/S1-D.
  S1 never interrupts GND directly.

PMUX:
  U_PMUX=TPS2116DRLR.
  pin1 GND -> GND
  pin2 VOUT -> VIN_MUX, tied to pin7
  pin3 VIN1 -> USB_VBUS_PROT
  pin4 PR1 -> PMUX_PR1 = junction of R_PR_TOP=30k and R_PR_BOTTOM=10k
  pin5 MODE -> USB_VBUS_PROT
  pin6 VIN2 -> BAT_SW
  pin7 VOUT -> VIN_MUX, tied to pin2
  pin8 ST -> PMUX_ST; TP allowed; optional R_ST_PU=10k to 3V3_SYS is DNP initially
  R_PR_TOP=0603WAF3002T5E 30k 1%
  R_PR_BOTTOM=ARG05DTC1002 10k 0.5%
  Nominal PR threshold ~4.00V. Physical transfer/hard-unplug behavior remains P9.

BUCK-BOOST:
  U_SYS=TPS631000DRLR.
  pin1 VOUT -> 3V3_SYS
  pin2 LX2 -> L1 terminal 2
  pin3 LX1 -> L1 terminal 1
  pin4 VIN -> VIN_MUX
  pin5 EN -> VIN_MUX directly; no RC/supervisor
  pin6 MODE -> MODE_PFM -> R_MODE=SER0603J0R 0R -> GND
  pin7 GND -> GND
  pin8 FB -> FB_3V3
  L1=DFE322512F-1R0M=P2 1uH
  C_IN=C2012X5R1V226M125AC 22uF/35V at VIN_MUX
  C_OUT=C2012X5R1A476M125AC 47uF/10V at 3V3_SYS
  R_FB_TOP=1206W4F5103T5E 510k from 3V3_SYS to FB_3V3
  R_FB_BOTTOM=0805W8F9102T5E 91k from FB_3V3 to GND
  Do NOT place a test point on LX1 or LX2.

DISCRETE USB OVP - P9 CONTROLLED SET
  U_OVP_REF=TS431BCX RFG
  Q_OVP_DRV=BC857BLT1G
  Q_OVP=FSS2301S P-channel MOSFET
  Z_OVP=BZT52C6V2-7-F, cathode to USB_OVP_IN/source, anode to OVP_GATE
  R_TOP_A=ARG05DTC1002 10k
  R_BOTTOM_A=ARG05DTC1002 10k
  R_GATE_PD=ARG05DTC1002 10k
  R_TOP_B=1206W4F5103T5E 510k
  R_BOTTOM_B=0603WAF4702T5E 47k
  R_HYST=0805W8F9102T5E 91k
  R_BASE=0603WAF3002T5E 30k
  R_BE_PU=0603WAF1003T5E 100k
  R_K1/R_K2/R_K3=0805W8F1001T5E, 3 x 1k series

OVP NET RULES
  USB_OVP_IN: S1-B output; Q_OVP source; TS431 divider/feed; PNP emitter; zener cathode.
  USB_VBUS_PROT: Q_OVP drain; TPS2116 VIN1+MODE; C_USB1/C_USB2; R_PR_TOP.
  OVP_GATE: FSS2301S gate; BC857BLT1G collector; R_GATE_PD to GND; zener anode; R_HYST endpoint.
  OVP_REF: TS431 REF and divider/hysteresis junction.
  OVP_K: TS431 cathode; R_K 3x1k feed path; R_BASE link. No capacitor directly K-A.
  OVP_BASE: BC857BLT1G base; R_BE_PU to USB_OVP_IN; R_BASE to OVP_K.

OVP ANALYTICAL HOLD POINTS - NOT A PHYSICAL PASS
- Normal USB no-nuisance boundary: 5.50V.
- TPS2116 recommended VIN maximum: 5.50V; absolute VIN maximum: 6.00V.
- Retained static analytical trip bound: ~5.6007..5.9157V.
- Static margin from max analytical trip to 6.0V: ~84mV before switching delay/overshoot.
- Retained analytical reset bound: ~5.0584..5.3664V.
- Initial injected qualification fault ceiling: 12V.
- BZT52C6V2 nominal VZ=6.2V at IZT=5mA; simple 12V/10k estimate gives only ~0.58mA,
  so actual FSS2301S |VGS| MUST be measured on the exact purchased parts.

TEST POINT PLAN
MANDATORY:
  TP_BAT_RAW, TP_BAT_FUSED, TP_BAT_SW, TP_USB_RAW, TP_USB_OVP_IN, TP_USB_PROT,
  TP_QG, TP_OVP_REF, TP_OVP_K, TP_PR1, TP_VIN_MUX, TP_3V3_SYS.
OPTIONAL:
  TP_OVP_BASE, TP_PMUX_ST, TP_FB, TP_MODE.
FORBIDDEN:
  No TP on LX1 or LX2.

P9 / IQC GATES - ALL STILL OPEN
- F_BAT path drop at loaded 1.80V; VIN at TPS631000 >1.65V during startup; reset count=0.
- Controlled prospective-AA-short/fuse-clearing test and fuse-placement review.
- OVP rising/falling sweeps, chatter, protected VIN1 peak, FSS2301S VGS/VDS at 12V injected fault.
- USB hard-unplug -> battery; battery -> USB insertion; reverse current/no-charge.
- >=100 transfer cycles and 0C/50C corner repeats.
- Incoming exact marking/pinout: FSS2301S, TS431BCX RFG, BC857BLT1G and USB connector.
- Real Altium Validate: Off-grid=0 and Electrical errors=0.

SCHEMATIC PROCESS RULE
This file is a controlled entry specification, not a schematic PASS.
Build 01_POWER.SchDoc manually. Do not run ECO/Update PCB until actual Altium validation and
required physical gates are complete. The package contains no fabricated SchDoc/SchLib binary.

```

## Datalogger_01_POWER_Schematic_Release_RevA_v1.0_FA_2026-08-18
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_01_POWER_Schematic_Release_RevA_v1.0_FA_2026-08-18.pdf`  
PDF/source SHA256: `28a197ab786f884dab84c88f8b64b5b6e17800803d0ae74c4b66e4f40a08d64c`

```text
                                                                         ‫ شماتیک تغذیه‬Release ‫ گزارش‬- Datalogger Rev-A ‫پروژه‬


                                                                                                                  01_POWER.SchDoc


                                     Checkpoint ‫گزارش نهایی اعتبارسنجی و‬
                                                                                FINAL_SCHEMATIC_VALIDATION = PASS



2026-08-18                                                                                                         Release ‫تاریخ‬

Altium Designer 26.8.1 Build 31                                                                                    Altium ‫نسخه‬

cad_release/schematics/01_POWER.SchDoc                                                                        ‫ شده‬Release ‫فایل‬

d3bc93885ea2b6cc962cf0344f365fdbb7e028c3314a39719c69d1210046225b                                                         SHA256

POWER_SCHEMATIC_ENTRY_BASELINE_v0.17_FA.txt                                                                    ‫ الکتریکی‬Baseline


  ‫ و‬Backfeed، Cold-start ،‫ رفتار انتقال منبع‬،P9 ‫ آزمونهای فیزیکی‬.‫ است‬Power ‫ صرفا ً مربوط به ساخت و اعتبارسنجی شماتیک بلوک‬PASS ‫این‬
                                                                                                 .‫آزمونهای دمایی همچنان باز هستند‬

[PDF PAGE BREAK]
                                                                                                             Release ‫های‬Gate ‫ نتیجه‬.1

  ‫نتیجه‬                                               ‫ معیار‬/ ‫شاهد‬                                                        Gate

  PASS         Compile successful, no errors found.                                                                         Compile / Validate

    0                                                                .‫ نهایی ثبت نشده است‬Validate ‫ در‬Error ‫هیچ‬                Electrical Errors

ENABLED        Off-grid object = Warning ‫ در‬Project Options ‫تأیید شد‬.                                                            Off-grid Rule

    0                                             .‫ وجود ندارد‬Off-grid object ‫ از نوع‬Warning ‫ تازه هیچ‬Validate ‫در‬           Off-grid Violations

  PASS                                   .‫ تبدیل شد‬R_PR_BOTTOM ‫ اصالح و به‬PR bottom ‫ خالی مقاومت‬Designator                         Annotation

 12 / 12                                                             .‫ حاضر هستند‬Baseline ‫ اجباری‬Test Point ۱۲          Mandatory Test Points

    0                                                                          .‫ وجود ندارد‬LX2 ‫ یا‬LX1 ‫ روی‬TP ‫هیچ‬      Forbidden LX Test Points



no driving source Warning ‫) و چهار‬BT1/J1/S1( off-board ‫ آیتمهای‬Footprint ‫ مربوط به‬Warning ‫ سه‬:‫ باقیمانده مستند و پذیرفته شدهاند‬Warning ‫هفت‬
                                                 .‫ اضافه نشده است‬No-ERC ‫ برای پنهانکردن صوری آنها‬.PMUX_PR1 ‫ و‬OVP_REF ،MODE_PFM ،FB_3V3 ‫روی‬

[PDF PAGE BREAK]
                                                                    Binary ‫ استاتیک فایل‬Audit .2


‫نتیجه‬   ‫شاخص‬                                 .‫ ندارند‬Footprint ‫ هستند و‬off-board/logical ً ‫ عمدا‬S1 ‫ و‬J1 ،BT1 ‫سه آیتم‬
                                                     .‫ لینک شدهاند‬TESTPOINT_GENERIC_1P5MM ‫ به‬Test Point ۱۲ ‫تمام‬
 48        SchDoc ‫های‬Component ‫کل‬

 36              Power ‫قطعات کنترلشده‬
                                               C_USB2 = DNP ،C_USB1 = POP :Assembly Carry-forward ‫وضعیت‬
                                                  Baseline ‫ این وضعیت از‬.R_ST_PU = DNP initially ‫ و‬initially
 12                 ‫های اجباری‬Test Point
                                            ‫ استنتاج نشده‬SchDoc ‫ عمومی‬Metadata ‫کنترلشده حمل میشود و صرفا ً از‬
 45       ‫ موجود‬Footprint/Model Link                                                                          .‫است‬

 0                    ‫ تکراری‬Designator

 0             ? ‫ خالی یا دارای‬Designator

 0         Library Source mismatch

[PDF PAGE BREAK]
                                                      Altium ‫ نهایی‬Validate ‫ شاهد‬.3




Compile successful, no errors found. :‫ نهایی‬Validate - 1 ‫شکل‬

[PDF PAGE BREAK]
                                                         Off-grid ‫ شاهد فعال بودن کنترل‬.4




Off-grid object = Warning :Project Options / Error Reporting - 2 ‫شکل‬

[PDF PAGE BREAK]
                                                 ‫ها‬Test Point ‫ و‬Sheet ‫ نمای نهایی‬.5




.‫ اجباری‬Test Point ۱۲ ‫ با‬01_POWER.SchDoc ‫ نمای کلی‬- 3 ‫شکل‬

[PDF PAGE BREAK]
                                                                                              ‫ موارد باز و گام بعدی‬،PASS ‫ محدوده‬.6

                                                                                                                     ‫ نشدهاند‬PASS ‫مواردی که هنوز‬

                                               ‫ محدوده باقیمانده‬/ ‫وضعیت‬                                                              ‫موضوع‬

   ،Battery-to-USB insertion، no-charge/backfeed ،‫ به باتری‬USB hard-unplug ‫ انتقال‬،280mA ‫ اثبات‬،loaded=1.80V ‫ با‬Cold-start   P9 Hardware
                                                                          .0C / 50C ‫های‬corner ‫ سیکل و‬100 ‫ حداقل‬،OVP/fuse     Qualification


                                                                             .‫ مجاز نیست‬Checkpoint ‫ در این‬- PROHIBITED       ECO / Update PCB


                                              .‫ تبدیل میشود‬Gate ‫ فقط در صورت ایجاد الزام مکانیکی مشخص به‬- NON-BLOCKING       3D



                                                                                                                                  ‫بلوک بعدی شماتیک‬

                                               .‫ خواهد بود‬02_MCU_CORE.SchDoc ‫ هدف‬Sheet ‫ است و نام‬MCU Core / SWD / Reset / Clock ‫بلوک بعدی‬


                                             :‫ مراجع دقیق‬.‫ میشود‬Cross-check ‫ ورودی کنترلشده ساخته و‬Baseline ‫ یک‬،MCU ‫ کردن هر قطعه‬Place ‫قبل از‬
Datalogger_MCU_Core_SWD_Reset_Clock_Final_BOM_RevA_v2.1_FA.pdf
Datalogger_Master_Pin_Budget_Conflict_Check_RevA_v1.1_FA_2026-08-13.pdf
                                                                                                                     .‫ورود مستقیم از حافظه مجاز نیست‬



                       cad_release/runtime_evidence/ ‫ و‬cad_release/TASK12_POWER_SCHDOC_RELEASE_QUALIFICATION_v1.0_FA.txt :Release ‫مرجع فنی‬
                                                                                                   .TASK12_POWER_SCHDOC_STATIC_AUDIT_v1.0_FA.txt

[PDF PAGE BREAK]

```

## Datalogger_MicroSD_Final_BOM_RevA_v1.3_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/10_POST_BASELINE_UPDATES_2026-08-19_TO_2026-08-22/T16_MICROSD_ST_PROCUREMENT_LOCK/sources/Datalogger_MicroSD_Final_BOM_RevA_v1.3_FA.pdf`  
PDF/source SHA256: `63b70a874652f4ba352230091cf12dc59e50fe87da81cf1cf8d54070bcb274a2`

```text
                 Datalogger MicroSD - Controlled BOM
                               Revision
Revision control page - Rev-A v1.3 - 2026-08-13


 Controlled change: D_ESD exact manufacturer is now YENJI Elec, MPN USBLC6-2SC6, SOT23-6, device top
 marking 0552S. This page supersedes only the USBLC6-2SC6 manufacturer/source assumptions in Rev-A v1.2;
 all unrelated architecture and BOM decisions are carried forward.



1. Manufacturer datasheet audit
Parameter                                     YENJI USBLC6-2SC6 datasheet value

VRWM                                          5V

VBR                                           >= 6 V at IT = 1 mA

Reverse leakage                               <= 0.5 uA at VRWM = 5 V

Clamp voltage                                 <= 10 V at 1 A; <= 20 V at 5 A (8/20 us)

Cj, I/O to GND                                0.6 pF typ; 0.8 pF max at 0 V, 1 MHz

Cj, I/O to I/O                                0.3 pF typ; 0.4 pF max at 0 V, 1 MHz

IEC 61000-4-2                                 +/-30 kV air; +/-25 kV contact

Package / pitch                               SOT23-6 / 0.95 mm

Marking                                       0552S + date code



2. Recalculation / electrical impact
Each protected SPI signal sees one YENJI I/O channel, therefore the added shunt capacitance is <= 0.8 pF per signal. This is
lower than the previously assumed ST USBLC6-2SC6 maximum I/O-to-ground capacitance, so no adverse signal-loading
recalculation forces a BOM or topology change. The existing MicroSD power-gate, 74HC125 buffer, MISO 22 Ohm series resistor,
and ESD placement rules are carried forward.
No numeric SPI timing margin is claimed here because the current source document does not lock a PCB trace impedance, driver output resistance, or
measured edge rate. Those values must not be guessed.

3. Package / schematic control
Use the YENJI pin diagram and package drawing as the library source: pins 1/6 are I/O1, pins 3/4 are I/O2, pin 2 is GND, and pin
5 is VCC. Suggested land pattern data from the datasheet: pitch P = 0.95 mm, pad X = 0.60 mm, pad Y = 1.10 mm, G = 1.40 mm,
C = 2.50 mm, Z = 3.60 mm. Schematic/PCB PASS is still forbidden until actual Altium Validate reports Off-grid = 0 and Electrical
errors = 0.

4. Procurement / incoming inspection
Iran source check: Aftab Rayaneh has an active USBLC62SC6-SOT23 product page; the retrieved page snapshot shows stock =
45. The supplier page does not explicitly identify YENJI as manufacturer, so purchase acceptance is conditional on incoming
marking/package verification against the YENJI datasheet: top mark 0552S, SOT23-6, correct pin-1 dot/marking.
Supplier URL: https://shop.aftabrayaneh.com/usblc62sc6-sot23-aftab.html

Project manufacturer source: yenji-elec-usblc6-2sc6_c323793_zc5b.pdf (YENJI Elec, 4 pages).


 Release effect: D_ESD1/D_ESD2 source/manufacturer updated; MicroSD architecture unchanged. Architecture/BOM source
 correction = PASS. Physical incoming-part verification = PENDING. Schematic Validation = NOT STARTED / NOT PASSED.
 No ECO / Update PCB is authorized by this revision.

[PDF PAGE BREAK]
STM32G070 DATA LOGGER / STORAGE FINALIZATION




‫خرید‬   BOM ‫ و‬MicroSD ‫نهایی‌سازی بلوک‬
‫ جدید‬STM32G070KBT6 / SPI1 / Pin Map ‫ همگام‌سازی کامل با‬- Rev-A v1.2


  Electrical BOM Locked / MCU Pin Assignment Updated / Footprint Drawing Cross-check Pending /
  Schematic Not Yet Validated



              ‫پارامتر‬                                            ‫مقدار‬
 MCU                            STM32G070KBT6 / LQFP-32

 Interface                      SPI1 / 3.3 V

 Socket                         MR01A-01245

 SPI buffer                     74HC125D,653

 Power switch                   AO3401A + BC847B

 ESD                            2 x USBLC6-2SC6



   ‫ معماری‬.‫ جایگزین می‌کند‬Rev-A ‫ را برای‬STM32G030F6P6 ‫ مبتنی بر‬v1.1 ‫ این سند‬:Revision delta
   ‫ اصالح شده و‬G070 ‫ به‬Pin Assignment ‫ و‬MCU ‫ تغییر نکرده‌اند؛ فقط‬BOM ‫ مقادیر و‬،‫ها‬MPN ،‫الکتریکی‬
  .‫ اضافه شده است‬Firmware ‫ به‬SPI ‫ رسمی‬Errata ‫قاعده‬



  ‫ شماتیک فقط پس از‬PASS .‫ و تخصیص پایه را قفل می‌کند‬BOM ،‫ فقط معماری‬PDF ‫ این‬:Release ‫قاعده‬
   Update PCB ‫ تا آن زمان هیچ‬.‫ معتبر است‬Electrical errors = 0 ‫ و‬Off-grid = 0 ‫ با‬Altium ‫ واقعی‬Validate
  .‫ مجاز نیست‬ECO ‫یا‬


Rev-A v1.2                                                                                    2026-08-09

[PDF PAGE BREAK]
STM32G070KBT6 ‫ روی‬MicroSD ‫ تخصیص پایه‌های‬.1
          Signal                MCU Port             Pin            Peripheral / Mode          ‫وضعیت‬

 SD_CARD_DET_N            PB9                   1            GPIO Input, Active-Low     LOCK

 SD_CS                    PA4                   11           SPI1_NSS / GPIO CS         LOCK

 SD_SCK                   PA5                   12           SPI1_SCK                   LOCK

 SD_MISO                  PA6                   13           SPI1_MISO                  LOCK

 SD_MOSI                  PA7                   14           SPI1_MOSI                  LOCK

 SD_PWR_CTL               PB1                   16           GPIO Output                LOCK




  ‫ در این بلوک به‌صورت‬PB1 ‫ و‬PB9 .‫ را دارند‬SPI1 ‫ نگاشت مستقیم‬DS12766 Rev.3، PA4/PA5/PA6/PA7 ‫طبق‬
  .‫ کارت الزم نیست‬SPI ‫ ویژه برای‬Multiplexing ‫ یا‬Remap ‫ بنابراین هیچ‬.‫ استفاده می‌شوند‬GPIO


‫ بدون تغییر‬- MicroSD ‫ سوکت نهایی‬1.1

                ‫پارامتر‬                                             Rev-A v1.2 ‫تصمیم‬

 Manufacturer                         Shenzhen ATOM Technology

 MPN                                  MR01A-01245

 Card type                            microSD

 Mechanism                            Push-Push / Ejector

 Card Detect                          ‫ وصل می‌شود‬PB9 ‫ به‬Rev-A ‫دارد؛ در‬
 Mounting                             Right Angle, SMD/SMT



   Altium، Drawing ‫ در‬Footprint ‫ اما قبل از ساخت‬،‫ خرید قفل است‬MPN :‫ نشده‬Release ‫ هنوز‬Footprint
  .‫ سوکت بی‌نام قبلی استفاده نشود‬Drawing ‫ از‬.‫ باید با قطعه تحویلی تطبیق داده شود‬MPN ‫رسمی همین‬


MICROSD / MCU PIN MAP                                                                                  Page 2

[PDF PAGE BREAK]
‫ معماری الکتریکی نهایی‬.2

  3V3_SYS -- Source Q_SD (AO3401A)
    Drain -------- SD_VDD -- 2x22uF + 10uF + 100nF
    Gate = SD_GATE
        |
      100k to 3V3_SYS
        |
    Collector BC847B
  SD_PWR_CTL --10k-- Base
        |
      100k
        |
       GND

  74HC125D VCC = 3V3_SYS (always powered)
  OE1/OE2/OE3 = SD_GATE   [PMOS OFF -> OE HIGH -> Hi-Z]
  CH1: MCU_SD_CS   -> SD_DAT3/CS
  CH2: MCU_SD_SCK -> SD_CLK
  CH3: MCU_SD_MOSI -> SD_CMD/DI
  CH4: unused: OE4=3V3_SYS, A4=GND, Y4=NC

  SD_DAT0/DO ---- 22R ---- MCU_SD_MISO
  SD_CS(card side) -- 100k -- SD_VDD
  MCU_SD_MISO ------ 100k -- GND
  SD_CARD_DET_N ----- 100k -- 3V3_SYS    [switch to GND]

  2x USBLC6-2SC6 protect CS/SCK/MOSI/MISO close to socket



‫ قرار می‌گیرد و سه‬High ‫ در‬Gate PMOS ،‫ وقتی کارت خاموش است‬:‫ دو کار همزمان انجام می‌دهد‬SD_GATE ‫گره‬
،‫ هنگام روشن‌شدن کارت‬.‫ می‌شوند‬High-Z ‫ از کارت جدا و‬CS/SCK/MOSI ‫ بنابراین‬،‫ هستند‬High ‫ بافر نیز‬OE
.‫ روشن می‌شود و سه کانال بافر فعال می‌شوند‬PMOS ،‫ می‌کند‬Low ‫ گره را‬BC847B

   ‫ بازدرایو دیجیتال و‬74HC125D ‫ نقش‬.‫ استفاده نمی‌شود‬MicroSD ‫ در مسیر‬4066 ‫ خانواده‬:‫تصمیم ثابت‬
  .‫ عبور می‌کند‬22Ω ‫ مستقیم و تنها از مقاومت سری‬MISO ‫جداسازی سه‌حالته است؛‬


Firmware ‫ توالی‬2.1
  .‫ قرار گیرد‬Low ‫ در‬SCK ‫ و‬High ‫ در‬CS ،‫• پیش از روشن‌کردن کارت‬
  .‫ چند میلی‌ثانیه صبر شود‬SD_VDD ‫ و پس از تثبیت‬SD_PWR_CTL = 1 •
  .‫ پایین شروع و سپس سرعت مرحله‌ای افزایش یابد‬Clock ‫ کارت با‬Initialization •
  .‫ خاتمه یابد‬SPI ‫ شود و تراکنش جاری‬sync/unmount ‫ فایل‌سیستم‬،‫• پیش از خاموشی‬
  ‫؛ سپس‬BSY = 0 ‫ و‬TXE = 1 :‫ رسمی رعایت شود‬Errata ‫ قاعده‬،Master TX ‫ پس از‬SPI ‫ کردن‬Disable ‫• برای‬
  .‫ خاموش شود‬Power Gate ‫ و بعد‬SPI Disable
MICROSD / ELECTRICAL ARCHITECTURE                                                              Page 3

[PDF PAGE BREAK]
‫‪ Power-Gate، Buffer، ESD .3‬و ‪Decoupling‬‬
‫‪ 3.1‬محاسبه ‪Power-Gate‬‬
‫برای پیک طراحی ‪ mA 400‬و حداکثر مقاومت روشن رسمی ‪ AO3401A‬برابر ‪ mΩ 85‬در ‪:VGS=-2.5 V‬‬

  ‫‪V_DROP,max = 0.4 A x 0.085 ohm = 34 mV‬‬
  ‫‪P_Q,max‬‬    ‫‪= (0.4 A)^2 x 0.085 ohm = 13.6 mW‬‬



 ‫بنابراین افت ‪ DC‬و تلفات ‪ PMOS‬در این نقطه کوچک است؛ ‪ Qualification‬نهایی همچنان با کارت واقعی انجام‬
‫می‌شود‪.‬‬

‫‪ 3.2‬وضعیت خطوط هنگام ‪SD OFF‬‬

         ‫‪Signal‬‬                       ‫مسیر‬                              ‫وضعیت هنگام ‪SD OFF‬‬


 ‫‪SD_CS‬‬                ‫‪MCU -> 74HC125 -> Card‬‬
                                                             ‫‪High-Z‬؛ ‪ Pull-up‬سمت کارت آن را ‪ High‬نگه‬
                                                            ‫می‌دارد‬
 ‫‪SD_SCK‬‬               ‫‪MCU -> 74HC125 -> Card‬‬                ‫‪High-Z‬‬

 ‫‪SD_MOSI‬‬              ‫‪MCU -> 74HC125 -> Card‬‬                ‫‪High-Z‬‬


 ‫‪SD_MISO‬‬              ‫‪Card -> 22R -> MCU‬‬
                                                             ‫کارت خاموش؛ ‪ Pull-down 100k‬سطح ‪ MCU‬را‬
                                                            ‫تعریف می‌کند‬


‫‪ 3.3‬حفاظت و خازن‌ها‬

            ‫‪Ref‬‬                   ‫مقدار‬                     ‫محل‬                           ‫هدف‬

 ‫‪C_SD_HF‬‬                  ‫‪100 nF‬‬               ‫چسبیده به ‪ VDD/GND‬سوکت‬           ‫‪HF decoupling‬‬

 ‫‪C_SD_MID‬‬                 ‫‪10 uF‬‬                ‫کنار سوکت‬                        ‫پشتیبانی بار متوسط‬

 ‫‪C_SD_BULK1/2‬‬             ‫‪2 x 22 uF‬‬            ‫کنار سوکت‬                        ‫پیک‌های جریان ‪Init/Write‬‬

 ‫‪C_BUF‬‬                    ‫‪100 nF‬‬               ‫چسبیده به ‪VCC 74HC125D‬‬           ‫‪ Decoupling‬بافر‬


  ‫دو ‪ USBLC6-2SC6‬مجموعًا چهار خط ‪ CS/SCK/MOSI/MISO‬را نزدیک سوکت پوشش می‌دهند‪ .‬مسیر تخلیه‬
  ‫‪ ESD‬به ‪ GND‬باید کوتاه و مستقیم باشد‪.‬‬


‫‪MICROSD / POWER + SIGNAL INTEGRITY‬‬                                                                     ‫‪Page 4‬‬

[PDF PAGE BREAK]
MPN ‫ بدون تغییر‬- MicroSD ‫ نهایی‬BOM .4
              Ref                         MPN                     Package                        ‫وظیفه‬                Qty


J_SD                       MR01A-01245                     SMD/SMT                   microSD + Ejector    ‫سوکت‬   1
                                                                                     + Card Detect


U_SD_BUF                   74HC125D,653                    SO14 / SOT108-1           ‫بافر سه‌حالته‬               1
                                                                                     CS/SCK/MOSI

Q_SD                       AO3401A                         SOT-23                    High-side power switch      1

Q_SD_DRV                   BC847B                          SOT-23                    Gate PMOS ‫درایو‬             1

D_ESD1,D_ESD2              USBLC6-2SC6                     SOT-23-6                  SPI ‫ چهار خط‬ESD             2

R_MISO                     SER0603F22R                     0603                      22 ohm series               1

R_BASE                     CR0603FA1002G                   0603                      10k base resistor           1
R_GATE,R_BASE_PD,R_CS_
PU,R_MISO_PD,R_CD_PU
                           0603WAF1003T5E                  0603                      5 x 100k, 1%                5

C_BUF,C_SD_HF              CL10B104KB8NNNC                 0603                      2 x 100nF                   2

C_SD_MID                   GRM21BR61E106KA73L              0805                      10uF, 25V, X5R              1

C_SD_BULK1/2               C2012X5R1E226M125AC             0805                      2 x 22uF, 25V, X5R          2


   ‫ بنابراین خریدهای قبلی‬.‫ تغییر نکرده است‬v1.1 ‫ نسبت به‬PCB ‫ مقدار یا تعداد‬،MPN ‫ هیچ‬:Revision ‫نتیجه‬
  .‫ را همگام می‌کند‬Firmware constraint ‫ و‬Pin Map ‫ حاضر صرفًا‬Revision ‫معتبر باقی می‌مانند؛‬



  ‫ فقط در بلوک ایزوالسیون‬4066 .‫ خرید یا استفاده نشود‬74HC4066 / HEF4066 ‫ هیچ‬MicroSD ‫ برای‬:‫ممنوع‬
  .‫ کاربرد دارد‬OLED


v1.1 -> v1.2 ‫ تغییرات سند‬4.1

                    ‫آیتم‬                            v1.1                                         v1.2

 MCU                                STM32G030F6P6                     STM32G070KBT6

 SPI pins                        G030 / ‫قدیمی‬                         PA4/PA5/PA6/PA7 = SPI1


 Card Detect                     ‫ نهایی جدید‬Pin ‫ بدون‬Net              PB9 / pin 1


 Power control                   ‫ نهایی جدید‬Pin ‫ بدون‬Net              PB1 / pin 16


 SPI Errata                      MicroSD ‫ثبت نشده در سند‬              TXE=1, BSY=0 before SPI disable in master TX


 BOM                             Locked                               ‫بدون تغییر‬

MICROSD / BOM + REVISION CONTROL                                                                                     Page 5

[PDF PAGE BREAK]
‫ معیارهای پذیرش و منابع‬.5

‫ شماتیک‬Release ‫ معیارهای قبل از‬5.1

   ‫ فقط از‬Card Detect ‫ و‬Pin numbering ‫ با قطعه تحویلی تطبیق داده شود؛‬MR01A-01245 ‫ رسمی‬Drawing •
  .‫ استخراج شود‬Drawing ‫همان‬
  .‫ متصل شوند؛ کانال چهارم ثابت و غیرفعال باشد‬SD_GATE ‫ به‬74HC125D ‫ مورد استفاده‬OE ‫• سه‬
  .‫ باشند‬High-Z ‫ از سمت کارت‬CS/SCK/MOSI ‫ نزدیک صفر و‬SD_VDD ‫ ولتاژ‬،SD OFF ‫• در‬
  .‫ در بار آزمون بدون داغی غیرعادی باشد‬AO3401A ‫ افت‬،SD ON ‫• در‬
  .‫ ابتدا با فرکانس پایین و سپس با افزایش مرحله‌ای انجام شود‬Initialization •
  .corruption ‫ یا‬Reset، CRC/FS error ‫ دقیقه بدون‬10 ‫ تکراری حداقل‬Write/Sync/Close •
  ‫ و در نهایت قطع‬SPI Errata ‫ سپس قاعده‬،sync/unmount ‫ ابتدا پایان تراکنش و‬Power-down ‫• در‬
  .SD_PWR_CTL
  .‫ کوتاه و مستقیم قرار گیرند‬Ground ‫ نزدیک سوکت با مسیر‬ESD arrays •
  .Electrical errors = 0 ‫ و‬Altium: Off-grid = 0 ‫ واقعی‬Validate •
  .‫ اجرا نشود‬Update PCB / ECO ‫ هیچ‬PASS ‫• تا قبل از‬
‫مرجع‬/‫ منابع رسمی‬5.2

          ID                                       ‫منبع‬                                        ‫کاربرد‬

 ST-DS
                 STMicroelectronics DS12766 Rev.3 - STM32G070CB/KB/RB         ‫های‬Alternate Function ‫ و‬Pinout
                 datasheet                                                    PA4...PA7، PB1، PB9

                 STMicroelectronics ES0468 Rev.5 - STM32G070CB/KB/RB device
 ST-ERR
                 errata                                                       Disable ‫ هنگام‬SPI BSY/TXE workaround

 NXP             Nexperia 74HC125/74HCT125 official datasheet                 Tri-state buffer behavior

                 Shenzhen ATOM Technology MR01A-01245 official
 ATOM                                                                         Socket mechanics + Card Detect
                 product/drawing

 AOSMD           AO3401A official datasheet                                   PMOS electrical limits

 YJ-ESD         YENJI Elec USBLC6-2SC6 datasheet (marking 0552S)
                                                                              ESD protection

 PREV            Datalogger_MicroSD_Final_BOM_RevA_v1.1_FA.pdf                ‫ و معماری قفل‌شده قبلی‬BOM


  .‫ قفل است‬MCU Pin Assignment ‫ و‬Architecture، BOM ‫ از نظر‬MicroSD Rev-A v1.2 :‫نتیجه نهایی‬
  Schematic Validation = .‫ است‬Pending ‫ مکانیکی قطعه واقعی‬Cross-check ‫ سوکت هنوز تا‬Footprint
  .NOT STARTED


MICROSD / RELEASE GATE                                                                                         Page 6

[PDF PAGE BREAK]

```

## Datalogger_OLED_SHT3x_Final_BOM_RevA_v1.3_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_OLED_SHT3x_Final_BOM_RevA_v1.3_FA.pdf`  
PDF/source SHA256: `67c04a86c79971fcd81689af4b444d58768c82e7e479a1e3b5ceb9c8782e9bfb`

```text
                  Datalogger OLED + external SHT3x -
                       Controlled BOM Revision
Revision control page - Rev-A v1.3 - 2026-08-13


 Controlled change: D_ESD exact manufacturer is now YENJI Elec, MPN USBLC6-2SC6, SOT23-6, device top
 marking 0552S. This page supersedes only the USBLC6-2SC6 manufacturer/source assumptions in Rev-A v1.2;
 all unrelated architecture and BOM decisions are carried forward.



1. Manufacturer datasheet audit
Parameter                                     YENJI USBLC6-2SC6 datasheet value

VRWM                                          5V

VBR                                           >= 6 V at IT = 1 mA

Reverse leakage                               <= 0.5 uA at VRWM = 5 V

Clamp voltage                                 <= 10 V at 1 A; <= 20 V at 5 A (8/20 us)

Cj, I/O to GND                                0.6 pF typ; 0.8 pF max at 0 V, 1 MHz

Cj, I/O to I/O                                0.3 pF typ; 0.4 pF max at 0 V, 1 MHz

IEC 61000-4-2                                 +/-30 kV air; +/-25 kV contact

Package / pitch                               SOT23-6 / 0.95 mm

Marking                                       0552S + date code



2. Recalculation / electrical impact
The existing I2C rise-time calculation remains valid because it is set by the locked pull-up network and the 300 ns Fast-mode
rise-time criterion. The YENJI array adds at most 0.8 pF from each protected I/O to ground. The table below shows the
unchanged Cbus limit and the small fraction consumed by the ESD array alone.

Case                               Req (kOhm)            Cbus max (pF)               After 0.8 pF TVS only (pF)         TVS share

PCB + SHT3x                               1.935                     182.9                            182.1                     0.437%

PCB + OLED                                1.589                     222.9                            222.1                     0.359%

PCB + SHT3x + OLED                        1.371                     258.3                            257.5                     0.310%



Conservative leakage check: treating the datasheet maximum 0.5 uA as line leakage against the 2.4 kOhm PCB pull-up gives
only 1.2 mV worst-case DC shift. No change is required to the 2.4 kOhm pull-ups, 47 Ohm series resistors, I2C2 pin assignment,
or 100 kHz operating target.

3. Package / schematic control
Use the YENJI pin diagram and package drawing as the library source: pins 1/6 are I/O1, pins 3/4 are I/O2, pin 2 is GND, and pin
5 is VCC. Suggested land pattern data from the datasheet: pitch P = 0.95 mm, pad X = 0.60 mm, pad Y = 1.10 mm, G = 1.40 mm,
C = 2.50 mm, Z = 3.60 mm. Schematic/PCB PASS is still forbidden until actual Altium Validate reports Off-grid = 0 and Electrical
errors = 0.

4. Procurement / incoming inspection
Iran source check: Aftab Rayaneh has an active USBLC62SC6-SOT23 product page; the retrieved page snapshot shows stock =
45. The supplier page does not explicitly identify YENJI as manufacturer, so purchase acceptance is conditional on incoming
marking/package verification against the YENJI datasheet: top mark 0552S, SOT23-6, correct pin-1 dot/marking.
Supplier URL: https://shop.aftabrayaneh.com/usblc62sc6-sot23-aftab.html

Project manufacturer source: yenji-elec-usblc6-2sc6_c323793_zc5b.pdf (YENJI Elec, 4 pages).

Release effect: D_ESD source/manufacturer updated; sensor I2C architecture unchanged. Architecture/BOM source correction = PASS. Physical
incoming-part verification = PENDING. Schematic Validation = NOT STARTED / NOT PASSED. No ECO / Update PCB is authorized by this revision.

[PDF PAGE BREAK]
‫‪STM32G070 DATA LOGGER / INTERFACE FINALIZATION‬‬




                       ‫نهایی‌سازی بلوک ‪ OLED‬و سنسور خارجی ‪SHT3x‬‬
                     ‫‪ — Rev-A v1.2‬همگام‌سازی با ‪ STM32G070KBT6‬و ‪ Pin Map‬جدید‬



 ‫وضعیت ‪Release — Electrical BOM Locked / MCU Pin Assignment Updated / Mechanical Qualification‬‬

 ‫‪Pending / Schematic Not Yet Validated‬‬




                       ‫پارامتر‬                                                 ‫مقدار‬

                        ‫‪MCU‬‬                                           ‫‪STM32G070KBT6 / LQFP-32‬‬


                    ‫سطح منطقی‬                                                   ‫‪3.3 V‬‬


                         ‫‪I²C‬‬                                           ‫‪Standard-mode / 100 kHz‬‬


                  ‫طول کابل سنسور‬                                             ‫حدود ‪m 1‬‬


                        ‫‪OLED‬‬                           ‫ماژول موجود ‪ 4P V1.0-12864-0.96‬روی ‪Main PCB‬‬


                       ‫سنسور‬                           ‫ماژول خارجی موجود خانواده ‪SHT3x‬‬


                    ‫کانکتور سنسور‬                      ‫فلزی گرد ‪ 6‬پین موجود کاربر‪ ،‬پنلی‪/‬سرکابلی‬

                       ‫‪Altium‬‬                                              ‫‪26.8.1 Build 31‬‬




 ‫‪ Delta‬نسبت به ‪ — v1.1‬معماری الکتریکی‪ ،‬مقادیر‪MPN ،‬ها و ‪ BOM‬تاییدشده قبلی تغییر نکرده‌اند‪ .‬فقط ‪ MCU‬از‬

 ‫‪ G030‬به ‪ G070‬همگام شده‪ ،‬پایه‌های ‪ I²C/OLED_CTL‬قفل شده و قواعد ‪ Errata‬مرتبط با ‪ I²C‬به سند اضافه شده‌اند‪.‬‬




 ‫قاعده ‪ — Release‬این ‪ PDF‬فقط معماری‪ BOM ،‬و ‪ Pin Assignment‬را قفل می‌کند‪ PASS .‬شماتیک فقط پس از‬

  ‫‪ Validate‬واقعی ‪ Altium‬با ‪ Off-grid=0‬و ‪ Electrical errors=0‬معتبر است؛ تا آن زمان هیچ ‪ ECO‬یا ‪Update PCB‬‬

 ‫مجاز نیست‪.‬‬

[PDF PAGE BREAK]
‫‪ .1‬سخت‌افزار موجود و تصمیم‌های قفل‌شده‬

  ‫• ماژول سنسور موجود با برچسب ‪ SHT3X‬و پایه‌های ‪ VIN / GND / SCL / SDA‬استفاده می‌شود؛ مقاومت‌های کد ‪103‬‬

  ‫روی ماژول به‌عنوان ‪Pull-up‬های تقریبی ‪ kΩ 10‬در نظر گرفته می‌شوند‪.‬‬

  ‫• ماژول ‪ OLED‬موجود روی ‪ PCB‬اصلی نصب می‌شود؛ چاپ پایه‌های روی ماژول ‪ SDA / SCK / VDD / GND‬است و‬

  ‫‪ SCK‬این ماژول همان ‪ SCL‬باس ‪ I²C‬است‪.‬‬

   ‫• از عکس‌ها ‪ MPN‬دقیق ‪ IC‬داخلی ‪ OLED‬یا گونه دقیق ‪ SHT30/SHT31/SHT35‬قابل اثبات نیست؛ بنابراین هر دو‬

  ‫ماژول در ‪ BOM‬به‌صورت ‪ Existing Assembly‬ثبت می‌شوند‪.‬‬


‫‪ Pin Assignment .2‬جدید روی ‪STM32G070KBT6‬‬

         ‫‪Net‬‬                      ‫‪GPIO‬‬           ‫‪ Pin‬فیزیکی‬          ‫‪Peripheral/Mode‬‬        ‫وضعیت‬

       ‫‪I2C_SCL‬‬                    ‫‪PA11‬‬               ‫‪22‬‬                 ‫‪I2C2_SCL‬‬            ‫‪LOCK‬‬


       ‫‪I2C_SDA‬‬                    ‫‪PA12‬‬               ‫‪23‬‬                 ‫‪I2C2_SDA‬‬            ‫‪LOCK‬‬


      ‫‪OLED_CTL‬‬                    ‫‪PB2‬‬                ‫‪17‬‬                ‫‪GPIO Output‬‬          ‫‪LOCK‬‬




 ‫تطبیق رسمی ‪ — MCU‬در ‪ DS12766 Rev.3، PA11‬به ‪ I2C2_SCL‬و ‪ PA12‬به ‪ I2C2_SDA‬نگاشت می‌شوند‪ .‬در ‪LQFP32‬‬

 ‫نیز ‪ PB2‬پین فیزیکی ‪ 17‬است و در این بلوک به‌عنوان ‪ GPIO‬ساده برای ‪ OLED_CTL‬استفاده می‌شود‪.‬‬




  ‫‪ Remap — Remap‬اختیاری ‪ PA9/PA10‬به جای ‪ PA11/PA12‬در ‪ Rev-A‬فعال نمی‌شود؛ ‪ PA9/PA10‬برای ‪ USART1‬و‬

 ‫توسعه ‪ IoT‬رزرو می‌مانند‪.‬‬




‫‪ 2.1‬پارامترهای نهایی باس ‪I²C‬‬


                        ‫پارامتر‬                                                ‫مقدار‬


                     ‫فرکانس باس‬                                               ‫‪100 kHz‬‬


                 ‫‪ Pull-up‬اصلی هر خط‬                                            ‫‪2.4 kΩ‬‬


            ‫مقاومت سری فقط شاخه سنسور‬                                          ‫‪47 Ω‬‬

[PDF PAGE BREAK]
                          ‫پارامتر‬                                                    ‫مقدار‬


                      ‫سطح باس و تغذیه‬                                                ‫‪3.3 V‬‬




‫‪ .3‬محاسبه ‪ Pull-up‬و حاشیه باس ‪I²C‬‬

‫‪Pull-up‬های اصلی ‪ SCL/SDA‬روی ‪ PCB‬برابر ‪ kΩ 2.4‬هستند‪ Pull-up .‬ماژول ‪ SHT3x‬از روی کد ‪ 103‬تقریبًا ‪ kΩ 10‬و ‪Pull-‬‬

‫‪ up‬ماژول ‪ OLED‬موجود حدود ‪ kΩ 4.7‬در نظر گرفته شده است‪ .‬این مقاومت‌ها هنگام اتصال هر شاخه به‌صورت موازی‬

‫عمل می‌کنند‪.‬‬


           ‫حالت‬                     ‫‪ R‬معادل ‪Pull-up‬‬         ‫جریان ‪ LOW‬با ‪VOL=0.4 V‬‬           ‫‪ Cbus‬متناظر با ‪tr=300 ns‬‬


        ‫‪PCB + SHT3x‬‬                     ‫‪1.935 kΩ‬‬                    ‫‪1.50 mA‬‬                          ‫‪183‬‬
                                                                                                     ‫‪p F‬‬


         ‫‪PCB + OLED‬‬                     ‫‪1.589 kΩ‬‬                    ‫‪1.83 mA‬‬                         ‫‪≈223 pF‬‬


     ‫‪PCB + SHT3x + OLED‬‬                 ‫‪1.371 kΩ‬‬                    ‫‪2.12 mA‬‬                         ‫‪≈258 pF‬‬




  ‫‪t_r ≈ 0.8473 × R_P × C_BUS‬‬




‫دیتاشیت خانواده ‪ SHT3x‬برای ‪ I²C‬زمان ‪ Rise‬حداکثر ‪ ns 300‬در ‪ Fast-mode‬و ظرفیت باس تا ‪ pF 400‬را مبنای طراحی‬

‫قرار می‌دهد‪ .‬بدترین جریان محاسبه‌شده این طراحی حدود ‪ mA 2.12‬است؛ بنابراین ‪ Sink‬جریان ماژول حاشیه مناسب‬

‫دارد‪ .‬ظرفیت واقعی کابل‪/‬کانکتور باید روی نمونه یک‌متری اندازه‌گیری شود‪.‬‬


‫‪ 3.1‬قواعد ‪ Errata‬برای ‪ I²C‬در ‪STM32G070‬‬

   ‫• سرعت واقعی باس همان ‪ kHz 100‬باقی می‌ماند؛ ولی طبق ‪ ES0468 Rev.5‬در ‪Standard-mode، I²C kernel clock‬‬

  ‫باید حداقل ‪ MHz 4‬باشد اگر فرستنده حداقل ‪ setup time‬استاندارد ‪ ns 250‬را داشته باشد‪.‬‬

   ‫• در ‪ Master mode‬ممکن است ‪ BERR‬به‌صورت کاذب ‪ Set‬شود‪ .‬در این حالت ‪ Firmware‬فقط ‪ BERR‬را ‪Clear‬‬

  ‫می‌کند و ‪ Transfer‬جاری ادامه پیدا می‌کند‪.‬‬

   ‫• برای جلوگیری از ‪ ،»Errata «Transmission stalled after first byte transfer‬اولین ‪ TXDR‬قبل از ‪Start preload‬‬

  ‫می‌شود؛ یا در ‪ Clock Tree‬نسبت ‪ APB clock‬به ‪ I²C kernel clock‬خارج بازه ‪ 1.5‬تا ‪ 3‬نگه داشته می‌شود‪.‬‬


  ‫نتیجه — این ‪Errata‬ها هیچ تغییر سخت‌افزاری در ‪ OLED/SHT3x‬ایجاد نمی‌کنند؛ فقط قواعد ‪ Clock Tree‬و‬

[PDF PAGE BREAK]
 ‫‪ Firmware‬هستند‪.‬‬




‫‪ .4‬بلوک نهایی سنسور خارجی ‪SHT3x‬‬

 ‫‪3V3_SYS -- FB_SENSOR (220 ohm @100MHz) -- 3V3_SENSOR ----+---- sensor VIN‬‬
                                                          ‫|‬
                                                       ‫‪100nF + 10uF‬‬
                                                          ‫|‬
                                                         ‫‪GND‬‬

 ‫‪PA11 / I2C2_SCL -- 47R -- ESD CH1 -------------------------- SCL_SENSOR‬‬
 ‫‪PA12 / I2C2_SDA -- 47R -- ESD CH2 -------------------------- SDA_SENSOR‬‬
 ‫‪Main I2C pull-ups: SCL/SDA -> 3V3_SYS through 2.4k each‬‬
 ‫‪Cable: about 1 m / shielded 6-core / metal 6-pin connector‬‬




‫‪ 4.1‬تخصیص شش رشته کابل‬


          ‫وظیفه منطقی‬                         ‫رنگ پیشنهادی‬                           ‫توضیح‬


           ‫‪SENSOR_3V3‬‬                             ‫قرمز‬                       ‫تغذیه سنسور پس از فریت‬

            ‫‪PWR_GND‬‬                              ‫مشکی‬                             ‫برگشت تغذیه‬

           ‫‪SCL_SENSOR‬‬                             ‫سفید‬                              ‫کالک ‪I²C‬‬


             ‫‪SCL_GND‬‬                               ‫زرد‬                        ‫برگشت نزدیک برای ‪SCL‬‬


           ‫‪SDA_SENSOR‬‬                              ‫آبی‬                              ‫داده ‪I²C‬‬


            ‫‪SDA_GND‬‬                                ‫سبز‬                        ‫برگشت نزدیک برای ‪SDA‬‬




‫سه سیم ‪ GND‬در ‪ PCB‬و انتهای سنسور به ‪ GND‬سیستم مشترک وصل می‌شوند‪ .‬این تخصیص به‌دلیل آن است که کابل ‪6‬‬

‫رشته انتخابی لزومًا زوج‌تابیده تضمین‌شده نیست؛ مسیرهای برگشت نزدیک‪ ،‬سطح حلقه را کاهش می‌دهند‪ .‬شیلد‪Drain/‬‬

‫به پوسته فلزی کانکتور متصل و در سمت دستگاه از طریق لینک ‪ Ω 0‬به ‪ GND‬وصل می‌شود؛ سمت سنسور شیلد به ‪GND‬‬

‫ماژول وصل نمی‌شود‪.‬‬


 ‫شماره‌گذاری کانکتور — شماره فیزیکی شش پین از عکس قفل نمی‌شود‪ .‬هنگام ساخت ‪ ،Harness‬زوج نری‪/‬مادگی با‬

 ‫‪ Continuity‬مولتی‌متر شماره‌گذاری و سپس نقشه ‪ Harness‬نهایی آزاد می‌شود‪.‬‬

[PDF PAGE BREAK]
‫‪ 4.2‬کابل‬

‫انتخاب قبلی کابل نمونه حفظ می‌شود‪ ،mm² / AWG24 0.25×6 :‬هادی افشان مس قلع‌اندود‪ ،‬فویل ‪ +‬شیلد بافته‪ ،‬قطر‬

‫خارجی حدود ‪ .mm 6.00‬شرط مکانیکی قبل از خرید‪/‬مونتاژ نهایی‪ :‬دهانه واقعی بست کانکتور سرکابلی باید با کولیس‬

‫اندازه‌گیری شود و ‪ OD‬کابل داخل آن جا شود‪.‬‬


‫‪ .5‬حفاظت و فیلتر شاخه سنسور — ‪ BOM‬بدون تغییر‬


           ‫‪.Ref‬‬              ‫‪ MPN‬دقیق‬               ‫پکیج‬                   ‫وظیفه‬               ‫‪Qty/PCB‬‬



                                                                  ‫‪،Ω @100 MHz 220‬‬
      ‫‪FB_SENSOR‬‬           ‫‪BLM21PG221SN1D‬‬            ‫‪0805‬‬                                          ‫‪1‬‬
                                                                  ‫فیلتر تغذیه سنسور‬

           ‫‪D_ESD‬‬            ‫‪USBLC6-2SC6‬‬           ‫‪SOT-23-6‬‬         ‫‪ ESD‬دو خط ‪SCL/SDA‬‬              ‫‪1‬‬



                                                                  ‫‪ Ω ±1% 47‬سری شاخه‬
 ‫‪R_SCL_SER / R_SDA_SER‬‬     ‫‪0603WAF470JT5E‬‬           ‫‪0603‬‬                                          ‫‪2‬‬
                                                                         ‫سنسور‬


                                                                    ‫‪kΩ ±1% Pull-up 2.4‬‬
  ‫‪R_SCL_PU / R_SDA_PU‬‬      ‫‪0603WAF2401T5E‬‬           ‫‪0603‬‬                                          ‫‪2‬‬
                                                                           ‫اصلی‬

     ‫‪C_SENSOR_HF‬‬          ‫‪CL10B104KB8NNNC‬‬           ‫‪0603‬‬              ‫‪100 nF 50 V X7R‬‬             ‫‪1‬‬


    ‫‪C_SENSOR_BULK‬‬        ‫‪GRM21BR61E106KA73L‬‬         ‫‪0805‬‬              ‫‪10 µF 25 V X5R‬‬              ‫‪1‬‬



                                                                  ‫‪ ،Ω 0‬اتصال‬

       ‫‪R_SHIELD‬‬              ‫‪SER0603J0R‬‬             ‫‪0603‬‬          ‫‪ SHIELD‬سمت‬      ‫‪↔GND‬‬            ‫‪1‬‬


                                                                  ‫دستگاه‬




 ‫محدوده ‪ — Revision‬هیچ‌یک از ‪MPN‬ها یا مقادیر این صفحه در ‪ v1.2‬تغییر نکرده‌اند؛ این صفحه از ‪ Release‬الکتریکی‬

 ‫‪ v1.1 Carry Forward‬شده است‪.‬‬




‫‪ 5.1‬قواعد ‪ Layout‬برای این شاخه‬


   ‫• ‪ USBLC6-2SC6‬باید نزدیک ورودی کانکتور خارجی قرار گیرد و مسیر برگشت ‪ ESD‬به ‪ Ground Plane‬کوتاه و مستقیم‬

  ‫باشد‪.‬‬

[PDF PAGE BREAK]
  ‫• ‪Ω 47‬ها بعد از ناحیه حفاظت و قبل از ورود باس به ناحیه داخلی ‪ PCB‬قرار گیرند‪.‬‬

  ‫• ‪ nF 100‬و ‪ µF 10‬تغذیه سنسور در سمت ‪ PCB‬و نزدیک خروجی ‪ 3V3_SENSOR‬قرار گیرند‪.‬‬


‫‪ .6‬بلوک نهایی ‪ OLED‬روی ‪ PCB‬اصلی‬


‫برای کاهش مصرف باتری‪ Gate-Power OLED ،‬حفظ می‌شود‪ .‬برای جلوگیری از ‪ Back-power‬از مسیر ‪ ،SCL/SDA‬دو کانال‬

‫‪ 74HC4066‬خطوط ‪ I²C‬را هنگام خاموشی نمایشگر قطع می‌کنند‪ .‬انتخاب اول خرید همان ‪ 74HC4066D,653‬از ‪Nexperia‬‬

‫است؛ ‪ MC74HC4066ADG/ADR2G‬جایگزین تاییدشده و ‪ HEF4066BT,653 Fallback‬قابل قبول باقی می‌ماند‪.‬‬

 ‫)‪3V3_SYS -------- Source Q_OLED (AO3401A‬‬
                   ‫‪Drain ---- OLED_VDD ---- 10uF + 100nF‬‬
                   ‫‪Gate‬‬
                     ‫|‬
                   ‫‪100k to 3V3‬‬
                     ‫|‬
              ‫‪Collector BC847B‬‬
 ‫‪PB2 / OLED_CTL --10k-- Base‬‬     ‫‪Emitter -- GND‬‬
                     ‫|‬
                   ‫‪100k‬‬
                     ‫|‬
                    ‫‪GND‬‬

 ‫‪PA11 / I2C2_SCL -- 74HC4066 CH1 -- OLED_SCK‬‬
 ‫‪PA12 / I2C2_SDA -- 74HC4066 CH2 -- OLED_SDA‬‬
 ‫‪OLED_CTL --47k-- OLED_BUS_EN --> CH1/CH2 enable‬‬
                  ‫|‬
                ‫‪100nF‬‬
                  ‫|‬
                 ‫‪GND‬‬
 ‫‪D_DELAY 1N4148WS: anode=OLED_BUS_EN, cathode=OLED_CTL‬‬




‫‪ 74HC4066‬از ‪ 3V3_SYS‬تغذیه می‌شود و ‪ Enable‬آن ‪ High-Active‬است‪ .‬دو کانال استفاده‌نشده ‪ Enable=GND‬خواهند‬

‫داشت‪ RC .‬با ‪ kΩ 47‬و ‪ nF 100‬ثابت زمانی ‪ ms 4.7‬ایجاد می‌کند؛ هنگام خاموشی‪ ،‬دیود خازن ‪ Enable‬را سریع تخلیه‬

‫می‌کند تا باس قبل از افت تغذیه ‪ OLED‬جدا شود‪.‬‬


  ‫‪ — Firmware‬پس از ‪ OLED_CTL=1‬حداقل ‪ ms 10‬قبل از اولین تراکنش ‪ I²C‬به ‪ OLED‬صبر شود‪ .‬قبل از خاموشی‪،‬‬

 ‫تراکنش ‪ I²C‬متوقف و سپس ‪ OLED_CTL=0‬شود‪.‬‬




 ‫‪ Pin‬جدید — در ‪ Rev-A v1.2، OLED_CTL‬روی ‪ PB2 / pin 17‬قرار دارد‪ .‬رفتار ‪ Power/Bus sequencing‬نسبت به ‪v1.1‬‬

 ‫هیچ تغییری نکرده است‪.‬‬

[PDF PAGE BREAK]
BOM ‫ و‬OLED ‫ اتصال ماژول‬.7

‫ ارتفاع‬.‫ است‬PBS-2.54-1X4GF ‫ قفل‌شده‬THT، 1×4، Pitch 2.54 mm. SKU/MPN ‫ هدر مادگی صاف‬:PCB ‫کانکتور روی‬

.‫ و مختصات سوراخ‌های نصب ماژول باید با نمونه واقعی و کولیس کنترل شوند‬Socket ‫دقیق‬


           OLED ‫چاپ روی‬                       PCB ‫ روی‬Net                                 ‫توضیح‬


                  GND                              GND                                     ‫زمین‬

                  VDD                          OLED_VDD                            ‫ سوئیچ‌شونده‬V 3.3

                   SCK                          OLED_SCL                                  I²C ‫کالک‬


                   SDA                          OLED_SDA                                  I²C ‫داده‬




‫ — بدون تغییر‬BOM OLED 7.1


         .Ref                    MPN              ‫پکیج‬                  ‫وظیفه‬                        Qty



       J_OLED                PBS-2.54-1X4GF      THT 1×4         OLED ‫سوکت ماژول‬                      1



                                                                SCL/SDA ‫ایزوالسیون‬
     U_OLED_SW               74HC4066D,653    SO14 / SOT108-1                                         1
                                                                ‫— انتخاب اول‬

                         MC74HC4066ADG /
    ALT-U_OLED_SW                                SOIC-14           onsemi ‫جایگزین‬                    ALT
                         MC74HC4066ADR2G


   ALT2-U_OLED_SW            HEF4066BT,653         SO14           V 3.3 ‫ در‬Fallback                  ALT


       Q_OLED                  AO3401A            SOT-23         High-side power switch               1


     Q_OLED_DRV                 BC847B            SOT-23           Gate PMOS ‫درایو‬                    1


       R_BASE               CR0603FA1002G          0603                10 kΩ ±1%                      1


  R_GATE / R_BASE_PD        0603WAF1003T5E         0603               100 kΩ ±1%                      2


       R_DELAY              0603WAF4702T5E         0603                47 kΩ ±1%                      1


       D_DELAY                 1N4148WS          SOD-323         Fast discharge Enable                1


   C_DELAY / C_4066        CL10B104KB8NNNC         0603                 100 nF                        2


     C_OLED_BULK         GRM21BR61E106KA73L        0805         OLED_VDD ‫ روی‬µF 10                    1

[PDF PAGE BREAK]
 ‫قانون خرید ‪ — 4066‬فقط یک خانواده برای ‪ OLED‬تهیه شود‪ .‬ترتیب ترجیح → ‪Rev-A: 74HC4066D,653‬‬

  ‫‪ .MC74HC4066ADG/ADR2G → HEF4066BT,653‬مارک کوتاه بدنه به‌تنهایی برای قفل ‪ MPN‬کافی نیست‪.‬‬




‫‪ .8‬فهرست خرید تجمیعی ‪OLED + SHT3x‬‬

‫موجودی بازار این بلوک در ‪ Release v1.1‬در تاریخ ‪ 08-08-2026‬بررسی شده بود‪ .‬چون ‪ v1.2‬فقط ‪ MCU/Pin Map‬را تغییر‬

‫می‌دهد‪ BOM ،‬خرید همان ‪ Release‬بدون تغییر ‪ Carry Forward‬می‌شود؛ موجودی و قیمت در لحظه ‪ Checkout‬باید‬

‫دوباره کنترل شوند‪.‬‬


          ‫اولویت‬                   ‫کاال ‪MPN /‬‬            ‫تعداد خرید پیشنهادی‬                ‫یادداشت‬


                                                                                 ‫انتخاب اول ‪OLED‬؛ ‪MPN‬‬


             ‫‪A‬‬                   ‫‪74HC4066D,653‬‬                    ‫‪3‬‬              ‫کامل ‪ Nexperia‬هنگام خرید‬

                                                                                 ‫تایید شود‬


                           ‫‪MC74HC4066ADG /‬‬                                       ‫جایگزین‪ ،‬نه عالوه بر ردیف‬
            ‫‪ALT‬‬                                        ‫‪ 3‬در صورت نبود ‪Nexperia‬‬
                           ‫‪MC74HC4066ADR2G‬‬
                                                                                 ‫باال‬

            ‫‪ALT2‬‬                 ‫‪HEF4066BT,653‬‬         ‫‪ 3‬فقط در صورت نبود ‪HC‬‬                  ‫‪Fallback‬‬



                                                                                 ‫‪ ESD‬کم‌ظرفیت؛ بخشی برای‬
             ‫‪A‬‬                    ‫‪USBLC6-2SC6‬‬                     ‫‪5‬‬
                                                                                 ‫کل پروژه‬

             ‫‪A‬‬                  ‫‪BLM21PG221SN1D‬‬                    ‫‪5‬‬                         ‫‪Ferrite 0805‬‬


             ‫‪A‬‬                   ‫‪PBS-2.54-1X4GF‬‬                   ‫‪5‬‬                         ‫‪Socket OLED‬‬


             ‫‪A‬‬                   ‫‪0603WAF470JT5E‬‬                  ‫‪100‬‬                    ‫‪ Ω 47‬شاخه سنسور‬

             ‫‪A‬‬                   ‫‪0603WAF2401T5E‬‬                  ‫‪100‬‬                    ‫‪ kΩ Pull-up 2.4‬اصلی‬

             ‫‪A‬‬                   ‫‪0603WAF4702T5E‬‬                  ‫‪100‬‬                      ‫‪47 kΩ OLED delay‬‬


             ‫‪A‬‬                     ‫‪1N4148WS‬‬                      ‫‪25‬‬                           ‫‪SOD-323‬‬


             ‫‪A‬‬                  ‫‪CL10B104KB8NNNC‬‬             ‫≥‪ 50‬کل پروژه‬                 ‫‪ nF 100‬مشترک‬

             ‫‪A‬‬                ‫‪GRM21BR61E106KA73L‬‬            ‫≥‪ 25‬کل پروژه‬                  ‫‪ µF 10‬مشترک‬

[PDF PAGE BREAK]
          ‫اولویت‬                        ‫کاال ‪MPN /‬‬            ‫تعداد خرید پیشنهادی‬                ‫یادداشت‬


             ‫‪A‬‬                        ‫‪CR0603FA1002G‬‬              ‫‪ 100‬کل پروژه‬                   ‫‪ kΩ 10‬مشترک‬

             ‫‪A‬‬                        ‫‪0603WAF1003T5E‬‬             ‫‪ 100‬کل پروژه‬               ‫‪ kΩ 100‬مشترک‬

             ‫‪A‬‬                          ‫‪SER0603J0R‬‬               ‫‪ 100‬کل پروژه‬                   ‫‪ Ω 0‬مشترک‬




 ‫موجود کاربر — ‪ ،AO3401A / BC847B‬خود ماژول ‪ ،OLED‬ماژول ‪ SHT3x‬و کانکتور فلزی ‪ 6‬پین موجودند و در این‬

 ‫‪ Revision‬خرید مجدد الزامی ندارند‪.‬‬




‫‪ .9‬موارد مکانیکی باز — نه ‪ BOM‬الکتریکی‬


  ‫• طول و عرض دقیق ‪ PCB‬ماژول ‪ OLED‬با کولیس ثبت شود‪.‬‬

  ‫• مختصات مرکز سوراخ‌های نصب ‪ ،OLED‬قطر سوراخ‌ها و ارتفاع ماژول پس از نصب روی ‪ Socket‬اندازه‌گیری شود‪.‬‬

  ‫• قطر رزوه‪/‬مدل دقیق کانکتور فلزی ‪ 6‬پین و حداکثر قطر کابل قابل عبور از گلند اندازه‌گیری شود‪.‬‬

  ‫مادگی ثبت شود‪.‬‬   ‫شش پین نری ↔‬        ‫• ‪Continuity mapping‬‬

  ‫• در صورت استفاده از ‪/Housing‬دسته‌سیم داخلی دیگر‪ Drawing ،‬سازنده و نمونه واقعی قبل از‬

  ‫‪ Footprint/Assembly‬تطبیق داده شود‪.‬‬


 ‫اثر بر ‪ — Release‬این اندازه‌ها ‪ BOM‬الکتریکی را باز نمی‌کنند؛ فقط ‪ Footprint‬مکانیکی‪ Hole pattern، Courtyard ،‬و‬

 ‫‪ Assembly Drawing‬را تعیین می‌کنند‪.‬‬




‫‪ 9.1‬معیارهای آزمون نمونه‬


                           ‫آزمون‬                                                    ‫معیار‬


                     ‫‪ I²C‬در ‪kHz 100‬‬                       ‫‪ OLED‬روشن و سنسور متصل بدون خطای باس‬


                 ‫‪ Rise Time‬در سر سنسور‬                    ‫≤ ‪ ns 300‬در معیار طراحی فعلی‬


                                                          ‫حداقل ‪ 10,000‬خواندن متوالی بدون خطای پروتکل‪ CRC/‬در‬
                           ‫‪SHT3x‬‬
                                                          ‫صورت پشتیبانی ماژول‬

[PDF PAGE BREAK]
                                    ‫آزمون‬                                                                     ‫معیار‬


                                  m 1 ‫کابل‬                                        ‫بدون خطای ارتباط در شرایط واقعی‬


                                ‫نویز محیطی‬                                        ‫منبع نویز‬/‫کابل برق‬/‫تست نزدیک رله‬

                                Hot-plug/ESD                                      MCU ‫ ناخواسته‬Reset ‫بدون قفل شدن یا‬



                                                                                   ‫ قابل‬Back-power ‫ واقعًا ایزوله و بدون‬OLED ‫ سمت‬SDA/SCL
                                  OLED OFF
                                                                                  ‫مشاهده‬

                              OLED sequencing                                     OFF ‫ در‬Power ‫ سپس‬Bus ‫؛‬ON ‫ در‬Bus ‫ سپس‬Power



                                    Altium                                        ECO/Update PCB ‫ پیش از هر‬Electrical errors = 0 ‫ و‬Off-grid = 0




    ‫ در محیط نویزی باید روی نمونه واقعی تایید‬m 1 ‫ مستقیم روی کابل حدود‬I²C ‫ — رابط‬Qualification ‫محدودیت‬

   .‫ یا رابط تفاضلی بررسی می‌شود‬Extender Bus ‫ بعدی‬Revision ‫ در‬،‫ یا نرخ خطا معیارها را رد کند‬Rise Time ‫ اگر‬.‫شود‬




‫ منابع رسمی و مرجع‬.10

1. STMicroelectronics — STM32G070CB/KB/RB datasheet, DS12766 Rev.3:
https://www.st.com/resource/en/datasheet/stm32g070kb.pdf
2. STMicroelectronics — STM32G070 device errata, ES0468 Rev.5: https://www.st.com/resource/en/errata_sheet/es0468-
stm32g070cbkbrb-device-errata-stmicroelectronics.pdf
3. Sensirion — SHT3x-DIS datasheet: https://sensirion.com/media/documents/213E6A3B/63A5A569/Datasheet_SHT3x_DIS.pdf
4. NXP — UM10204 I2C-bus specification and user manual: https://www.nxp.com/docs/en/user-guide/UM10204.pdf
5. Nexperia — 74HC4066D: https://www.nexperia.com/product/74HC4066D
6. onsemi — MC74HC4066A datasheet: https://www.onsemi.com/pdf/datasheet/mc74hc4066a-d.pdf
7. Nexperia - HEF4066BT: https://www.nexperia.com/product/HEF4066BT
8. YENJI Elec - USBLC6-2SC6 manufacturer datasheet; SOT23-6; top mark 0552S.

9. Murata — BLM21PG221SN1D: https://pim.murata.com/en-us/pim/search/?partNum=BLM21PG221SN1D
10. AOSMD — AO3401A: https://www.aosmd.com/products/mosfets/p-channel-mosfets-8v-60v/ao3401a
11. Nexperia — BC847B: https://www.nexperia.com/product/BC847B
12. Solomon Systech — SSD1306 family page: https://www.solomon-systech.com/product/ssd1306


v1.1 ‫ از‬Carry Forward ‫ منابع بازار‬10.1

    Lion Electronic — PBS-2.54-1X4GF / BLM21PG221SN1D / 0603WAF470JT5E / CL10B104KB8NNNC / •

    GRM21BR61E106KA73L

   Aftab Rayaneh - USBLC62SC6-SOT23; active Iran listing. Incoming mark 0552S must be verified.




    Matrix Cable — shielded 6-core AWG24 candidate •

[PDF PAGE BREAK]
 ‫ یک بار‬Checkout ‫ و تعداد خرید باید هنگام‬MPN، Package .‫یادآوری بازار — موجودی و قیمت بازار ایران پویا است‬

 .‫دیگر کنترل شوند‬




Release v1.2 ‫ وضعیت نهایی‬.11

                          ‫موضوع‬                                                   ‫نتیجه‬

                      MCU integration                                    PASS — STM32G070KBT6


                          I²C pins                       PA12/pin23 = I2C2_SDA ‫ ؛‬PASS — PA11/pin22 = I2C2_SCL


                       OLED control                                   PASS — PB2/pin17 = OLED_CTL


               I²C electrical architecture                                  v1.1 ‫بدون تغییر از‬


                SHT3x cable protection                                      v1.1 ‫بدون تغییر از‬


                    OLED power isolation                                    v1.1 ‫بدون تغییر از‬


                       Electrical BOM                                    LOCKED / Carry Forward


                Mechanical qualification                                        PENDING


                         Schematic                                   NOT STARTED / NOT VALIDATED


                          PCB/ECO                        PROHIBITED until schematic PASS




 ‫ با‬MCU/Pin Assignment ‫ در بخش‬Supersedes — Datalogger_OLED_SHT3x_Final_BOM_RevA_v1.1_FA.pdf

 .‫ تاییدشده آن بدون دلیل فنی تغییر نکرده‌اند‬BOM ‫ تصمیم‌های الکتریکی و‬.‫این سند جایگزین می‌شود‬




 ،‫ کل دستگاه‬BOM ‫ پس از پایان‬.‫ نیست‬Update PCB/‫ نهایی پروژه — این سند به‌تنهایی مجوز طراحی‬PASS ‫معیار‬

 Electrical ‫ و‬Off-grid=0 ‫ شود؛ فقط‬Validate ‫ ساخته و‬Altium Designer 26.8.1 Build 31 ‫شماتیک باید در‬

 .‫ پذیرفته می‌شود‬PASS ‫ به‌عنوان‬errors=0




                                             END OF RELEASE DOCUMENT

[PDF PAGE BREAK]

```

## Datalogger_MCU_Core_SWD_Reset_Clock_Final_BOM_RevA_v2.1_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_MCU_Core_SWD_Reset_Clock_Final_BOM_RevA_v2.1_FA.pdf`  
PDF/source SHA256: `3ee9cf3ac434f4cb3aacd361a6ce4206a5e4bb96bf656224cce69d117ff54758`

```text
STM32G070 DATA LOGGER / MCU CORE FINALIZATION




              ‫ و‬MCU Core، Clock، SWD ‫نهاییسازی‬
                                        Reset
                           ‫ خرید و قواعد پیادهسازی‬Rev-A v2.1 - STM32G070KBT6 / LQFP-32 / BOM

       Electrical Architecture + Purchase BOM Locked / Schematic Not Yet Validated / PCB ECO
                                                                                                     Prohibited



                                                  MCU                                                   Package
  STM32G070KBT6                                              LQFP-32, 7 x 7 mm, 0.8 mm pitch


                                          Clock Rev-A                                                  Debugger
  HSI16 nominal 16 MHz; no HSE/LSE populated                 ST-LINK via SWD, 1x5 service header


                                        Reset switch                                                 Target CAD
  B3F-4055, on main PCB                                      Altium Designer 26.8.1 Build 31


                     Delta v2.1 vs v2.0 - Pin Map synchronization only (Navigation v1.0 + RTC v1.2):
             PB3/pin27 = RTC_INT_N; PB4/pin28 = KEY_DOWN; PB5/pin29 = KEY_SET; PB8/pin32 = KEY_BACK.
                       MCU electrical core, Clock, SWD/Reset and BOM carry forward unchanged.




     Validate ‫ شماتیک فقط پس از‬PASS .‫ قطعات و الزامات طراحی را قفل میکند‬،‫ فقط معماری‬PDF ‫ این‬:‫ پروژه‬Release ‫قاعده‬
             .‫ مجاز نیست‬ECO ‫ یا‬Update PCB ‫ تا آن زمان هیچ‬.‫ است‬Electrical errors = 0 ‫ و‬Off-grid = 0 ‫ با‬Altium ‫واقعی‬


Rev-A v2.1                                                                                                2026-08-09

[PDF PAGE BREAK]
                                                            ‫‪ .1‬معماری تغذیه ‪ MCU‬و ‪Decoupling‬‬

  ‫‪3V3_SYS ------------------------ pin 4‬‬                ‫‪VDD/VDDA‬‬
     ‫‪|-- C_MCU_HF‬‬        ‫‪100 nF ------- GND‬‬
     ‫‪`-- C_MCU_BULK 4.7 uF ------- GND‬‬


  ‫‪GND ---------------------------- pin 5‬‬                ‫‪VSS/VSSA‬‬


  ‫‪Package note:‬‬
  ‫‪VBAT pin‬‬          ‫‪: not available in LQFP32 -> internally bonded to VDD/VDDA‬‬
  ‫‪VREF+ pin‬‬         ‫‪: not available in LQFP32 -> internally connected to VDD‬‬
  ‫‪VREFBUF‬‬           ‫‪: MUST remain disabled‬‬


 ‫برای زوج تغذیه مشترک ‪ ،VDD/VDDA - VSS/VSSA‬خود ‪ ST‬استفاده از ‪ 1 x 100 nF + 1 x 4.7 uF‬و قرارگیری بسیار نزدیک به پایهها را‬
‫الزام‪/‬توصیه میکند‪ .‬در ‪ LQFP-32‬پایه ‪ 4‬تغذیه و پایه ‪ 5‬زمین مشترک دیجیتال‪/‬آنالوگ هستند‪[ST-DS: DS12766 Rev.3, Power supply; ST- .‬‬
                                                                                                                       ‫]‪AN: AN5096 Rev.4‬‬


                   ‫کارکرد و ‪Placement‬‬                   ‫‪Package‬‬                                   ‫‪ / MPN‬مقدار‬                         ‫‪Ref‬‬

  ‫نزدیکترین خازن به ‪ ،pin 4/5‬مسیر برگشت‬                               ‫‪CL10B104KB8NNNC / 100 nF, 50 V,‬‬
                                                     ‫‪0603‬‬                                                          ‫‪C_MCU_HF‬‬
                         ‫‪ GND‬بسیار کوتاه‬                              ‫‪X7R, ±10%‬‬

                                                                      ‫‪C2012X5R1E475K125AB / 4.7 uF, 25‬‬
      ‫کنار ‪ MCU‬و روی همان ریل ‪3V3_SYS‬‬                ‫‪0805‬‬                                                          ‫‪C_MCU_BULK‬‬
                                                                      ‫‪V, X5R, ±10%‬‬


    ‫نتیجه‪ :‬رگوالتور محلی جدید برای ‪ MCU‬اضافه نمیشود‪ MCU .‬مستقیما ً از ‪ 3V3_SYS‬تغذیه میشود‪ .‬بودجه کل توان کل دستگاه در‬
                                                                                            ‫مرحله تجمیع ‪ BOM‬دوباره کنترل خواهد شد‪.‬‬


                                                                                     ‫‪ 1.1‬اثر مصرف ‪ MCU‬بر معماری تغذیه‬

                  ‫کاربرد طراحی‬                      ‫‪Max @ 85°C‬‬                                    ‫‪Typ‬‬               ‫حالت مرجع دیتاشیت‬

         ‫مبنای عادی ‪Firmware‬‬                   ‫‪mA 3.0‬‬                             ‫‪mA 2.1‬‬                 ‫‪Run, Flash, 16 MHz, Range 1‬‬

 ‫حالت ‪ Burst‬در صورت نیاز واقعی‬                 ‫‪mA 8.4‬‬                             ‫‪mA 7.0‬‬                 ‫‪Run, Flash, 64 MHz, Range 1‬‬


      ‫اعداد جدول در شرایط اندازهگیری دیتاشیت و با ‪peripheral‬های غیرفعال هستند؛ برای بودجه نهایی دستگاه‪ ،‬مصرف ‪peripheral‬ها جداگانه جمع میشود‪.‬‬


‫‪MCU CORE / POWER‬‬                                                                                                                    ‫‪Page 2‬‬

[PDF PAGE BREAK]
                                                                       ‫‪Clock Strategy - Rev-A .2‬‬

        ‫تصمیم قفلشده‪ :‬در ‪ Rev-A‬هیچ کریستال یا اسیالتور خارجی ‪ HSE/LSE‬برای ‪ MCU‬نصب نمیشود‪ System clock .‬پایه از‬
                                             ‫‪ HSI16‬داخلی استفاده میکند‪ RTC .‬دقیق همچنان ‪ DS3231 + CR2032‬خارجی است‪.‬‬


                             ‫تصمیم پروژه‬                     ‫مقدار رسمی ‪STM32G070‬‬                                       ‫پارامتر‬

                            ‫‪ 15.88 ... 16.08 MHz @ 3.0 V, 30°C‬مبنای ‪MHz 16‬‬                                    ‫‪HSI16 nominal‬‬

 ‫برای ‪ clock‬عمومی کافی؛ ‪ UART‬آینده جداگانه‬
                                             ‫‪-1% ... +1%‬‬                                                 ‫‪HSI16 drift, 0...85°C‬‬
                                 ‫چک شود‬

     ‫برای هر ‪ IoT module‬و ‪ baud rate‬باید‬
                                             ‫‪-2% ... +1.5%‬‬                                             ‫‪HSI16 drift, -40...85°C‬‬
                ‫‪ tolerance‬تطبیق داده شود‬

 ‫فقط در صورت نیاز ‪ performance‬به صورت‬
                                             ‫‪up to 64 MHz‬‬                                                         ‫‪PLL output‬‬
                                    ‫‪Burst‬‬


          ‫‪ :PC14 / PC15‬در ‪ LQFP-32‬این دو پایه عالوه بر ‪ ،OSC32‬قابلیت مسیر ‪ oscillator‬خارجی را نیز دارند‪ .‬فعال ً به مدار دیگری‬
       ‫تخصیص داده نمیشوند و بدون قطعه باقی میمانند‪ .‬اگر در ‪ Revision‬آینده‪ ،‬دیتاشیت ماژول ‪ IoT‬نشان دهد ‪ HSI16‬برای دقت‬
                                                 ‫‪ UART‬کافی نیست‪ ،‬همین دو پایه گزینه توسعه ‪ HSE‬خواهند بود‪[ST-DS: Table 11] .‬‬



    ‫‪ :Errata clock/I2C‬سرعت باس ‪ I2C‬همچنان ‪ 100 kHz‬است‪ ،‬اما در ‪ Firmware‬باید ‪ I2C kernel clock >= 4 MHz‬باشد‪.‬‬
                             ‫همچنین ‪ workaround‬رسمی ‪ first-byte/BERR‬که قبال ً برای ‪ ES0468‬ثبت شده رعایت میشود‪.‬‬


                                                                           ‫‪ 2.1‬چرا ‪ HSE‬را ‪ DNP‬هم اضافه نکردیم؟‬
                                                                     ‫• در ‪ Rev-A‬نیاز عملکردی اثباتشدهای برای ‪ HSE‬وجود ندارد‪.‬‬
  ‫• افزودن ‪ footprint‬بدون انتخاب ‪ crystal‬دقیق‪ load capacitance ،‬و ‪ drive-level‬با قانون «بدون حدس» پروژه ناسازگار است‪.‬‬
                                                     ‫• رزرو ‪ PC14/PC15‬امکان بازنگری مهندسی در ‪ Revision‬آینده را حفظ میکند‪.‬‬


‫‪MCU CORE / CLOCK‬‬                                                                                                        ‫‪Page 3‬‬

[PDF PAGE BREAK]
                                                                             SWD ‫ و‬Reset، BOOT .3

  NRST / pin 6 ---------+---- C_NRST 100 nF ---- GND
                            +---- SW_RESET B3F-4055 -- GND
                            `---- J_SWD pin 5 NRST


  PA13 / pin 24 -------------------- J_SWD pin 2             SWDIO
  PA14-BOOT0 / pin 25 -------------- J_SWD pin 4             SWCLK
  3V3_SYS -------------------------- J_SWD pin 1             VTref
  GND ------------------------------ J_SWD pin 3             GND



                                                                                                               Reset 3.1

      ‫ خارجی اضافه‬Pull-up ‫) است؛ بنابراین‬typ. 40 kOhm( 25...55 kOhm ‫ داخلی با مقدار معادل رسمی‬Pull-up ‫ دارای‬NRST ‫پایه‬
   ،nF 100 ‫ داخلی و‬RPU ‫ با این‬.‫ قرار میگیرد‬pin 6 ‫ و در نزدیکترین فاصله به‬ST ‫ رسمی‬Figure ‫ مطابق‬100 nF ‫ خازن خارجی‬.‫نمیشود‬
  ‫ تابع‬Reset ‫ قرار میگیرد؛ این محاسبه فقط برای درک مرتبه زمانی است و رفتار واقعی‬2.5...5.5 ms ‫ در بازه تقریبی‬RC ‫ثابت زمانی ساده‬
                                                                         [ST-DS: Table 51 + Fig.17] .‫ نیز هست‬MCU ‫مدار داخلی‬


                                ‫وضعیت‬                                       ‫انتخاب‬                                        Ref

                           POPULATE       CL10B104KB8NNNC / 100 nF X7R 0603 C_NRST

                                          B3F-4055, SPST-NO tactile, projected
                           POPULATE                                                  SW_RESET
                                          7.3 mm, 2.55 N

               DNP / NOT REQUIRED                                             ‫ ندارد‬R_NRST_PU


                                                                                                             BOOT0 3.2

  ‫ یا‬Jumper ،‫ هیچ کلید‬Rev-A ‫ در‬.‫ مدیریت میشود‬Option Bytes ‫ بهصورت پیشفرض از‬STM32G0 ‫ در‬BOOT configuration
  RDP = Level ‫ نیز‬Development ‫ در فاز‬.‫ قفل میماند‬SWCLK ‫ برای‬PA14-BOOT0 .‫ اضافه نمیشود‬BOOT0 ‫مقاومت مستقل‬
                              [ST-AN: AN5096, Boot configuration] .‫ فقط با نیاز مشخص انجام میشود‬Option Bytes ‫ و تغییر‬0


                                                                                                                 SWD 3.3

                             ‫کارکرد‬                                MCU                                Signal         J_SWD

          Target ‫ فقط تشخیص سطح‬3V3_SYS                                    VTref                                      1

                  Serial wire data PA13 / pin 24                          SWDIO                                      2

                        Reference GND                                     GND                                        3

                 Serial wire clock PA14 / pin 25                          SWCLK                                      4

                 Reset / recovery pin 6                                   NRST                                       5



   PA13=SWDIO ‫ نیز‬ST .‫ خود برد است‬3V3_SYS ‫ از‬VTref ‫ هدر فقط‬Pin 1 .‫ پروگرامر تغذیه نشود‬5V ‫ یا‬3.3V ‫ برد از خروجی‬:‫ممنوع‬
    [ST-AN: AN5096, Debug .‫ الزم نیست‬SWD ‫ تعریف میکند و مقاومت خارجی روی‬Reset ‫های داخلی‬Pull ‫ را با‬PA14=SWCLK ‫و‬
                                                                                                               management]



MCU CORE / RESET + SWD                                                                                                   Page 4

[PDF PAGE BREAK]
                              STM32G070KBT6 - Rev-A ‫ کامل‬Pin Map .4
         ‫یادداشت‬            Status                                    Rev-A ‫وظیفه‬                  Port   Pin

                            LOCK     SD_CARD_DET_N                                    PB9                   1


 oscillator option      RESERVED                                         ‫بدون اتصال‬   PC14                  2


 oscillator option      RESERVED                                         ‫بدون اتصال‬   PC15                  3


                            LOCK     3V3_SYS + decoupling                             VDD/VDDA              4


                            LOCK     GND                                              VSS/VSSA              5


                            LOCK                                      Reset + SWD     NRST                  6


                          IoT/DEV    UART4_TX                                         PA0                   7


                          IoT/DEV    UART4_RX                                         PA1                   8


‫خروجی حساس ممنوع‬          SPECIAL                               ADC / Input / Spare   PA2                   9


                        RESERVED                                        ADC spare     PA3                  10


                            LOCK     SD_CS / SPI1_NSS                                 PA4                  11


                            LOCK     SD_SCK                                           PA5                  12


                            LOCK     SD_MISO                                          PA6                  13


                            LOCK     SD_MOSI                                          PA7                  14


                        RESERVED                            Control/PWM/ADC future    PB0                  15


                            LOCK     SD_PWR_CTL                                       PB1                  16


                            LOCK     OLED_CTL                                         PB2                  17


  startup caveat     LOW PRIORITY                               Control/PWM future    PA8                  18


                      IoT PRIMARY    USART1_TX                                        PA9                  19


                        RESERVED                                Control/PWM future    PC6                  20


                      IoT PRIMARY    USART1_RX                                        PA10                 21


   no PA9 remap             LOCK     I2C2_SCL                                         PA11                 22


  no PA10 remap             LOCK     I2C2_SDA                                         PA12                 23


                            LOCK     SWDIO                                            PA13                 24


                            LOCK     SWCLK                                            PA14-BOOT0           25


                            LOCK     KEY_UP                                           PA15                 26


                            LOCK     RTC_INT_N                                        PB3                  27


                            LOCK     KEY_DOWN                                         PB4                  28


                            LOCK     KEY_SET                                          PB5                  29

[PDF PAGE BREAK]
                           EXPANSION        I2C1_SCL                                                PB6        30


                           EXPANSION        I2C1_SDA                                                PB7        31


                                   LOCK     KEY_BACK                                                PB8        32



       .‫ برای خروجیهایی که تغییر ناخواستهشان خطر دارد استفاده نمیشود‬،Backup-domain/LSCO ‫ رسمی‬Errata ‫ بهدلیل‬:PA2
                     [ST-ERR: ES0468 Rev.5] .‫ را اجرا میکند‬Backup Domain ‫ رسمی‬POR/BOR workaround ‫ در‬Firmware


                     PB3/pin27 = RTC_INT_N is internal-PCB only and is not exposed to J_NAV/panel harness.
                            I2C2 remains on PA11/PA12; PA9/PA10 remain reserved for USART1 / IoT.



MCU CORE / PIN MAP                                                                                           Page 5

[PDF PAGE BREAK]
                        MCU Core + Clock + SWD + Reset ‫ نهایی‬BOM .5

                    ‫ وضعیت‬/ ‫خرید‬       Qty PCB             Package                          ‫ مشخصه‬/ MPN                    Ref

 ‫ نیز‬Kavir ‫ و‬Lion ‫در سبد خرید کاربر؛‬             LQFP-32 7x7, P=0.8
                                         1                            STM32G070KBT6                        U_MCU
                   ‫عرضه فعال دارند‬               mm

      ‫ رسمی‬MPN ‫ مشترک؛‬BOM ‫از‬
                                                                      CL10B104KB8NNNC / 100 nF 50 V X7R
   ‫ و عرضه داخلی بررسی‬Samsung            1              0603                                               C_MCU_HF
                                                                      ±10%
                                ‫شد‬

                                                                      CL10B104KB8NNNC / 100 nF 50 V X7R
              ‫ مشترک‬BOM ‫از همان‬          1              0603                                               C_NRST
                                                                      ±10%

     ‫ عدد در بررسی جاری؛‬Lion: 940                                     C2012X5R1E475K125AB / 4.7 uF 25 V
                                         1              0805                                               C_MCU_BULK
                 ‫ مشترک پروژه‬BOM                                      X5R ±10%

 MOQ=5 ،‫ موجود‬:ECA ‫؛‬Lion: 378            1       THT 12x12 mm         B3F-4055 / Omron                     SW_RESET

 Zagros ‫ و‬Javanelec ‫؛‬Lion: 523                   THT, 1 row, 2.54     PLS-2.54-1X40GF / Gosun; cut 5
                                       pins 5                                                              J_SWD
                       ‫ فعال‬listing              mm                   positions


                                                                             ‫ وجود ندارند‬BOM ‫ قطعاتی که عمدا ً در‬5.1

                                         ‫دلیل‬                                  ‫وضعیت‬                                       ‫آیتم‬

     ‫ رزرو شدهاند‬PC14/PC15 ‫نیاز فعلی ندارد؛‬               NOT POPULATED                  HSE crystal + load network

                 ‫ خارجی‬DS3231 ‫زمان دقیق با‬                NOT POPULATED                  LSE crystal

                   ‫ داخلی‬Pull-up ‫ دارای‬NRST                 NOT FITTED                   R_NRST_PU

 ‫ داخلی را فراهم کرده است‬Reset ‫های‬ST Pull                   NOT FITTED                   SWDIO/SWCLK external pulls

‫ برای‬PA14 ‫؛‬Option Bytes ‫ با‬Boot default
                                                            NOT FITTED                   BOOT0 switch/jumper
                                       SWCLK


   ‫موجود بازار‬/‫ از اقالم مشترک‬header ‫ و‬Reset ،‫ جدید است؛ خازنها‬MCU ‫ فقط‬Revision ‫ قطعات جدید اصلی این‬:‫وضعیت خرید‬
                                                                        .‫ جدیدی خرید الزم ندارد‬oscillator ‫ هیچ قطعه‬.‫قبلی هستند‬


MCU CORE / BOM                                                                                                           Page 6

[PDF PAGE BREAK]
                                     ‫‪ Placement، Bring-up .6‬و معیار ‪PASS/FAIL‬‬

                                                                ‫‪ Placement rules 6.1‬برای مرحله ‪ PCB‬آینده‬
                             ‫• ‪ C_MCU_HF‬باید در نزدیکترین فاصله ممکن به ‪ pin 4/5‬قرار گیرد و ‪ loop‬تغذیه‪/‬زمین حداقل شود‪.‬‬
                                                           ‫• ‪ C_MCU_BULK‬کنار ‪ MCU‬و روی همان ریل ‪ 3V3_SYS‬قرار گیرد‪.‬‬
                                ‫• ‪ C_NRST‬نزدیک ‪ pin 6‬باشد؛ مسیر ‪ NRST‬از نودهای سوئیچینگ ‪ Buck-Boost‬و ‪ SD‬دور بماند‪.‬‬
     ‫• ‪ J_SWD‬نزدیک لبه ‪ PCB‬و پس از مونتاژ قابل دسترسی باشد؛ ‪ SWDIO/SWCLK‬کوتاه و بدون ‪ Stub‬غیرضروری ‪ Route‬شوند‪.‬‬
       ‫• ‪ Footprint MCU‬فقط از ‪ outline‬و ‪ footprint example‬رسمی ‪ ST‬برای ‪ LQFP32‬با ‪ pitch 0.8 mm‬ساخته‪/‬کنترل شود‪.‬‬
                                            ‫• ‪ PC14/PC15‬فعال ً بدون ‪ trace‬عملکردی باقی بمانند تا رزرو ‪ oscillator‬خراب نشود‪.‬‬

                                                                        ‫‪ Firmware constraints 6.2‬ثبتشده‬

                                                ‫قانون ‪Rev-A‬‬                                                         ‫موضوع‬

    ‫در ‪ LQFP32‬باید ‪ Disabled‬بماند‪ ،‬چون ‪ VREF+ pin‬وجود ندارد و‬
                                                                ‫‪VREFBUF‬‬
                             ‫‪ +VREF‬داخلی به ‪ VDD‬وصل است‪.‬‬

       ‫‪kHz 100‬؛ ‪ kernel clock‬حداقل ‪MHz 4‬؛ ‪workaround‬های‬
                                                                ‫‪I2C2‬‬
                ‫‪ ES0468‬برای ‪ BERR/first TX byte‬رعایت شوند‪.‬‬

              ‫‪ SPI1 / MicroSD‬قبل از ‪ Disable‬در ‪ Master TX: TXE=1‬و ‪.BSY=0‬‬

  ‫خروجی کنترلی حساس نباشد؛ ‪Backup Domain reset sequence‬‬
                                                                ‫‪PA2‬‬
                               ‫پس از ‪ POR/BOR‬مطابق ‪.Errata‬‬

       ‫‪Development: RDP Level 0‬؛ ‪ Option Bytes‬فقط با نیاز‬
                                                                ‫‪Security‬‬
                 ‫مشخص؛ ‪ REV_ID‬قبل از قفل امنیتی خوانده شود‪.‬‬


                                                                           ‫‪ 6.3‬آزمونهای ‪ Bring-up‬بعد از ساخت‬

                                   ‫‪FAIL‬‬                                      ‫‪PASS‬‬                                     ‫مرحله‬

             ‫اتصال کوتاه‪/‬مقاومت غیرعادی‬                            ‫عدم ‪ short‬مشهود‬           ‫خاموش‪ :‬مقاومت ‪3V3_SYS/GND‬‬

                 ‫افت ریل‪/‬مصرف غیرعادی‬           ‫‪ 3V3‬پایدار‪ MCU ،‬بدون گرمای غیرعادی‬               ‫روشنکردن با ‪Current Limit‬‬

                         ‫عدم اتصال پایدار‬                       ‫‪ Device‬قابل شناسایی‬                  ‫‪SWD + VTref + GND‬‬

               ‫هر خطای ‪verify/program‬‬                                      ‫بدون خطا‬               ‫‪Erase / Program / Verify‬‬

                           ‫رفتار نامطمئن‬             ‫‪ Reset‬و اجرای مجدد ‪firmware‬‬                            ‫‪RESET button‬‬

                          ‫عدم ‪recovery‬‬                    ‫‪ Recovery‬از طریق ‪NRST‬‬                     ‫‪Connect under Reset‬‬


   ‫این جدول ‪ PASS‬شماتیک نیست‪ .‬معیار ‪ Release‬شماتیک فقط ‪ Validate‬واقعی در ‪ Altium Designer 26.8.1 Build 31‬با‬
                           ‫‪ Off-grid=0‬و ‪ Electrical errors=0‬است‪ .‬سپس و فقط سپس ورود به ‪ ECO/PCB‬مجاز خواهد بود‪.‬‬


‫‪MCU CORE / RELEASE RULES‬‬                                                                                              ‫‪Page 7‬‬

[PDF PAGE BREAK]
                                                                        ‫ منابع رسمی و وضعیت تأمین‬.7

                         ‫کاربرد‬                                                                     ‫منبع‬                ID

   ،Pinout، power، reset، HSI16 STMicroelectronics DS12766 Rev.3 - STM32G070CB/KB/RB
                                                                                                            ST-DS
             current، package datasheet

     ،Decoupling، SWD، BOOT STMicroelectronics AN5096 Rev.4 - Getting started with STM32G0
                                                                                                            ST-AN
             VREFBUF، layout MCUs hardware development

  ،PA2/backup، I2C ‫ محدودیتهای‬STMicroelectronics ES0468 Rev.5 - STM32G070CB/KB/RB device
                                                                                                            ST-ERR
                Firmware ‫ و‬SPI errata

                                  Samsung Electro-Mechanics CL10B104KB8NNN# official product
        nF, 50 V, X7R, 0603 100                                                                             SAMSUNG
                                  data

        uF, 25 V, X5R, 0805 4.7 TDK C2012X5R1E475K125AB official product data                               TDK

 B3F-4055، 12x12، 7.3 mm، 2.55
                                  Omron B3F official datasheet                                              OMRON
                   N، SPST-NO

    PLS-2.54-1X40GF male THT
                                  Ningbo Gosun PLS series product/datasheet                                 GOSUN
                       header


                                                                                            09-08-2026 ‫ کنترل‬- ‫بازار ایران‬

                                    ‫نتیجه‬                          ‫وضعیت‬/‫فروشنده‬                                      ‫قطعه‬

                                            ‫سبد؛ کاربر‬/‫ امکان خرید‬:Kavir ‫ عدد؛‬Lion: 53
                                    GO                                                    STM32G070KBT6
                                                             ‫نیز به سبد خرید اضافه کرده‬

                                    GO                    ‫ موجود‬:ECA ‫ عدد؛‬Lion: 378 B3F-4055

                                    GO         ‫ مشترک پروژه‬BOM ‫ در‬+ ‫ عدد‬Lion: 940 C2012X5R1E475K125AB

                                            MPN ‫؛‬Lion + Enabz/Labkhand listing
                                    GO                                                    CL10B104KB8NNNC
                                                          ‫ مشترک پروژه‬BOM ‫از قبل در‬

                                                Zagros ‫ و‬Javanelec ‫ عدد؛‬Lion: 523
                                    GO                                                    PLS-2.54-1X40GF
                                                                          ‫ فعال‬listing


  ‫ نیاز خرید واقعی‬،‫ مشترک‬BOM ‫ برای قطعات‬.‫ موجودی فروشگاهها پویاست و در زمان پرداخت نهایی دوباره چک میشود‬:‫تذکر تأمین‬
                                                                 .‫با موجودی قطعاتی که قبال ً تهیه شدهاند تطبیق داده شود‬


           MCU Core + Clock + SWD + Reset - BOM / Architecture LOCKED for Rev-A v2.1
                             Schematic Validation = NOT STARTED



DATALOGGER REV-A                                                                                                      Page 8

[PDF PAGE BREAK]

```

## Datalogger_RTC_CR2032_Final_BOM_RevA_v1.2_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_RTC_CR2032_Final_BOM_RevA_v1.2_FA.pdf`  
PDF/source SHA256: `8c57930007eb3ce21a7ad6c396d684ff1fed86554f4da942855beb3be636b571`

```text
STM32G070 DATA LOGGER / RTC BLOCK FINALIZATION



  CR2032 ‫ و باتری پشتیبان‬RTC ‫نهاییسازی بلوک‬
        ‫ و اصالح محاسبات‬RTC_INT_N ‫ افزودن‬،STM32G070KBT6 ‫ همگامسازی با‬- Rev-A v1.2



    Architecture + BOM + Pin Assignment LOCKED / Schematic Not Yet Validated / PCB
                                                                                        ECO Prohibited




                                                RTC                                                     MCU

  DS3231SN#                                               STM32G070KBT6 / LQFP-32



                                        Main supply                                           Backup battery

  3V3_SYS                                                 CR2032 / 3 V primary lithium



                                                I2C                                               Target CAD

  I2C2 / 100 kHz                                          Altium Designer 26.8.1 Build 31



    G070 ‫ به‬Pin Assignment ‫ و‬MCU .‫ حفظ شده است‬CR2032 ‫ و‬DS3231 ‫ هسته الکتریکی‬:v1.1 ‫ نسبت به‬Delta
     PB3 / pin ‫ روی‬RTC_INT_N ‫ با نام‬MCU ‫ فقط» به ورودی داخلی‬Test Point« ‫ از حالت‬INT/SQW ‫همگام شدهاند؛‬
   .‫ محاسبات عمر باتری نیز با واحد صحیح بازنویسی شدهاند‬.‫ اضافه شده است‬kOhm 10 ‫ مستقل‬Pull-up ‫ ارتقا یافته و‬27




        Validate ‫ شماتیک فقط بعد از‬PASS .‫ شماتیک‬PASS ‫ نه‬،‫ است‬BOM/‫ معماری‬PASS ‫ این سند‬:Release ‫قاعده‬
    ‫ مجاز‬Update PCB ‫ یا‬ECO ‫ تا آن زمان هیچ‬.‫ معتبر است‬Electrical errors = 0 ‫ و‬Off-grid = 0 ‫ با‬Altium ‫واقعی‬
                                                                                                     .‫نیست‬




DATALOGGER REV-A                                                                                         Page 1

[PDF PAGE BREAK]
                                                                            ‫ معماری الکتریکی نهایی‬.1

  3V3_SYS -------------------- VCC          pin 2    DS3231SN#
        |-- C_RTC 100 nF ------- GND


  CR2032 (+) ----------------- VBAT pin 14
  CR2032 (-) ----------------- GND          pin 13


  I2C_SCL -------------------- SCL          pin 16   -> MCU PA11 / pin 22 / I2C2_SCL
  I2C_SDA -------------------- SDA          pin 15   -> MCU PA12 / pin 23 / I2C2_SDA


  3V3_SYS -- 10 kOhm --+------ INT/SQW pin 3
                            +------ TP_RTC_INT
                            `------ MCU PB3 / pin 27       (RTC_INT_N)


  32kHz pin 1 ---------------- NC
  RST      pin 4 ---------------- NC
  N.C. pins 5..12 ------------ GND (mandatory)
  TP_VBAT -------------------- VBAT test pad




         2.4 ‫های اصلی‬Pull-up ‫ از‬RTC ‫ قرار نمیگیرد؛‬RTC ‫ در‬SDA/SCL ‫ محلی جدیدی روی‬Pull-up ‫ هیچ‬:Rev-A ‫تصمیم‬
                                                  .‫ قفل شدهاند استفاده میکند‬OLED/SHT3x ‫ باس که در بلوک‬kOhm


                                                                   MCU ‫ مرتبط با‬Pin Assignment 1.1

     Status                 Mode                  ‫ فیزیکی‬Pin             MCU GPIO                    Net


        LOCK              I2C2_SCL                   22                     PA11                  I2C_SCL


        LOCK              I2C2_SDA                   23                     PA12                  I2C_SDA


        LOCK              GPIO input                 27                     PB3                  RTC_INT_N


        ‫ این انتخاب با‬.‫ استفاده میشود و در معرض کانکتور خارجی نیست‬PCB ‫ عمدا ً برای یک سیگنال داخلی روی همان‬PB3 ‫پایه‬
                                       .‫ آن سازگار است‬Injection ‫ بهدلیل حساسیت‬Navigation ‫ از‬PB3 ‫تصمیم قبلی حذف‬




DATALOGGER REV-A                                                                                             Page 2

[PDF PAGE BREAK]
                                                       ‫‪ INT/SQW .2‬و دلیل اتصال به ‪MCU‬‬
  ‫خروجی ‪ INT/SQW‬در ‪ DS3231‬از نوع ‪ Open-drain‬است و برای استفاده نیاز به ‪ Pull-up‬خارجی دارد‪ .‬در مشخصات رسمی‪،‬‬
‫خروجی در جریان ‪ Sink‬برابر ‪ mA 3‬حداکثر ‪ V 0.4‬تضمین شده است‪ .‬با ‪ Pull-up‬برابر ‪ kOhm 10‬روی ‪ ،V 3.3‬جریان ‪ LOW‬فقط‪:‬‬


                                 ‫‪I_LOW = 3.3 V / 10 kOhm = 0.33 mA‬‬


                         ‫است؛ یعنی حدود یکنهم جریان آزمون ‪ mA 3‬دیتاشیت‪ .‬بنابراین حاشیه ‪ Sink‬بسیار مناسب است‪.‬‬


       ‫رفتار هنگام خاموشی دستگاه‪ :‬در حالت پیشفرض ‪ ،BBSQW=0‬وقتی ‪ VCC < VPF‬شود‪ INT/SQW ،‬به ‪-High‬‬
   ‫‪ impedance‬میرود‪ Pull-up .‬نیز از ‪ 3V3_SYS‬تغذیه میشود که هنگام خاموشی صفر است؛ بنابراین این مسیر عمدا ً بار‬
                                                                               ‫‪ DC‬روی ‪ CR2032‬ایجاد نمیکند‪.‬‬


                                                              ‫‪ 2.1‬قواعد ‪ Firmware‬برای ‪RTC_INT_N‬‬
      ‫• در ‪ Rev-A‬حالت مورد نظر ‪ INTCN=1‬است؛ خروجی برای ‪ Alarm Interrupt‬استفاده میشود‪ ،‬نه ‪.Square Wave‬‬

                                                          ‫• اگر ‪ Alarm‬استفاده نشود‪ A1IE=A2IE=0 ،‬باقی بمانند‪.‬‬

                          ‫• اگر ‪ Alarm‬فعال شد‪ Firmware ،‬پس از سرویس وقفه ‪ Flag‬متناظر ‪ A1F/A2F‬را ‪ Clear‬کند‪.‬‬

                         ‫• ‪ BBSQW‬در ‪ Rev-A‬برابر ‪ 0‬باقی بماند تا در ‪ Backup-only‬خروجی ‪ INT/SQW High-Z‬باشد‪.‬‬

                     ‫• در ‪ ،Startup‬بیت ‪ OSF‬بررسی شود؛ اگر ‪ 1‬بود‪ ،‬زمان ثبتشده معتبر تلقی نشود تا دوباره ‪ Set‬شود‪.‬‬


  ‫اتصال ‪ RTC_INT_N‬قابلیت آینده را بدون ‪ Revision‬سختافزاری اضافه میکند؛ استفاده ‪ Firmware‬از ‪ Alarm‬در ‪-Rev‬‬
                                                                                             ‫‪ A‬اجباری نیست‪.‬‬




‫‪DATALOGGER REV-A‬‬                                                                                          ‫‪Page 3‬‬

[PDF PAGE BREAK]
                                                                              ‫‪ .3‬تغذیه‪ CR2032 ،‬و عدم شارژ‬

         ‫تصمیم پروژه‬                                     ‫مقدار رسمی‬                                           ‫پارامتر‬


          ‫‪3V3_SYS‬‬                                        ‫‪2.3...5.5 V‬‬                                                    ‫محدوده ‪VCC‬‬


  ‫‪CR2032 nominal 3.0 V‬‬                                   ‫‪2.3...5.5 V‬‬                                                ‫محدوده ‪VBAT‬‬


         ‫‪100 nF X7R‬‬                                      ‫‪0.1...1.0 uF‬‬                                                     ‫خازن ‪VCC‬‬


        ‫نصب نمیشود‬                                        ‫الزم نیست‬                                ‫خازن ‪ VBAT‬در ‪Backup mode‬‬


            ‫‪LOCK‬‬                                   ‫باید به ‪ GND‬متصل شوند‬                                          ‫‪N.C. pins 5..12‬‬


         ‫‪ NC‬در ‪Rev-A‬‬                ‫‪ Pull-up‬داخلی اسمی ‪kOhm 50‬؛ ‪ Pull-up‬خارجی ممنوع‬                                           ‫‪RST‬‬



      ‫‪ CR2032‬تحت هیچ شرایطی شارژ نمیشود‪ .‬هیچ مقاومت‪ ،‬دیود‪ LED ،‬یا مسیر ‪ DC‬از ‪ 3V3_SYS‬به ‪ VBAT‬اضافه‬
     ‫نمیشود‪ .‬طبق دیتاشیت ‪ ،DS3231‬قطعه برای جلوگیری از ‪ Reverse Charging‬هنگام استفاده با ‪Primary Lithium‬‬
                                                                                           ‫‪ Battery‬دارای شناسایی ‪ UL‬است‪.‬‬


                                                                                      ‫‪ 3.1‬عمر تئوری ‪ -‬اصالح واحد ‪v1.1‬‬
        ‫ظرفیت اسمی ‪ Panasonic CR2032‬برابر ‪ mAh 225‬است‪ DS3231 .‬در ‪ Timekeeping‬روی ‪ VBAT=3.63 V‬جریان‬
                                                             ‫‪ Typical‬برابر ‪ uA 0.84‬و ‪ Maximum‬برابر ‪ uA 3.0‬مشخص میکند‪.‬‬


                        ‫‪T_typ = 225 mAh / 0.00084 mA = 267,857 h = 30.6 years‬‬


                           ‫‪T_max = 225 mAh / 0.003 mA = 75,000 h = 8.6 years‬‬

  ‫این اعداد فقط نسبت ظرفیت نامی به جریان ‪ RTC‬هستند و عمر سرویس تضمینی نیستند‪ Self-discharge .‬باتری‪ ،‬دما‪ ،‬عمر انبار‪ ،‬آلودگی ‪ PCB‬و نشتی‬
     ‫سطحی میتوانند زودتر غالب شوند‪ .‬خطای ‪ v1.1‬فقط در برچسب واحد مخرج بود؛ عدد محاسبهشده همان نسبت صحیح ‪ mAh/mA‬را دنبال میکرد‪.‬‬




‫‪DATALOGGER REV-A‬‬                                                                                                              ‫‪Page 4‬‬

[PDF PAGE BREAK]
                                                              RTC - Rev-A v1.2 ‫ نهایی‬BOM .4

            ‫وضعیت‬                   Qty       ‫ مقدار‬/ Package              ‫ قطعه‬/ MPN                   Ref


  ‫ قبال ً خریداری‬- Carry Forward              16-SO, 300 mil /
                                     1                                     DS3231SN#                    U_RTC
              ‫شده‬                                   W16#H2


                                             100 nF, 50 V, X7R,
        ‫ مشترک پروژه‬MPN              1                                 CL10B104KB8NNNC                  C_RTC
                                               0603, +/-10%


   - Navigation ‫ مشترک‬MPN                    10 kOhm, +/-0.5%,
                                     1                                   ARG05DTC1002           R_RTC_INT_PU
         ‫ جدید ندارد‬SKU                              0805


   ‫ نامشخص؛ فقط همان‬MPN                                               ‫ مطابق نقشه‬CR2032 ‫هولدر‬
                                     1       Vertical THT, 2-pin                                        BT1
            ‫نقشه‬/‫مدل‬                                                           ‫کاربر‬


                                           3 V, 225 mAh, primary
        Carry Forward                1                                  Panasonic CR2032                 B1
                                                    lithium


         ‫بدون قطعه خرید‬              1              PCB ‫پد‬                   Test pad              TP_VBAT


         ‫بدون قطعه خرید‬              1       net RTC_INT_N ‫روی‬               Test pad             TP_RTC_INT



                ‫ قفلشده‬MPN ‫ از همان‬kOhm 10 ‫ مقاومت‬.‫ جدیدی الزم نیست‬SKU ‫ یا‬IC ‫ هیچ‬:Revision ‫اثر خرید این‬
                                          .‫ مشترک پروژه است‬BOM ‫ نیز از‬nF 100 ‫ استفاده میشود و خازن‬Navigation


                                                                      ‫ قطعاتی که عمدا ً نصب نمیشوند‬4.1

                                   ‫دلیل‬                                 ‫وضعیت‬                    ‫آیتم‬


      ‫ وجود دارد‬OLED/SHT3x ‫ باس در بلوک‬kOhm 2.4 ‫ اصلی‬Pull-up          NOT FITTED          Local I2C pull-ups


       ‫ است؛ دیتاشیت آن را الزم نمیداند‬Backup supply ‫ فقط‬VBAT         NOT FITTED           VBAT capacitor


             ‫ است‬kOhm 50 ‫ داخلی اسمی‬Pull-up ‫ دارای‬RST                 PROHIBITED        RST external pull-up


                    ‫ استفاده نمیشود‬Rev-A ‫ در‬32kHz                     NOT FITTED        32kHz pull-up / load




DATALOGGER REV-A                                                                                              Page 5

[PDF PAGE BREAK]
                                                                ‫‪ .5‬مبنای مکانیکی هولدر ‪CR2032‬‬
   ‫این بخش بدون تغییر از ‪ v1.1 Carry Forward‬میشود‪ MPN .‬سازنده از تصویر ارسالی قابل اثبات نبود؛ بنابراین ‪Footprint‬‬
                                                             ‫فقط بر اساس همان نقشه و نمونه واقعی ‪ Release‬میشود‪.‬‬


                   ‫کاربرد ‪PCB‬‬                                ‫مقدار‬                           ‫پارامتر‬


       ‫‪Mechanical courtyard / keepout‬‬                     ‫‪23.80 mm‬‬                       ‫قطر‪/‬عرض خارجی ناحیه باتری‬


               ‫مرجع ناحیه ‪CR2032‬‬                          ‫‪20.50 mm‬‬                          ‫قطر داخلی نشاندادهشده‬


               ‫‪Board clearance‬‬                            ‫‪27.60 mm‬‬                            ‫طول کلی در نمای جانبی‬


              ‫‪Component height‬‬                             ‫‪7.60 mm‬‬                                     ‫ارتفاع کلی تقریبی‬


             ‫‪Mechanical reference‬‬                          ‫‪6.70 mm‬‬                                           ‫ارتفاع بدنه‬


               ‫‪Footprint pitch‬‬                            ‫‪20.00 mm‬‬                              ‫فاصله مرکز دو سوراخ‬


          ‫‪Footprint drill geometry‬‬                     ‫‪2 x dia 0.80 mm‬‬                                            ‫‪Drill‬‬


             ‫‪THT assembly check‬‬                            ‫‪3.00 mm‬‬                                 ‫طول پایه زیر ‪PCB‬‬



         ‫‪ :Footprint HOLD‬قطر ‪ Pad‬مسی در نقشه مرجع مشخص نشده است‪ Drill .‬و ‪ Pitch‬قفل هستند‪ ،‬ولی ‪Pad‬‬
      ‫‪ diameter‬باید بر اساس ‪ Annular Ring Rule‬سازنده ‪ PCB‬تعیین شود و قبل از ‪ Release‬روی یک نمونه واقعی با‬
                                                                            ‫کولیس‪/‬مولتیمتر ‪ Cross-check‬شود‪.‬‬


                                                                                ‫‪Placement / Layout 5.1‬‬
                                             ‫• ‪ DS3231‬تا حد امکان از ‪ ،Buck-Boost‬سلف و نودهای ‪ SW‬دور قرار گیرد‪.‬‬

                                        ‫• ‪ C_RTC‬مستقیما ً کنار ‪ VCC pin 2‬و با مسیر برگشت بسیار کوتاه به ‪ GND‬باشد‪.‬‬

                                                                 ‫• مسیر ‪ VBAT‬کوتاه و دور از نودهای سوئیچینگ باشد‪.‬‬

                                   ‫• ‪ CR2032‬پس از مونتاژ دستگاه قابل تعویض بماند و قطب مثبت روی ‪ Silk‬واضح باشد‪.‬‬

                                           ‫• برای حرکت فنر و خارجکردن باتری ‪ Keepout‬مکانیکی کافی در نظر گرفته شود‪.‬‬

                       ‫• ‪ RTC_INT_N‬یک سیگنال داخلی است؛ مسیر آن کوتاه بماند و از ‪ SW_NODE‬فاصله داشته باشد‪.‬‬




‫‪DATALOGGER REV-A‬‬                                                                                                  ‫‪Page 6‬‬

[PDF PAGE BREAK]
                                                               Release ‫ معیار پذیرش و وضعیت‬.6

                                           PASS ‫معیار‬                                                    ‫کنترل‬


                                          DS3231SN#                                                              MPN RTC


                  16-SO, 300 mil / W16#H2 / official land pattern basis                                   Footprint RTC


                     PA11/pin22 = I2C2_SCL; PA12/pin23 = I2C2_SDA                                           I2C Pin Map


                  PB3/pin27 = RTC_INT_N; 10 kOhm pull-up to 3V3_SYS                                       RTC Interrupt


               Pitch 20.00 mm + drill-fit 0.80 mm verified on real sample                                           Holder


                        ‫ تأیید شود‬Continuity ‫ با‬GND ‫ به‬- ‫ و‬VBAT ‫ هولدر به‬+                                         Polarity


                     ‫ وجود نداشته باشد‬VBAT ‫ به‬3V3_SYS ‫ خارجی از‬DC path ‫هیچ‬                            CR2032 charging


                                Pins 5..12 connected to GND                                                       N.C. pins


                              Off-grid = 0 / Electrical errors = 0                                      Altium Validate



          ‫ شرط مکانیکی‬.‫ قفل است‬Architecture/BOM/Pin Assignment ‫ از نظر‬RTC + CR2032 Rev-A v1.2 :‫نتیجه‬
                 .‫ هنوز شروع نشده است‬Schematic Validation .‫ هولدر هنوز نیازمند تطبیق نمونه واقعی است‬Footprint



                                                                                                  ‫ منابع رسمی‬.7
1. Analog Devices / Maxim Integrated - DS3231 Datasheet: https://www.analog.com/media/en/technical-documentation/
   data-sheets/DS3231.pdf
2. Analog Devices - DS3231 Product Page: https://www.analog.com/en/products/ds3231.html
3. Panasonic Energy - CR2032 Datasheet (2026): https://energy.panasonic.com/content/dam/panasonic-energy/master/
   pdf/en/datasheet/lithium/CR2032_Datasheet_EN.pdf
4. STMicroelectronics - DS12766 Rev.3, STM32G070CB/KB/RB Datasheet: https://www.st.com/resource/en/datasheet/
   stm32g070kb.pdf
5. STMicroelectronics - ES0468 Rev.5, STM32G070CB/KB/RB Errata: https://www.st.com/resource/en/errata_sheet/es0468-
   stm32g070cbkbrb-device-errata-stmicroelectronics.pdf
6. Project source - Datalogger_RTC_CR2032_Final_BOM_RevA_v1.1_FA.pdf and user-provided holder drawing, reviewed
   2026-08-09.



   Document: Datalogger_RTC_CR2032_Final_BOM_RevA_v1.2_FA.pdf - Review date: 2026-08-09 - No schematic/ECO/PCB update
                                                                                                                  .performed




  DATALOGGER REV-A                                                                                                    Page 7

[PDF PAGE BREAK]

```

## Datalogger_Navigation_Buttons_Final_BOM_RevA_v1.0_FA
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_Navigation_Buttons_Final_BOM_RevA_v1.0_FA.pdf`  
PDF/source SHA256: `f1b22dc3eedb75a9d97b863dff416b07780b2201f68862beaec230b36821393e`

```text
                                                Rev-A ‫دیتاالگر‬

             ‫ خرید و الزامات اتصال‬BOM ،‫ — معماری نهایی‬Navigation Buttons ‫بلوک‬

                                    Revision A · Document v1.0 · 2026-08-09



                        ‫آیتم‬                                                       ‫وضعیت قفل‌شده‬


                      ‫ مبنا‬MCU                               STM32G070KBT6 — LQFP-32


                                                              ‫ — شماتیک هنوز ساخته‬BOM / Architecture LOCKED
                    ‫وضعیت بلوک‬
                                                             ‫نشده‬

                       ‫کلیدها‬                                ‫ · پنلی‬DS-316 · Momentary · SPST-NO × 4

                        ‫کابل‬                                 ‫ کامًال داخل بدنه‬،cm 5 ‫ حدود‬،‫ رشته‬5

                                                              ‫ تا تایید‬ECO / Update PCB ‫ · بدون‬Build 31 26.8.1
                       Altium
                                                             ‫شماتیک‬




 ‫ شماتیک فقط پس از‬PASS ‫ است؛‬Navigation ‫ بلوک‬BOM ‫ معماری و‬PASS ‫مرز اعتبار این سند — این سند‬

 .‫ معتبر خواهد بود‬Electrical errors=0 ‫ و‬Off-grid=0 ‫ با‬Altium ‫ واقعی‬Validate




‫ معماری و تخصیص پایه‌ها‬.1

‫ استفاده‬Rev-A ‫ در‬Matrix ‫ و‬ADC ladder .‫ متصل می‌شوند‬Active-Low ‫ مستقل و‬GPIO ‫چهار کلید به چهار‬

.‫ برای این چهار ورودی خاموش است‬MCU ‫ داخلی‬Pull-up/Pull-down .‫نمی‌شوند‬


           ‫کلید‬                         GPIO                       MCU ‫ فیزیکی‬Pin                     Net


           UP                           PA15                               26                       KEY_UP


         DOWN                            PB4                               28                      KEY_DOWN


           SET                           PB5                               29                       KEY_SET


          BACK                           PB8                               32                      KEY_BACK


                                Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09

[PDF PAGE BREAK]
   ‫• ‪ PB3‬عمدًا برای کلید پنلی استفاده نمی‌شود و آزاد باقی می‌ماند؛ این تصمیم از بازبینی مشخصات تزریق جریان‬

   ‫‪ STM32G070‬ناشی شده است‪.‬‬

   ‫• هر کلید ‪ DS-316‬در حالت فشرده خط مربوطه را به ‪ GND‬مشترک وصل می‌کند؛ حالت رهاشده توسط ‪Pull-up‬‬

   ‫خارجی ‪ HIGH‬می‌ماند‪.‬‬


‫‪ .2‬شبکه الکتریکی نهایی هر کانال‬


 ‫‪( J_N AV / KE Y_x S MF 05C .TC‬نزدیک کانکتور) → ‪ → R_SER = 1 kΩ‬نود ‪MCU‬؛ در نود ‪MCU:‬‬
                                                                                 ‫مسیر سیگنال‪—T‬‬

  ‫‪ R_PULL = 10 kΩ‬به ‪ 3V3_SYS‬و ‪ C_FILTER = 100 nF‬به ‪ .GND‬کلید پنلی ‪ DS-316‬بین ‪ KEY_x‬و ‪GND_COMMON‬‬

  ‫قرار می‌گیرد‪.‬‬




                   ‫عنصر‬                               ‫مقدار قفل‌شده‬                                ‫‪MPN‬‬


                   ‫‪R_SER‬‬                                 ‫‪1 kΩ ±1%‬‬                    ‫‪0805W8F1001T5E / UNI-ROYAL‬‬


                  ‫‪R_PULL‬‬                               ‫‪10 kΩ ±0.5%‬‬                   ‫‪ARG05DTC1002 / Viking Tech‬‬


                                                                                     ‫‪CL10B104KB8NNNC / Samsung‬‬
                  ‫‪C_FILTER‬‬               ‫‪100 nF ±10%, X7R, 50 V‬‬
                                                                                     ‫‪Electro-Mechanics‬‬


                    ‫‪ESD‬‬                  ‫‪5-channel TVS array‬‬                         ‫‪SMF05C.TCT / Semtech‬‬




‫‪ .3‬کنترل عددی سطوح منطقی و ‪RC‬‬

‫با ‪ VDD = 3.3 V، R_PULL = 10 kΩ‬و ‪:R_SER = 1 kΩ‬‬

   ‫• جریان هنگام فشردن کلید‪.I ≈ 3.3 / 11 kΩ = 0.300 mA :‬‬

   ‫• ولتاژ نامی ‪ GPIO‬در حالت ‪.LOW: V_LOW × 3.3 k 1/( 10k+ 1k) = 0.300 V‬‬

   ‫• با تلرانس قطعات انتخابی‪ ،‬بدترین نسبت ‪ LOW‬تقریبًا ‪ VDD×0.092‬باقی می‌ماند؛ فاصله زیادی با حد‬

   ‫تضمین‌شده ‪ VDD×0.3‬دارد‪.‬‬

   ‫• ثابت زمانی ‪ Release‬نامی‪τ = 10 kΩ × 100 nF = 1.0 ms :‬؛ عبور از آستانه تضمین‌شده ‪ HIGH‬تقریبًا ‪ms 1.11‬‬

   ‫نامی و حدود ‪ ms 1.23‬در ترکیب تلرانس بدبینانه است‪.‬‬



                                  ‫‪Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09‬‬

[PDF PAGE BREAK]
  ‫• ثابت زمانی ‪ Press‬تقریبًا (‪ 100 nF = 90.9 µs × )10k || 1k‬و عبور از آستانه ‪ LOW‬حدود ‪ ms 0.15–0.13‬است‪.‬‬


 ‫‪ — Debounce‬این ‪ RC‬برای تضعیف ‪ EMI‬و پالس‌های کوتاه است‪ ،‬نه تضمین ‪ Debounce‬مکانیکی‪ .‬زمان‬

 ‫‪ Debounce‬نرم‌افزاری فقط بعد از تست کلید واقعی ‪ DS-316‬روی نمونه فیزیکی قفل می‌شود‪.‬‬




‫‪ .4‬کانکتور و ‪ Harness‬نهایی‬


‫برای چهار سیگنال کلید و یک زمین مشترک‪ ،‬رابط ‪ 5‬پین عمودی انتخاب شده است‪ .‬خانواده ‪ SHOUHAN‬به‌صورت‬

‫‪ Header + Housing + Crimp Terminal‬قفل می‌شود‪.‬‬


        ‫جزء‬            ‫‪ / MPN‬مشخصه‬                   ‫سازنده‬                  ‫تعداد مونتاژ‬         ‫یادداشت‬


   ‫‪ Header‬روی ‪PCB‬‬      ‫‪2.54mm-5P ZZ-MS‬‬             ‫‪SHOUHAN‬‬                         ‫‪1‬‬             ‫‪Straight / THT‬‬


    ‫‪ Housing‬کابل‬          ‫‪XH2.54-5Y‬‬                ‫‪SHOUHAN‬‬                         ‫‪1‬‬              ‫‪5-position‬‬


   ‫‪Crimp terminal‬‬        ‫‪XH-2.54-DZ‬‬                ‫‪SHOUHAN‬‬                         ‫‪5‬‬              ‫‪AWG22–28‬‬


                                                                                            ‫طول آزاد هدف ≈‪50‬‬
       ‫‪Wire‬‬            ‫‪AWG26 stranded‬‬          ‫‪Assembly material‬‬                ‫‪ 5‬رشته‬
                                                                                            ‫‪mm‬‬




 ‫هشدار ‪ Footprint‬بسیار مهم — عنوان فروشگاهی ‪ Header‬عبارت «‪ »2.54mm‬دارد‪ ،‬اما ‪ Drawing‬سازنده‬

  ‫‪ SHOUHAN‬فاصله پایه ‪ PCB‬را ‪ mm 2.50‬نشان می‌دهد و سوراخ پیشنهادی ‪ PCB Ø0.80 mm‬است‪Footprint .‬‬

 ‫فقط از ‪ Drawing‬سازنده ساخته شود؛ نام فروشگاهی مبنای ‪ Pitch‬نباشد‪.‬‬




  ‫• ‪ Drawing/Specification‬سازنده برای ‪ :Header‬دمای محیط ‪ ،C° 85+…25−‬جریان نامی ‪ ،A 3‬ولتاژ نامی ‪250‬‬

  ‫‪ ،VAC/DC‬ضخامت ‪ PCB‬قابل اعمال ‪.mm 1.6…1.2‬‬

   ‫• دیتاشیت ‪ SHOUHAN‬برای ترمینال ‪ XH-2.54-DZ‬بازه سیم ‪ AWG22‬تا ‪ AWG28‬را مجاز می‌داند؛ ‪ AWG26‬داخل‬

  ‫این بازه است‪.‬‬

  ‫• طول ‪ mm 50‬فعًال «طول آزاد هدف» است‪ ،‬نه طول برش تولید‪ .‬طول برش نهایی پس از ‪ Dry-fit‬واقعی‬

  ‫‪/PCB‬پنل‪/‬کانکتور در قاب تعیین می‌شود تا کرمپ و ‪ Service Loop‬کم نشود‪.‬‬



                             ‫‪Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09‬‬

[PDF PAGE BREAK]
J_NAV ‫ قفل‌شده‬Pinout .5

            Pin J_NAV                                    Net                                  ‫اتصال پنل‬


                 1                               GND_COMMON                               DS-316 ‫مشترک چهار‬


                 2                                     KEY_UP                                 DS-316 UP


                 3                                   KEY_DOWN                               DS-316 DOWN


                 4                                     KEY_SET                               DS-316 SET


                 5                                   KEY_BACK                                DS-316 BACK




  ‫ رنگ‌ها جزو‬.)‫ شماره‌دار‬Label/Heat-shrink ‫ پنج رشته باید قابل شناسایی باشند (رنگ متفاوت یا‬،Harness ‫• برای‬

  .‫ الکتریکی قفل‌شده نیستند‬BOM

  ‫ اختصاصی همان کلید‬Signal ‫ مشترک و پایه دیگر به‬GND_COMMON ‫ یک پایه از هر چهار کلید به‬،‫• سمت پنل‬

  .‫متصل می‌شود‬


Navigation — Rev-A v1.0 ‫ نهایی‬BOM .6

      RefDes            ‫ مشخصه‬/ MPN                     ‫شرح‬                        Qty                ‫یادداشت‬


                                                                                                ‫پنل؛ سوراخ اسمی‬

                                                                                                ‫؛‬mm 10≈ ‫خانواده‬
                                              Push Button, SPST-NO,
    SW_NAV1…4               DS-316                                                  4           ‫نمونه واقعی پیش از‬
                                              Momentary, panel mount

                                                                                                ‫سوراخ‌کاری کنترل‬

                                                                                                ‫شود‬

                                                                                                ‫ کانال‬4 ‫؛‬J_NAV ‫نزدیک‬
                                              5-channel TVS/ESD array,
      D_NAV1              SMF05C.TCT                                                1
                                              SC70-6                                            ‫ کانال پنجم‬،‫مصرف‬
                                                                                                NC


     R_SER1…4           0805W8F1001T5E        1 kΩ, ±1%, 1/8 W, 0805                4                 UNI-ROYAL


     R_PULL1…4           ARG05DTC1002         10 kΩ, ±0.5%, 1/8 W, 0805             4                 Viking Tech


                                              100 nF, ±10%, 50 V, X7R,                          Samsung Electro-
      C_FIL1…4          CL10B104KB8NNNC                                             4
                                              0603                                              Mechanics


                              Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09

[PDF PAGE BREAK]
       ‫‪RefDes‬‬               ‫‪ / MPN‬مشخصه‬                      ‫شرح‬                      ‫‪Qty‬‬                   ‫یادداشت‬

                                                   ‫;‪5P vertical THT header‬‬
       ‫‪J_NAV‬‬                ‫‪2.54mm-5P ZZ-MS‬‬                                            ‫‪1‬‬                    ‫‪SHOUHAN‬‬
                                                   ‫‪drawing pitch 2.50 mm‬‬


                                                   ‫‪5P mating housing, 2.50‬‬
       ‫‪P_NAV‬‬                   ‫‪XH2.54-5Y‬‬                                               ‫‪1‬‬                    ‫‪SHOUHAN‬‬
                                                   ‫‪mm family‬‬


                                                   ‫–‪Crimp contact, AWG22‬‬
    ‫‪TERM_NAV1…5‬‬               ‫‪XH-2.54-DZ‬‬                                               ‫‪5‬‬                    ‫‪SHOUHAN‬‬
                                                   ‫‪28‬‬


                                                                                                  ‫‪Assembly material; cut‬‬
                                                   ‫‪5 conductors; target free‬‬
       ‫‪W_NAV‬‬                ‫‪AWG26 stranded‬‬                                          ‫‪ 5‬رشته‬        ‫‪length after enclosure‬‬
                                                   ‫‪run ≈50 mm‬‬
                                                                                                  ‫‪dry-fit‬‬




‫‪ .7‬وضعیت تأمین و مقدار پیشنهادی خرید‬


                 ‫قطعه‬                       ‫تأمین ایران (بررسی ‪)09-08-2026‬‬                     ‫پیشنهاد خرید‬


                                           ‫لیون‪ :‬موجودی باال؛ دیجی‌قطعه نیز‬
          ‫‪0805W8F1001T5E‬‬                                                                      ‫حداقل ‪ 10‬عدد‬
                                           ‫‪ MPN‬دقیق را فهرست کرده‬

                                           ‫لیون‪ 1,605 :‬عدد موجود در بررسی‬
           ‫‪ARG05DTC1002‬‬                                                                       ‫حداقل ‪ 10‬عدد‬
                                           ‫امروز‬

                                           ‫لیون‪ 6,594 :‬عدد موجود؛ ‪ eNabz‬نیز‬          ‫حداقل ‪ 10‬عدد ‪ /‬ترجیحًا از موجودی‬
         ‫‪CL10B104KB8NNNC‬‬
                                           ‫‪ MPN‬دقیق را فهرست کرده‬                   ‫مشترک پروژه‬

                                           ‫لیون‪ 3,322 :‬عدد موجود؛ چند‬

            ‫‪SMF05C.TCT‬‬                     ‫فروشگاه داخلی دیگر نیز ‪ MPN‬را‬                      ‫‪ 2‬عدد (‪ 1‬یدکی)‬

                                           ‫فهرست می‌کنند‬

          ‫‪2.54mm-5P ZZ-MS‬‬                  ‫لیون‪ 1,468 :‬عدد موجود‬                                  ‫‪ 2‬عدد‬

                ‫‪XH2.54-5Y‬‬                  ‫لیون‪ 3,138 :‬عدد موجود‬                                  ‫‪ 2‬عدد‬

               ‫‪XH-2.54-DZ‬‬                  ‫لیون‪ 3,280 :‬عدد موجود‬                    ‫‪ 10‬عدد برای ‪ 5‬اتصال ‪ +‬یدکی کرمپ‬

                                           ‫‪ :ECA‬چند رنگ از ‪ DS-316‬موجود؛ مدل‬
                 ‫‪DS-316‬‬                                                             ‫‪ 5‬عدد (‪ 1 + 4‬یدکی)‬
                                           ‫سفید در بررسی امروز موجود بود‬


                                 ‫‪Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09‬‬

[PDF PAGE BREAK]
               ‫قطعه‬                   ‫تأمین ایران (بررسی ‪)09-08-2026‬‬                         ‫پیشنهاد خرید‬


          ‫‪AWG26 stranded‬‬             ‫‪ :ECA‬حلقه ‪ m 10‬در چند رنگ موجود‬             ‫به‌مقدار الزم؛ ‪ 5‬رشته کوتاه‬




  ‫نکته تأمین ‪ kΩ — MPN 10‬اصلی ‪ kΩ 10‬پروژه برای این بلوک ‪ ARG05DTC1002‬است‪ .‬این ‪ MPN‬از نظر دیتاشیت‬

  ‫رسمی ‪ Viking‬دقیقًا ‪ kΩ / 0805 / ±0.5% / 1/8 W 10‬است‪ .‬در بررسی امروز موجودی داخلی مستقیم آن در لیون‬

 ‫تأیید شد؛ برای خرید نهایی موجودی دوباره کنترل شود‪.‬‬




‫‪ .8‬قواعد ‪ Layout / Assembly‬که همراه ‪ BOM‬قفل می‌شوند‬


  ‫• ‪ SMF05C.TCT‬تا حد ممکن نزدیک ‪ J_NAV‬قرار گیرد‪ .‬مسیر ‪ ESD‬به ‪ Ground Plane‬کوتاه و مستقیم باشد‪.‬‬

  ‫• ترتیب مسیر هر ‪ :Signal‬کانکتور → ‪ → TVS‬مقاومت سری ‪ → kΩ 1‬نود ‪ MCU. R_PULL‬و ‪ C_FILTER‬در سمت‬

  ‫‪ MCU‬قرار گیرند‪.‬‬

   ‫• کانال پنجم ‪ SMF05C.TCT‬استفاده نمی‌شود و ‪ NC‬باقی می‌ماند؛ آن را به سیگنال دیگری بدون بازبینی مستقل‬

  ‫وصل نکن‪.‬‬

  ‫• در ‪ Firmware، PA15/PB4/PB5/PB8‬همگی ‪ Digital Input‬و بدون ‪ Pull‬داخلی تنظیم شوند‪ .‬منطق کلید ‪Active-‬‬

  ‫‪ Low‬است‪.‬‬

   ‫• هیچ ‪ Shield‬برای ‪ Harness‬پنج‌سانتی‌متری داخل قاب الزام نشده است‪ .‬اگر مکانیک نهایی مسیر کابل را از کنار‬

  ‫نود ‪/SW‬سلف ‪ Buck-Boost‬عبور دهد‪ Routing ،‬فیزیکی ‪ Harness‬باید بازنگری شود‪.‬‬

   ‫• قبل از سوراخ‌کاری پنل‪ ،‬قطر رزوه و ضخامت قابل‌بستن ‪ DS-316‬خریداری‌شده با خود نمونه اندازه‌گیری شود؛‬

  ‫عرضه‌های بازار ایران ممکن است تولیدکننده یکسانی نداشته باشند‪.‬‬


‫‪ .9‬معیار ‪ PASS/FAIL‬این بلوک‬


               ‫معیار‬                                 ‫وضعیت‬                                      ‫توضیح‬


                                                                                 ‫مقادیر‪MPN ،‬ها‪ Connector family ،‬و‬
         ‫‪Architecture / BOM‬‬                            ‫‪PASS‬‬
                                                                                 ‫‪ Pinout‬قفل شده‌اند‪.‬‬




                              ‫‪Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09‬‬

[PDF PAGE BREAK]
                ‫معیار‬                                      ‫وضعیت‬                                      ‫توضیح‬


                                                                                        ‫ و سوراخ پنل بعد‬Harness ‫طول نهایی‬
            Mechanical fit                                 PENDING
                                                                                       .‫ نمونه واقعی تایید شود‬Dry-fit ‫از‬

     Schematic Compile / Validate                          PENDING                     .‫شماتیک هنوز ساخته نشده است‬

                                                                                        Altium ‫ واقعی‬Validate ‫فقط پس از‬
               Off-grid                                    PENDING
                                                                                       .‫ باشد‬0 ‫باید‬

                                                                                        Altium ‫ واقعی‬Validate ‫فقط پس از‬
           Electrical errors                               PENDING
                                                                                       .‫ باشد‬0 ‫باید‬

                                                                                        ‫تا قبل از تایید کامل شماتیک اجرا‬
          Update PCB / ECO                              NOT ALLOWED
                                                                                       .‫نشود‬




‫ منابع مرجع فنی‬.10

  .Viking Tech — ARG05DTC1002 official product specification: 0805, 10 kΩ, ±0.5%, 1/8 W, 25 ppm/°C •

  .UNI-ROYAL — Thick Film Chip Resistors, Chip Series, V.10 (part-number coding and 0805 ratings) •

  Samsung Electro-Mechanics — CL10B104KB8NNN# official component data: 100 nF, ±10%, 50 VDC, •

  .X7R, 0603

  .Semtech — SMF05C product documentation (TVS array for ESD/transient protection) •

  SHENZHEN SHOUHAN TECHNOLOGY — 2.54mm-5P ZZ-MS specification/drawing; XH-2.54-DZ •

  .specification

  .Daier — DS-316 SPST Mini Push Button official product reference •

  .STMicroelectronics — STM32G070KB datasheet (GPIO electrical limits / pin assignment baseline) •


  ‫ مرحله بعد پروژه باید‬.‫ نهایی است‬BOM ‫ از نظر معماری و‬Navigation Rev-A v1.0 — ‫وضعیت انتشار‬

  ‫ باشد؛ هیچ‬STM32G070KBT6 ‫ بر مبنای‬Pin Map ‫ فقط در بخش‬OLED ‫ و‬MicroSD ‫ اسناد‬Revision/‫بازبینی‬

 .‫ در این سند تغییر داده نشده است‬PCB ‫شماتیک یا‬




                                    Datalogger Rev-A · Navigation Buttons · v1.0 · 2026-08-09

[PDF PAGE BREAK]

```

## Datalogger_Expansion_Architecture_RevA_v1.0_FA_2026-08-13
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/02_HISTORICAL_BASELINE_V8/datalogger_source_revA_preschematic_v8_2026-08-18/Datalogger_Expansion_Architecture_RevA_v1.0_FA_2026-08-13.pdf`  
PDF/source SHA256: `a149969f93f2db02e5b3378cc0aefb92608d197bef348cbd5dbbfb1d5d0dec65`

```text
DATALOGGER REV-A


                                              Rev-A - v1.0 ‫معماری توسعه‬
                                                Internal Daughterboard + Protected External Port | 2026-08-13




                                       ‫معماری توسعه‬                                           ‫ پرمصرف‬IoT

         Internal + External                                                USB-ONLY


   ‫ از قبل حدس زده‬Main PCB ‫ روی‬24V/GSM/‫ توسعهپذیر باشد؛ درایور رله‬Core Board ‫ یک‬Rev-A: Main PCB ‫هدف‬
   .‫ ممنوع است‬Main ‫ به ریلهای‬Backfeed ‫ اما‬،‫ آینده میتواند پاور اختصاصی داشته باشد‬Daughterboard .‫نمیشود‬




                                                            Daughterboard ‫ هدر داخلی‬- J_EXP .1

                             ‫کاربرد‬                                               Net / MCU              Pin


                                  Output-only ‫ کممصرف؛‬Logic power 3V3_SYS                                      1


                                                            Reference                          GND             2


                                                       IoT ‫ اصلی‬UART PA9 / USART1_TX                           3


                                                       IoT ‫ اصلی‬UART PA10 / USART1_RX                          4


                                                            ‫ دوم‬UART PA0 / USART4_TX                           5


                                                            ‫ دوم‬UART PA1 / USART4_RX                           6


                                                        Expansion I2C PB6 / I2C1_SCL                           7


                                                        Expansion I2C PB7 / I2C1_SDA                           8


                                      ‫؛ خروجی حساس ممنوع‬ADC/Input/ID PA2 / EXP_ID_ADC                          9


                                                           ADC/GPIO PA3                                     10


                                                      ADC/GPIO/PWM PB0                                      11


                                                          GPIO/PWM PC6                                      12


                               startup caveat ‫؛‬GPIO/PWM low-priority PA8                                    13


                                                signal ‫ نزدیک‬Reference                         GND          14




DATALOGGER REV-A                                                                                     3 ‫ از‬1 ‫صفحه‬

[PDF PAGE BREAK]
                              ‫کاربرد‬                                               Net / MCU                  Pin


                                            Polarization / anti-misplug KEY / NC                                15


                                                             Reference                            GND           16



                    . MECH-HOLD footprint/‫ دقیق تا انتخاب نمونه‬pitch 2.54mm. MPN ,8×2 :Mechanical target



                                                             USB-only ‫ توان افزونه‬- J_EXP_PWR .2


 2×2 header
 Pin 1 = USB_5V_AUX      Pin 2 = USB_5V_AUX
 Pin 3 = GND              Pin 4 = GND


                                             .‫ قابل استفاده است‬USB ‫ در حضور‬S1-B ‫ فقط پس از‬USB_5V_AUX •
            Type-C/‫ پاوربانک‬capability ‫ میماند تا جریان پیک ماژول واقعی و‬DNP/Open ‫ اولیه‬enable/link ‫• مسیر‬
                                                                                                 .‫مشخص شود‬
                                                            .‫ تغذیه نمیشوند‬AA×2 ‫ از‬GSM/LTE/NB-IoT ‫• ماژولهای‬



                                                 ‫ پورت توسعه خارجی محافظتشده‬- J_EXT .3

                   ‫نقش‬                                               Net                                Pin


                               Reference                                                   GND                      1


                             Output-only 3V3_SYS                                                                    2


                              I2C external PB6 / I2C1_SCL                                                           3


                              I2C external PB7 / I2C1_SDA                                                           4


                              GPIO/PWM PC6 / EXT_IO1                                                                5


                               GPIO/ADC PA3 / EXT_IO2                                                               6




 J_EXT connector -> ESD -> series R -> MCU
 4 external signal lines => 2 × YENJI USBLC6-2SC6 (two data lines/device)
 YENJI pin 2=GND, pin 5=VCC, pins 1/6=line1, pins 3/4=line2.



  ‫ در شماتیک دستی با توجه به کاربرد پایه و کابل نهایی تعیین میشود؛ از االن‬J_EXT ‫ مکانیکی‬MPN ‫مقدار مقاومت سری و‬
                                                                                               .‫حدس زده نمیشود‬




DATALOGGER REV-A                                                                                        3 ‫ از‬2 ‫صفحه‬

[PDF PAGE BREAK]
                                                           ‫ آینده‬Daughterboard ‫ برای‬Power ‫ سیاست‬.4

                                        .‫ هستند؛ تزریق ولتاژ به آنها ممنوع است‬Output-only USB_5V_AUX ‫ و‬3V3_SYS •
                       level ‫ و‬GND/reference ‫ میتواند منبع تغذیه اختصاصی داشته باشد؛ در آن حالت‬Daughterboard •
                                                                                               .‫ بررسی میشود‬compatibility
                    ‫ از طریق‬backfeed ‫ جلوگیری از‬،‫ متصل باشد‬Main ‫ به سیگنالهای‬Daughterboard ‫• اگر پاور مستقل‬
                                                  .‫ اجباری است‬Revision ‫ متناسب با همان‬isolation/ORing/level-shifting
                .‫ تخصصی طراحی میشوند‬Daughterboard ‫ روی‬Power Driver ‫ سلونوئید و‬،‫ رله‬،12/24V ‫• خروجیهای‬



                                                                      ‫ پایههایی که عمدا ً عمومی نمیشوند‬.5

                                  ‫علت‬                                                              ‫پایه‬


                                                     ‫ آینده‬oscillator ‫ رزرو‬PC14 / PC15


                                                        SWDIO / SWCLK PA13 / PA14


                                                   ‫ اختصاصی‬Reset/SWD NRST


                                        RTC/OLED/SHT3x :‫ سیستم‬I2C2 PA11 / PA12


                                                ‫مالکیت بلوکهای قفلشده‬                                     MicroSD / Navigation pins




                                                                                                                 ‫ وضعیت‬.6

                                     LOCK                                                                    J_EXP electrical pinout


                                     LOCK                                                                         J_EXP_PWR policy


                                     LOCK                                                                    J_EXT electrical pinout


                              MECH-HOLD                                                           Connector exact MPN / footprint


                                SCH-HOLD                                                            External series resistor values


                                 PENDING                                                           Physical cable/EMI qualification




                                                                                                                     ‫ منابع‬.7

STM32G070xB official datasheet: https://www.st.com/resource/en/datasheet/stm32g070cb.pdf
YENJI USBLC6-2SC6 datasheet: included locally under datasheets/YENJI_USBLC6-2SC6_c323793.pdf




DATALOGGER REV-A                                                                                                         3 ‫ از‬3 ‫صفحه‬

[PDF PAGE BREAK]

```

## Datalogger_Master_Pin_Budget_Conflict_Check_RevA_v1.1_FA_2026-08-13
Original member: `Datalogger_RevA_MASTER_BACKUP_2026-08-29_T22_RELEASE_EXACT/10_POST_BASELINE_UPDATES_2026-08-19_TO_2026-08-22/T16_MICROSD_ST_PROCUREMENT_LOCK/sources/Datalogger_Master_Pin_Budget_Conflict_Check_RevA_v1.1_FA_2026-08-13.pdf`  
PDF/source SHA256: `f9f009d8047e9a94c2f37c97173f02678c51c468b909481a4d66bba36c06a3aa`

```text
DATALOGGER REV-A


        Master Pin Budget + Conflict Check - v1.1
                                                     STM32G070KBT6 | Expansion integrated | 2026-08-13




                                ‫پایههای حسابشده‬                                                    ‫ ناخواسته‬Conflict

                      32 / 32                                                       0


     Validate ‫ به معنی‬PASS ‫ این‬.‫ را بهروزرسانی میکند‬Expansion ownership ‫ و‬Pin Budget ‫ فقط‬v1.1 ‫این نسخه‬
                                                                                                     .‫شماتیک نیست‬




                                                                                     Master Pin Map .1

        Status              Owner                        Net / Function                             MCU pin           Pin


                   LOCK              MicroSD                               SD_CARD_DET_N PB9                      1


             RESERVED                   MCU                               Oscillator reserve PC14                 2


             RESERVED                   MCU                               Oscillator reserve PC15                 3


                   LOCK                Power                                       3V3_SYS VDD/VDDA               4


                   LOCK                Power                                          GND VSS/VSSA                5


                   LOCK                 MCU                                     Reset/SWD NRST                    6


                    EXP             Expansion                        USART4_TX / J_EXP pin5 PA0                   7


                    EXP             Expansion                        USART4_RX / J_EXP pin6 PA1                   8


                 SPECIAL            Expansion              EXP_ID_ADC / input only preferred PA2                  9


                    EXP             Expansion                    ADC/GPIO / J_EXP10 / J_EXT6 PA3                  10


                   LOCK              MicroSD                              SD_CS / SPI1_NSS PA4                    11


                   LOCK              MicroSD                                        SD_SCK PA5                    12


                   LOCK              MicroSD                                      SD_MISO PA6                     13


                   LOCK              MicroSD                                      SD_MOSI PA7                     14


                    EXP             Expansion                      ADC/GPIO/PWM / J_EXP11 PB0                     15


                   LOCK              MicroSD                                   SD_PWR_CTL PB1                     16


                   LOCK                 OLED                                     OLED_CTL PB2                     17


        LOW PRIORITY                Expansion            GPIO/PWM / J_EXP13; startup caveat PA8                   18




DATALOGGER REV-A                                                                                              3 ‫ از‬1 ‫صفحه‬

[PDF PAGE BREAK]
        Status                    Owner                             Net / Function                              MCU pin         Pin


         IOT PRIMARY                      Expansion                     USART1_TX / J_EXP3 primary IoT PA9                    19


                   EXP                    Expansion                        GPIO/PWM / J_EXP12 / J_EXT5 PC6                    20


         IOT PRIMARY                      Expansion                     USART1_RX / J_EXP4 primary IoT PA10                   21


                 LOCK             RTC/OLED/SHT3x                                     I2C2_SCL system bus PA11                 22


                 LOCK             RTC/OLED/SHT3x                                     I2C2_SDA system bus PA12                 23


                 LOCK                         MCU                                                SWDIO PA13                   24


                 LOCK                         MCU                                                SWCLK PA14-BOOT0             25


                 LOCK                  Navigation                                               KEY_UP PA15                   26


                 LOCK                          RTC                                           RTC_INT_N PB3                    27


                 LOCK                  Navigation                                            KEY_DOWN PB4                     28


                 LOCK                  Navigation                                               KEY_SET PB5                   29


                   EXP                    Expansion                           I2C1_SCL / J_EXP7 / J_EXT3 PB6                  30


                   EXP                    Expansion                           I2C1_SDA / J_EXP8 / J_EXT4 PB7                  31


                 LOCK                  Navigation                                             KEY_BACK PB8                    32




                                                                                                     Conflict rules .2

                                                      .‫ است‬OLED/SHT3x ‫ و‬RTC ‫ بین‬I2C2 ‫ تنها اشتراک عمدی‬PA11/PA12 •
                         .‫ هستند؛ این اشتراک عمدی است‬J_EXT ‫ و‬J_EXP ‫ مشترک بین‬I2C1 Expansion ‫ باس‬PB6/PB7 •
        ‫ است؛ مصرف همزمان‬Expansion ‫ میشوند و مالکیت آنها‬J_EXT expose ‫ و‬J_EXP ‫ همزمان روی‬PA3 ‫ و‬PC6 •
                                                                            .‫دختربرد مدیریت شود‬/firmware ‫باید توسط‬
                                    .‫ برای خروجی کنترلی حساس استفاده نمیشود‬Errata/LSCO caveat ‫ به دلیل‬PA2 •
                                                                      .‫ آینده حفظ میشوند‬oscillator ‫ برای‬PC14/PC15 •



                                                                      Expansion connector mapping .3


 J_EXP 2×8:
 1=3V3,2=GND,3=PA9,4=PA10,5=PA0,6=PA1,7=PB6,8=PB7,9=PA2,10=PA3,11=PB0,12=PC6,13=PA8,14=GND,15=KEY/
 NC,16=GND
 J_EXT 1×6: 1=GND,2=3V3,3=PB6,4=PB7,5=PC6,6=PA3




                                                                                                        Gate status .4

                           PASS                                                  Architecture + Pin Assignment conflict check




DATALOGGER REV-A                                                                                                          3 ‫ از‬2 ‫صفحه‬

[PDF PAGE BREAK]
                     NOT STARTED                                                                  Manual schematic created


                     NOT STARTED                                                     Altium Validate Off-grid=0 / Electrical=0


                       FORBIDDEN                                                                           ECO / Update PCB




                                                                                                    ‫ منبع رسمی‬.5

ST STM32G070xB datasheet: https://www.st.com/resource/en/datasheet/stm32g070cb.pdf




DATALOGGER REV-A                                                                                                   3 ‫ از‬3 ‫صفحه‬

[PDF PAGE BREAK]

```
