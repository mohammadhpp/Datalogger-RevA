# Project History — Datalogger RevA

This is a compact milestone history, not a replacement for Git commit history.

## T20 — controlled BOM / connector baseline

- Approved OLED high-frequency decoupling correction: `C_OLED_HF = 100 nF` (`CL10B104KB8NNNC`) on `OLED_VDD`.
- Selected internal SHT3x PCB connector: 6-pin straight male 2.54 mm 2510-style THT.
- Kept the external metal/military-style panel connector as a separate interface.
- Established requirement to expose/label the six connector pin names for continuity testing and manual assembly.

## T21 — expansion / interface architecture

- Expanded the design for additional external sensing/control use cases.
- Considered light, CO2, CO, city-gas/gas-detector paths and external IoT/SIM-type modules.
- Reinforced manual-assembly silkscreen requirements and 100 mil schematic grid discipline.

## T22 — footprint / physical-interface audit

- Audited project warnings, PCB-mounted vs off-board parts, and connector completeness.
- Verified the need for PCB-side sockets/connectors for all off-board devices.
- Established explicit Pad-number vs Pin-designator verification before footprint assignment/ECO.
- ECO/compile reached clean execution after footprint corrections.
- Identified that prior ZIP handoffs were not sufficient as the only AI-continuity mechanism.

## T23 — PCB routing

- Began controlled block-by-block routing on the 2-layer PCB.
- Routing Stage 1 completed.
- Routing Stage 2 v3 completed.
- Handoff lineage records 48 tracks + 3 GND vias at that checkpoint.
- User requested more assembly/rework room around `U_SYS` and less crowding of thick tracks at IC pins.
- Corrected routing sequence decision: remaining signal/power blocks should be completed before the final Bottom Layer GND polygon.
- Stage 3 OVP / protected-USB routing was formally closed after final audit and DRC PASS.
- Stage 4 remaining power / USB / power-distribution routing was completed through Stage4I. Global `3V3_SYS` is connected at 34/34 pads and `USB_VBUS_PROT` at 8/8 pads.
- Stage 4 closed with accepted PCB checkpoint `5205a902577784c061c5db5fcf529707a8ea2752` and post-Stage4I collision snapshot `f798bdd34bd316866b4fb8102c6ddbba3e3989a6`.
- Stage 5 signal routing began with an externally planned SWD debug-pair candidate; the Bottom GND polygon remains deferred.
- Stage5A SWD debug pair (`SWDIO`, `SWCLK`) passed DRC and was saved at PCB checkpoint `77fed8e2f76d5eed73fb5d3d81b96ce2d1ec7888` with snapshot `a067fc546e8a9ea8fe3dcbda82ac7a13fd932479`.
- Stage5B v1 was rejected safely by preflight before apply because a marginal diagonal touched the axis-expanded `C_MCU_HF.1` bounding rectangle. The external collision model was corrected to mirror Altium's conservative rectangle test.
- Stage5B v2 completed `NRST` across all five pads with 12 tracks / 2 vias, passed DRC, and was saved at PCB checkpoint `747622fd0cccd34f6636183d5b56aecf16a708f9` with snapshot `956ee7ef5a7b14fcf63326d331e5cc708a2eef76`.
- Stage5C completed `RTC_INT_N` across RTC, pull-up, test point and MCU with 8 scripted tracks / 3 vias, passed DRC, and was saved at PCB checkpoint `d786903658079c055acdff33afba12fa14dfc16e` with snapshot `698faffa45f73e7469fcb77b0b493c11c483e9d0`.

## Git / backup evolution

### Local Git baseline

- Working repo established at `C:\#MHP FILES\DataLoger` on branch `main`.
- Local bare backup established at `C:\#MHP FILES\GitRepos\DataLoger.git` as remote `localbackup`.
- AutoSave workflow was developed to create automatic checkpoint commits and push to the local bare backup.

### Private GitHub integration — 2026-09-09

- Private repo connected: `mohammadhpp/Datalogger-RevA`.
- Existing Git history pushed to GitHub.
- GitHub configured as remote `github` without replacing `localbackup/main` as the tracked upstream.
- Git AutoSave upgraded to v2.4 dual backup.
- Verified end-to-end synchronization to both localbackup and GitHub.
- Historical tag `baseline-2026-08-26` synchronized to GitHub.

### AI continuity layer — 2026-09-09

- Added Git-tracked continuity documentation:
  - `AI_START_HERE.md`
  - `AI_CONTINUITY/CURRENT_HANDOFF.md`
  - `AI_CONTINUITY/DECISIONS_AND_CONSTRAINTS.md`
  - `AI_CONTINUITY/LESSONS_LEARNED.md`
  - `AI_CONTINUITY/HISTORY.md`
  - `AI_CONTINUITY/UPDATE_PROTOCOL.md`
- Goal: make the project resumable from Git even if chat context is unavailable or a different AI/session is used.


## T23 — closeout / final GND plane — 2026-09-20

- Completed remaining GND fanout and custom NAV escape.
- Created one poured Bottom Layer GND polygon from the live Altium BoardOutline.
- Final T23 GND object counts: **117 tracks / 46 vias**.
- Final post-pour full DRC shown in Altium: **0 warnings / 0 rule violations**.
- Clean pre-logo T23 rollback checkpoint:
  `a1e4193edacf4f03da623616e470258cd1dc147e`.
- T23 is formally **CLOSED / PASS**.

## T24 — board release / manufacturing-prep refinements

### Stage1 — top silkscreen branding — 2026-09-20

- Added the user-approved monochrome chibi portrait logo to the intentionally empty lower-left Top Overlay area.
- Added centered branding text:
  - `SANAT NEGAR`
  - `M.PAHLAVIAN`
