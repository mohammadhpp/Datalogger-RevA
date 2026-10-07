# Lessons Learned — Datalogger RevA

These are project-specific lessons intended to prevent repeated mistakes across AI sessions.

## PCB routing / physical design

1. **Do not pour the final GND polygon too early.**
   - Finish the major signal/power routing first.
   - Early polygon pours cause repeated repours, hide ratsnest clarity, and can mask return-path planning problems.

2. **Wide tracks need controlled pad escape.**
   - A rule-compliant wide track can still be a poor physical design if it crowds IC pins.
   - Use a short, electrically justified neck-down at dense IC pads, then widen outside the escape zone.
   - Preserve soldering/rework room, especially around `U_SYS`.

3. **Manual assembly readability is a real engineering requirement.**
   - Never sacrifice all RefDes/orientation markings merely to compact placement.
   - Silkscreen should help a human assemble, inspect, and debug the board.

4. **Route in functional blocks and checkpoint with DRC.**
   - Complete a coherent block, run DRC, then continue.
   - Do not wait until the entire board is routed to discover a systematic width/clearance mistake.

5. **Interpret DRC in context.**
   - Unrouted nets are expected while untouched blocks remain.
   - GND vias may appear as Net Antennae before the intended GND polygon exists.
   - Do not distort the routing sequence only to make an intermediate DRC report cosmetically clean.

6. **Do not equate pad-center endpoints with electrical connectivity.**
   - A routed track may legitimately terminate on the copper edge of a pad instead of its geometric center.
   - Stage 3 Final OVP Audit v1 false-failed `R_TOP_B.1` because it required an endpoint at the pad center `(4895,5090)` even though the same-net track validly entered the pad at approximately `(4865,5090)`.
   - Future audit scripts should prefer actual Altium connectivity/geometry-overlap evidence, or explicitly support verified pad-edge entry, instead of using center-coordinate equality as the only connectivity test.
   - DRC plus live-board connectivity should outrank brittle coordinate heuristics.

7. **Collision checking is not route planning.**
   - Repeatedly guessing coordinates and then asking a preflight checker whether they collide is still trial-and-error.
   - Dense routing should be planned from the full obstacle field first; preflight is the independent verifier, not the pathfinder.

8. **Do not run heavy route-search algorithms inside Altium PascalScript.**
   - A live-board A* experiment during T23 Stage 4G blocked the Altium UI and made the application appear hung.
   - Altium scripts for this project must stay lightweight: baseline checks, exact geometry preflight, static apply, connectivity analysis.
   - Heavy search/planning belongs outside Altium.

9. **For dense scripted routing, plan externally from the latest collision snapshot.**
   - Use `AI_BOARD_COLLISION_SNAPSHOT_T23.tsv` as the external planning geometry source.
   - Model Top/Bottom obstacles, Multi Layer pads, existing track widths, vias, electrical clearance, and via-to-pad mask sliver.
   - When two target nets compete for the same corridor, plan them as a pair rather than independently.
   - The accepted Stage 4G solution (`CC1_RD_RET` / `CC2_RD_RET`) used this method successfully.

10. **Do not use absolute Altium Track-object count as the sole route PASS gate.**
    - Altium can split or merge primitives when new copper joins existing copper.
    - Prefer script-added object count, geometry/connectivity checks, exact preflight, and final DRC.

11. **Audit expected object counts against the actual final build block before shipping a script.**
    - Stage4H1 v3 passed exact preflight and applied successfully, then falsely reported FAIL because the script expected `25 tracks / 8 vias` while its build block actually contained exactly `24 AddTrackMil` calls and `8 AddViaMil` calls.
    - `GAddedTracks/GAddedVias` are useful only if the expected values were mechanically verified against the final apply code.
    - A count-audit mismatch must be diagnosed before discarding geometry that already passed exact preflight; do not reflexively treat it as a routing failure.

12. **External collision math must mirror Altium's exact conservative primitive.**
   - Stage5B v1 passed an external Euclidean corner-distance check but correctly failed the live Altium preflight because the diagonal intersected the axis-expanded pad bounding rectangle of `C_MCU_HF.1`.
   - For scripted dense routing, external track-to-pad verification must use the same axis-expanded `BoundingRectangle` intersection semantics as the Pascal preflight; Euclidean distance to the unexpanded rectangle is not equivalent at corners.
   - A clean external result is trustworthy only when its geometry model reproduces known live preflight failures as well as accepted routes.

