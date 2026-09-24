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