- Artwork is implemented as **964 Top Overlay fill runs**.
- Saved artwork bounds from the post-logo snapshot:
  - X = `4934 .. 5362 mil`
  - Y = `4364 .. 4816 mil`
- User visually approved the result and reported DRC OK.
- The first successful logo script version (v1.1) left an active Altium `PCB:Zoom` command after execution, which blocked normal Save.
- Recovery was completed safely with Save Copy, Altium restart, and replacement of the working `DATALOGER_RevA.PcbDoc`.
- Script v1.2 was then added without `RunProcess('PCB:Zoom')`; use v1.2 if reproduction is ever required.
- Current saved post-logo PCB checkpoint:
  `43306bfd199b10555d7fa2f5f45a8550b8363720`.
- T24 Stage1 status: **PASS / SAVED**.


## T24 — courtyard / release-prep closure — 2026-09-23

- Completed persistent courtyard coverage for all PCB components.
- Final post-save/reopen audit: **129 / 129 components covered**.
- Final Full Batch DRC: **0 warnings / 0 rule violations**.
- Canonical working PCB: `DATALOGER_RevA.PcbDoc`.
- Canonical promoted library: `Datalogger_RevA_Clean.PcbLib`.
- Final user checkpoint after Snapshot Exporter + Git_Save: `3ea38daf1998dc926ec7ee77df95ce5ccf42d3b8`.
- T24 courtyard/manufacturing-prep subtask is formally **CLOSED / PASS**.

## T25 — functional verification / simulation — planned start

- User approved a new phase for functional verification and simulation before final manufacturing release.
- First substage: **T25A Power Tree / Simulation Model Audit**, beginning from the actual `01_POWER.SchDoc` and current source libraries.
- Initial engineering focus: TPS631000 / 3V3_SYS startup and transient behavior, switched SD/OLED loads, and simulation-model availability/limitations.

## T25A — power-tree / simulation-model evidence audit — 2026-09-23

- Read and Git-blob-verified the actual `01_POWER.SchDoc` plus MCU, SD, RTC, OLED/SHT3x and expansion sheets.
- Extracted battery / protected USB → TPS2116 mux → TPS631000 → 3V3_SYS and separate switched SD/OLED supply branches.
- All 115 components in the six inspected power-related sheets contain only PCB footprint model records; no attached simulation model was found. TI's TPS631000 encrypted PSpice and TPS2116 unencrypted transient PSpice packages are external candidates requiring compatibility and pin-map tests.
- Detailed report: `AI_CONTINUITY/T25A_POWER_TREE_SIMULATION_MODEL_AUDIT.md`.
- No simulation waveform, changed engineering source, or new DRC result was claimed. Next: T25B exact-part model qualification and sourced stimulus/load profiles.

## T25D — first encrypted TPS631000 PSpice runtime evidence — 2026-09-24

- PSpice 25.1.0 completed the isolated 10 µs tool smoke of the official encrypted TPS631000 model in 30.98 seconds. `.out` ended `JOB CONCLUDED`, produced 1000 printed voltage rows and raw DAT, with no simulator errors or warnings. At 10 µs, simulated VOUT was 0.1182 V under a TI-example test source/load and project nominal passives. The v4 wrapper's `NO_PASS` was a false negative due to an unavailable process exit code; classifier corrected in Git. This is a limited model/engine runtime PASS, not converter regulation or board startup qualification.
- T25E TPS2116 isolated model smoke v1 was prepared from the verified TI archive and exact physical-to-subcircuit mapping; Windows runtime remains pending. Canonical Altium files and the last T24 0/0 DRC were not changed.

## T25E — TPS2116 PSpice isolated runtime gate — 2026-09-24

- Verified original TI ZIP/header and built a versioned standalone PSpice model smoke. User's Windows PSpice 25.1.0 finished the 7 ms fixed-source fixture cleanly in 0.83 seconds, with 701 printed rows, raw DAT, `JOB CONCLUDED`, and zero simulator errors/warnings. **Limited isolated model/runtime PASS**; no controlled source transfer or board power-tree PASS.
- Corrected the fixture interpretation: its 3.3 Ω load actually drew 1.498 A at simulated final VOUT 4.944 V, so it did not reproduce TI's stated 1 A example. The next project step is a sourced battery/USB/load requirements matrix followed by bounded staged integrated tests. No canonical Altium change or new DRC.

## T25F/T25G — source/load matrix and isolated mux priority behavior — 2026-09-24

- T25F enumerated actual project power nets, exact component MPNs, nominal capacitors and unknown cell/adapter/card/display load parameters. The TI TPS2116 reference and project PR1 divider imply a static VIN1 selection boundary of 3.639–4.369 V including stated device/resistor tolerances, nominal 4.000 V; this is not a measured dynamic threshold.
- T25G PSpice 25.1.0 isolated TPS2116 fixture completed in 1.11 s with 801 printed points, DAT, no simulator error/warning. Status/output traces confirm the vendor model switched from VIN1 to VIN2 and back under one explicitly defined 5→3.3→5 V fixture ramp, VIN2=3 V, 330 Ω load. **Limited model priority-state PASS**; board USB/AA handoff, full TPS631000 startup and SD/OLED load response remain open. No engineering source change or new DRC.

## T25P/T25Q/T25R — model-audit verdict, bounded startup gate and capacitor-model retrieval — 2026-09-24–25

