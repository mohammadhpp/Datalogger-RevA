# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25BZ USB OVP/handoff bounded review, 2026-09-28

- User directed **S1 to be found later** and authorized continuing without step-by-step approval. Do not spend next work on S1; its three-pole functional map and unqualified exact MPN are in `T25BY`.
- `AI_CONTINUITY/T25BZ_USB_OVP_HANDOFF_ARCHITECTURE_SCREEN_FA.md` rechecks the existing pass-through OVP incompatibility with strict 5.50V recommended VIN1 while no nuisance cutoff at 5.50V is required. The historical 5.600692..5.915721V trip calculation leaves only 84.279mV to the 6V absolute corner before dynamics.
- Exploratory TPS54202 preregulator remains **screen only**, not selected ECO. New critical connection constraint: VIN allows 4.5..28V but EN abs max is 7V and recommended max 5.5V; never tie EN directly to raw USB when the 12V fault must be tolerated. TI permits EN floating, or a separately qualified UVLO network.
- The former T25BR 110uF nominal VIN_MUX recommendation does not guarantee no reset: conditional energy at 0.924W, η=0.75, 2.7325→1.84V needs 15.09/30.19/60.38uF effective for 25/50/100us; neither 55% retention nor mux maximum interruption is established, and reverse direction must be tested. No R_ST_PU/PR1/capacitor ECO yet.
- Next independent work: complete a **single candidate USB/preregulator bill of materials and netlist** with all exact Iran-sourced passives, safe EN and source fault bounds; compare to existing OVP. If models and guaranteed Ceff cannot prove transfer, specify one instrumented power prototype gate. No repeat of invalid T25BT/T25AE fixture; no purchase, CAD unchanged, fabrication hold.

## CURRENT EXACT POINT — T25BY three-pole ECO map and Iran sourcing audit, 2026-09-28

- `AI_CONTINUITY/T25BY_THREE_POLE_S1_ECO_MAP_AND_IRAN_SOURCING_FA.md` defines P1 BAT_FUSED→BAT_SW, P2 USB_VBUS_RAW→USB_OVP_IN, P3 joining **only the return ends** of the two distinct 5.1k CC Rd resistors to GND. User-approved three-pole decision remains the target; current four-pole CAD remains unchanged.
- Searching Iranian listings did **not** establish an exact, available, maintained 3PST MPN with three independent contacts and justified BAT contact drop. Six terminals in a listing can denote a two-pole illuminated or momentary device. Foreign APEM 4651A32 is an identified 3PST type, not Iran-qualified. Exact holder/contact resistance/fit also open. Do not substitute a two-pole or buy an unqualified switch.
- One ECO must audit the six wire/pin map, current off-board switch footprint/termination, PCB routing, ERC and Full DRC, in conjunction with OVP/no-reset power-gate closure; no partial CAD/purchase. No new Windows ZIP/PSpice cycle requested. **FABRICATION HOLD.**

## CURRENT EXACT POINT — T25BX corrected for user-approved three-pole S1, 2026-09-28

- User explicitly states the **latest Claude decision approved a three-pole switch**. GitHub main `01_POWER.SchDoc` blob `da2d005712c47000eb8c16157eca464d3fee4fe1` still draws four independent S1 contacts: A BAT_FUSED→BAT_SW, B USB_VBUS_RAW→USB_OVP_IN, C CC1_RD_RET→GND, D CC2_RD_RET→GND. Distinguish approved design from unmodified CAD.
- Three-pole implementation inferred from those nets: one BAT pole, one USB pole, third joins only the **return ends** of the two separate CC Rd resistors to GND. Verify against the exact earlier three-pole decision/pinout before ECO; do not join raw CC1/CC2 nets. The third-pole map is an inference, not a witnessed Claude wiring drawing.
- T25BO_P1's DPST procurement/architecture pass and T25BX's initial preference for EN/SPST are **retracted**. The current corrected report is `AI_CONTINUITY/T25BX_LIVE_S1_TOPOLOGY_AND_OFF_ARCHITECTURE_FA.md`. It keeps the conditional battery resistance budget and lists exact three-pole MPN/holder/Iran sourcing as OPEN.
- CAD, BOM and buying unchanged. OVP 5.50V/limited fault, weak 1.80V battery path, and no-reset handoff remain OPEN. No repeated invalid vendor fixture. One consolidated ECO and purchase after a complete proposal/prototype gate. Last accepted T24 DRC 0/0 is for unchanged CAD. **FABRICATION HOLD.**

