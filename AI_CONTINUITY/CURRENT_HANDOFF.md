# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25BL TPS22918 ECO procurement-blocked by Iran-local rule; new Iran-available load-switch qualification required, 2026-09-28

### Live project baseline

- Authoritative source: private GitHub `mohammadhpp/Datalogger-RevA`, branch `main`, plus the user's local repo `C:\\#MHP FILES\\DataLoger`. Historical ZIPs are rollback/evidence only.
- No RevA board has been fabricated. Final PCB-mounted BOM parts were purchased before this redesign review; do not silently change CAD or purchased-BOM assumptions.
- T23 routing **PASS / CLOSED**. T24 courtyard **129/129 persistent / CLOSED**. Last accepted Full Batch DRC remains **0 warnings / 0 violations** at PCB checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
- Canonical PCB: `DATALOGER_RevA.PcbDoc`. Canonical PCB library: `Datalogger_RevA_Clean.PcbLib`.
- T25BF must **not** be rerun. No PSpice simulation is currently running.
- **FABRICATION HOLD remains active.**

### 2026-09-28 non-destructive GitHub cleanup audit

Report: `AI_CONTINUITY/GITHUB_CLEANUP_AUDIT_2026-09-28.md`.

Audit findings:
- 32 root-level T23/T24-named files total 1,215,177 bytes. They are historical routing/DRC/courtyard evidence and were **not deleted or moved**.
- `DATALOGER_RevA.PcbLib` and `Datalogger_RevA_Clean.PcbLib` are byte-identical: 294,912 bytes, blob `f0a6f2ff01768d69fac595770efa8a8685bf91a7`. The Clean filename is canonical and referenced by the project. The alternate copy is only a deletion candidate after a live-Altium dependency check; it was **not deleted**.
- `AI_CONTINUITY/` had 76 files totaling 1,382,682 bytes at audit time. Most of the size is source/evidence retention; no continuity/source record was deleted.
- `DATALOGER_final.PrjPcb` still referenced `Datalogger_RevA_Clean.SchLib`, but the SchLib had been removed in engineering checkpoint `3ea38daf...`. The exact historical blob `13cfb621487d7078a49562502bbc142f553a5834` was restored byte-identically.
- SchLib restore commit: `4c1496497932f05cf8af4234936ba66468dc2c2a`.
- Cleanup audit commit: `214168916b20ae424d1833fa30c412557aa7014f`.

Do not perform further cleanup by deletion merely to reduce repository size. Any later archive move needs a manifest and reference-path audit.

### T25BF/T25BG retained verdict

User result `Datalogger_T25BF_v1_Result_20260928_101716.zip` was already audited. Both official TI encrypted TPS631000 traces completed but neither established a regulated 3.3V pre-event state:
- VIN=1.80V pre-event VOUT 1.485..1.950V.
- VIN=2.80V control pre-event VOUT 2.632..2.635V.

Therefore post-step waveforms are not valid regulated-load-step evidence. Precharging COUT does not initialize inaccessible encrypted controller states. Short-window/precharge retries are closed.

### T25BH retained conditional slew target

`AI_CONTINUITY/T25BH_SD_SLEW_THRESHOLD_VERDICT_FA.md` computed conditional minimum artificial conductance-ramp constants from 81.641us to 3923.242us across the 19/280mA background and assumed 0.5/1.0/1.5A source-ceiling sensitivities. The values are design sensitivities only; they do not map to the live AO3401A/BC847B gate and do not qualify the board.

### T25BI — controlled-inrush redesign review

Report:
`AI_CONTINUITY/T25BI_CONTROLLED_SD_INRUSH_REDESIGN_REVIEW_FA.md`

Reproducible arithmetic:
`AI_SCRIPTS/T25/T25BI_TPS22918_Controlled_Inrush_Screen_v1.py`

Selected **simulation candidate**, not yet CAD/BOM ECO:
- TI `TPS22918`, catalog SOT-23-6 load switch.
- Proposed mapping: VIN=`3V3_SYS`, VOUT=`SD_VDD`, ON=`SD_PWR_CTL`, CT capacitor to GND, QOD tied to VOUT, GND to GND.
- Add dedicated 1uF X5R/X7R input bypass at VIN/GND if proposal is approved.
- Initial CT target: **4.7nF X7R, +/-10%, >=16V**.
- Existing downstream SD nominal bank remains 54.1uF for the first model fixture.
- Current AO3401A/BC847B/gate-resistor circuit remains untouched in Altium pending simulation and explicit ECO approval.