- Closed the **T25A source/model audit** with an explicit T25P verdict: TPS631000/TPS2116 isolated model fixtures can run, but full `3V3_SYS` startup, biased capacitor compliance, mux source handoff and SD/OLED transient **remain OPEN / NO PASS**; last physical DRC is T24 0/0.
- Fixed T25Q v1 Windows PowerShell legacy-encoding ParserError by shipping ASCII-only v2. User's actual T25Q v2 ZIP proved the 10 µs TPS631000 model pilot completed in ~31 s; the 12 ms full run **was not attempted** because a 37356 s linear *heuristic* exceeded the 600 s limit. Result and ZIP hash are recorded in `T25Q_V2_WINDOWS_RESULT_AND_RUNTIME_VERDICT.md`.
- Official TDK exact-part pages expose a shared C2012-series DC-bias PSpice archive. User ran T25R one-click Windows collector, but the official ZIP download returned **HTTP 403** before any archive or exact-part model could be inspected. Exact-part C(V,T) qualification remains **OPEN**; no repeated unchanged downloader. Result recorded in `T25R_V1_WINDOWS_HTTP403_RESULT.md`. No Altium source edit or fresh DRC accompanied these simulation-documentation milestones.

## T25S — consolidated power-tree design-review endpoint — 2026-09-25

- Reconfirmed current canonical `01_POWER.SchDoc` hash against T25A, independently replayed published FB divider, TPS2116 priority-window, capacitor-nameplate and conditional retention arithmetic, and consolidated design-source/model/hardware claims into `T25S_CONSOLIDATED_POWER_TREE_DESIGN_REVIEW.md`.
- Closed the **T25A audit** without reopening pre-schematic selections based on an HTTP 403 or 10 µs truncated startup. Integrated source transfer, actual SD/OLED current transients and 3V3 startup remain **OPEN / NO PASS** until qualified inputs and a validated full-time model or instrumented prototype are available. Repetitive identical PSpice/vendor-download attempts stopped. No new Altium design or DRC changes.

## T25V — recovered source PDFs and historical master purchase BOM — 2026-09-25

- Located the previously missed 29 August T22 full continuity ZIP in stored project files. Its 768 members contain 30 PDF entries (23 distinct SHA256), seven-block pre-schematic calculation/release reports and the actual 14-sheet 16 August `Datalogger_Purchase_BOM_RevA_v0.17...xlsx` with Master BOM, Power and OVP arithmetic, sources and P9 gates. The Sept 8 stage-specific T23 ZIP and current Git lacked these PDFs; previous blanket claims of unavailable PDFs were corrected.
- Preserved the historical files in `Datalogger_T25V_Recovered_Design_Documents_2026-09-25.zip` with byte-level provenance manifest and comprehensive gap audit `AI_CONTINUITY/T25V_RECOVERED_DESIGN_BASIS_AND_GAPS_FA.md`. T16 ST ESD, T20 OLED 100nF, T22 connector changes and current seven SchDocs prevail over stale PDF labels; user-confirmed purchased stock remains separate from old workbook order suggestions.
- Static power calculations and seven historical/current quantity deltas reconstructed; high-priority OVP static margin, 1.80V battery startup path, biased Ceff and actual SD/OLED transients remain unqualified. No canonical CAD edit, new simulation PASS or fresh DRC.

## T25V prototype-load provenance correction — 2026-09-25