## Schematic / library / ECO

13. **Pad numbers must match schematic pin designators.**
   - Before assigning/replacing footprints, verify physical pad numbering against the schematic pins and selected connector/part drawing.
   - A visually correct footprint with wrong pad numbering is unacceptable.

14. **Do not move schematic architecture merely to solve a footprint-management problem.**
   - Prefer deliberate footprint assignment and mapping verification over unnecessary schematic rearrangement.

15. **Off-board symbols still require explicit PCB hardware.**
   - A logical off-board device without a deliberate board-side connector is an incomplete design.

## Git / AI continuity

16. **Chat history is not a reliable project database.**
   - Stable design decisions, exact current point, and lessons must live in Git.

17. **A ZIP handoff alone is insufficient for day-to-day continuity.**
   - Git history plus a concise current handoff is superior for identifying what changed and why.
   - Full offline ZIPs remain valuable for disaster recovery and migration.

18. **Do not replace the known-good local backup architecture when adding cloud backup.**
   - Preserve `localbackup` as the required upstream/rollback path.
   - Add GitHub as a second remote.

19. **Online failure must not invalidate a valid local checkpoint.**
   - AutoSave treats local backup as required and GitHub sync as secondary.
   - Loss of internet should produce a warning, not destroy local continuity.

20. **Before continuing from a new AI/session, verify the repo itself.**
   - Read `AI_START_HERE.md` and continuity files.
   - Inspect latest commits and the current engineering file state instead of trusting an old chat summary blindly.

## Collaboration workflow

21. **Routine screenshots are not mandatory.**
   - Proceed from verified files and known state for ordinary steps.
   - Ask/use screenshots when the user is unsure, when visual placement/routing verification is needed, or when the file state cannot answer the question reliably.

22. **When a sequence recommendation is found to be suboptimal, correct it explicitly in the handoff.**
   - Do not silently carry a bad next-step recommendation into future sessions.


23. **Do not mutate PcbLib footprints through DelphiScript on the current Altium build.**
   - T24 PcbLib courtyard repair attempts v2/v3/v4 all produced the same native null-read Access Violation in `ScriptingSystem.DLL`, even after removing iterator mutation, component navigation, state rebuilds, and exception flow.
   - The same PCBServer object-creation transaction pattern is proven on PcbDoc in T23, while Altium's documented PcbLib interfaces still crash natively in this environment.
   - Treat this as an Altium scripting-engine/PcbLib implementation defect or build regression until proven otherwise. Use native PcbLib UI editing for persistent footprint changes, and never save the library after such a crash.

24. **Separate PSpice engine evidence from wrapper process status and project qualification.**
   - A v4 `Start-Process` invocation returned no usable `ExitCode`, so a direct `$exit -ne 0` check falsely labeled a successful simulator run `NO_PASS`. If exit is unavailable, require independently verified `JOB CONCLUDED`, job time, no error/fatal markers, and actual trace data; a known nonzero exit remains a failure.
   - For hand-written PSpice decks, named net voltages in `.PROBE64` and `.PRINT TRAN` use square-bracket node names such as `V([VOUT])`. The earlier `V(VOUT)` generated `ORPSIM-15090`; `V(alias(*))` selected no traces and raised `ORPSIM-16527`.
   - Bound first encrypted-model engine smoke runs by both short simulation duration and process wall time. A 0.6 ms attempt consumed more than 30 minutes without usable completion evidence; a distinctly labeled 10 µs tool smoke completed cleanly in 30.98 seconds but cannot validate a 3.3 V startup or actual SD/OLED load step.

25. **Check the resulting load current at the actual simulated voltage.**
   - The T25E fixture chose 3.3 Ω to represent 1 A if the output were 3.3 V, but the TPS2116 model produced 4.944 V at 7 ms; the real final fixture current is 1.498 A. Label such resistors as fixture choices and compute currents from simulation data before comparing with a vendor example or a product load. A clean PSpice job qualifies runtime for that stimulus; static-source simulation alone does not validate priority transfer or real USB/AA/SD/OLED behavior.

26. **Separate a mux's status indication from measured current and sampled voltage limits.**
   - T25G ST went low in the first sampled 1.65–1.66 ms interval, but VOUT remained above the 3 V VIN2 fixture and only decayed toward 3 V later under 22 µF nominal output capacitance and 330 Ω load. ST confirms the model's selection state, not that VIN2 delivered a given current at that instant. An 801-point trace spaced 10 µs apart cannot establish sub-sample worst-case dip or precise switching time; add branch-current probes and adequate resolution before asserting either.

