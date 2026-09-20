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