Why this candidate:
- TPS22918 is active, VIN 1..5.5V, 2A continuous, 53mOhm typical RON at 3.3V, active-high ON, adjustable CT slew, QOD, and leaded SOT-23-6.
- TI publishes an **official unencrypted TPS22918 PSpice transient model package `SLVMBI6A`**.
- It removes the current gate-Qg/threshold mapping problem. It does **not** provide adjustable current limiting, so actual card startup/operating current remains open.

TI Rev-C typical 3.3V 10%-90% tR screen:
- CT 1.0nF -> 1.680ms -> nominal 54.1uF cap-only inrush about 85.014mA.
- CT 2.2nF -> 3.580ms -> about 39.895mA.
- **CT 4.7nF -> 7.980ms -> about 17.898mA.**
- CT 10nF -> 17.505ms -> about 8.159mA.

These times are **typical at 25C** in the TI test condition (CL=0.1uF), not guaranteed RevA timing. The card's real current transient is still unknown.

For commanded SD-off with VIN held at 3.3V, using datasheet RPD max 35ohm and nominal 54.1uF gives a simple RC 3.3V->0.5V screen of about 3.573ms. SD interface lines still must be low/disconnected while the card is unpowered and power-cycle timing must be validated.

T25BI status:
`CONTROLLED_INRUSH_TOPOLOGY_SELECTED_FOR_SIMULATION / CT_4P7NF_INITIAL / OFFICIAL_PSPICE_MODEL_AVAILABLE / CAD_UNCHANGED / FABRICATION_HOLD`.

### T25BJ/T25BK — official TPS22918 sweep executed and independently audited

User result:
`Datalogger_T25BJ_Sweep_v2_Result_20260928_120158.zip`

Result ZIP SHA256:
`0addb80d7255dad9101b128f1d1cc36fdab867afb25349d6f6b4b61c9cc9ea76`

All 16 official-model PSpice cases:
- `JOB CONCLUDED`;
- zero counted warning;
- zero counted error/fatal;
- 7,001 raw voltage rows and 7,001 raw source-current rows each.

**The generated `T25BJ_v2_Summary.csv` is rejected.** PSpice split voltage traces and `I(V_SRC)` into separate PRINT tables; the PowerShell regex consumed the next timestamp as a false seventh field. Raw PSpice outputs are valid and were re-audited independently.

Auditor:
`AI_SCRIPTS/T25/T25BK_Audit_T25BJ_Raw_v1.py`

Verdict report:
`AI_CONTINUITY/T25BK_TPS22918_VENDOR_MODEL_SWEEP_VERDICT_FA.md`

Preferred CT=4.7nF, nominal CSD=54.1uF corrected raw results:
- 0mA fixture: rise 7.060ms, to 2.7V 8.745ms, VINmin 3.298V, source peak 20.24mA, QOD to 0.5V 2.72ms.
- 100mA fixture: rise 7.320ms, to 2.7V 9.025ms, VINmin 3.289V, source peak 113.4mA.
- 200mA fixture: rise 7.470ms, to 2.7V 9.200ms, VINmin 3.280V, source peak 202.5mA.
- 400mA fixture: rise 7.690ms, to 2.7V 9.455ms, VINmin 3.261V, source peak 392.5mA, VOUT pre-off about 3.238V, QOD to 0.5V 0.64ms.

CSD=27.05uF sensitivity at CT=4.7nF confirms nearly the same heavy-load peak; at 400mA fixture source peak remains 392.5mA. Therefore load current dominates the heavy case rather than capacitor inrush.

Device-model verdict:
`TPS22918_CT_4P7NF_VENDOR_MODEL_GATE_PASS / RAW_OUT_AUDIT_PASS / TPS631000_SOURCE_GATE_STILL_OPEN / NO_BOARD_PASS / FABRICATION_HOLD`.

### T25BL — exact Altium ECO proposed, not applied

Proposal:
`AI_CONTINUITY/T25BL_SD_POWER_SWITCH_ECO_PROPOSAL_FA.md`

