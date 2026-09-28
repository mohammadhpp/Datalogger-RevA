# CURRENT HANDOFF — Datalogger RevA

## CURRENT EXACT POINT — T25BG/T25BH official-model verdict and conditional SD slew targets executed, 2026-09-28

### Live project baseline

- Authoritative source: private GitHub `mohammadhpp/Datalogger-RevA`, branch `main`, plus the user's local repo `C:\\#MHP FILES\\DataLoger`. Historical ZIPs are rollback/evidence only and must not override live Git.
- No RevA board has been fabricated. All PCB-mounted BOM parts were purchased and are physically available. Simulation/design-risk review remains before manufacturing output or factory submission.
- T23 routing **PASS / CLOSED**. T24 courtyard **129/129 persistent / CLOSED**. Last accepted Full Batch DRC **0 warnings / 0 violations** at PCB checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
- Canonical files remain `DATALOGER_RevA.PcbDoc` and `Datalogger_RevA_Clean.PcbLib`; T25BG/T25BH changed no CAD, BOM, population or DRC state.
- Purchase workbook v0.17 `Power Calculations!B6=0.28A`: **280 mA** is the maximum design load/envelope, not a measured peak. **19 mA** is an older-prototype observation with unknown measurement bandwidth, not RevA background current. The historical 400mA SD value is a PMOS drop-sizing point, not measured card load.

### T25BF/T25BG — official TPS631000 run completed but load-step prestate invalid

User result `Datalogger_T25BF_v1_Result_20260928_101716.zip`: SHA256 `ef3a96ed867491a93662109932ec8e908c48ac7902f0139c3e8d60c22817eea9`, 708,083 bytes, 14 safe members and 1,510,235 uncompressed bytes.

Both official TI encrypted TPS631000 jobs concluded with DAT, 2,001 waveform rows and zero counted warning/error:

- VIN=1.80V: pre-event VOUT 1.485..1.950V; mean absolute input current 0.225mA; post-window VOUT ended 0.7788V.
- VIN=2.80V control: pre-event VOUT 2.632..2.635V; post-window VOUT ended 2.998V.

Neither trace had a regulated 3.3V pre-event state, so its post-step waveform is not valid load-step evidence. Precharging COUT did not initialize inaccessible encrypted controller state. TI's enable delay and soft-start ramp are millisecond-scale; a 20us fixture cannot bypass them, while prior bounded runtime evidence makes full startup with this encrypted model impractical. This is a fixture/model-state limitation, not proof that the board fails. Stop further short-window/precharge retries.

Independent auditor: `AI_SCRIPTS/T25/T25BG_Audit_T25BF_Raw_v1.py`. Raw evidence SHA256 `811694cd4152c2d479b1949643983f70656f2159298045e14c4139c55497f1dd`. Report: `T25BG_TPS631000_OFFICIAL_MODEL_PRESTATE_VERDICT_FA.md`.

### T25BH — conditional SD capacitor-inrush slew targets computed

The transparent T25AZ two-capacitor fixture was extended with deterministic RK4 plus bisection. It finds the minimum hypothetical conductance-ramp time constant `1-exp(-t/tau)` that keeps `3V3_SYS` at or above the 2.04V MCU PDR comparison screen.

| Assumed background | Assumed source ceiling | Conditional minimum tau | SD_VDD to 2.7V |
|---:|---:|---:|---:|
| 19mA | 0.5A | 783.105us | 256.000us |
| 19mA | 1.0A | 188.184us | 126.900us |
| 19mA | 1.5A | 81.641us | 84.850us |
| 280mA | 0.5A | 3923.242us | 561.950us |
| 280mA | 1.0A | 370.605us | 174.000us |
| 280mA | 1.5A | 128.418us | 103.750us |

All six no-card-load cases reach 2.7V within 0.562ms. The calculation repeated byte-identically; evidence SHA256 `eccd8aa3cc95fe305dbe9863d6c72024ec0efadc23cdb9bceb9b6969e39e550c`.

These values are conditional design targets, not real MOSFET timing. They assume 0.1ohm source, 0.05ohm switch, instantaneous source ceilings and 47uF/54.1uF nameplate capacitances. Real card/OLED current, DC-biased Ceff, TPS631000/TPS2116 dynamics and the AO3401A/BC847B network are excluded. T25AT already establishes that the AO3401A vendor timing/Qg conditions do not map to the live 3.3V BC847B/10k/100k driver. Therefore the existing board is not qualified by T25BH.

Script: `AI_SCRIPTS/T25/T25BH_SD_Slew_Threshold_v1.py`. Report: `T25BH_SD_SLEW_THRESHOLD_VERDICT_FA.md`.

### Current engineering verdict and remaining gates

- SD inrush: `CONDITIONAL_SLEW_TARGETS_COMPUTED / REAL_GATE_MAPPING_OPEN / NO BOARD PASS`.
- Continuous battery→USB→battery no-reset behavior remains a locked user requirement, not a PASS. TPS2116 vendor-model discrepancy and the 1.80V weak-AA fast-collapse warning remain open.
- Historical USB requirement remains no nuisance at 5.50V. Existing OVP static trip envelope 5.600692..5.915721V conflicts with TPS2116 recommended 5.5V boundary and leaves only 84.279mV to absolute 6V at the upper static trip before dynamics; OVP transient remains unqualified.
- Exact installed effective capacitances, real unbranded 4GB card transient and actual four-pin OLED module dynamic current remain unknown. The WEO012864V PDF is for a bare 20-pin panel and cannot supply the carrier current waveform.
- No integrated 3V3 startup, source handoff, SD/OLED switched-load or fabrication PASS exists. Preserve **FABRICATION HOLD**.

### Source continuity

The T22 full archive, T23 Stage2 archive and curated T25V recovery ZIP remain private GitHub Release assets under `continuity-archives-2026-09-25`; the user previously downloaded/opened all three and confirmed their SHA256 values. Git-readable recovered PDF text and all 14 workbook sheets are in `T25V_RECOVERED_BLOCK_DOCUMENT_TEXT.md` and `T25V_PURCHASE_BOM_V017_CELL_EXPORT.json`. See `SOURCE_ARCHIVE_REGISTRY_2026-09-25.json`; do not claim these sources are missing or delete the last independent copy.

Detailed prior milestones are in `HISTORY.md`, `HANDOFF_ARCHIVE_THROUGH_T25T_2026-09-25.md` and `HANDOFF_ARCHIVE_PRE_T25AF_2026-09-26.md`. Do not append another live exact point here.

**NEXT EXECUTABLE ACTION:** After the user's decision below, perform a source-backed controlled-inrush redesign review for the SD power branch, select only qualified candidate topology/values, produce a bounded simulation fixture, and present the proposed schematic/ECO before modifying CAD or purchased-BOM assumptions.

**BLOCKER REQUIRING USER:** Choose one: (1) authorize the controlled-inrush redesign review (recommended; no CAD edit until its proposal is approved), (2) keep the existing circuit and retain fabrication HOLD, or (3) explicitly accept prototype-only risk. No additional Windows/PSpice run is pending now.
