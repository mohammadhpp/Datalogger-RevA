# T25B — Official TI Model Archive Preflight

Date: 2026-09-23. Status: **static archive and pin-map PASS; simulator execution PENDING**.

## Git/source checkpoint

- User ran `Git_Save.cmd` v2.5. New GitHub `main` checkpoint: `248879d3e7488af5a5920b54f0a4a5a5c01821e0`, child of the T25A continuity commits.
- That checkpoint changed `DATALOGER_final.PrjPcb` and `Script_Project1.PrjScr` only. The project removed a duplicate `DATALOGER_RevA.PcbLib` document entry, but still lists canonical `Datalogger_RevA_Clean.PcbLib` and canonical `DATALOGER_RevA.PcbDoc`. The schematic, canonical PCB and canonical PcbLib were not changed in this checkpoint.
- `DATALOGER_final.PrjPcb` lists `Datalogger_RevA_Clean.SchLib`, but that file is absent from GitHub's `main` tree. Do not try to rebuild/replace the canonical schematic library from the older T23 backup without checking the current local project first. Embedded symbols on the present SchDoc sheets can still be audited.

## Downloaded official archives

| Device | Official archive | ZIP SHA256 / bytes | Static contents |
| --- | --- | --- | --- |
| `U_SYS` TPS631000DRLR | [TI TPS631000 encrypted model](https://www.ti.com/lit/zip/SLVMDV2), advertised as SLVMDV2.ZIP | `f55c75639ad5b62c5437ec114301905fe6c63408cdb689825eb542c095ecd946`; 540,827 bytes | ZIP integrity PASS. Contains `TPS631000_SYMBOL.lib` with `**$ENCRYPTED_LIB` / `$CDNENCSTART_ADV2`, OrCAD symbols/project and soft-start profiles. |
| `U_PMUX` TPS2116DRLR | [TI TPS2116 unencrypted transient model](https://www.ti.com/lit/zip/SLVMDI4), advertised as SLVMDI4A.ZIP | `730dd922475b68183cb2d3ecac3259c8f5637e6458764ced7f3fbc0c89da80a7`; 59,924 bytes | ZIP integrity PASS. Contains `TPS2116_TRANS.LIB`, OrCAD symbol/project and startup profile. Model header: TI Final 1.10, 05 May 2021, transient, PSpice 17.2-2016 S074. |

These are vendor assets downloaded for local inspection, **not attached to the current Altium schematic and not committed into the project's Git tree**.

## Exact subcircuit-to-schematic pin mapping

The following headers were read from the actual ZIP contents, then compared with `01_POWER.SchDoc` binary pin records. They are *not* an assertion that a given simulator accepts the models.

| TPS631000 physical pin | Schematic `U_SYS` | `TPS631000_STARTUP` interface position |
| ---: | --- | ---: |
| 1 | VOUT (`3V3_SYS`) | 1 VOUT |
| 2 | LX2 (`L1`) | 2 LX2 |
| 3 | LX1 (`L1`) | 3 LX1 |
| 4 | VIN (`VIN_MUX`) | 4 VIN |
| 5 | EN (`VIN_MUX`) | 5 EN |
| 6 | MODE (`MODE_PFM`, 0 Ω to GND) | 6 MODE |
| 7 | GND | 7 GND |
| 8 | FB (`FB_3V3`) | 8 FB |

The exact vendor header is `.SUBCKT TPS631000_STARTUP VOUT LX2 LX1 VIN EN MODE GND FB PARAMS: SS=0`. Its exposed order matches physical pins 1–8. Internal behavior is encrypted and cannot be inspected or modified.

| TPS2116 physical pin | Schematic `U_PMUX` | `TPS2116_TRANS` interface position |
| ---: | --- | ---: |
| 1 | GND | 1 GND |
| 5 | MODE (`USB_VBUS_PROT`) | 2 MODE |
| 4 | PR1 (`PMUX_PR1`) | 3 PR1 |
| 8 | ST (`PMUX_ST`) | 4 ST |
| 3 | VIN1 (`USB_VBUS_PROT`) | 5 VIN1 |
| 6 | VIN2 (`BAT_SW`) | 6 VIN2 |
| 2 | VOUT (`VIN_MUX`) | 7 VOUT_0 |
| 7 | VOUT (`VIN_MUX`) | 8 VOUT_1 |

The exact vendor header is `.SUBCKT TPS2116_TRANS GND MODE PR1 ST VIN1 VIN2 VOUT_0 VOUT_1`. **Its positional order differs from physical pin-number order.** An import that maps pins 1–8 sequentially would be wrong. Both physical VOUT pins must join `VIN_MUX`; use the explicit mapping above.

## Archive/runtime limits

1. The TPS631000 example `Soft_Start.cir` references `../../../tps631000.lib`, but there is no file of exactly that name in the downloaded ZIP. The archive's `TPS631000_SYMBOL.lib` exposes `TPS631000_STARTUP`. A copy of the original example will not run as-is without resolving that library path/reference in an **isolated** working directory. The example also uses its own source, divider, load and passive values; do not mistake that example for the Datalogger circuit.
2. The TPS631000 encrypted payload is intended for compatible Cadence/PSpice execution. Altium simulator compatibility is unproved. Do not claim a working converter transient merely because the ZIP is intact and the pin names match.
3. TPS2116's model states that turn-on, switchover in priority/manual mode, reverse-current blocking, quiescent/standby current, on-resistance versus VIN and ST behavior are modeled. Its own header explicitly says **temperature dependence is not modeled**. It uses PSpice syntax/behavioral elements; runtime compatibility outside PSpice has not been checked.
4. No native PSpice/Altium runtime is available in this analysis workspace. Neither model was executed here. The static checks cannot validate convergence, startup timing, load-step amplitude, ripple or a rail-pass requirement.

## Next exact action — T25B runtime smoke tests

1. On a machine with supported PSpice, unpack each original archive to a separate temporary folder. Verify its SHA256 above. Keep the project's canonical `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc` and libraries untouched.
2. Run the TPS2116 supplied startup example against `TPS2116_TRANS.LIB`. Confirm the transient completes without missing-model/error messages; plot VIN1, VIN2, both VOUT pins, PR1 and ST. This is a **tool/model smoke test**, not a board qualification.
3. For TPS631000, inspect the example's missing `tps631000.lib` reference in the local PSpice project. Resolve it only by pointing to the included `TPS631000_SYMBOL.lib` in a duplicate example folder, then confirm whether the compatible simulator accepts the encrypted `TPS631000_STARTUP` block and completes a transient. Record the exact simulator edition/version and any errors.
4. Only after both examples run: construct a separate project-specific power bench using the T25A pin/net mapping and actual component values. Do not substitute the TI example's component values or invent AA source resistance, USB droop, effective capacitance, SD/OLED load waveforms or acceptance limits.
5. First check whether the **current local** `Datalogger_RevA_Clean.SchLib` exists and why it is absent from GitHub before any eventual model attachment/ECO. A read-only, isolated testbench can proceed without modifying this source library.

No PCB change and no fresh DRC were performed in this preflight. Last accepted T24 Full Batch DRC remains 0 warnings / 0 violations.
