# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25BO/P1 and T25BP/P2 architectures selected; T25BR/P3 hold-up architecture selected; T25BQ official TPS54202 model preflight ready, 2026-09-28

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

Every newly proposed RevA component/replacement must have practical Iranian availability evidence before executable ECO/BOM use.

Updated evidence:
- User supplied a direct screenshot of SkyTech Iran product page for **TPS22918DBVT(13MW)**.
- The page lists the exact part as a 5.5V / 2A / 52mOhm load switch, SOT-23-6, with Iranian single and volume pricing and quality label `ORIGINAL(distributor)`.
- Therefore `TPS22918DBVT = IRAN_AVAILABILITY_PASS`.
- Exact live stock quantity was not shown in the screenshot, so order-time stock must still be reconfirmed.
- Combined status for U_SD_SW: `TECHNICAL_PASS + IRAN_AVAILABILITY_PASS`.

The earlier TPS22918 procurement block is superseded. Do not switch to SY6280 unless TPS22918 later becomes unavailable or another engineering reason arises.

T25BL local-procurement gate is now fully cleared by user-provided Lion Electronic evidence:

- `TPS22918DBVT(13MW)`: PASS, SkyTech Iran.
- `C_SD_CT`: **TDK C1608NP01H472J080AA**, 4.7nF +/-5%, 50V, NP0/C0G, 0603 — Lion screenshot stock 3,940 pcs.
- `C_SD_SW_IN`: **TDK C2012X7R1H105K125AB**, 1uF +/-10%, 50V, X7R, 0805 — Lion screenshot stock 6,460 pcs.
- 100k ON pulldown: existing project part.

Official TDK data was checked for both exact MPNs. The 4.7nF NP0 part is technically stronger for CT stability than the earlier provisional X7R +/-10% choice. The 1uF part is 0805 rather than provisional 0603, so the final PCB ECO must use the correct 0805 footprint.

All newly introduced T25BL parts now meet:
`TECHNICAL PASS + IRAN AVAILABILITY PASS`.


### T25BO — P1 weak-battery path architecture selected

At the locked 1.80V pack-under-load corner, only 150mV exists above the TPS631000 >1.65V startup boundary. With Pout=0.924W, `Rpath,max=0.267857*eta ohm`. Using F1 catalog cold resistance about 38mOhm and TPS2116 VIN2 RON max 66mOhm at 1.8V leaves only about 83.5..137.1mOhm for holder/wire/copper/contact across eta=0.70..0.90.

Selected consolidated-ECO architecture:
- remove panel S1 from both battery and USB high-current paths;
- F1 output goes directly to TPS2116 VIN2;
- USB-C CC Rd returns are permanently grounded;
- split TPS631000 EN from VIN_MUX;
- use a low-current maintained SPST only to connect EN to VIN_MUX; add 100k EN pulldown to GND;
- target >=50mil BAT_FUSED->VIN2 route where geometry permits, shortest possible pad neck, paired vias if required.

Report: `T25BO_WEAK_BATTERY_PATH_ARCHITECTURE_FA.md`.
Status: `P1_ARCHITECTURE_SELECTED / CAD_UNCHANGED`.

### T25BP — P2 USB front-end architecture selected

Preferred replacement for the threshold-only discrete OVP:
`USB_VBUS_RAW -> TPS54202 buck -> USB_VBUS_PROT -> TPS2116 VIN1`.

Preferred IC: `TPS54202DDCR`, 4.5..28V input, 2A synchronous buck, DDC-6. Iran-local listing evidence exists; exact order-time stock still requires recheck.

Initial target:
- VOUT ~3.576V;
- RFB top=100k, bottom=20k;
- L=10uH;
- Cin=22uF nominal;
- Cout=44uF nominal;
- Cff=56pF;
- Cboot=0.1uF.

TPS2116 PR1 proposed update:
- top=20k +/-1%;
- bottom=existing 10k +/-0.5%;
- first-order command boundary ~2.733..3.273V.

