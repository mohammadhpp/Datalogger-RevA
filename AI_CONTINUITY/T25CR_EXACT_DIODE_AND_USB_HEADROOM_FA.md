# T25CR — Vishay SS14 exact-MPN Iran screening and LDO headroom, 2026-10-09

**Scope and classification:** `ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_BOARD_OR_COMPONENT_PASS`. Distinct headroom/thermal sensitivity, no repeat of T25CJ/CK/CL/CN/CO/CP invalid or completed simulations, no PSpice waveform or MCU/SD no-reset inference. Authoritative Git main T25CQ `6dd79825466d3a8d8a9ba25c6691489785b37df6`. Existing 01_POWER.SchDoc, PCB, populated parts and procurement are unchanged. **FABRICATION HOLD**.

## New exact-manufacturer and Iran observation (partial progress only)

Iran seller Afranik [diode catalog](https://afranik.ir/passive/diode.html) displayed exact `SS14-E3/61T`, **Vishay**, DO-214AC SMA, product price in Iranian rial, MOQ10 and add-to-cart. An indexed catalog snapshot explicitly presents the part number/manufacturer, unlike previously ambiguous generic SS14/Toshiba/Vishay listings. This is **EXACT_MPN_LOCAL_LISTING_SEEN**, not paid-stock/lot/authenticity proof; checkout availability, reel labels and traceability unverified. Alternative distributor lists and global DigiKey stock are not Iran acceptance.

Manufacturer [Vishay SS12..SS16 official datasheet 88746 (Rev 23-Apr-2020)](https://www.vishay.com/docs/88746/ss12.pdf) covers **SS14**: `VRRM=40V`, `IF(AV)=1A` under rated-lead-temperature/board assumptions, `IFSM=40A` for a single 8.3ms half-sine at rated load, `VF<=0.50V @ 1A, TA25C` (300us pulse, 1% duty). Reverse leakage maximum at **rated blocking 40V** is `IR<=0.2mA @TA25C`, `IR<=6mA @TA100C`; neither number is the measured leakage at our actual 3.3/5V and the 100C figure warns against assuming zero battery backfeed. `TJ-65..150C`. `RthetaJA_typ=88C/W` refers to test board 5x5mm copper pads, not verified RevA 2-layer PCB. SMA cathode band marking is explicit. Note: TI LDO and diode product datasheets are different vendors.

## Executed sensitivity calculation with 27 headroom and 9 thermal scenarios

Reproducible standard-library script `AI_SCRIPTS/T25/T25CR_Diode_Headroom_Screen_v1.py`; `python ...` has been executed with all regression assertions passing; full generated JSON `T25CR_Diode_Headroom_Screen_Result.json` available as a local conversation deliverable and regeneratable next to the script. This is **arithmetic executed**, not vendor SPICE or hardware qualification. `AI_EVIDENCE/T25CR/SCREEN_AUDIT.json` records stable summary, precise criteria, and evidence hashes.

Under **hypothetical** USB=5.00V, `VF=.5V`, LDO Vout=3.3V, `dropout=.9V`, DC headroom `5-.5-3.3-.9 = +.30V`. With 4.75V **scenario** (not project-locked source spec) it is +.05V. USB5.0/VF.6/dropout1.2 yields −.10V. TI [TLV767 overview](https://www.ti.com/product/TLV767) advertises dropout `900mV typical` at vendor conditions; this is **not** a max guaranteed at 280mA/temperature. Vishay `VFmax=.5V` is at 1A/25C and is **not** a guaranteed worst case at all RevA temperatures. S1/cable/OVP-path conduction losses are not in these equations. Consequently no usable worst-case VIN–VOUT guarantee can yet be claimed.

At nominal Iout=280mA and hypothetical VF=.5V, diode dissipates .140W. If a 12V fault is passed by the existing OVP MOSFET, LDO at assumed VIN=11.5V dissipates `(11.5-3.3)*.280=2.296W` of load-related heat; multiplying by historic reference `thetaJA 77.7C/W` gives **178.3992C junction rise on reference-board sensitivity**, with no claim for actual PCB/thermal limit. **A forward-series diode does not clamp 12V** and does not substitute a validated OVP response, thermal design or accurate reverse path. OUT-to-IN bypass diode is a different current path and can still send energy upstream.

## Engineering verdict

1. `SS14-E3/61T`: **promoted only from generic ambiguous search to exact-MPN locally-listed technical candidate**; not selected, no TECHNICAL+IRAN STOCK PASS until seller lot, verified ordering, leakage/forward corner and assembly suitability are confirmed.
2. The hypothetical series-diode addition might consume meaningful USB headroom even at 5.0V. Evaluate real manufacturer VF(I,T) and TLV767 VDO(I,T) with path resistances before selecting; a low-loss active reverse-blocking device may be a competing class but needs its **own exact Iranian MPN** and reverse validation. No new controller automatically selected.
3. Original OVP `TS431BCX RFG/BC857BLT1G/FSS2301S` network needs source-bounded real waveform at `USB_OVP_IN,USB_VBUS_PROT,OVP_REF,OVP_K,OVP_BASE,OVP_GATE`, VGS, IK, reverse and proper capacitance. Static 5.915721V historical trip **is not a dynamic clamp**. Model gap persists; no physically valid new fault simulation has been claimed.
4. Actual post-mux effective Cbus, BAT1.80V, mux current-conserving model, transfer deadtime, NRST/MCU/SD integrity remain unproved, independently of this diode screening. Do not repeat invalid TPS2116/TPS2121/TPS259533/TPS631000 fixtures.

**NEXT EXECUTABLE ACTION:** Synthesize an exact full protected-USB alternative or a valid bounded TS431/PNP/FET switching model with independent source/temperature/diode constraints. If no exact manufacturer model exists, do *not* fabricate full OVP PASS; prepare one specific PSpice/bench fixture once named evidence can run. Resume separate BAT/mux test preparations meanwhile.

**BLOCKER REQUIRING USER:** None for routine research and executable file preparation. No buy, assembly, CAD ECO, Gerber, manufacturing permission is requested or implied. **FABRICATION HOLD**.
