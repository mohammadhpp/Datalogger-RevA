# T25DF — Nov 10 user cart + power-passive correction
Classification: executed bounded DC calculations and screenshot-based procurement audit; no electrical whole-system PASS; no Altium CAD, Gerber or order changed.
User supplied live Lion and SkyTech basket screenshots dated 2026-11-10. TPS2113APW explicitly rejected by user due cost and lack of qualified transition. Purchased original TPS631000DRLR must be preserved as candidate.

## Cart edits
KEEP Lion TLV61070ADBVR qty5; boost 2.2uH DFE322512F-2R2M=P2 qty5 (reduce10 to5); CL21B104KBCNNNC 100nF/50V X7R/0805 qty25; C1608NP01H472J080AA 4.7nF C0G/0603 qty20.
REMOVE Lion alternative DFE252012F-2R2M=P2 qty5 as duplicative; remove two off-board TPS54202 ready-built modules from product-component buying cart.
KEEP SkyTech TPS54202DDCR qty5, TPS22918DBVT qty5 (current photo with visible inventory). SkyTech TPS2116DRLR qty5 should be removed if already held from original PCB purchased BOM; keep purchased stock for experimental downstream regulated-source mux only, no device or system handoff PASS. TPS2113APW qty0.
Keep Lion VLCF5028T-100M1R0-2 10uH/Isat1.05A qty2 ONLY for limited 280mA test. TI TPS54202 high-side peak current limit range2.5–3.9A; 1.05A saturation inductor is not qualified for a final board short-circuit fault. Need shielded 10uH Isat>=4A or documented fault-current mitigation, exact manufacturer and Iranian stock currently OPEN.

## Missing passives and materials for 3 prototype builds + reserves
Boost: 510k and91k 1% 0805 qty10 each; 22uF/35V X5R 0805 quantity counted in shared bank (below). Boost optional330pF C0G0805 qty10 DNP until actual Ceff and loop stability; 330pF across510k gives fzero about945Hz.
USB buck: 100k and22.1k 1%0805 qty10 each; 56pF C0G0805 qty10; 100nF/50V bootstrap already Lion basket; 10uH high-current alternative as above.
Shared: C2012X5R1V226M125AC 22uF35V X5R0805 approx30 pcs across converter input/output and spares, or subtract exact existing stock; must measure/obtain DC bias Ceff. TI buck at3.3V nominal44uF output and crossover f0 screen needs Ceff>=29.924uF if f0<40k. TPS631000 previous capacitors are not automatically downstream mux capacitors.
Bus after new downstream mux: C2012X5R1A476M125AC 47uF10V X5R0805 qty15 only if actual biased Ceff/inrush passes.
SD: C2012X7R1H105K125AB 1uF50V X7R0805 qty10; already basket 4.7nF CT C0G 0603 qty20; generic100k PD from stock. Do not buy old TPS2121 RUX-specific 20k/33k/44.2k divider values because mux and pinout are not selected.
Test hardware: 12ohm >=5W qty3, 180ohm >=0.25W qty3, 2AA low-contact-resistance holders qty3, 2-pin 5.08mm THT terminal >=2A qty10, breakaway THT headers qty3; S1 three independent maintained ON/OFF poles exact source unqualified.

## Physically bounded electrical calculation, NOT tested hardware
Pout=3.3V*0.280A=0.924W. At Vin-pack1.8V and assumed efficiency75..85%, input current averages0.684..0.604A before extra post-pack copper/holder drops. For 2.2uH at1MHz idealized duty about0.455, inductor triangular ripple0.372A and normal illustrative peak0.79..0.87A, less than quoted 3.4A Isat of DFE322512F-2R2M=P2. DCR0.066ohm nominal I^2R coil loss24..31mW. These are scenarios, not regulator startup, inrush or short pass.
TLV61070A Vref PWM 485..515mV, feedback 510k/91k and both resistors +/-1% produces 3.1493..3.4596V static output range without leak/transients. Fresh AA pack VIN>Vout can force boost pass-through; MCU/SD3.6V cap must be protected.
TPS54202 100k/22.1k at Vref0.596V yields 3.29283V nominal. 10uH/500kHz/280mA ideal CCM peak inductor current at Vin 5/5.5/12/28V ~0.392/0.412/0.519/0.571A; startup/fault peaks not covered.

## Retain already purchased TPS631000DRLR rather than scrap
TPS631000 is a genuine buck-boost (handles battery Vin above and below3.3V), with 8uA typical Iq vs 20uA typical TLV61070A in different operating descriptions. Its DRL0008A 8 pad 2.1x1.6mm SOT-5X3 has 0.5mm pitch, 0.3mm copper pad width, 0.2mm interpad gap and bottom terminations; normal iron-only hand assembly without magnifier is high risk, especially one-sided home etched no solder mask. Solder paste, controlled hot air, magnification, stencil if possible and inspection on professional solder-masked board are feasible; otherwise outsource only this IC. Do not characterize TLV61070A boost-only part as unconditionally superior. Neither 1.8V@280mA with battery path nor USB handoff/reset/SD has system PASS.

Primary manufacturer sources: https://www.ti.com/lit/ds/symlink/tps631000.pdf ; https://www.ti.com/lit/ds/symlink/tlv61070a.pdf ; https://www.ti.com/lit/ds/symlink/tps54202.pdf ; https://www.ti.com/lit/ds/symlink/tps22918.pdf .
Spreadsheet produced in chat: Datalogger_RevA_Cart_Revision_2026-11-10.xlsx (cart edits, missing components, linked numerical formulas, locks).
NEXT EXECUTABLE ACTION: user edits screenshot carts, purchases only independent validated or limited-coupon parts and passives; determine real 10uH high-Isat exact source and rapid low-power power mux; then physical 1.8V 280mA coupon and one Altium ECO + new DRC. BLOCKER REQUIRING USER: actual irreversible cart checkout; RevA fabrication HOLD.