- The user **retracted an earlier erroneous 85 mA number**: the actual historic 3.3 V prototype reading was **19 mA**, with 20-pin STM32G030F6, sensor sampling each 1 s, OLED all pixels on, 4GB SD write each 5 s (user's most recent stated conditions). This is a past prototype reading, not a validated fast peak of today's different RevA MCU/SD/OLED board.
- Independently, T22 legacy captured-knowledge notes **19 mA DMM average /16 mA after external 220 µF capacitor removal** on a one-second SD-writing setup. A DMM average does not bound short current spikes; one-second and five-second write intervals must remain distinct unless original lab notes reconcile them.
- The user's explicit final confirmation: **all power calculations and power component selections were based on 280 mA** as the conservative design envelope. Do not redo original selections at 19 mA or infer an 85 mA prototype peak. The T25V report and CURRENT_HANDOFF were corrected; no CAD source edit/new DRC.

## T25V source-index and retention guard — 2026-09-25

- Verified full T22 ZIP (72,765,718 bytes) and T23 Stage2 ZIP (105,917,226 bytes) against SHA256; T23 exceeds GitHub's ordinary 100 MiB single-file limit. Current Git main contained no original PDF, workbook or the three archive payloads. An 8 MB curated ZIP in stored project files contains only selected T22 items, so none of these originals can be deleted on the claim 'the ZIP is uploaded to GitHub'.
- Committed `SOURCE_ARCHIVE_REGISTRY_2026-09-25.json` with full archive hashes and per-member inventories; readable nine-block historical text and every cell/formula of 14-tab purchase workbook as separate Git files. Added Persian retention index, startup/protocol links, and GitHub Actions read-only source guard. Git's primary CAD authority and prior T24 0/0 DRC unchanged; these uploads are historical text/metadata, not original binary ZIPs or a new simulation result.

## T25V full historical archive preservation in private GitHub Release — 2026-09-25

- Published pre-release [`continuity-archives-2026-09-25`](https://github.com/mohammadhpp/Datalogger-RevA/releases/tag/continuity-archives-2026-09-25) with three **full** ZIP assets: original T22 (72,765,718 bytes), T23 Stage2 (105,917,226 bytes), curated T25V (7,981,136 bytes). GitHub API reports `uploaded` and SHA256 digests equal to the independently computed original hashes in `SOURCE_ARCHIVE_REGISTRY_2026-09-25.json`. T23 asset name was normalized on upload, byte hash unchanged. This preserves historical source evidence, not a fabrication release or new electrical PASS.
- Previous T25V statements that complete ZIP payloads were absent from all of GitHub refer to the earlier snapshot; they are now present as **Release assets**, although still not tracked in `main`. Independent download, ZIP integrity and restored-copy hash comparison are pending, so keep an original/independent backup until verified per `SOURCE_REGISTRY_AND_RETENTION_RULE_FA.md`.
- Updated the registry, entry point, live handoff, retention guide and guard to distinguish Release assets from Git-tracked files. CI checks local continuity and recorded digests, not remote asset availability or simulation.

- Extended GitHub Actions continuity guard to query live private Release API on every main push and once a week with `contents:read`; compares all three actual asset states, sizes and server-computed digests. First live check passed at commit `c2db1e3fcd72c3e5753d37a30d73e821eae612f4`, run 36162669117. Does not download or extract ZIPs.

## T25V user operational confirmation — 2026-09-25

- User reported that Windows `Git_Save.cmd` completed and that ZIPs are OK. No console log or SHA-256/ZIP extraction result for Release redownload was supplied, so independent download/hash validation before deleting a sole original remains an open evidence check; do not infer new DRC, engineering simulation PASS or fabrication release.

## T25W — verified historical backup restore and bounded pre-fab power risk screen — 2026-09-25

- User reported Windows Git Save completed; independently downloaded and opened all three private GitHub Release ZIPs and computed matching SHA-256 for T22, T23 Stage2 and T25V. This is a **user attestation**; no PowerShell transcript was supplied. GitHub Release API/weekly Actions independently confirm stored asset size and digest. Redundant old local backup may be removed only with an independent retained second copy; no CAD or manufacturing state changed.
- Rechecked live `01_POWER.SchDoc`, `03_MICROSD.SchDoc`, `06_OLED_SHT3X.SchDoc` Git blobs against T25A/T25T. `T25W_PRE_FAB_POWER_RISK_BOUNDS_FA.md` and `AI_SCRIPTS/T25/T25W_Power_Risk_Bounds_v1.py` recalculate static OVP max trip 5.915721 V vs TPS2116 absolute 6 V (84.279 mV headroom), flag trip range above 5.5 V recommended input, and derive conditional `R_path<0.267857*eta ohm` for full 280 mA output from a 1.80 V loaded AA pack at VIN 1.65 V. Combined switched-branch nominal charge 211.86 uC is only an identity, not a voltage dip or peak current. Script default and explicit illustrative scenario were executed; no invented actual efficiency, ESR, Ceff, SD or OLED current was introduced.
- OVP overshoot/delay, battery cold start, effective MLCC C and real card/OLED switched waveforms remain **OPEN / NO PASS**. No SchDoc, PcbDoc or PcbLib edit, no new DRC; last accepted T24 0/0 physical gate persists. No Gerber/factory action.

## T25X — current OVP net audit and bias/model gate — 2026-09-25

- Decoded unchanged current `01_POWER.SchDoc` blob `da2d005712c47000eb8c16157eca464d3fee4fe1` and independently reconstructed TS431, PNP, P-MOS and zener nets, including three 1kΩ series cathode-feed resistors and 30kΩ base-to-cathode path. Found official Diodes BZT52C6V2 family SPICE model; order is anode/cathode, reversed with respect to schematic pin numbers. Exact executable TS431BCX, BC857BLT1G and FSS2301S transient models were not validated.
- Official Taiwan Semi TS431 specifies recommended cathode current 1–100mA; at historical lower static trip 5.600692V a source-bounded **optimistic upper limit** for IK is 1.1547mA under K≥2.483V, base≤VIN, 1% resistance minima. Actual IK/turn-off remains unknown. FSS2301S single-part PDF prints +10V, while the manufacturer's exact-model catalogue confirms +/-10V; its 45ns typical MOSFET delay in the manufacturer's 2.5Ω bench setup do not establish board 12V-fault clamp or cutoff latency. `T25X_OVP_MODEL_AND_BIAS_FEASIBILITY_FA.md` records evidence, uncertainty, and required waveform probes.
- Historical static OVP trip begins above TPS2116 5.5V recommended VIN and highest trip has 84.279mV only to 6V absolute maximum; no dynamic protection PASS can be inferred. No CAD/BOM/factory change, no PSpice run, no new DRC; prior T24 0/0 physical gate unchanged.

## T25Y — received PCB components, DNP correction and conditional OVP timing — 2026-09-25

- User reconfirmed that **all PCB-mounted components are purchased and physically received**; no board has been built. Newly attached T23 ZIP SHA256 `1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea`, size 105,917,226 bytes, 148 entries and no PDF matches the archived registry; current Git main remains design authority.
- Found a consequential population distinction: current SchDoc includes both C_USB1 and C_USB2 at protected USB VIN1, 22uF nameplate each, plus R_ST_PU, but v0.17 historical assembly specifies C_USB2/R_ST_PU **DNP initially**. Current PrjPcb has `Variant=[No Variations]` and symbols lack explicit assembly parameter; physically delivered stock does not identify the final installed count. Corrected T25F to distinguish 22uF initial vs conditional 44uF nominal and conditional ST pull-up.
- Added T25Y workbook-anchored ramp and fully ON RC-step **scenario-only** timing windows (`0.0842794931/S`; `0.080042708*R_total*C_eff` for hypothetical 5.5->12V). The pure-Python script executed against recovered authentic workbook cells. Extended the same script with a DC-only solution of the official Diodes BZT52C6V2 submodel at 25C for isolated 12V source and 10k gate resistor: Iz=0.589364mA, VGS=-6.106355V; FOSAN's official catalogue establishes +/-10V for FSS2301S despite a +10V print in its single-part PDF, so the 3.893645V difference is a **nominal isolated-model margin only**, not a board stress PASS. No PNP/hysteresis, device-corner or transient proof. Unknown Rtotal, Ceff, actual source waveform and full TS431/PNP/FET models prevent OVP or integrated power-tree PASS; no engineering or BOM edit, no fresh DRC, no manufacturing outputs.

## T25Z — source-traced OVP cutoff budget and model gate — 2026-09-25

- Inspected the exact onsemi recommendation-table row for BC857BLT1G in the live browser: datasheet and CAD links, no downloadable SPICE entry exposed in that row; an indexed search snippet listing other SPICE models is not a validated exact file. The Taiwan Semiconductor TS431BCX and FOSAN FSS2301S transient models remain unqualified. Avoided building a false complete PSpice model from substitutes.
- Derived workbook-anchored conditional VIN1 cutoff budgets using OVP Calc v0.17 B9=5.9157205069V and B7=6V. Python script `T25Z_OVP_Shutoff_Budget_v1.py` executed zero-input instructional case and four-input hypothetical case, and rejected incomplete parameter sets. For illustrative unverified 10us cutoff at nominal 22uF/44uF, allowable current into VIN1 is below 185.415/370.830mA with zero engineering reserve. No effective C, source current/slew or cutoff measured; not a board simulation or OVP PASS. Detail: `T25Z_OVP_CUTOFF_BUDGET_AND_MODEL_GATE_FA.md`.
- No CAD, BOM, population or factory edits, no new PSpice/DRC. T24 DRC 0 warnings / 0 violations remains historical physical checkpoint; pre-fabrication OVP, integrated AA/3V3 and switched SD/OLED are OPEN.

## T25AA — vendor-model USB-to-AA transfer fixture ready — 2026-09-25

- Rechecked user-attached historical T23 ZIP SHA256 `1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea`; it is not current CAD. From unchanged live `01_POWER.SchDoc` and successful T25G official TPS2116 run, prepared unique one-click `Run_T25AA_Transfer_v1.cmd` plus ASCII `T25AA_TPS2116_Battery_Transfer_v1.ps1`, with source/model hash and pin checks, 120s per 3ms case, captured logs/waveforms and automatic min VIN_MUX measurements.
- Declared two separate C_IN=22uF nameplate/4.2uF hypothetical cases; VIN1 5V->0V 10us at 1ms, ideal VIN2=1.8V at IC, PR1 actual30k/10k, ST initial DNP with 1G numerical reference and resistive fixture3.3ohm. These sources/capacitances/load do not represent measured AA path, converter efficiency or real SD/OLED peaks. Prior T25G .out 801 rows validated printed-column parsing; PS1 syntax not executed on Windows in this turn. New TI vendor-model simulation **PENDING user's Windows one-click run and result ZIP**. Detail: `T25AA_TPS2116_USB_UNPLUG_VENDOR_SIM_READINESS_FA.md`.
- No CAD, component population, BOM or factory edits; no fresh DRC. Pre-fabrication OVP, converter/3V3 and offboard switched load gates remain OPEN.

## T25AB — v1 PSpice evidence audited; null-exit wrapper and invalid initial state — 2026-09-25

- User-provided T25AA v1 ZIP SHA256 `88e6aa893b31519e742b0e89622acb4abc740d44a1cd5c99ff3726d5ed848ab5` was independently extracted and parsed. Its only TI TPS2116 PSpice 25.1 case concluded in 1.34s with 3001 voltage rows, no counted solver errors/warnings. Wrapper falsely labeled it incomplete due null process ExitCode; no 4.2u fixture or DAT inside ZIP. VIN_MUX remained below 1V even at constant VIN1=5V before USB unplug; mean 0.141534V over 0.8..0.95ms. No valid pre-unplug state means the zero output after unplug cannot qualify source handoff or prove a hardware board failure.
- TI E2E support describes a TPS2116 priority-mode model VIN2-first outcome that contradicts EVM physical behavior; its mechanism is not established for this particular run. Unique v2 `Run_T25AB_Transfer_Diagnostic_v2.cmd` and `T25AB_TPS2116_Transfer_Diagnostic_v2.ps1` define six bounded TI vendor-model controls to separate heavy startup load, ST numerical DNP, VIN2=1.8 vs3V and illustrative C_IN, with a pre-unplug steady-state gate. Full report `T25AB_TPS2116_V1_FORENSIC_AND_DIAGNOSTIC_GATE_FA.md`. New Windows v2 result is pending.
- No CAD/BOM/population/factory change, no fresh DRC. T24 0/0 remains physical-stage checkpoint; OVP, AA path, actual 3V3 and switched loads remain OPEN.

## T25AC/T25AD — six-run TPS2116 result audited; source-current probe prepared — 2026-09-25

- Audited the user's T25AB v2 ZIP SHA256 `c024bbdc801ddcb729c3bc52d8ab4bdb7ffad6e3f7793b81a5784caa824346cb`: all six official-model PSpice runs concluded with 3001 rows and no counted solver errors/warnings. At light load C_IN=22uF/330ohm, VOUT 4.428V at1.01ms to3.367V at3ms follows RC tau~7.265ms and remained above ideal backup input, so source transfer was unobserved. Heavy 22uF cases had no 5V prestate; hypothetical 4.2uF heavy case started at4.944V, but reached zero after ideal VIN1 5V->0 in10us with backup1.8V. Hardware implication remains undecided.
- Checked official TI datasheet section7.4: a powered-input fall faster than 1V/10us needs >=2.5V on other input to prevent possible reset. The fixture's ideal fall is5V/10us; actual USB fall unknown. Section7.6.1 also delays connection until output drops near new input; section7.3.3 describes ST external pull-up while the historic PCB population is R_ST_PU DNP. Record separate population review without approving a board edit. See `T25AC_TPS2116_DIAGNOSTIC_TRACES_AND_COLLAPSE_RULE_FA.md`.
- Prepared ASCII one-click T25AD v3 with five bounded PSpice runs measuring I(V_BAT_FIXTURE), threshold crossing, late VOUT/current and a 10us/100us control. No Windows execution yet; no new CAD changes, DRC or fabrication output. Integrated power-tree simulation remains OPEN.

## T25AE — TPS2116 current probe reviewed; vendor-model handoff blocked — 2026-09-26

- User-supplied T25AD v3 ZIP SHA256 c33310074b651d883672d74bfcdddb478400ddd3b736b5dc101e4d61499de398 is intact: 27 members, five full PSpice .cir/.out/.dat sets, all solver JOB CONCLUDED and zero counted errors/warnings. Direct .out inspection found no sustained backup current even for ideal VIN2=3.0V and light 330ohm load after capacitor passed VIN2; VOUT at8ms1.689V. Slow 100us VIN1 collapse with 1.8V ideal source and heavy fixture fed 0.539A for 42us, but ceased when VIN1/connected MODE fell from0.9V to0.8V at1.084ms. This suggests model-mode behavior but does not prove its internals or PCB behavior.
- TI datasheet recommends MODE=VIN1 priority and warns backup<2.5V against fast fall; a TI E2E engineer says if VIN1 is invalid and VIN2>=1.6V the hardware should select VIN2 regardless of MODE and documents another SPICE-vs-EVM discrepancy. Vendor-model transfer is BLOCKED_BY_VENDOR_MODEL_DISCREPANCY, actual fast 1.8V fallback risk OPEN, full 3V3/OVP/SD/OLED UNQUALIFIED. Evidence T25AE_TPS2116_REAL_MODEL_CROSSCHECK_FA.md; no further identical PSpice runs planned. Attached duplicate T23 historical archive verified SHA256 1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea; do not use its CAD to override live main. No CAD edits/DRC.

## T25AF — approved OVP gate confirms static requirement conflict; transient remains unqualified — 2026-09-26

- Rechecked live power schematic Git blob da2d005712c47000eb8c16157eca464d3fee4fe1 and original historic purchase workbook OVP Calc v0.17 cells B5:B9/B17. Project no-nuisance at USB=5.5V coincides with TPS2116 recommended VIN max5.5V; historical static min/max OVP trip5.6006922227/5.9157205069V is100.692/415.721mV above operating max. Worst static trip leaves84.2794931mV to TI absolute6V before cutoff delay. Workbook already flags ANALYTICAL HOLD / P9 ONLY, NOT Production LOCK. This is a conditional requirements conflict for a low-load rising USB source, not proof hardware is damaged on ordinary5V input.
- Manufacturer evidence and exact-part inventory rechecked: Taiwan Semi TS431B recommended IK >=1mA with only1.1547mA optimistic upper near low trip, TDK exact 22uF characteristic sheet does not give a qualified Cmin for installed lot/population. Missing validated TS431/FSS2301S/BC857 transient macros and bounded USB fault source/t_cut make OVP dynamic PASS impossible on present evidence. Detail T25AF_OVP_SPEC_CONFLICT_AND_TRANSIENT_GATE_FA.md. User decision required on whether full5.5V no-nuisance is essential vs narrower5V source with earlier cutoff. No PCB/BOM edits, PSpice, new DRC or factory outputs.

## T25AG — no-reset requirement reconciled with prior calculation gates — 2026-09-26

- User reconfirmed continuous automatic USB priority and battery fallback with no device reset during connection/disconnection. Earlier v0.17 workbook already sets 1.80V battery minimum under load, 280mA output design envelope, 5.50V USB no-nuisance and P9 zero-reset both-direction gates; the preceding T25AF/T25AG question to reselect these numbers was corrected in the Git continuity documents. These are **locked design targets / pending P9 tests**, never functional PASS.
- TPS2116 and TPS631000 datasheets allow 1.80V battery and 5.50V input within their static supply operating ranges, subject to <=150mV battery-path startup drop at the declared corner; TPS2116 §7.4 separately warns when USB falls >1V/10us with alternate source <2.5V. Existing OVP static upper trip5.9157V exceeds TPS2116 recommended5.5V before dynamics. Gate remains OPEN pending valid no-reset/OVP/3V3 evidence; no CAD, population, factory or fresh DRC change. See T25AG and T25AF.

## T25AH — separate USB and mux capacitor dropout screens — 2026-09-26

- Rechecked unchanged live 01_POWER.SchDoc and recovered workbook 1.80V loaded AA, 0.280A design, 5.50V USB and original P9 PENDING no-reset gates. Derived separate ideal constant-power energy budgets at PR1 static bounds 3.638806..4.368844V: with only C_USB1, the slow-fall condition at the latest PR1 corner needs Ceff>=2.539295/eta uF; C_IN=TI recommended 4.2uF hypothetical gives 23.91*eta us from that late boundary to 1.65V, and 22uF *nominal* gives125.22*eta us. No Ceff/eta or actual USB waveform qualified. Script T25AH_Hard_Unplug_Envelope_v1.py checks original workbook SHA and prints only conditional screens; detailed report T25AH_HARD_UNPLUG_ENERGY_ENVELOPE_FA.md.
- Prior ideal VIN1 5->0V/10us PSpice stimulus must not be labeled a measurement of cable unplug downstream of C_USB1. TPS2116 model discrepancy and no-reset/OVP/startup/load gates remain OPEN; no CAD, assembly, new DRC or fabrication release.

## T25AQ — PSpice downstream rail-gap fixture staged — 2026-09-26

- Staged ASCII PowerShell 5.1 plus one-click CMD for the user's existing PSpice 25.1 engine, four bounded switched-branch 3V3/SD/OLED scenarios. Actual C_OUT and switched local capacitor nameplates mapped from live SchDocs, 280mA design envelope respected, all unknown effective capacitances, branch currents and 10/50us regulator-output gaps explicitly labeled hypothetical. Pre-run deck/static checks passed. Windows numerical simulation remains **PENDING USER RUN**, and a successful fixture cannot establish physical USB/battery handoff, MCU no-reset, SD write integrity, OVP or fabrication PASS. See T25AQ report and CURRENT_HANDOFF; no CAD/BOM modifications or new DRC.

## T25AR — user's PSpice execution audited; conditional SD-on rail floor risk — 2026-09-27

- Preserved user-supplied T25AQ 227363-byte result ZIP SHA256 `a36556eadbe23be08489caa29ac223466b69ec7e44b85efc0f594b89975347b1` in Git `AI_EVIDENCE/T25AQ/`. All four official PSpice 25.1 engine jobs completed with 2251 printed points and no solver warning/error. Independent full-wave audit replicated 10/50us *hypothetical* gap minima 3.083V minimum at C_OUT=10.4uF effective reference; importantly SD branch initial-enable min 3V3_SYS=1.576V (10.4uF case) or 2.099V (47uF nameplate case). The initial runner only summarized handoff windows. This reveals a conditional inrush risk, not a measured reset or hardware proof. Live SD schematic driver (AO3401A+BC847B, 10k/100k) checked; unknown effective capacitances, actual MOSFET turn-on, TPS631000 dynamic limits and real card/module currents still block fabrication. See T25AR report and reviewer script; no CAD/BOM edit or new DRC.

## T25AS — source-grounded SD-enable charge screen; physical PASS remains open — 2026-09-27

- Rechecked live 01_POWER and 03_MICROSD Git blobs, exact purchased workbook v0.17 identity and STM32G070KBT6 PDR falling maximum 2.04V; Q_SD is AO3401A with BC847B/10k/100k drive, 54.1uF local SD capacitors nominal, C_OUT 47uF nominal. Conservative 280 mA design load preserved; old 19 mA prototype reading remains historical.
- With declared **hypothetical** 10us/50us charge-to-2.04V, charge balance needs 10.006/2.2252A at assumed 10.4uF effective C_OUT, or 5.3944/1.30288A at unqualified 47uF nameplate C_OUT and 54.1uF SD nameplate. Neither cap bias nor real Q_SD/converter dynamics established; T25AQ ideal-source current at its worst rail floor could approach 17.24A. Reproducible source-hash gated script and limitations in T25AS report. No new PSpice run, CAD/BOM edit, fresh DRC or factory PASS.

## T25AT — clarify 1.80V battery source rating; stage representative test gate — 2026-09-27

- Rechecked TI TPS631000 product Rev C: 1.5A output capability stated with VIN>=2.7V, VOUT=3.3V; do not use that headline or ~2.9A typical internal switch current as guaranteed output at historical 1.80V loaded AA corner. AOS AO3401A 3.5ns turn-on rise is for a -10V/3ohm test, not the 3V3 BC847B/10k/100k SD driver. Reparsed exact SD capacitor MPNs in live 03_MICROSD.SchDoc. Updated source-qualified validation requirements and a concrete small power-path test protocol in T25AT report; no new PSpice, no CAD/BOM edit, no fabrication release.

## T25AV — executed bounded SD-branch enable simulation; correct stage to pre-fabrication — 2026-09-27

- User clarified that RevA has no fabricated PCB; an oscilloscope or physical coupon is not the simulation-stage next action. Executed a separate SciPy Radau two-node behavioral transient, 84 cases with scenario source ceilings 0.5/1/1.5/3/100A (none a TPS631000 guarantee at VIN=1.80V), conductance ramps 0/10/100us and nominal/illustrative output and SD capacitances. Source script verified 01_POWER.SchDoc, 03_MICROSD.SchDoc Git identities and original v0.17 purchased workbook SHA/280mA/1.80V cells. Raw JSON and Persian report committed; unlimited-source 47uF case agrees with user-run T25AQ PSpice 2.099V floor within 1mV, but model cannot establish board behavior. Under illustrative 280mA post-on load, 47uF/54.1uF nameplate and assumed 1.5A cap the minima were 1.641V (instant) and 2.036V (100us conductance trajectory). Preserve NO HARDWARE PASS and continue vendor model/parameter qualification and simulation before factory files; no CAD/BOM edit or fresh DRC.

## T25AX — reconcile 19mA observed, 280mA design and 400mA SD switch point — 2026-09-27

- Recomputed original v0.17 workbook B5/B6/B8 and verified binary source hashes. User's 19mA is a reading on an older MCU/prototype with unrecorded measurement bandwidth, not a qualified instantaneous peak or guaranteed time average. MCU datasheet Run Flash max3mA at16MHz or 8.4mA at64MHz with peripherals excluded; bare SHT3x measure max1.5mA; RTC conversion max0.575mA; two-low-line I2C pull-ups 4.230mA conditional; partial mixed-condition sums 9.305/14.705mA before unknown SD/OLED and other loads. User OLED PDF is a bare 20-pin panel, not the purchased four-pin module. Historical 400mA sizes SD PMOS conduction drop, not measured SD. SD 54.1uF nameplate requires Q=178.53uC at3.3V; charge-time current separate from card steady draw. 280mA is 14.737 times prototype display reading, but lack of card/module current waveform prevents a true RevA peak. Script/raw/report in T25AX; no fresh hardware simulation, CAD/BOM change, DRC or fab PASS. T25AV 180mA+100mA partition remains entirely a scenario.

## T25AZ/T25BA — 19mA versus 280mA sensitivity and PSpice gate — 2026-09-27

- Executed deterministic RK4 12-case capacitor-only sensitivity against unchanged live power/SD identities and authenticated workbook cells. Assumed background 19/280mA, hypothetical source ceilings 0.5/1.0/1.5A, and conductance 0/100us. The lower background improved rail minima about 31–104mV; nominal 47uF output and 54.1uF SD charge sharing dominated. Minima span 1.545–2.085V. Only 19mA/1.5A/100us exceeded 2.04V, by 44.7mV, but source capability at VIN=1.80V, biased Ceff and switch timing remain unqualified. Evidence SHA256 97f6963a14d5dd6b77fc7b95cf45d9ef8d2adc3579ea41ee52ab2faf35e456f5. No board/fabrication PASS.
- Committed T25BA one-click CMD and ASCII PowerShell fixture for 12 PSpice 25.1 runs with timeout, solver/waveform gates and ZIP evidence. Windows execution is the only pending user action. Fixture excludes real converter/mux/card/OLED behavior; no CAD/BOM edit, DRC or factory output.

## T25BA/T25BB — failed fixture audited and corrected unique PSpice run staged — 2026-09-27

- Audited user ZIP Datalogger_T25BA_v1_Result_20260927_233357.zip, SHA256 486adc32760c820bba1d08ed9164f63934e3fa9ca86b71a250646b502ce1e4d3, 2497 bytes and six safe members. Wrapper status INCOMPLETE_0_OF_12; first case stopped at PSpice ORPSIM-15142 floating 3V3_SYS. No DAT or transient rows exist, so T25BA has no electrical verdict. Failure manifest committed.
- Root cause is the fixture's ABM-driven rail lacking a topology-check DC reference. Staged unique T25BB v1 with R_RAIL_DC=1G, only 3.3nA at 3.3V, plus independent per-case failure capture. Windows rerun pending; no CAD/BOM/DRC/factory change and no board PASS.

## T25BC/T25BD — independent T25BB waveform audit and prestate-gated rerun — 2026-09-28

- Audited user T25BB ZIP SHA256 bf1a473606c605103af248a0002717591dacdd8581953d52449b830abb8a3997: 62 safe members, 12 jobs concluded, 12,501 rows/case, DAT and zero solver error/warning. Pre-state inspection rejects two 19mA/0.5A cases because PSpice pseudo-transient advanced CTL/SD_VDD before 1ms; their 3.298V report values are not valid event minima. Ten valid cases agree with T25AZ within 3.697mV and 1.3us. Deterministic auditor and raw-derived JSON committed; conditional fixture only, no board PASS.
- Staged unique T25BD v1 for all 12 cases with SKIPBP, a 1ms C_OUT precharge interval and hard gates on sample count, rail, SD, control-before/control-after and pseudo-transient absence. Windows ZIP pending. No CAD/BOM/DRC/factory change.

## T25BE/T25BF — capacitor fixture validated; official converter load-step staged — 2026-09-28

- Independently audited user T25BD ZIP SHA256 9258c18c9c0ab4b9edc9809e4a69f68eb9e16f53a1062dfa59fc1436d284c628: 62 safe members, 12 complete PSpice jobs, 12,501 rows/case, DAT, zero warning/error, no pseudo-transient and 12 valid prestates. All cases agree with T25AZ within 2.321mV and 0.55us. Eleven conditional minima fall below 2.04V; only 19mA/1.5A/100us reaches 2.087V. This closes the two-solver capacitor-only fixture, not hardware or fabrication qualification.
- Staged T25BF with verified official TI SLVMDV2 encrypted TPS631000 model, ideal VIN=1.80V and 2.80V control, project nominal passives, precharged 3.3V output and 19mA-to-total-280mA step in a 20us bounded window. Precharge cannot initialize encrypted internal steady state, so input-current/pre-event VOUT must be audited before interpretation. Windows run pending; no CAD/BOM/DRC/factory change.


## T25BG/T25BH — official-model prestate rejected; conditional SD slew targets computed — 2026-09-28

- Audited user T25BF ZIP SHA256 ef3a96ed867491a93662109932ec8e908c48ac7902f0139c3e8d60c22817eea9: both official encrypted TPS631000 jobs concluded with DAT, 2,001 rows and zero warning/error, but neither had regulated 3.3V before the event. VIN=1.8V prewindow was 1.485..1.950V with only 0.225mA mean absolute input current; VIN=2.8V control was 2.632..2.635V. Post-step traces are invalid as load-step evidence. Precharged COUT did not initialize encrypted internal controller state; short-window retry route closed. This is a model/fixture limitation, not proof of board failure.
- Executed deterministic T25BH RK4/bisection over the transparent T25AZ capacitor-only fixture. Conditional conductance-ramp tau required for the 2.04V screen spans 81.641us to 3923.242us for 19/280mA backgrounds and assumed 0.5/1.0/1.5A ceilings. Worst declared 280mA/0.5A case needs 3923.242us and reaches SD 2.7V at 561.950us. Evidence reran byte-identically, SHA256 eccd8aa3cc95fe305dbe9863d6c72024ec0efadc23cdb9bceb9b6969e39e550c. Real gate timing, biased Ceff and actual card/converter behavior remain open; no CAD/BOM/DRC/factory change and no board PASS.

## T25CE — preserve expansion5V; executed sensitivity and new USB model fixture — 2026-10-02

- Live07_EXPANSION depends on USB_VBUS_PROT for USB_5V_AUX through R_EXP_PWR_EN0ohm. Replacing the whole rail with3.576V would violate5V expansion; new USB preregulator requires a dedicated mux-input branch, and expansion protection is still open.
- Actual Python execution produced raw LC/static/cap-only evidence. Min buck3.442642V vs max proposed PR3.261709V leaves180.933mV static margin, excluding dynamics. Pre-Cff f0 screen at minVout requires Ceff>28.6844uF; nameplate44uF does not establish it. Found direct Iran stock for SRN1060-100M and exact56pF Fenghua, with fit/Ceff open; TDK coil pending and module out of stock. Manufacturer29mOhm DCR supersedes retailer290mOhm.
- Staged six **new TPS54202** official TI USB-only cases and one-click Windows runner with hash/prestate/time gates. TI payload is encrypted despite title. Python split-PRINT/prestate parser checks passed, vendor/Powershell runtime not executed here. User's existing Windows PSpice run/ZIP is the vendor dependency, not a repeat of invalid TPS2116/TPS631000 loops. CAD unchanged, no purchase/new DRC/system or fabrication PASS.