## CURRENT EXACT POINT — T25BW consolidated power decision; no repeated vendor-model loop, 2026-09-28

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


### T25BS continuity correction — authoritative

Report: `AI_CONTINUITY/T25BS_CONTINUITY_CORRECTION_19mA_280mA_FA.md`.

The project had drifted into T25BO/T25BP/T25BR/T25BQ architecture changes too early. Those documents/scripts are now **inactive exploratory material** and must not drive CAD/BOM/procurement.

Correct recovered chain:
- `19mA` = old prototype observation, unknown bandwidth; not RevA background/peak.
- `280mA` = RevA purchase-workbook maximum design envelope; not a measured peak.
- T25AZ transparent analysis compared both.
- T25BD/T25BE actual PSpice completed **12/12 valid** conditional 19mA/280mA cases and independently matched T25AZ.
- T25BE showed that lowering background from 280mA to 19mA alone does not remove uncontrolled SD-capacitor inrush: 11/12 conditional cases fell below the 2.04V screen; only 19mA / 1.5A / 100us reached 2.087V.
- T25BF then used the official encrypted TPS631000 model with an explicit **19mA -> total 280mA** load step at VIN=1.80V and a VIN=2.80V control.
- Both T25BF simulator jobs completed, but neither had a regulated 3.3V pre-event state; therefore the load-step waveform is invalid for hardware judgment. Do not rerun T25BF.
- T25BH and the later TPS22918 T25BI/BJ/BK work remain valid as the SD controlled-inrush sub-gate.
- The unresolved active gate is now **TPS631000 startup/source behavior at the locked 1.80V loaded-pack corner**, not selection of a new OVP/buck/handoff architecture.

Steady-load arithmetic does not identify 280mA as obviously excessive: 3.3V*0.28A=0.924W; at VIN=1.80V this corresponds to roughly 0.57..0.73A input for eta=90..70%. The current-limit/inductor static screens have ample numerical headroom, but this is not a guaranteed 1.80V output-current specification and does not close startup/transient behavior.

### T25BT — restored official-model 19mA -> 280mA gate

Prepared files:
- `AI_CONTINUITY/T25BT_TPS631000_SS1_LOADSTEP_GATE_FA.md`
- `AI_SCRIPTS/T25/T25BT_TPS631000_SS1_19_to_280_LoadStep_v1.ps1`
- `AI_SCRIPTS/T25/Run_T25BT_TPS631000_SS1_19_to_280_LoadStep_v1.cmd`

T25BT does **not** rerun T25BF. It uses the same official TI encrypted TPS631000 package but changes the model instance to `SS=1`, with explicit COUT=3.3V and L1 current initial-condition seeds, to test whether the vendor model can establish a valid regulated pre-state quickly.

Two cases:
- VIN=1.80V project corner, load 19mA -> TOTAL 280mA;
- VIN=2.80V control, same load step.

The script has a hard pre-state gate. If the 7..9.8us VOUT window is not stable around 3.3V, the post-step waveform is automatically rejected. Source current is intentionally left for independent raw-table audit after upload.

This use of SS=1 follows TI's documented steady-state-initialization convention for multiple official switching-converter PSpice models; it is still an experiment for this TPS631000 model and cannot bypass the pre-state validity requirement.

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

