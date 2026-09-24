# T25M — Executed startup charge accounting and TDK bias-model status

Date: 2026-09-24. Status: **bounded arithmetic scenario EXECUTED; vendor capacitor effective-C payload NOT QUALIFIED; true board transient OPEN**.

## Direct source audit

- Current manufacturer [TI TPS631000 Rev. C PDF](https://www.ti.com/lit/ds/symlink/tps631000.pdf), §§5.3, 5.5 and 6.3.2: 3.3 V effective `C_OUT` recommended **at least 10.4 µF**, enable-to-ramp delay **0.87 ms typical / 1.5 ms maximum** (no minimum listed), soft-start ramp **6.42 / 7.55 / 8.68 ms** min/typ/max. The chip initially limits inductor current; a constant-slope output voltage is **not** asserted.
- Project's actual `C_OUT` MPN `C2012X5R1A476M125AC` is nominal **47 µF** (T25F); manufacturer [TDK exact-part page](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1A476M125AC) contains a plotted DC-bias characteristic and offers a PSpice DC-bias model. The visibly plotted curve falls substantially between 0 V and 3.3 V. TDK says its plotted graph is reference information, not guaranteed product characteristics. **No exact 3.3 V graph sample/CSV, model payload, ESR or tolerance-range effective C was successfully retrieved or run.** Therefore no numeric `C_eff(3.3 V)` and no TI 10.4 µF compliance verdict is entered. The official archive URL is a ZIP not returned as text by web search; the local execution environment cannot access that domain for binary download. A browser's data-download action yielded no accessible CSV, so do not infer values from an unverified file.
- Related project `C_IN` `C2012X5R1V226M125AC` likewise has an [exact-part TDK model link](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1V226M125AC); it remains unqualified at real bias. No part substitution is made.

## Reproducible executed envelope

Added and executed `AI_SCRIPTS/T25/T25M_Power_Timing_Envelope_v1.py` using only Python standard library. It reads no Altium binary and changes no circuit. The same command can later accept an independently measured/model-verified effective value with `--c-eff-uf`. Current built-in cases are TI's **effective minimum 10.4 µF** and the **project's nominal/nameplate 47 µF**; the latter is illustrative, explicitly not the effective capacitor.

```text
T25M SOURCE-BOUND ACCOUNTING; NOT A BOARD STARTUP OR LOAD-STEP PASS
TI enable delay typical 0.87 ms; maximum 1.50 ms; no minimum specified
TI ramp min/typ/max 6.42/7.55/8.68 ms
typical-condition sequence 8.42 ms; maximum-plus-maximum 10.18 ms
C_OUT case                    C(uF)  Q(uC)   E(uJ)   Iavg(mA)*
TI effective minimum            10.40   34.32    56.63      4.546
project nameplate only          47.00  155.10   255.91     20.543
* Capacitor charge / TI typical ramp duration; NOT peak, converter input or actual waveform.
47 uF is unqualified at 3.3 V; OLED/SD startup load, switch slew and source impedance unknown.
```

These are `Q=C×3.3V`, `E=0.5×C×3.3V²` and `Iavg=Q/7.55ms`. The last number is a **capacitor-only algebraic average over TI's nominal ramp duration**, not a prediction that the TPS631000 actually supplies constant current or reaches 3.3 V in that time with this board's unknown loads. It does not include converter efficiency, battery ESR, effective capacitor C(V,T), SD/OLED startup, MCU current, mux/OVP transient or TI control loop. No voltage-vs-time waveform is generated because doing so from the available sources would require inventing dynamics.

## Engineering implication and next gate

At 3.3 V, effective C is the first missing parameter for a defensible coupled converter/branch scenario; **47 µF printed in the BOM cannot be used as `C_eff`**. A vendor model or bias measurement should feed the script's explicit parameter; its current default does not imply any board PASS. Independently obtain the user module's actual 3.3 V supply/load waveform or retain it as an unknown parameter for product claims. The encrypted TPS631000 PSpice run remains a 10 µs engine smoke; millisecond startup must run to completion on a compatible PSpice host or be measured.

No Altium edits, no fresh DRC. Canonical PCB/PcbLib and last T24 129/129 courtyard + Full Batch DRC 0 warnings / 0 violations are unchanged.
