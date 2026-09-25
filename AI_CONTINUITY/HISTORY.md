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
- Official Taiwan Semi TS431 specifies recommended cathode current 1–100mA; at historical lower static trip 5.600692V a source-bounded **optimistic upper limit** for IK is 1.1547mA under K≥2.483V, base≤VIN, 1% resistance minima. Actual IK/turn-off remains unknown. FSS2301S gate-source 10V rating and 45ns typical MOSFET delay in the manufacturer's 2.5Ω bench setup do not establish board 12V-fault clamp or cutoff latency. `T25X_OVP_MODEL_AND_BIAS_FEASIBILITY_FA.md` records evidence, uncertainty, and required waveform probes.
- Historical static OVP trip begins above TPS2116 5.5V recommended VIN and highest trip has 84.279mV only to 6V absolute maximum; no dynamic protection PASS can be inferred. No CAD/BOM/factory change, no PSpice run, no new DRC; prior T24 0/0 physical gate unchanged.