## T25BV — raw T25BT result independently audited, 2026-09-28

Report: `AI_CONTINUITY/T25BV_T25BT_RAW_AUDIT_VERDICT_FA.md`.
User result `Datalogger_T25BT_v1_Result_20260928_220315.zip`, SHA-256 `e85e8677543759a77e9e55ffb665914c00d83510d97eaf2cc9f0a40371c3b916`, was retrieved and independently parsed. Both official TI model jobs concluded, zero counted warning/errors; each raw PRINT table contains 4,001 voltage rows and 4,001 current rows. Pre-step (7..9.8us) VOUT is **1.614..2.268V falling at VIN=1.80V** and **2.652..2.662V at VIN=2.80V control**. Neither is a regulated 3.3V state. Source-current data also contradict credible steady 19mA transfer: mean +0.218mA in the 1.80V pre-window; model-only multi-amp swings in the 2.80V control.

The generated `T25BT_v1_Summary.txt` has a cross-line parser defect: 6,001 alleged voltage rows with timestamps treated as voltages, including `PRE_MIN=7E-06V`. Disregard its numeric fields. Its invalid-prestate label agrees with independent raw evidence. `T25BU_Audit_T25BT_Result_v1.ps1` was patched to use horizontal row separators; **no further user run is required for this result**. The initial request for a user PowerShell bypass was made when local ZIP access temporarily failed and is now superseded.

Verdict:
`ACTUAL_TEST_WITH_RAW_EVIDENCE / OFFICIAL_MODEL_JOBS_COMPLETED / BOTH_PRESTATES_INVALID / POST_STEP_REJECTED / NO_HARDWARE_FAILURE_INFERRED / NO_BOARD_PASS / FABRICATION_HOLD`.

## T25BW — consolidated power decision after user approved shorter workflow

Read `AI_CONTINUITY/T25BW_CONSOLIDATED_POWER_DECISION_GATE_FA.md`. User explicitly agreed to one integrated power-block review and one eventual Iran-qualified purchase decision, with no further routine Windows PSpice scripts, partial CAD edits or staged orders. Reviewed GitHub main current SchDoc hashes, workbook requirements, vendor evidence and candidate local procurement.

Decisions: 280mA design ceiling remains and 19mA old prototype reading is not a substitute. TI typical TPS631000 current graph does not justify replacing the converter solely from T25BT's invalid prestate. Existing TPS2116, L1 and F1 retained pending actual weak-pack series-drop gate. TPS22918 + exact two TDK capacitors are technically and Iran-market qualified candidates for the SD sub-branch, but remain unpurchased/unapplied. Current OVP and no-reset handoff are still unqualified. T25BO/BP/BR exploratory architecture changes and arbitrary 110uF hold-up are **not selected**. Do not represent the three SD candidate parts as a complete power purchase list.

**NO BOARD PASS / NO PARTIAL PURCHASE / NO CAD ECO / FABRICATION HOLD.**

## NEXT EXECUTABLE ACTION

Develop one coherent battery/USB/OVP/handoff design proposal using the current schematic and the locked 1.80V/5.50V/no-reset conditions. Resolve exact S1/holder series resistance, USB fault source and protected VIN1 limit, and whether a credible validated model can close TPS2116 handoff. If the vendor-model route cannot do so, specify a small instrumented power prototype (separate from production RevA) and its acceptance signals/conditions instead of requesting the user rerun invalid fixtures. Confirm MPN, footprint, electrical minimum and Iranian seller for **every** new part before any consolidated ECO/purchase decision. Keep user intervention at one concrete reviewable decision; do not ask for routine screenshots, ZIPs or another T25BF/BT run.

## BLOCKER REQUIRING USER

None now. A later approval will be needed only for a fully specified consolidated power ECO/purchase or a concrete limited power prototype. User has authorized independent read-only engineering work and asked to reduce repeated execution burden.
