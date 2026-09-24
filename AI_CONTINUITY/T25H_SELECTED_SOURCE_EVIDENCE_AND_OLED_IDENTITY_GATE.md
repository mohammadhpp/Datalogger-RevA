# T25H — User-selected source evidence and OLED identity gate

Date: 2026-09-24. Status: **source identifiers partly resolved; OLED identity / integrated transient OPEN**.

## Inputs and traceability

- User named **Camelion Digi Alkaline** cells, a **4 GB unbranded microSD** card, generic standard **USB chargers/power banks**, and uploaded six-page `WEO012864V` OLED PDF, local upload SHA256 `dc0ff4fdfedda0a7fb21ba24aacb3444bac927b2a25df5fa38bc3a94665fecf4`. This is a user-selected reference, but they have not yet confirmed that the purchased/displayed assembly is the bare WEO part or a separate carrier.
- Canonical six-sheet connectivity and exact parts remain T25A/T25F evidence. In particular `06_OLED_SHT3X.SchDoc` has `J_OLED` PBS-2.54-1X4GF four-pin female header, pins 1=`OLED_VDD` (switched 3V3), 2=GND, 3=`OLED_SCL`, 4=`OLED_SDA`. `C_OLED_BULK` 10 µF plus `C_OLED_HF` 0.1 µF nominal on the branch. The header itself is not a display model.

## Source model facts and remaining unknowns

| Source | Evidence now | Do not infer |
| --- | --- | --- |
| `BT1` two series AA Camelion Digi Alkaline LR6 | Manufacturer [Camelion product page](https://camelion.com/product/camelion-digi-alkaline-lr6-mignon-bp2/): nominal **1.5 V per cell**; listed **2700 mAh per cell** only for 25 mA continuous load at 20 ±2 °C to 0.9 V endpoint. Series pair nominal 3.0 V and does **not** double Ah. Product-page package variant BP2 is illustrative of the named family, not confirmed package SKU. | No cell internal resistance versus discharge, temperature and frequency; no holder/contact/fuse series impedance; no measured pulsed voltage or actual runtime from the low-current capacity rating. |
| `J_SD` / `SD_VDD` | User's actual card described only as **4 GB unbranded**; board socket `MR01A-01245`, branch capacitors 54.1 µF nominal before bias. | Card capacity is no write/idle/inrush current spec; do not generate an alleged actual-card load step without current measurement. |
| `J1` / `USB_VBUS_RAW` | User uses unspecified standard USB chargers and power banks. The board expects a USB-C 5 V sink connection through the discrete OVP and TPS2116 path (T25F). Nominal 5 V may be an explicitly labeled **fixture stimulus**. | No specific adapter current limit, USB negotiation/PD capability, cable resistance, ramp, droop or OVP transient; generic “standard” does not establish a regulated on-board source under dynamic load. The board schematic is **not** a battery charger. |

## Critical OLED identity / interface conflict

- User-uploaded `WEO012864V` PDF is a Winstar **bare COG/FPC 20-pin panel**, SSD1315, 128×64, with logic `VDD` **2.8–3.3 V** and display `VCC` **7.0–8.0 V**, typical 7.5 V. Its `VCC` operating current at 50% pixels ON is **6 mA typical / 12 mA maximum**. Those figures are on the **7.5 V panel rail**; they are **not** its total input current on the existing board's switched 3.3 V four-pin header, and no 3.3 V module startup/update transient was supplied. Manufacturer [WEO page](https://www.winstar.com.tw/products/oled-module/graphic-oled-display/ssd1315-oled.html) corroborates raw COG and points to PCB version.
- Direct insertion of this 20-pin bare WEO into `J_OLED` is impossible. Its FPC additionally requires interface strap/reset/charge-pump circuitry and a compatible 20-pin interconnect/carrier or redesign. There is **no evidenced 7.5 V supply on the four-pin OLED board interface**. No engineering change is authorized by an uploaded panel datasheet alone.
- Manufacturer [WEA012864V page](https://www.winstar.com.tw/products/oled-module/graphic-oled-display/oled-0_96-inch-i2c.html) and [WEA PDF](https://www.winstar.com.tw/uploads/files/3ba4968d7bfc3593e2ae029a21013ffc.pdf) document a different **COG+PCB four-pin** assembly: 2.54 mm pitch; pins 1=VCC, 2=GND, 3=SCL, 4=SDA; VCC **2.8–3.3 V**; **16.5 mA typical / 33 mA maximum at VCC=3 V, 50% pixels ON**. The four pin names/order/pitch match `J_OLED` on paper, but a mechanical/gender/orientation and operating-mode check is needed. This is a **candidate alternative only**: not the confirmed user's hardware, and its specified 50%-on static current is not a measured startup/inrush/update waveform for the user's assembly.

## Next exact action and verification boundary

1. Obtain front/back photo or exact part number of the **physical four-pin OLED assembly** that the user intends to connect, and clarify whether the WEO PDF identifies a bare purchased panel or is only a panel reference. Confirm connector orientation/gender, controller, I2C pin order, onboard charge pump/regulator and supply rating before selecting an OLED load function or changing Altium.
2. Proceed independently with a **bounded, distinctly labeled TPS631000 full-startup feasibility bench** using source-declared fixture values and a process wall-time limit. This is separate from OLED/card/USB product qualification; do not report a full `3V3_SYS` PASS from a partial/encrypted-model run.
3. For the unbranded card and variable USB sources, eventual physical voltage/current captures or explicitly bounded source/load sweeps are needed for board-level claims. Any behavioral load is a scenario, never a measured actual device.

No Altium edits or fresh physical DRC. T24 129/129 courtyards and Full Batch DRC 0 warnings/0 violations remain the last physical evidence; T25G limited isolated priority fixture PASS remains intact.