27. **A panel datasheet is not a four-pin carrier's supply-current model.**
   - User-supplied WEO012864V PDF specifies a bare 20-pin OLED requiring distinct logic and display voltages; the existing OLED connector is four pins and switched 3.3 V. A related PCB module WEA012864V has a compatible pin order/pitch on paper and a 50%-on 3 V current spec, but the user's physical assembly has not been identified. Verify exact assembly, supply arrangement and mating before importing current ratings, making a connector substitution or claiming a load-step result.
   - For an unbranded microSD and unspecified chargers/power banks, distinguish declared source/load scenario sweeps from measured hardware behavior. A 25 mA alkaline capacity rating cannot define pulsed AA source resistance.

28. **Do not turn a visually similar module photo into an engineering identity.**
   - T25I inferred a reverse-polarity blocker from two photos that the user later identified as the **wrong OLED module**. The user's correct photo in T25J shows VCC, GND, SCL, SDA, matching `J_OLED` signal order on paper. Retract the T25I connector pin swap and crossed-cable advice; preserve the old report with a visible correction. Verify module identity, allowed supply, actual installed header orientation and pad continuity on the physical device before assembly. The earlier 0/0 DRC does not check off-board module mating or supply rating.

29. **A capacitor's catalog value is not its biased circuit capacitance.**
   - TDK `C2012X5R1A476M125AC` visibly loses a substantial fraction of 47 µF across the DC-bias plot by 3.3 V, while TI TPS631000's 10.4 µF minimum is an **effective** 3.3 V condition. A nameplate-only arithmetic sweep is useful for planning but cannot prove stability or startup; obtain the exact vendor bias payload/measurement and include tolerance/temperature/aging before declaring the threshold met. Do not fill unavailable DC-bias samples with graph guesses.
   - A data-sheet delay/ramp and `Q=C×V` yield a time/charge budget, not a closed-loop transient waveform or peak current. Keep the T25M script labeled as accounting and the encrypted-model 10 µs result as a limited engine smoke.

## T25N inductor ratings vs transient behavior

- Read the **exact manufacturer part row** and its test definitions: for Murata `DFE322512F-1R0M=P2`, 4.8 A is a DC current causing **30% inductance reduction**; 3.8 A is the DC current causing **40°C rise on Murata's six-layer test board**. Neither is an unlimited peak rating or the TPS631000 current limit. Different layers/ambient/AC core loss can change the board thermal result.
- Compare a converter's inductor to TI's **boost peak formula plus 20% saturation margin** using explicitly stated VIN, load, assumed efficiency, inductance under current and switching frequency. Nominal L tolerance in TI's recommended interval and a successful static example cannot prove startup, transient, weak-cell full-load behavior, or L(I,T) at actual current.

## T25Q Windows PowerShell 5.1 script encoding

- The v1 `.ps1` in Git contained UTF-8 without a BOM and em dashes inside string literals. The user's Windows PowerShell read it using a legacy code page, producing a `ParserError` near line 152 **before any PSpice run** and before ZIP creation. This is an automation failure, not an electrical or vendor-model result.
- For one-click scripts targeting Windows PowerShell 5.1, use **ASCII-only source text** (or an explicitly verified UTF-8 BOM), check bytes before Git publishing and use new versioned names/output folders after a failed attempt. Do not classify a launcher that prints its final static instructions as evidence the called PowerShell script actually ran; require its unique result ZIP.

## T25Q bounded PSpice runtime evidence — 2026-09-25

- A **finished short PSpice pilot** can establish model compatibility without establishing startup. The exact TPS631000 v2 pilot independently showed `JOB CONCLUDED`, 1001 rows and VOUT 0.1182 V at 10 µs, while TI soft start takes milliseconds. Do not label the incomplete voltage as a startup failure or success.
- A **runtime projection is a gating heuristic**, never an observed full transient. In T25Q v2 a 31.13 s / 10 µs pilot projected 37356 s for 12 ms; the full job was skipped before launch. Preserve `FULL_RUN_SKIPPED_SLOW_MODEL` separately from simulator abort, convergence error or an electrical failure. No repeated microsecond runs convert a missing millisecond waveform into evidence.
- For exact TDK C2012 parts, a downloadable *series* PSpice model link does not prove either exact model exists inside. Scan actual archive for both full part numbers and inspect units/conditions before deriving a reference C(V); account for tolerance, temperature and aging separately before claiming TI effective-C minima are met. Manufacturer characteristic charts explicitly label reference data as nonguaranteed.
- T25R shows that a vendor product page's **download link is not proof the bytes can be retrieved** from the user's network: PowerShell received HTTP 403, and the evidence ZIP has only a report. Record HTTP access failures independently of part/model failure; do not invent the missing C(V) or repeat an unchanged downloader. A successful official-browser download or vendor/bench characterization is required before claiming exact-part effective capacitance.