Live `03_MICROSD.SchDoc` remains unchanged at blob `0793ee4aeae92fc5737796ce4631dac9770619f3`.

Proposed replacement:
- remove active SD switch elements `Q_SD=AO3401A`, `Q_SD_DRV=BC847B`, `R_SD_DRV_BASE=10k` and old PMOS `R_GATE=100k`;
- add `U_SD_SW=TPS22918DBVT`, DBV/SOT-23-6;
- physical mapping: pad1 VIN=`3V3_SYS`, pad2 GND, pad3 ON=`SD_PWR_CTL`, pad4 CT=`SD_CT`, pad5 QOD=`SD_VDD`, pad6 VOUT=`SD_VDD`;
- add `C_SD_CT=4.7nF`, proposed `CL10B472KB8NNNC`, X7R +/-10%, 50V, 0603;
- add `C_SD_SW_IN=1uF`, proposed `CL10A105KP8NNNC`, X5R +/-10%, 10V, 0603;
- add/repurpose one 100k `0603WAF1003T5E` as `R_SD_ON_PD` from `SD_PWR_CTL` to GND so TPS22918 ON never floats;
- tie QOD directly to VOUT;
- keep the existing downstream SD capacitor bank and SD signal circuitry unchanged;
- delete `SD_GATE` only if it becomes orphaned after ECO.
- conservative firmware proposal: keep SD power OFF at least 5ms before re-enable until hardware validation closes the value.

The TPS22918 candidate is an active TI catalog device. TI DBV pinout is 1 VIN, 2 GND, 3 ON, 4 CT, 5 QOD, 6 VOUT. Current CAD has **not** been changed.

### Iran-local procurement rule — locked 2026-09-28

User requires every newly proposed RevA component/replacement to be practically available from an Iranian seller/supplier before it can become an executable ECO or BOM change. Global distributor stock alone is not sufficient.

Immediate effect on T25BL:
- TPS22918 remains technically validated in the bounded vendor-model fixture but **Iran-local stock was not verified**, so the TPS22918 ECO is **PROCUREMENT_BLOCKED / REFERENCE_ONLY** and must not be applied to CAD.
- Digikapart currently lists a 1uF 0603 X5R +/-10% 50V MLCC (`06035C105KAT2A`) as available.
- Exact 4.7nF 0603 X7R Iranian stock was not verified in the current search; an Iranian 4.7nF SMD 0805 listing exists.
- `SY6280` appears in recent SkyTech Iran stock/replenishment lists and is a candidate for technical evaluation. Available preliminary datasheet: 2.4..5.5V, programmable current limit 0.13..2A range, typical 80mOhm, automatic output discharge, SOT23-5; no adjustable CT slew pin. It is not a drop-in functional equivalent to TPS22918.

Do not choose SY6280 merely because it is locally available; first re-run the controlled-inrush/source-margin analysis around its programmable current-limit behavior and card-startup constraints.

### Remaining engineering gates

- T25BL requires explicit user approval before changing schematic/PCB/purchased-BOM assumptions.
- Actual unbranded 4GB card transient remains unknown.
- TPS631000 source capability/transient at loaded battery VIN=1.80V remains unqualified.
- Continuous battery->USB->battery no-reset behavior remains a requirement, not a PASS.
- OVP transient gate remains open.
- Exact installed effective capacitances under bias remain open.
- No integrated startup/handoff/SD/OLED or fabrication PASS exists.

## NEXT EXECUTABLE ACTION

Do **not** apply T25BL TPS22918 ECO.

1. Treat TPS22918 result as a validated reference architecture only.
2. Search/qualify Iran-available load-switch candidates, starting with SY6280 because current Iranian stock evidence exists.
3. For each candidate, verify datasheet/source quality, package/manual-assembly suitability, input range, RON, discharge behavior, inrush/current-limit mechanism, and compatibility with the 3.3V SD rail.
4. Re-run a bounded SD startup/inrush analysis against T25BH source sensitivities.
5. Only after both **technical PASS + Iran-local availability PASS**, issue a replacement exact ECO and ask for explicit user approval.
6. Then apply schematic/PCB changes, DRC/audits and continue TPS631000/USB handoff/OVP gates before fabrication release.

No T25BF rerun. Fabrication Hold remains.
