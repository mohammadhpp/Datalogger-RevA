# T25CQ — diode reverse-path and post-mux hold-up gate, 2026-10-09

**Classification:** ACTUAL_EXECUTED_CONDITIONAL_ARITHMETIC_NO_HARDWARE_PASS (Python standard-library script run with assertions); diode and OVP physical qualification remain **BLOCKED_BY_NAMED_MODEL_OR_INSTRUMENT**. Git main T25CP `3ef4dd67f71d16b9ff7a257e7d1ba2fb3548aeeb` is the parent; T25CJ/CK/CL/CN/CO/CP analyses are not repeated. No CAD, purchase, manufacturing files, physical test or new DRC.

## New distinct engineering finding — four capacitors are NOT one common hold-up store

Post-mux `3V3_SYS` Cbus is different from protected `C_USB1`, LDO `CIN/COUT` and battery-converter output capacitance. During a true break-before-make deadtime at constant 280 mA, and **only if no source replenishes Cbus**, charge balance is `Cbus_eff >= I*t_gap/(V_start-V_floor)`. With scenario `Vstart=3.3V` and **illustrative** `Vfloor=2.7V` (not proven MCU BOR/SD write threshold):

| source deadtime scenario | min Cbus EFFECTIVE, not nameplate |
|---:|---:|
|5 us|2.333 uF|
|10 us|4.667 uF|
|25 us|11.667 uF|
|50 us|23.333 uF|
|100 us|46.667 uF|

Inverting the same equation, effective Cbus 0.5/1/4.7/10/22/44 uF supports at most 1.071/2.143/10.071/21.429/47.143/94.286 us at those scenario values. These are capacitor-only bounds, **not proven real mux deadtimes** or integrated waveforms. Actual Cbus *effective minimum* is not established; CP's 0.5/10 uF values are LDO output fixture values, not an installed post-mux BOM claim.

## New distinct LDO series-diode sensitivity; NO diode chosen

Using **hypothetical** series `VF=0.5V`, LDO dropout `0.9V` at 280 mA input and regulated OUT=3.3V, a 1uF *effective* LDO CIN starts at 4.5V (USB 5V) and has only 0.3V above the assumed headroom floor of 4.2V. With **no replenishment**, `t=C*DeltaVIN/I` gives 1.071us for 1uF at USB5V, 2.857us at USB5.5V. With C_in 10uF scenarios those become 10.714/28.571us. The 0.9V and 0.5V figures are *sensitivity assumptions*, **NOT temperature/part-specific maximums**; do not use the result to claim a real transfer succeeds/fails. At 280mA, diode forward dissipation is 84/140/168mW for assumed VF 0.3/0.5/0.6V. A series diode moves heat from LDO to diode but does not eliminate system loss.

TI TLV767 RevD §9.1.4 explicitly says intrinsic OUT-to-IN reverse current is not limited; [TI application forum](https://e2e.ti.com/support/power-management-group/power-management/f/power-management-forum/1410332/tlv767-reverse-protection-diode-required) distinguishes an OUT→IN bypass diode from an upstream series diode ahead of CIN. **Bypass diode is not upstream reverse isolation**. **Series diode before CIN is not by itself a current clamp around the LDO internal body path**; test both actual node differentials and return currents. CP vendor macro model omits physical reverse body diode; its 1.5uA reverse observation must not qualify the design.

## Exact-MPN Iran procurement gate (new 2026-10-09 observation)

- [Atrinelec SS14 listing](https://www.atrinelec.com/Product/2484/SS14) announces sellable stock, but headline says **Toshiba** while long description/footer states **Vishay** and includes a Vishay-style data-sheet narrative. The exact **manufacturer ordering MPN is therefore unverified**; do not attach onsemi/Toshiba/Vishay guaranteed VF, IR, surge or footprint to this offer without seller lot/top-mark/datasheet confirmation.
- [Aftab Rayaneh search](https://shop.aftabrayaneh.com/index.php?route=product%2Fsearch&search=%D8%AF%DB%8C%D9%88%D8%AF+%D8%B4%D8%A7%D8%AA%DA%A9%DB%8C) shows generic `1N5819 SS14` pack listings with claimed stock, **not the exact manufacturer's MPN**.
- [ECA 1N5819/SS14 listing](https://eshop.eca.ir/%D8%AF%DB%8C%D9%88%D8%AF-%D8%B4%D8%A7%D8%AA%DA%A9%DB%8C/4600-%D8%AF%DB%8C%D9%88%D8%AF-%D8%B4%D8%A7%D8%AA%DA%A9%DB%8C-1a-40v-%D9%85%D8%AF%D9%84-1n5819-%D9%BE%DA%A9%DB%8C%D8%AC-sma.html) says out of stock. These are dated observations, not reservations; full exact-MPN Iran PASS **not achieved**.
- [onsemi SS14 specification](https://www.onsemi.com/download/data-sheet/pdf/ss14fl-d.pdf) applies specifically to different `SS14FL` package (SOD-123F), **not** the generic `SS14` SMA marketplace listing. Do NOT transfer it. [onsemi SS14 example](https://www.lcsc.com/product-detail/C83852.html) is an internationally listed manufacturer-specific SMA part, but Iran supply for onsemi SS14 is **not** established. Unselected research reference only.

**Verdict:** Series/bypass diode procurement remains `IRAN_EXACT_MPN_OPEN / ELECTRICAL_CORNER_OPEN`. No change to live power CAD and do not make a partial purchase.

## Actual execution and reproducibility

`AI_SCRIPTS/T25/T25CQ_Power_Handoff_Budget_v1.py` is dependency-free and has four exact decimal regression checks. Executed locally as:

`python T25CQ_Power_Handoff_Budget_v1.py --out T25CQ_Budget_Result.json`

Full numeric output is preserved in `AI_EVIDENCE/T25CQ/BUDGET_RESULT.json`. These simple energy/charge equations are deliberately independent from any encrypted/mock simulator. They do **not** substitute for OVP output waveforms, reverse body-diode model, source impedance, actual mux current, or true MCU/SD reset/write limits.

## Remaining executable gate

1. Qualify **one exact diode** manufacturer/order-code and actual Iranian seller's lot; require VF at real 280mA and temp, IR at upstream/backfeed temperature, VR, surge, package/rework and thermal under the current power proposal.
2. Obtain model/characterization for actual `TS431BCX RFG/BC857BLT1G/FSS2301S` OVP network, including upstream source slew/current/impedance and effective C, and test both fault edges with correct `USB_OVP_IN, USB_VBUS_PROT, OVP_K, OVP_REF, OVP_BASE, OVP_GATE, VGS, IK` probes. Historical static trip 5.915721V is **not** an imposed dynamic clamp.
3. Independently establish source-loaded BAT1.80V margin, mux input-current conservation and *measured/model-valid* gap, post-mux **actual Cbus_eff**, MCU NRST/BOR/SD writes and the two no-reset transfers before selecting the whole power BOM.
4. Preserve TPS631000 / Murata 1uH L1, closed TPS22918 SD screening, S1 three-pole decision and deferred sourcing. No repeat of T25AE vendor-mux, T25BF/BT bad prestate, CO faulty OVC, CP same fault matrix or unchanged Windows timeout.

**NEXT EXECUTABLE ACTION:** Advance exact manufacturer-part diode screening and validate the *physical OVP output input-stress envelope* with a current-conserving model or named physical data; only then assemble whole-power design/ECO for one approval. **BLOCKER REQUIRING USER:** None for autonomous research. A real board, components purchase or Windows run is **not requested**. **FABRICATION HOLD**.