Report: `T25BP_USB_FRONT_END_BUCK_ARCHITECTURE_FA.md`.
Status: `P2_WIDE_INPUT_BUCK_ARCHITECTURE_SELECTED / OFFICIAL_MODEL_GATE_PENDING / CAD_UNCHANGED`.

### T25BR — P3 PMUX handoff / hold-up architecture selected

For weak-battery USB removal, energy-balance sensitivity from the low PR boundary to ~1.8V gives effective VIN_MUX C requirements around:
- 17.7us -> 10.32uF;
- 50us -> 29.15uF;
- 100us -> 58.30uF;
- 200us -> 116.60uF.

Selected starting population for consolidated ECO:
- nominal ~110uF VIN_MUX bank = five x existing `C2012X5R1V226M125AC` 22uF parts in parallel;
- one is current C_IN, four additional footprints;
- populate existing `R_ST_PU` 10k to 3V3_SYS.

55% effective retention of the nominal bank (~60.5uF) is only a screening threshold, not a guaranteed TDK Cmin.

Report: `T25BR_PMUX_HANDOFF_HOLDUP_REDESIGN_FA.md`.
Status: `P3_ARCHITECTURE_SELECTED / TPS54202_COLLAPSE_MODEL_PENDING / CAD_UNCHANGED`.

### T25BQ — official TPS54202 model preflight prepared

Ready:
- `AI_SCRIPTS/T25/T25BQ_TPS54202_Model_Preflight_v1.ps1`
- `AI_SCRIPTS/T25/Run_T25BQ_TPS54202_Model_Preflight_v1.cmd`

It acquires TI package `SLVMBJ5C`, hashes/inventories it, extracts visible subcircuit headers and creates a result ZIP. It does not run PSpice and does not edit Altium/BOM.

### Consolidated power closure rule — locked 2026-09-28

User requires the **entire power block to be closed before buying new parts**, so purchases can be placed once.

No partial T25BL purchase or CAD ECO is allowed now even though the SD branch parts have cleared technical/procurement gates.

The active closure sequence is:
1. battery path at the locked 1.80V pack-under-load corner, including S1/path resistance;
2. USB input protection/OVP architecture;
3. USB<->battery no-reset handoff with weak battery;
4. TPS631000 / 3V3 source margin with the controlled SD branch;
5. consolidate every required new/replacement part into one Iran-qualified purchase list;
6. request one explicit user approval for the consolidated power ECO/purchase;
7. only then modify Altium.

### Remaining engineering gates

- T25BL requires explicit user approval before changing schematic/PCB/purchased-BOM assumptions.
- Actual unbranded 4GB card transient remains unknown.
- TPS631000 source capability/transient at loaded battery VIN=1.80V remains unqualified.
- Continuous battery->USB->battery no-reset behavior remains a requirement, not a PASS.
- OVP transient gate remains open.
- Exact installed effective capacitances under bias remain open.
- No integrated startup/handoff/SD/OLED or fabrication PASS exists.

## NEXT EXECUTABLE ACTION

1. Run `AI_SCRIPTS\T25\Run_T25BQ_TPS54202_Model_Preflight_v1.cmd`.
2. Upload `Datalogger_T25BQ_Model_Preflight_v1_Result_*.zip`.
3. Independently verify TI package hash, exact TPS54202 subcircuit pin order and model dependencies.
4. Build/run the official-model USB preregulator sweep at VIN=5.0/5.5/12V, target VOUT~3.576V and clearly labelled 0/0.3/0.5A fixtures.
5. Audit raw outputs, including hard-unplug collapse slope through the TPS2116 PR threshold.
6. Reconcile with the selected 110uF VIN_MUX hold-up bank and weak-battery P1 path.
7. Continue P4 TPS631000 source-margin and P5 OLED/sensor gates.
8. Only after all power gates close, issue one Iran-qualified consolidated purchase list and one consolidated ECO for explicit user approval.

No partial CAD edit. No staged purchase. No T25BF rerun. Fabrication Hold remains.