## T25S design review versus validation scope

- Keep a previously accepted datasheet/nominal schematic calculation on its **actual claim**. A 10 µs PSpice pilot and a failed HTTP download cannot overturn the FB divider or static PR1 arithmetic; conversely those equations cannot establish biased C, real source ESR, startup waveform, or switched carrier/card currents.
- After an exact model cannot complete the relevant time scale, **stop producing repetitive low-information fixtures**. A practical alternate final integration gate is instrumented prototype waveforms against source- and device-specific criteria, with explicit operating sequence and tolerances. Neither an invented averaged regulator nor a blanket claim that PSpice completion is mandatory should block a bounded engineering decision.

## T25 continuity failure and source-provenance correction (2026-09-25)

- Before requesting another BOM or PDF, inspect current SchDocs, existing T25 reports, stored project uploads and their identity. `T25T_CURRENT_SCHEMATIC_MPN_INVENTORY.md` extracted 133 schematic designators / 55 MPN strings; those counts include logical items and do not attest to purchased lots. A fuzzy-named `BOM_PURCHASE_VERIFIED.csv` stored with other projects actually lists Arduino Nano/HC-06/IRLZ44N and is **not a Datalogger BOM**. Match circuit-specific designators/MPNs, not just filenames.
- GitHub's complete tracked tree currently has no PDF, but the WEO OLED bare-panel PDF was uploaded and already analyzed in T25K. No PDF is generally ignored by `.gitignore`. The user's local Windows folder has not been enumerated, so do not claim that block PDFs do not exist; locate before drawing that conclusion.
- Recent verified interface facts must carry forward: T25J retracts the wrong OLED photo and confirms correct-photo `VCC,GND,SCL,SDA` order matches the `J_OLED` schematic signal order; T23 routing and `03_MICROSD.SchDoc` already define the card socket interface. These connectivity facts do not imply characterized real SD-card/OLED-carrier current profiles or board-level simulation PASS.
- A 151,800-character handoff with 65 historical `CURRENT EXACT POINT` headings obscured the live next step, including a superseded manufacturing path and a redundant request for the BOM. Exact original preserved in `HANDOFF_ARCHIVE_THROUGH_T25T_2026-09-25.md`; future updates replace the one short live checkpoint and link dated evidence rather than accumulating headings.

## T25Y — installed population is not the symbol or purchased count

- A populated schematic symbol and a purchased matching MPN do **not** prove that footprint is assembled. `C_USB2` and `R_ST_PU` exist in the live power SchDoc, while recovered v0.17 assembly instructions say both **DNP initially**; the current PrjPcb says `Variant=[No Variations]` and does not settle final POP/DNP. T25F initially counted two USB capacitors and linked ST to 3V3_SYS as though both were installed; T25Y corrected this. Before claiming board waveforms, audit actual population by designator and model both unresolved states with explicit effective-capacitance uncertainty. Do not ask the user to rebuy a part merely because it was originally DNP; the user confirms every PCB component is already in hand.

- For signed stress limits, inspect the original datasheet image **and cross-check a manufacturer's full catalogue**: the single-part FOSAN FSS2301S PDF prints `VGS +10V`, while FOSAN Semiconductor's official catalogue lists this exact FSS2301S/A1SHB as `VGS +/-10V`. That resolves the negative-rating ambiguity. The computed `VGS=-6.106V` and 3.894V nominal difference are for an isolated DC vendor-zener fixture only; they cannot certify complete board transients, population, lot or temperature corners.

## T25AB — solver completion is not a valid switching test

