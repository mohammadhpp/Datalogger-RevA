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
