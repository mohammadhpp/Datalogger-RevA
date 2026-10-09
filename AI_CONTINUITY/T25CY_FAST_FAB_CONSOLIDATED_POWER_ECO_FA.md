# T25CY — rapid RevA one-shot power ECO, purchase and build decision

Date 2026-10-09. Git parent fad03ccea3d4adc90453c4caf0c714bed0b2fc80. **DESIGN PROPOSAL ONLY / NO WHOLE-BOARD POWER PASS / FABRICATION HOLD.** User requests prompt completion and consolidated purchase data. Do not repeat invalid TPS2116/TPS631000/TPS2121 PSpice fixtures or issue more arithmetic-only approval stages. One mechanical/power ECO, then DRC and a small functional proof.

## Recommended single power architecture (not applied)

USB-C VBUS -> maintained S1 USB pole -> TPS54202DDCR buck (input 4.5–28V and its separate 10uH shielded coil, EN floating, 12V bounded fault input) -> USB_REG3V3 nominal3.305V -> TPS2121RUXR IN1. BAT loaded2xAA at 1.80V -> fused/holder/S1 BAT pole -> retain TPS631000DRLR and original Murata DFE322512F-1R0M=P2 1uH -> BAT_REG3V3 *always enabled* -> TPS2121 IN2. TPS2121 OUT pins1+8 -> new effective postmux bank -> existing3V3_SYS MCU/RTC/OLED and screened TPS22918 SD soft-start switch. S1 pole #3 switches only shared return ends of *two separate* USB-C CC1/CC2 Rd resistors. R_EXP_PWR_EN DNP, no raw USB fault output to 5V AUX or AA charging.

**Important correction:** upstream-mux USB buck target3.576V proposed previously is **not safe to copy downstream of TPS631000**. The new mux OUT directly supplies 3V3 loads, so USB source must be ~3.30V with over/undershoot validated below3.6V MCU/SD maximum. Do not add separate TLV76701 or SS14 for this architecture and do not connect the old pass-through TS431/PNP/FSS2301S output in parallel to the new buck. Replacing TPS2116DRLR with TPS2121RUXR is a new netlist+footprint; parts are not pin compatible, and the live CAD is still unchanged.

### Numeric starting points, **not locked BOM**:

- USB TPS54202: R_FB_TOP 100k1%, R_FB_BOTTOM 22k1%, TI VFB typ0.596 ->3.305V; 2x TDK C2012X5R1V226M125AC input 22uF/35V, 3x same output, separate 10uH shielded L, 100nF/50V BOOT-SW. Ceff after DC bias/temp and Cff loop yet to qualify. 5ms typical soft-start requires BAT regulator already ready. 12V source bounded fault is within buck VIN range, not proof of unbounded surge.
- TPS2121 RUX pins IN1=7, IN2=2, OUT=1/8, PR1=6, CP2=3, OV1=5, OV2=4, ILIM=10, SS=11, ST=9, GND=12. XREF PR1 from USB through20k+100k divider, CP2 from BAT through33k+100k divider; all resistors 1%. OV1,OV2 GND when unused per TI; ILIM 44.2k to GND (TI specified current limit 2..3A) and SS100nF to GND initial only; ST GND when unused or qualified TP/pull-up if reading. Layout verified for RUX thermal pad and switch surge.
- Postmux 3x TDK C2012X5R1A476M125AC nominal47uF/10V initial + fourth footprint DNP, only if biased effective capacitance/inrush permits. Separate before-mux input and BAT COUT capacitors. T25BK/BL SD switch TPS22918DBVT and CT4.7nF C1608NP01H472J080AA, bypass1uF C2012X7R1H105K125AB; do not reselect SD. Preserve expansion DNP/open and all mandatory test points.
- Exact S1 3PST maintained ON/OFF, holder, TDK SPM4020T-100M-LR or **validated exact Iranian equivalent** remain pending. S1 panel MPN deferred historically but board-side six conductors must be routed and rated; do not confuse six terminal DPDT with true 3 poles.

## Newly executed one-shot priority static test (not vendor device PASS)

Reproducible local T25CY_Priority_Corners_v1.py, 256 static corners using TI FB=.581..611, ±1% FB resistors, historical battery *static* 3.214242..3.392396V (not actual AA1.8 vendor proof), ±1% PR1/CP2 dividers. Under these assumptions USB DC spans **3.169614..3.444379V**, minimum PR1−CP2 difference **+69.214mV**, and equality switchpoint spans **2.876080..3.086278V**. With an additional *single adverse* TI comparator offset −40mV, minimum crossing becomes **2.828239V**. TPS2121 IN recommended min2.8V: only28mV illustrative margin. The actual transient, line/ripple, reverse blocking, current limiting, bias/resistor leakage and Ceff not represented; **DO NOT USE STATIC CASES TO AUTHORIZE FABRICATION**. Local full ZIP SHA256 4d17ff792fbfdb136b53257e7e73a1306a35161711f72ba8cc380ca7a9c41e46 (generated artifact), text report/BOM in that bundle, with complete 256-row CSV.

