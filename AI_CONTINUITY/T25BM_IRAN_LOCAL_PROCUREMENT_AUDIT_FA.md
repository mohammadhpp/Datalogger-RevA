# T25BM — Iran-local procurement audit for T25BL added parts

Date: 2026-09-28.

Locked rule: every newly proposed RevA component must have both technical acceptance and practical Iranian availability evidence before executable ECO/BOM use.

## U_SD_SW — TPS22918DBVT

**PASS — technical + Iran availability.**

User supplied a direct screenshot from SkyTech Iran for:
- `TPS22918DBVT(13MW)`
- SOT-23-6
- vendor summary 5.5V / 2A / 52mOhm
- retail and quantity pricing shown
- quality label shown as `ORIGINAL(distributor)`.

This clears the prior procurement block. Exact on-hand quantity must still be reconfirmed at order time.

## C_SD_SW_IN — 1uF

**PASS — Iran availability.**

Iranian Digikapart currently lists:
- `06035C105KAT2A`
- 1uF
- 0603 / 1608 metric
- X5R
- +/-10%
- 50V
- status shown as `موجود`.

This exceeds the electrical minimum for the proposed local TPS22918 VIN bypass.

## C_SD_CT — 4.7nF

**OPEN — value/package availability found, exact dielectric/tolerance not yet verified locally.**

An Iranian marketplace listing (ISEE/Sisoog index, seller: Chohreh Electronics, Tehran) currently shows:
- 4.7nF
- SMD 0805
- status `موجود`.

However that listing exposes no dielectric, voltage or tolerance specification. Therefore it is not yet acceptable for final RevA BOM under the locked procurement rule.

Global reference MPN `CL10B472KB8NNNC` is confirmed as 4.7nF, +/-10%, 50V, X7R, 0603, but global stock does not satisfy the Iran-local requirement by itself.

## Current procurement gate

- TPS22918DBVT: PASS
- 1uF VIN bypass: PASS
- 100k ON pulldown: existing project part / no new procurement issue
- 4.7nF CT capacitor: OPEN

T25BL must remain unapplied until an Iran-available 4.7nF capacitor with adequate documented dielectric/tolerance/voltage is identified, or an alternate CT value with Iran-local availability is technically re-qualified.

CAD unchanged. Fabrication Hold remains.


## Lion Electronic user-provided procurement evidence — 2026-09-28

User supplied screenshots from Lion Electronic showing exact TDK parts and live Iranian stock/pricing.

### C_SD_CT — exact local part now PASS

**TDK C1608NP01H472J080AA**
- 4.7 nF
- +/-5%
- 50 VDC
- NP0/C0G
- 0603 / EIA 1608
- Lion Electronic screenshot shows stock: **3,940 pcs**
- quantity pricing displayed for 20 / 200 / 2000 / 4000 pcs.

TDK official product data confirms: production status, 4.7 nF +/-5%, 50 VDC, NP0 (0 +/-30 ppm/degC), 0603, -55 to +150 C.

This is electrically **better than the earlier proposed 4.7 nF X7R +/-10%** for the TPS22918 CT node because NP0/C0G gives materially lower capacitance variation with voltage and temperature.

TI TPS22918 guidance recommends at least 16 V CT-capacitor rating for VIN=1.2..4 V; TI application support further recommends 25 V minimum for optimal margin because CT can see approximately 3x VIN. The 50 V rating therefore has ample margin at the RevA 3.3 V rail.

Status:
`C_SD_CT_C1608NP01H472J080AA = TECHNICAL_PASS + IRAN_AVAILABILITY_PASS`.

### C_SD_SW_IN — exact local part now PASS

**TDK C2012X7R1H105K125AB**
- 1 uF
- +/-10%
- 50 VDC
- X7R
- 0805 / EIA 2012
- Lion Electronic screenshot shows stock: **6,460 pcs**
- quantity pricing displayed for 20 / 200 / 1000 / 2000 pcs.

TDK official product data confirms: production status, 1 uF +/-10%, 50 VDC, X7R, 0805, -55 to +125 C.

TI TPS22918 layout guidance recommends a 1 uF low-ESR ceramic bypass using X5R or X7R placed close to VIN/GND. Therefore this exact part is technically suitable. Its 0805 package differs from the earlier provisional 0603 footprint; the final ECO must use an 0805 footprint and verify local placement clearance.

Status:
`C_SD_SW_IN_C2012X7R1H105K125AB = TECHNICAL_PASS + IRAN_AVAILABILITY_PASS`.

### Updated T25BL procurement gate

- TPS22918DBVT: PASS
- C_SD_CT = TDK C1608NP01H472J080AA: PASS
- C_SD_SW_IN = TDK C2012X7R1H105K125AB: PASS
- 100k ON pulldown: existing project part, no new procurement dependency

Therefore all newly introduced T25BL parts now satisfy the locked dual requirement:
`TECHNICAL PASS + IRAN AVAILABILITY PASS`.

T25BL is no longer procurement-blocked. CAD is still unchanged pending explicit user approval of the consolidated ECO.