- A vendor-model PSpice `JOB CONCLUDED` plus printed voltages proves only that the mathematical model produced a trace. Require the intended **pre-event steady state** (here VIN_MUX near VIN1=5V) before measuring unplug dip. The v1 trace had 3001 rows and no counted errors, but pre-unplug VIN_MUX never reached 1V. Treat it as invalid stimulus/operating point or model behavior pending controlled diagnosis, not as proof the assembled circuit will fail.
- PowerShell `Start-Process -PassThru` `ExitCode` can be unavailable even when the .out says `JOB CONCLUDED` and has full data. If code is null, use explicit solver log/data verification; if a nonzero code is present, still flag failure. Preserve console, stderr, netlist, .out and .dat in result ZIP even on partial failure so the next agent can audit actual evidence.
- TI technical support has explicitly reported a TPS2116 SPICE priority-mode VIN2-first misbehavior relative to their EVM. Before converting a low-VIN2 vendor macro-model result into a hardware claim, run light-load and ST pull-up **diagnostic controls** and prefer documented physical behavior when the model contradicts it. A diagnostic ST pull-up to an independent supply is not a decision to populate R_ST_PU on RevA.

## T25AC — a healthy solver and a held-up capacitor do not prove transfer

- In T25AB v2, 3ms VOUT~3.367V at light load was a 22uF/330ohm decay above both candidate VIN2 voltages; quantify RC and record actual source current through `I(V_BAT_FIXTURE)` after VOUT approaches VIN2 before declaring backup transfer. An apparent 5V pre-event in one case does not rescue other cases whose prestate failed. Distinguish ideal test fixture capacitor and 3.3ohm load from actual converter, USB and battery networks.
- Official TPS2116 section7.4 gives an explicit cross-condition: when the supply powering the IC collapses faster than1V/10us, the other supply must be >=2.5V to prevent possible reset. Applying a 5V/10us artificial collapse with VIN2=1.8V exercises this documented risk; neither a poor macro-model result nor an unmeasured physical USB slew proves the purchased PCB fails. ST is an open-drain status output; datasheet section7.3.3 calls for an external pull-up, while historic R_ST_PU initial DNP must be treated as a separate unresolved population question.

## T25AE — inspect a vendor model source current and stop at contradiction

- Solver completion with a realistic-looking voltage trace says nothing about physical handoff. T25AD v3 source-current samples show long-lived capacitor discharge and effectively no backup feed even under an ideal 3V VIN2/330ohm control. A slower 100us fall briefly supplied 0.539A, then turned off when tied MODE/VIN1 fell from0.9 to0.8V; coincident logic-level crossing is a hypothesis about macro-model internals, not proof of a board bug.
- The 1V/10us / 2.5V datasheet warning is a conditional risk for fast-collapse/low-backup scenarios, not an excuse to call every model failure a legitimate reset. Crosscheck slower fall and >=2.5V backup controls with the datasheet and TI EVM support; when model contradicts these, mark its affected verification gate blocked and move to independent evidence. Preserve raw deck, .out, .dat and hash, not merely a wrapper PASS/FAIL label.

## T25AF — reconcile product requirements before more OVP simulation

- A calculated OVP trip above5.5V cannot by itself guarantee a pass-through TPS2116 input always remains inside its recommended <=5.5V range for every slowly rising low-load source, while also promising no cutoff at exactly5.5V. Inspect source workbook requirement and gate status alongside the physical datasheet: v0.17 explicitly states ANALYTICAL HOLD / P9 ONLY and NOT Production LOCK. With current historical B8/B9 values the upper static trip leaves84.279mV to ABSOLUTE6V, not a validated dynamic budget or an ordinary operating region.
- Do not treat a manufacturer nameplate 22uF/tolerance/characterization chart as a guaranteed installed biased Cmin, a MOSFET vendor 45ns fixture delay as the complete reference/PNP/FET cutoff, or an optimistic TS431 IK upper bound as proof of >=1mA recommended actual cathode current. Resolve the 5.5V no-nuisance requirement before selecting a new threshold or parts; user has purchased the PCB components, but no board has been fabricated.

## T25AG — check locked historical acceptance gates before asking the user to reselect them

- The real recovered v0.17 Purchase BOM already specifies 1.80V minimum **at loaded battery-pack terminals**, 280mA 3V3 design load, and no nuisance USB trip at 5.50V (Power Calculations B8/B6/B18; OVP Calc B5); P9-F01/O01/C01/C02/C03 already specify zero-reset/cutoff/backfeed validation as PENDING. Asking the user for these numbers again misstates missing *verification* as missing *requirements*. Keep historical status and present-day SchDoc authority separate, but do not erase old criteria merely because the workbook binary is not tracked in Git main.
- TI TPS2116 can operate with VIN2 as low as 1.6V, but a different conditional requirement applies to fast source collapse: alternate source >=2.5V to prevent an internal reset at >1V/10µs fall. At a 1.80V loaded AA pack the purchased topology's uninterrupted hard-unplug claim needs real slow-collapse characterization, valid modeling or a qualified circuit remedy; this is a risk, not a declared failure of the physical board.

