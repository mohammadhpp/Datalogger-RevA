# T25K — Actual OLED PDF: what can be modeled without inventing a load

Date: 2026-09-24. Status: **panel facts and conditional 3V3 power floor derived; exact four-pin carrier load and integrated transient OPEN**.

## Evidence and applicability

- Re-read all six pages of the user's uploaded `WEO012864V` PDF, SHA256 `dc0ff4fdfedda0a7fb21ba24aacb3444bac927b2a25df5fa38bc3a94665fecf4`. This is a **20-contact FPC bare panel** (page 3 specifies 0.7 mm pitch × 19 = 13.3 mm), 128×64 OLED with **SSD1315**, selectable SPI/I²C. The user's **correct**, photographed blue carrier in T25J is four holes with `VCC, GND, SCL, SDA` on silk. Its PCB supply path/controller/driver current and exact panel identity cannot be verified from its front photograph. Treat use of WEO figures for that blue carrier as **conditional on confirming it contains the same WEO panel and operates at the PDF's specified point**.
- Page 4 gives raw panel pins 1–4 for two flying pump capacitors, 5 `VBAT` for on-chip DC/DC, 6 and 19 `VCC` as the panel high-voltage drive rail, 7 `VSS` ground, 8 `VDD` logic supply; I²C selection is BS[1:0]=10 and raw `D0` clock/`D1+D2` data. Page 4 says `VCC` needs a capacitor to `VSS` when charge pump is enabled. It does **not** say the 3.3 V four-pin carrier must be supplied externally with 7.5 V. A correctly assembled carrier may form its own panel rail with the on-chip charge pump and external capacitors, subject to its actual PCB wiring.
- Page 6 specifies logic `VDD` **2.8–3.3 V**, panel `VCC` **7.0–8.0 V** (typical **7.5 V**), and **panel `VCC` current** with 50% display ON **6 mA typical / 12 mA maximum**. No carrier input current, display pattern other than 50%, startup/inrush or update waveform, conversion efficiency or carrier capacitor network is specified. The PDF's absolute-maximum `VBAT` −0.3–6.0 V is **not** a guaranteed operating range of the pictured carrier.

## Conditional power calculation, not a board current rating

At the PDF's **7.5 V typical panel rail** and 50% pixels on: `P_panel = VCC × I_CC`.

| Conditional 50%-on panel operating point | `P_panel` at 7.5 V | Ideal minimum 3.3 V input current if the **same panel** is supplied solely by the carrier input |
| --- | ---: | ---: |
| PDF typical panel current 6 mA | **45 mW** | **13.64 mA** |
| PDF maximum panel current 12 mA | **90 mW** | **27.27 mA** |

The ideal input figures are `P_panel / 3.3 V` at impossible 100% conversion efficiency and zero logic/PCB current. If the real charge pump efficiency `η` is below 1 or logic draws power, `I_carrier = P_panel / (η × V_carrier) + I_logic + I_other` is higher. This is **not an upper bound**, not the carrier's rated input current, and not a transient profile. The 12 mA maximum applies to the PDF's **panel VCC** under the stated 50%-on condition only. We cannot assert a product worst-case, battery-life estimate, or switched-load PASS from this calculation.

Separately, the real schematic's OLED branch has `C_OLED_BULK` 10 µF and `C_OLED_HF` 0.1 µF (T25F): **10.1 µF nominal**. If initially discharged and ultimately charged to 3.3 V, its nominal charge is **33.33 µC** and energy **54.99 µJ**. The corresponding edge current is **unknown** without the MOSFET gate waveform, resistance, effective biased capacitance, and carrier's own capacitance. These numbers are an accounting identity, not an observed rail dip.

## Simulation-model disposition

- `J_OLED` and the carrier have **no verified vendor PSpice macro-model** in the project's audited schematic. Keep OLED on the **behavioral-load branch**, with explicit `C_eff(V,T)`, `I_logic(mode,t)`, pump efficiency `η(mode,V)`, and `I_startup(t)` / `I_update(t)` parameters **unassigned** until actual carrier evidence or measurements are available. A mathematically stated ideal lower-power exercise or sensitivity sweep can be run as a labeled **scenario**; it is not a model of the user's hardware. Do not treat the Winstar **WEA012864V** separate four-pin module's 16.5/33 mA specification as the blue module's current.
- Independently continue bounded TI encrypted TPS631000 startup feasibility from T25D, retaining explicit source/nominal passives and wall-time limits. The previously completed 10 µs smoke only reached 0.1182 V and cannot validate full 3V3 startup; the user does not need to repeat T25D/T25G. With PSpice installed only on the user's Windows machine, this environment has no direct access to `psp_cmd.exe`; no fabricated waveform or converter PASS is claimed here.
- **NEXT:** keep converter full-startup qualification separate from OLED exact-load qualification. If the module supply current or board assembly is later available, measure `OLED_VDD` current during off→on, idle, 50% on, full update at the board's real supply, then replace the free behavioral parameters. Verify header pad continuity and supply voltage before energizing the physical module.

Canonical Altium engineering files unchanged. Last physical T24 courtyard 129/129 and Full Batch DRC 0 warnings/0 violations; no new DRC. T25G isolated mux priority fixture PASS limited to its declared stimulus.