## Consolidated candidate purchasing: NOT ALL IRAN VERIFIED

| Role | Part and board quantity | Iran evidence and decision |
| --- | --- | --- |
| USB buck | TPS54202DDCR ×1 (quote 4 for 3 samples+spare) | Iranian Lion listing **221 shown on 2026-10-09**, https://lionelectronic.ir/products/792-TPS54202DDCR ; verify checkout/traceability |
| NEW power mux | TPS2121RUXR ×1 (quote4) | Old T25CK Iran Lion listing 28, **today not revalidated**; source and footprint gate OPEN |
| NEW separate USB coil | TDK SPM4020T-100M-LR 10uH ×1 (quote4) | TDK thermal/sat/DCR technical candidate, **no verified exact Iran seller**, alternative vendor+MPN/footprint OPEN |
| Input/output buck caps | C2012X5R1V226M125AC 22uF/35V ×2IN+3OUT | Existing purchased BOM part; new free-stock count and actual biased Ceff OPEN |
| Postmux Cbus | C2012X5R1A476M125AC 47uF/10V ×3 +1 optional DNP pad | Existing purchased BOM part; effective Cbus/inrush/board fit OPEN |
| 100nF | CL10B104KB8NNNC ×2 for buck BOOT and mux SS (plus HF as needed) | Purchased BOM existing; new count to reconcile |
| Resistor new values | USB FB lower22k; PR1 top20k; CP2 top33k; mux ILIM44.2k, each ×1; existing100k ×3 | Exact 1%/0603 MPNs and available Iran new quantities OPEN |
| SD subgate | TPS22918DBVT ×1; C1608NP01H472J080AA 4.7nF ×1; C2012X7R1H105K125AB 1uF ×1 | Exact MPN previously screened with user's Iran listing, recheck at checkout |
| Panel S1 and holder | 3PST maintained switch and low-R 2xAA holder ×1 each | Exact MPN/pinout/Iran stock and battery Rpath not qualified; S1 exact deferred |
| NOT NEEDED | TLV76701, SS14, new TPS631000, new original L1, TPS54202 alternate module | Don't buy for this architecture |

Quote 3 assembled *engineering samples* plus spare parts (not 3 production-approved boards). Exact local BOM file with 20 lines and supplier status is in offline ZIP; this Git report preserves main decision unambiguously.

## Shortest valid finish / non-negotiable acceptance

1. **One** Altium power/SD/S1 ECO, physical pads and 2-layer re-layout; replace prior mux correctly, offboard six-wire connector and all RefDes/polarity, route high-current; fresh ERC/compile + **new Full Batch DRC 0/0**; test points USB_REG/BAT_REG/TPS2121 input currents, VIN/EN/buck OUT/SW, MCU.VDD/NRST, SD_VDD/SD_write, 3V3_SYS. Historic T24 PASS is superseded for changed nets, not new ECO PASS.
2. Three real electrical *gates only*: (a) USB input 5.0/5.50V and bounded12V fault with 3.3V output, startup and max 280mA; (b) AA terminal loaded1.80V, buck/boost ready and true S1/holder Rpath, USB attach/unplug both ways (rapid/slow), rail minimum and both source currents; (c) SD write integrity/CRC and MCU NRST plus OLED actual carrier while transferring. TI vendor model missing/invalid for integrated transient; do not fake whole-power SPICE. **If not obtainable, fastest reliable path is power-only prototype test before final RevA fab**. If user knowingly authorizes sample RevA PCBs instead, fabricate only small engineering sample run with test points and no production PASS.
3. Cannot buy or fabricate this proposed new power block yet: exact Iran 10uH source and other MPNs, input/output effective caps, static priority offset/ripple and actual source switching need qualification; after exact one-shot BOM and single user approval, apply ECO. No Gerber or product-qualification claim in current turn.

**NEXT EXECUTABLE ACTION:** resolve exact local 10uH coil and remaining MPN rows with user-purchased-stock cross-check; then apply *single approved* power ECO and run minimal 3 electrical gates before engineering sample fabrication. **BLOCKER REQUIRING USER:** explicit one-time approval of fully sourced new BOM/ECO/samples, not recurring routine confirmation. FABRICATION HOLD.
