# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25BI complete / T25BJ official TPS22918 model-package preflight prepared, 2026-09-28

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

### T25BJ — prepared, external package acquisition required

Files committed:
- `AI_SCRIPTS/T25/T25BJ_TPS22918_Model_Preflight_v1.ps1`
- `AI_SCRIPTS/T25/Run_T25BJ_TPS22918_Model_Preflight_v1.cmd`

The launcher:
1. uses an existing `SLVMBI6*.zip` in Windows Downloads if present, otherwise downloads `https://www.ti.com/lit/zip/SLVMBI6` directly from TI over HTTPS;
2. expands the package;
3. records the ZIP SHA256, file inventory and hashes;
4. extracts model-text filenames and every visible `.SUBCKT` header;
5. creates `Datalogger_T25BJ_Model_Preflight_v1_Result_<timestamp>.zip`;
6. performs **no PSpice run**, no Altium edit, no BOM edit.

The current AI environment can verify TI's product page and model availability but cannot retrieve the binary ZIP payload itself. Therefore this one external acquisition step is the next unavoidable dependency.

### Remaining engineering gates

- Actual unbranded 4GB card startup/operating transient is unknown.
- TPS22918 CT timing with the RevA 54.1uF bank must be checked with the official model; typical datasheet arithmetic alone is not a board PASS.
- TPS631000 1.80V real transient source behavior remains unqualified; T25BH's 0.5/1.0/1.5A ceilings are sensitivity assumptions only.
- Continuous battery->USB->battery no-reset behavior remains a locked requirement, not a PASS.
- OVP transient gate remains open.
- Effective installed capacitances under bias remain open.
- No integrated startup/handoff/SD/OLED or fabrication PASS exists.

## NEXT EXECUTABLE ACTION

On the user's Windows repo, run:

`AI_SCRIPTS\T25\Run_T25BJ_TPS22918_Model_Preflight_v1.cmd`

Then upload the generated `Datalogger_T25BJ_Model_Preflight_v1_Result_*.zip`.

On receipt, do **not** stop at inventory. Parse the official model pin order/dependencies, immediately construct the bounded T25BJ TPS22918 fixture (CT 2.2/4.7/10nF; CSD sensitivity; 0/100/200/400mA clearly-labeled load stimuli), provide/run the one-click PSpice wrapper, audit raw waveforms, and only then present the exact proposed Altium ECO. Do not modify CAD before explicit user approval of that ECO.

No T25BF rerun. Fabrication Hold remains.
