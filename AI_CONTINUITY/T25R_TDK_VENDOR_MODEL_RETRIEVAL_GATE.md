# T25R — Exact TDK capacitor bias-model retrieval gate

Date: 2026-09-25. Updated status: **T25R v1 Windows collector executed; official TDK model ZIP request returned HTTP 403; no archive/model/biased Ceff available; electrical sign-off OPEN.**

## Windows result supersedes pending download instructions

User's `Datalogger_T25R_v1_Result_20260925_105939.zip` independently inspected: it contains only a diagnostic report and records TDK `DownloadFile` **(403) Forbidden**. No vendor model was downloaded or parsed. Do not rerun the same script without changed authorized access. Full evidence and restricted next route: `AI_CONTINUITY/T25R_V1_WINDOWS_HTTP403_RESULT.md`. The historical one-click instructions below describe the executed attempt, not a pending task.

## Manufacturer sources and identity

- Exact [TDK C_OUT 47 µF `C2012X5R1A476M125AC`](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1A476M125AC) and [TDK C_IN 22 µF `C2012X5R1V226M125AC`](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1V226M125AC) product pages expose **DC Bias / Superimposition Model (PSpice)** links. Both link to TDK's public C2012 commercial/general series archive `https://product.tdk.com/system/files/dam/technicalsupport/tvcl/pspice/capacitor_mlcc_com_general_c2012_pspice.zip`. This is a *series* download: **the exact two parts' presence and model syntax must be checked after extraction**. The web tool cannot read ZIP content, and the shell here lacks external TDK network access, so no numeric value was extracted or assumed.
- TDK's public graph page states that characteristic graph data are for reference and do **not guarantee** the product characteristics. A model curve, if found, is a *typical or reference simulation input* until its conditions and worst-case tolerance, temperature and aging are qualified against TI's **10.4 µF effective C_OUT** and **4.2 µF effective C_IN** minima from T25O.
- [TI TPS631000 official product page](https://www.ti.com/product/TPS631000) currently lists the same **encrypted PSpice model SLVMDV2** as the primary official simulation model. No manufacturer-qualified average model for this exact part was identified on that product page; no substitute is asserted as validated.

## Executable data-collection step

After normal Windows `Git_Save.cmd` sync, double-click `AI_SCRIPTS\T25\Run_T25R_TDK_Capacitor_Model_Audit_v1.cmd`. The PowerShell 5.1 script (ASCII-only CRLF, unique v1 names, no source modification) downloads the TDK ZIP to a timestamped Documents directory, checks ZIP signature and SHA256, extracts, scans textual model files for **both exact part numbers**, and packages `Documents/Datalogger_T25R_v1_Result_<timestamp>.zip` with a small report, matching lines, and the original TDK archive if at most 25 MB. Even a network/extraction error generates a result report and ZIP where possible. It does **not** run PSpice, evaluate model equations, or change Altium files. Static source and link checks completed here; **Windows runtime pending**, so no promise of a successful TDK download or Ceff gate.

Next: independently review the uploaded result ZIP, confirm model definitions/units and conditions, then compute traceable nominal bias-dependent C only if the exact model is actually present. Assess tolerance, temperature and aging separately; mark compliance OPEN until all bounds are justified. Future behavioral startup/load scenarios remain conditional on actual SD/OLED and source current profiles.

The T25Q v2 result remains **10 µs pilot PASS limited / 12 ms full NOT RUN**. T25P's 3V3 startup and integrated power-tree sign-off remain **OPEN / NO PASS**. Last accepted T24 physical DRC 0 warnings / 0 violations, 129/129 courtyards; no new schematic/PCB/PcbLib edits or DRC.