## T25AH — track which capacitor holds which node

- The purchased C_USB1 is on protected USB_VBUS_PROT (TPS2116 VIN1), while C_IN is on VIN_MUX (TPS631000 VIN). For unplug, one shapes the selected USB input fall and the other bridges the break-before-make interval after selection; do not silently add their nameplate values or substitute a 10us ideal voltage drop imposed directly at VIN1 for cable removal on the actual topology.
- PR1 resistor/reference tolerance has two distinct relevant corners: upper 4.368844V transfers earliest and minimizes time from 5.5V to the command, while lower 3.638806V transfers latest, yields the highest constant-power VIN1 fall slope and least isolated C_IN energy before 1.65V. Comparing a conditional energy time against the manufacturer's *typical* 17.7us switch time does not prove a maximum gap, prevent RCB delays, qualify capacitance under bias or validate MCU rail continuity.

## T25AL — Altium simulation output must contain usable trace data

- A newly opened `.sdf` tab alone does not prove successful model parsing or convergence. In T25AK the fake resistor subcircuit produced plausible 200us voltages while the official TI model inline opened `.sdf*` with a roughly `1e20` axis and no discernible curves. Interpret only after checking Messages or numeric traces.
- Running a 200us fixture with an unplug event scheduled at 1ms cannot establish source transfer. If both external `.LIB` and inline-model variants lack valid data, do not blame `.LIB` alone or expand to 20ms before distinguishing parse, solver, and plot issues.

## T25AP — Use exact mounted MCU and each switched rail's own limits

- The earlier prototype used STM32G030F6, but current `02_MCU_CORE.SchDoc` / T25T inventory has `STM32G070KBT6`. ST DS12766 Rev3 specifies POR/PDR for this device, VDD operation 2.0–3.6V and maximum falling VPDR 2.04V. Do not ask for an unverified programmable BOR option byte or transfer G071/G030 electrical limits to G070.
- A MCU that stays above its reset threshold does not prove an in-progress SD write survives. SD Association's conventional first-row microSD VDD range starts at 2.7V; check `SD_VDD` at the socket after its switch and local capacitor, not only `3V3_SYS` or MCU VDD. The user's unbranded 4GB card has no qualified current profile.
- The user-supplied WEO PDF concerns a 20-pin bare panel, not the photographed four-pin carrier. Its 2.8V logic minimum is conditional until that carrier's actual panel and power circuit are confirmed. Do not call the panel current or voltage a measured module rail requirement.

## T25AR — inspect full simulation history, including load enabling

- A wrapper that summarizes only planned handoff windows can miss a worse *different* event. T25AQ handoff-window minima were all >3.08V in a simplified model, while independently scanning its entire PSpice .out found 3V3_SYS=1.576V during initial enabling of nominal 54.1uF SD decoupling in the C_OUT=10.4uF reference scenario. Future simulation reviewers must inspect raw waveforms across startup, every branch enable, both source transfers and recovery, and report threshold crossings with timestep and actual model scope. Neither simulated sub-2.04V nor >2.04V under illustrative switch/nominal capacitance proves actual MCU reset or safety. Do not equate a microSD card's expected power-up below its 2.7V working limit with an SD-write error.

## T25AT — datasheet headline ratings need their stated input and driver conditions

- TI's TPS631000 1.5A *output* specification is tied to VIN>=2.7V and VOUT=3.3V; the ~2.9A *typical internal switch* rating is different. Neither value qualifies converter transient output when the two-AA pack is 1.80V under load. AOS AO3401A nanosecond switching data uses a -10V gate and 3ohm test generator, not the actual 3V3/BC847B/10k/100k driver. Keep conditional charge screens distinct from validated SD-on timing, MCU no-reset and SD-write integrity.


## T25BK PSpice PRINT-table parser lesson

