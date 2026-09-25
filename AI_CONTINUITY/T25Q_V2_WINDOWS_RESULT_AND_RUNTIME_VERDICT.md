# T25Q v2 — Windows pilot result and exact-model runtime gate

Date: 2026-09-25. Evidence: user-uploaded `Datalogger_T25Q_v2_Result_20260925_104259.zip`, SHA-256 `bab09295c26b696d1174f8d7c8940a68c869b10e9cd245975489a5bbf1832f68`. This is a Windows OrCAD X/PSpice 25.1 result for an **isolated TI converter fixture**, not a simulation of the Datalogger board.

## Independent evidence check

- Archive has `Pilot_10us.cir`, `Pilot_10us.console.txt`, `Pilot_10us.out`, `Pilot_10us.stderr.txt` (empty), `Pilot_10us.dat` (807219 bytes) and `T25Q_v2_Result.txt`. It has **no** `Full_12ms` deck, output or waveform: the full run was **never launched**.
- Result report: pilot 10 µs, wall elapsed **31.13 s**, `concluded=True`, errors **0**, warnings **0**, last recorded time **10 µs**, `VOUT=0.1182 V`; status `FULL_RUN_SKIPPED_SLOW_MODEL`.
- Independently inspected raw `.out`: **1001** voltage rows through 10 µs, ending `VIN=2.800 V`, `VOUT=0.1182 V`, `FB=0.01841 V`; `JOB CONCLUDED`, PSpice solver job time **30.92 s**, no error, warning or abort. The console also reports completed transient. Thus the corrected ASCII-only v2 runner actually executed PSpice and its bounded pilot **PASS** for the narrow model/engine smoke.
- Deck identifies official TI archive hash `f55c75639ad5b62c5437ec114301905fe6c63408cdb689825eb542c095ecd946`; `TPS631000_STARTUP` pin order `VOUT LX2 LX1 VIN VIN 0 0 FB`. Fixture is ideal constant **2.8 V input**, TI example **3.3 Ω** resistance, project **nominal** `C_IN=22 µF`, `C_OUT=47 µF`, `L1=1 µH`, FB **510 kΩ/91 kΩ**; `MODE=0`, `EN=VIN`. It does not qualify the TDK capacitors' effective values, AA/USB drive or SD/OLED load.
- Pilot **31.13 s / 10 µs × 12 ms = 37356 s (~10 h 22 min 36 s)** by the script's *linear heuristic*; this exceeds its 600 s gate. This is **not** a measured 12 ms runtime, nor proof linear scaling is exact. The earlier 0.6 ms converter run was stopped after ~30 min, consistent with caution about an unbounded rerun.

## Decision

**T25Q v2 pilot PASS; exact-model 12 ms fixture NOT RUN / NO VERDICT; board startup, transient and switched-load verification OPEN.** In particular 0.1182 V at 10 µs does not indicate a failed 3.3 V startup: TI's stated enable delay and soft-start operate on a millisecond scale. This outcome is a **runtime feasibility gate**, not an electrical acceptance test. Do not rerun the same short pilot or launch an unbounded long exact-model job as a purported route to system sign-off.

## Next executable engineering route

1. Continue read-only sourcing of the exact TDK `C2012X5R1A476M125AC` and `C2012X5R1V226M125AC` numerical DC-bias/temperature/aging data, and available manufacturer-validated reduced-order TPS631000 representation. Preserve traceable citation/part/condition for each parameter. Nominal 47/22 µF must not be presented as effective minimum values.
2. Build **clearly labeled behavioral/system scenarios** only with documented assumptions and ranges; do not assign measured accuracy or converter switching detail to a reduced-order model without independent validation. Actual photographed four-pin OLED carrier input load, microSD write/inrush and battery/USB source behavior remain uncharacterized, so show scenario outcomes as conditional.
3. For an actual board electrical verdict, obtain effective-C bounds, quantified source and switched-load profiles, measured or bounded acceptance limits, and a completed relevant startup/transient on a suitable validated model or physical hardware. Keep `3V3_SYS` startup, mux switchover and SD/OLED load-step **OPEN / NO PASS** until then.

Canonical `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc`, `Datalogger_RevA_Clean.PcbLib` untouched. No fresh DRC. Last T24 physical checkpoint 129/129 courtyards, Full Batch DRC 0 warnings / 0 violations, checkpoint `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
