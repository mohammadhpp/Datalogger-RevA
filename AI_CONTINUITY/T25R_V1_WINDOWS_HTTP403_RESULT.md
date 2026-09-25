# T25R v1 — Windows vendor archive retrieval result: HTTP 403

Date: 2026-09-25. Evidence: user-uploaded `Datalogger_T25R_v1_Result_20260925_105939.zip`, SHA-256 `0f3acfb704569694865f8627642ceb6f04a2cb2cb9d05afd5437e97ddbea6c95`.

## Independently inspected result

The ZIP contains **only** `T25R_v1_Result.txt` (534 bytes). The report timestamp is `2026-09-25T10:59:39.8948968+03:30`, declares exact `C_OUT=C2012X5R1A476M125AC` and `C_IN=C2012X5R1V226M125AC`, and ends:

```text
STATUS: FETCH_OR_INSPECTION_FAILED; Exception calling "DownloadFile" with "2" argument(s): "The remote server returned an error: (403) Forbidden."
```

The attempted URL is TDK's C2012 commercial/general DC-bias PSpice series archive: `https://product.tdk.com/system/files/dam/technicalsupport/tvcl/pspice/capacitor_mlcc_com_general_c2012_pspice.zip`. The script successfully started and packaged the diagnostic result, but **download was refused before ZIP verification, extraction, exact-part scanning or numeric model evaluation**. There is no vendor archive, exact-part model match, C(V,T), effective capacitance or PSpice waveform in this result. HTTP 403 is a remote access result, **not a finding that either capacitor fails TI's requirement**. No bypass, guessed curve, or substitute part is justified.

## Action / stop condition

- Do **not** rerun the unchanged T25R v1 downloader as if it could supply a new model under identical access conditions. The official exact-part TDK pages still publicly list the PSpice DC-bias model, but their *series* ZIP content has **not** been read. Search/index and this executor's prior direct request did not yield numeric model bytes; current alternate numeric vendor source is not qualified.
- If the user can open the exact official [TDK C_OUT page](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1A476M125AC) in an ordinary browser, its **DC Bias / Superimposition Model (PSpice)** link may allow a single direct official download and upload of the resulting TDK ZIP for inspection; if the browser also reports 403, record that and stop this retrieval route. The [TDK C_IN page](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1V226M125AC) exposes a link to the same C2012 archive. Do not request changing security settings or use a third-party mirror.
- Independent route: exact-part manufacturer data or bench characterization under operating DC bias, temperature, aging and tolerance; assess TI **effective** 10.4 µF `C_OUT` / 4.2 µF `C_IN` minima only after qualified evidence. Absent that evidence, T25O gate and the integrated startup/SD/OLED transient remain **OPEN / NO PASS**.

T25Q v2 remains **10 µs isolated pilot PASS limited, 12 ms startup NOT RUN**. Canonical `01_POWER.SchDoc`, `DATALOGER_RevA.PcbDoc`, `Datalogger_RevA_Clean.PcbLib` untouched. No new DRC; last T24 checkpoint 129/129 courtyards, 0 warnings / 0 violations, `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`. The September 8 T23 offline ZIP is rollback only.
