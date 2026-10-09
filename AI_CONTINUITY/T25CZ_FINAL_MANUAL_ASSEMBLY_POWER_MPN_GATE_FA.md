# T25CZ — Final hand assembly package feasibility (2026-10-09)

**USER LOCK**: «مونتاژ نهایی دستی است؛ قطعات انتخابی پکیج‌های دشوار نداشته باشند». All newly selected IC packages must have visible, inspectable and hand-solderable leads. Preferred SOT23-3/5/6, SOIC-8 or larger THT, TSSOP-8 is acceptable with manual rework skill and inspection. MSOP-8 requires a trial before acceptance. Do not choose DFN/QFN/VSON/WSON/WLCSP/BGA with hidden thermal pads or tiny SOT5x3 power ICs for the final hand assembled units. New passives prefer 0805; retain already approved 0603 elsewhere unless access problems are discovered. Existing 2-layer/REFDES/pin1/offboard connector rules remain.

**CORRECTION OF T25CY**: Previous QFN TPS2121RUXR and 2.1x1.6mm 8-pin SOT-5x3 TPS631000DRLR are **not approved for final manual assembly**, even though the latter was purchased. Do not purchase using the T25CY PDF / initial BOM until this package constraint is applied. Old Git reports stay archived; no Altium edits.

| Part | Package | Decision | Real gate |
| --- | --- | --- | --- |
| TPS54202DDCR, USB buck | visible-lead SOT23-thin-6 | retain as hand-assembly candidate | TI 4.5..28V; Iran Lion exact MPN recorded; real 5V/5.5/12V fault, coil/Ceff OPEN |
| TPS2121RUXR, power mux | VQFN-HR12 | reject from final hand assembly, not purchase | had fast typical5us, not proof of no-reset |
| TPS2113APW, alternative power mux | TSSOP-8 visible leads (0.65mm) | NEW PRIMARY HAND ASSEMBLY CANDIDATE, not chosen for ordering | 2.8..5.5V input, 1.25A TSSOP version, reverse blocking, 55uA typical operating and 0.5uA standby (not normal load current); Iranian ISEE lists Tehran IC-Kala seller, live authenticity and lot unverified; USB priority / switchover and Cbus_eff need test |
| TPS631000DRLR, current AA regulator | SOT5x3 DRL8, 2.1x1.6mm | replace as final hand assembly recommendation | current RevA PCB unchanged; 1.8V 280mA tests already open |
| TLV61070ADBVR, new AA boost | SOT23-6 visible leads | NEW PREFERRED HAND PACKAGE ENGINEERING CANDIDATE, not chosen for ordering | TI VIN .5..5.5, startup minimum1.3V, 2.5A valley switch limit, low-load 20uA typical from VOUT; actual 1.8V pack 280mA load, inductor, S1 DC loss, inrush, 3.3V regulation and exact Iran stock OPEN |
| MCP1642B-33I/MS, AA boost alternative | MSOP-8 visible 0.65mm leads | conditional if SOT alternative cannot pass; trial solder needed | vendor EVM claims over400mA typical at 3.3V from VIN1.5V, but not a guaranteed corner; exact Iran availability and system low-power OPEN |
| TPS22918DBVT, SD load switch | SOT23-6 visible leads | retain as hand-assembly candidate | T25BL screening and previously observed Iran listing; dynamic SD still open |

Manufacturer references:
- TI: https://www.ti.com/product/TPS2113A/part-details/TPS2113APW ; https://www.ti.com/product/TLV61070A/part-details/TLV61070ADBVR ; https://www.ti.com/product/TPS2121/part-details/TPS2121RUXR ; https://www.ti.com/product/TPS631000/part-details/TPS631000DRLR ; https://www.ti.com/product/TPS54202/part-details/TPS54202DDCR ; https://www.ti.com/product/TPS22918/part-details/TPS22918DBVT .
- Iran candidate seller index TPS2113APW: https://isee.sisoog.com/nc-products/2170945651/TPS2113APW . Index shows one local shop listed and other out of stock, not a checkout verification.
- Microchip EVM: https://www.microchip.com/en-us/development-tool/ADM00460 .

**Proposed architecture still unapplied:** 5V USB via TPS54202 3.3 buck -> IN1 of leaded TPS2113APW; 2×AA loaded at1.8V -> verified available low-VIN leaded boost (TLV61070A technical first) -> IN2; priority mux output -> MCU/SD/OLED 3V3. Keep separate 3.3 rails and existing SD switch plan. Do not assume the previous TPS2121 RUX PR1/CP2 resistor network is compatible with TPS2113A. Design new control circuit from vendor truth before any ECO.

**Low-power caveat:** TPS2113A active 55uA typical vs TPS2121 input ~200uA typical. TLV61070A at low load 20uA typical from VOUT vs original TPS631000 8uA typical, so regulator change is NOT proven lower-consumption. Total sleep power and real startup/handoff must be tested, not inferred from device headline.

**All locks remain:** 2-layer, final manual assembly, local Iran exact-MPN new parts, loaded 1.80V AA terminal, 280mA max design, normal 5.50V USB no nuisance, bounded12V fault, no MCU reset or corrupt SD write on both transitions. Neither 3V3 USB/BAT source model nor full test has passed. No CAD, purchase or Gerber mutation. FABRICATION HOLD.

NEXT EXECUTABLE ACTION: qualify Iran-local exact stock for TPS2113APW, TLV61070ADBVR or other hand-solderable boost, 10uH USB coil, 3PST S1 and holder, then prepare one complete new power ECO and test 1.80V/280mA and handoff. BLOCKER REQUIRING USER: only one consolidated informed purchase/fabrication approval once technical sourcing is closed.
