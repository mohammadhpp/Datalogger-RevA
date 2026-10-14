# T25DC — Iran sourcing correction for user-chosen TLV61070ADBVR

Date 2026-10-15, source is the user's explicit statement: **«لیون موجود داره»**, immediately after selecting TLV61070ADBVR in T25DB.

## Evidence and status
- **MPN exact:** Texas Instruments TLV61070ADBVR, SOT-23-6.
- **Iranian seller named by user:** Lion Electronic (لیون الکترونیک), https://lionelectronic.ir/
- **Status:** `IRAN_AVAILABILITY_USER_REPORTED / SELLER_IDENTIFIED`. The owner confirms this exact IC is in stock with Lion. No seller detail URL, SKU, real-time number of units, price, lot or checkout proof could independently be fetched in current web search. **Do NOT retain old absolute NO_IRAN_SOURCE claim**, and equally do not fabricate a direct listing URL, stock number or order.
- International listing verifies exact part identity, NOT Iranian seller inventory: https://www.ti.com/product/TLV61070A , https://www.digikey.lv/en/products/detail/texas-instruments/TLV61070ADBVR/16982069 .
- User-selected exact IC stays as preferred, `MCP1642B` excluded from main boost design. This is neither a full technical pass at 1.80V / 280mA, nor approval to order/modify Altium.

## Next sourcing priority: the inductor and capacitors
TI TLV61070A datasheet design recommendations include shielded **2.2uH**:
- Coilcraft XGL4030-222ME: 2.2uH, DCR max 15mΩ, saturation 7A (manufacturer datasheet table; the EVM uses XGL4030-222MEC exact suffix).
- Würth Elektronik 74438357022: 2.2uH, DCR max 13.5mΩ, saturation 7A.
Official TI source: https://www.ti.com/lit/gpn/tlv61070a, §8.2.2.2 and Table 8-2. These are technical references only; **Iranian exact-MPN availability not confirmed**. Do not order 1uH old Murata as a substitute.
- Input/out caps need EVM/vendor capacitance at bias, temp and manual 0805/1206 packaging. TI EVM used 2.2uH Coilcraft XGL4030-222MEC on a 4-layer PCB; do not infer single-layer board PASS from this. https://www.ti.com/lit/ug/slvucc9/slvucc9.pdf

## Current production gate
Part choice **SELECTED by user**, local stock **CONFIRMED BY USER**, direct seller stock data **NOT INDEPENDENTLY VERIFIED**, electrical/model and fiber-laser one-layer layout **OPEN**. Do not buy before consolidated BOM final review and user action.

NEXT EXECUTABLE ACTION: find locally stocked shielded2.2uH with actual DCR/Isat and exact MPN; get detailed listing/lot for IC in final one-shot BOM, then perform AA1.80V 280mA supply and laser PCB layout gate.
BLOCKER REQUIRING USER: none for research; eventual consolidated purchase and fabrication is a single informed action. FABRICATION HOLD.