- Do not assume every expression in one `.PRINT TRAN` directive appears on the same numeric row in the PSpice `.out` file. In T25BJ, PSpice 25.1 emitted the six voltage columns in one table and `I(V_SRC)` in a second table.
- A regex expecting seven numeric fields accidentally consumed the **next row's timestamp** as source current, creating impossible summary values such as `VIN_min=0.000105V` and `I_source_peak=0.0251A` even though all 16 simulator jobs had concluded normally.
- Future auditors must locate each PRINT table by its own header, parse the tables independently by time, and only then combine metrics. Raw `.out` data outranks a generated summary CSV when the two disagree.
- Preserve the failed/generated summary as evidence, but mark it rejected rather than deleting it. `AI_SCRIPTS/T25/T25BK_Audit_T25BJ_Raw_v1.py` is the reference implementation for this case.


## T25CF — import the official numerical profile before interpreting model failure

- TPS54202 package's Startup/trans.sim explicitly sets20ns maxstep,ABSTOL10n,VNTOL10u,ITL1=1500,ITL2=400,ITL4=100. Copying only encrypted LIB omits reference solver settings. A changed numerical-profile test is justified once; these settings neither guarantee convergence nor certify circuit accuracy. Preserve profile identity and all unchanged electrical lines.
- JOB CONCLUDED/Simulation complete can coexist with ORPSIM-15139. Check actual end time, solver errors and valid prestate before events; a0.8824V startup value at1.243ms cannot be called regulated output or unplug voltage. If the explicit changed profile also fails, block this macro-model route and move to independent evidence; do not create endless Windows reruns.

## T25CG — timeout has no implicit simulated timestamp

- T25CF's .out stopped in bias listing while stdout announced transient. PRINT tables may be emitted at job completion; zero supplied rows does not prove solver never advanced. Without DAT/progress logs actual simulated endtime is UNKNOWN, not0s. ORPSIM-16534 warns a cost, not a proven cause. Record runtime limits and mark bounded route blocked; no blind timer/solver retry.
- Moving mux downstream of regulators can remove raw1.80V from the backup pin only if the backup regulator is kept ready and its rail stays>=2.5V dynamically. Do not disable it atUSB attach and then claim instant backup. Retune USB/PR1 for the actual3V3 consumer range; preserve converter outputC upstream and separately qualify load-sideCbus/RCB/SDswitch drop. Nominal rail/static margin/typical switchover do not prove noreset.


## T25CH — PR threshold window, precise monitor and standby provenance

- Moving a mux after regulators requires proving the PR1 window, not merely changing resistor nominal. Reject an emptycornerwindow before vendor simulation. FiniteCbus does not repair a sustained selected undervoltage; higher-voltageautomatic mode does not imply USBpriority withoverlappingrails.
- A reset supervisor used as source-good signal introduces release delay and usually onlytypicalassertion timing. Check outputtestcondition, unpowered behavior, pulldownloading and watchdog disable; never connectitsRESET toMCUNRST by assumption. Stocklisting isnottechnicalqualification orpurchase.
- Match exactmanufacturer/MPN: LionMAX809S linksUMW; don'tborrowAnalogspecs. OrdinaryTPS3823-33DBVR is85°C perTI evenifretailer says125°C. Saveddatedexcerpt preservesannouncedstock.
- TPS631000 IQ atVOUT andVIN aredistinctpin currents/testconditions. AddFBdivider outputload andpowerconversion; headline8uA isnot guaranteedAA-packstandbycurrent.


## T25CI — model identity, local control runtime and supply sequencing

- A model ZIP revision labelled encryption removal may have the same electrical core as olderTINA. Compare core/source/hash; do notcallit a new improvedmodel. Low-bias nominalreference validity must precede switching claims. 1mAmodelworking doesnotprovephysical100uA partfails.
- ngspice canreturn0 after TRANaborted. Requireactualendtime/erroraudit/rawtrace; a completednominalcontrolfixture atidealMON doesnotprove diodeOR/startup,muxbranchcurrent,MCUNRSTorSDwrites. A timeoutwithoutdatahasUNKNOWNsimulatedprogress.
- MonitorpoweredfrommuxoutputoronlymissingBAT canlatchUSB-onlystartup. IndependentMONOR needsrealdiode/current/clamp evidence; a fixedVF behaviouralOR isonlysensitivity. USB-poweredreference reducesAAstandbybutitsstartup isanotherdynamicgate.
- LM4040DIM3X-2.5 isLM4040-N,notLM4040D25IDBZR. LM4040-N SOT23pin1K/pin2A differsfromTLV431DBZpin1REF/pin2K/pin3A. BAS70-04seriespair isnotcommoncathode;2packagesusing1diodeeachisintentionaldraft.
- Readdatasheettablecolumns/conditions:TLV1701VOL900mVisMAXat25C/36V/100mVod,notfulltemp3Vbound;70nAleakand460/560nsdelaysaretypical. Staticmargincannotabsorbunboundedbuckripple. Hysteresiscomparethresholdsofthesamecorner.
- ExistingMPNpresence isnotsparequantity. NeverreallocateFB/CC/SD/OLEDretainedparts toasourcedraft; selleromittedNOPBsuffixmustnotbeinvented.


