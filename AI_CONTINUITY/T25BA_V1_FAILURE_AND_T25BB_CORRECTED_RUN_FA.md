# T25BA v1 failure forensic and T25BB corrected run

Date: 2026-09-27. The user executed T25BA v1 in PSpice 25.1 and uploaded Datalogger_T25BA_v1_Result_20260927_233357.zip.

## Audited T25BA evidence

- ZIP SHA256: 486adc32760c820bba1d08ed9164f63934e3fa9ca86b71a250646b502ce1e4d3
- ZIP size: 2497 bytes; six safe regular members; no path traversal or symlink.
- Wrapper status: INCOMPLETE_0_OF_12.
- PSpice stopped during circuit checking in the first case. No transient waveform or DAT file exists.
- Exact solver error: ERROR(ORPSIM-15142): Node 3V3_SYS is floating.
- Therefore T25BA produced no numerical simulation result and cannot confirm or contradict T25AZ.

The cause is fixture topology, not a RevA hardware finding. The rail was driven only by an ABM current source, a current sink and capacitors. PSpice's DC topology checker did not treat that ABM output as a qualifying DC path to reference.

## Corrected unique stage T25BB v1

T25BB adds R_RAIL_DC=1G from 3V3_SYS to ground. At 3.3V it draws only 3.3nA, negligible against 19mA and 280mA scenarios, while providing a DC topology reference. It also catches each case independently so a later case failure does not discard all remaining diagnostic files.

Run AI_SCRIPTS\T25\Run_T25BB_SD_Charge_19_vs_280_v1.cmd after Git Save. Upload Datalogger_T25BB_v1_Result_*.zip whether status is complete or incomplete.

This remains a conditional capacitor-only cross-check. It is not the real TPS631000/TPS2116/card/OLED model, does not alter CAD/BOM, and does not authorize fabrication.