## T25CJ/CK/CL — population intent, model power accounting and interrupted retention

- HistoricalDNP/Openintentisnotcurrentassemblydisconnection. AuditpartparametersandPrjPcbvariant/outputpopulation beforeclaimingcutoff. Recordtheunappliedpopulationfixintheonepowerproposal;donotsilentlyremoveresistor/copper.
- returncode0withngspicetranabort/partialWRDATAisnotcompletedtest. Keepactuallastsimulatedtimeandabortnode;rejectpartialeventresult.
- Unencryptedofficialmodelcanbeabstract:checkinput/outputpoweraccounting,unmodelledIQ/thermal,internalUVLO/offsetbeforeinterpretingzeroinputcurrentasbackfeedproof. IdealregulatedinputsdoNOTtestAA1.8/converterstartup.
- Newpartstockdoesnotqualifythermal/reversecurrent/variantmodel. DoNOTuseLM1117modelasLD1117/TLV761/TLV767;doNOTpresentadjustable76701asfixed76733. Package-specificthetaDCY95.4isnotKVU67.2oractualPCBtheta.
- ExecutortransportfailureisnotcircuitFAIL. Runtimeoutputreceivedandfullrawdurablearchiveareseparategates;pendingrawretentionmustbeexplicit. Recoverexistingfilesbeforeunchangedretests. GitcontinuityCIisnotfunctionalPASS.


## T25CM/CN/CO — recovery, scoped models and source accounting

- Recover existing raw files after executor outage before rerunning tests; saved/received/mathematical completion/durable bytes are separate claims. Pin archive version and verify rematerialized SHA/CRC; no upload duplication after unknown outcome.
- A first nominal model timeout may be a profile issue: TLV76701 explicit TI20ns startup profile completed where100ns timed out. Change official profile once with documented identity; do not infer hardware failure from timeout or blindly increase runtime.
- Generic SPICE helper subcircuits collide across vendor files: COMPHYS_BASIC_GEN input loading differs. Nested wrappers isolate originals without editing vendor bytes. Model current accounting must be valid before feeding it from a converter; TPS2121 omission would falsely unload BAT/LDO.
- TPS259533 filename/header alone does not decide validity; source tracing shows5.7V comparator+3us delay+enableAND drivesOVLO shutdown, unlike databookclamp. Reject that fault claim even when full trace completes; do not infer real thermal delay. Preserve valid nominal subset with exact scope.
- A startup that settles later than pre-event window needs a later event/prewindow, not an invalid transfer result; combined533/LDO3ms event completed normal5.5V case. Do not transplant its31.25k feedback result onto Iran31.6k version.
- Package JEDECtheta and no-loadIQ max do not guarantee actual PCB temperature or280mA ground current. Exact resistor tolerance/TCR corners are DC conditions, not transient/SDwrite/NRST proof.


## T25CP — line-edge and reverse-model scope

- TLV767 wide input rating is not a promise of unchanged output during fast line edges. Inspect both rising and falling events, output extrema and real source/Ceff limits; larger COUT did not monotonically improve every nominal overshoot.
- Vendor TLV767 model omits physical OUT-to-IN body diode. Forced output with zero input reports only1.5uA behavioral shutdown current; reject reverse safety/hold-up inference. Source-current edge spikes also include CIN current; distinguish current at LDO pin from total source current.
- Schottky OUT-to-IN bypass and series diode before CIN have different purposes. Neither proves AA/mux reverse blocking by itself. Do not turn generic diode name or typical guidance into full-temperature exact-part qualification.
- Windows ngspice codemodel command kept literal quotation marks in the library filename; fix loader path syntax while preserving failed output, not electrical parameters. Printed adaptive timestamps can round equal; retain their samples/extrema and prohibit backwards time, rather than discard rows.
