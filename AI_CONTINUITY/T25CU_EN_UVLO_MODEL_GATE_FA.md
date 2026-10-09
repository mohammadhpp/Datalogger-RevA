# T25CU — verified TI TPS54202 EN/UVLO circuit-scope gate

Date 2026-10-09. Source: TI [TPS54202 Rev C datasheet](https://www.ti.com/lit/ds/symlink/tps54202.pdf), pages 3-5 and 9-10; continuing T25CT. **Category: ACTUAL_TEST_WITH_RAW_EVIDENCE, only arithmetic parameter sweep and direct KCL crosscheck. Vendor PSpice transient not run. FABRICATION HOLD.**

TI explicitly says **float EN to enable**. Internally VIN has rising UVLO 3.9..4.4V, 400..560mV hysteresis. VIN operating 4.5..28V; **EN recommended -0.1..5.5V, absolute -0.3..7V**, EN rising1.21..1.28V. EN Ip=0.7uA and hysteresis Ih=1.55uA are *typical, no guaranteed worst-case bound*. EN floating is an actual vendor-endorsed topology, not a claim of 5V startup/waveform or safety in any external source fault.

## Distinct numerical gate

120 DC corner values executed by standard Python with **independent nodal KCL identity**: V_EN = V_IN*Rbottom/(Rtop+Rbottom) + I_en*(Rtop||Rbottom), two dividers, VIN=4.5/5/5.5/12/28V, ±1% resistor extremes, I=0/.7/2.25uA scenarios (NOT guaranteed maxima). Detailed JSON is in same-turn downloadable T25CU ZIP; compact audit and reproducer in Git.

| Candidate / input | model-screen finding |
|---|---:|
| TI reference 562k/102k at 5V | EN max 0.976746V with +2.25uA typical scenario and favorable 1% tolerance: BELOW EN rising minimum1.21V |
| Hypothetical 150k/100k at 5V | EN min 1.976048V with no internal sourced current |
| Same at 12V | EN max 4.992973V with favorable 1% corner plus typical +2.25uA |
| Same at 28V | EN min 11.065869V with zero internal current, > ABS7V; UNSAFE to assume compatibility with full rated VIN |
| Same network 12V corner | 10.6844uA is allowable *sourced-current ceiling* to stay EN <=5.5 in the worst resistor corner; vendor lacks matching guaranteed current maximum |

No fixed passive ideal divider (zero current) works across entire VIN4.5..28: required ratio >=1.28/4.5=0.28444 at low input while required <=5.5/28=0.19643 at high input. This incompatibility does not prohibit floating EN or a rated active limiter. The 150k/100k network is an **unselected bounded-to-12V thought experiment**, not a BOM value, approved ECO or procurement. No verified exact Iranian MPN for its resistors was selected because divider is not recommended as the default.

## System consequence

TPS54202 typical soft-start is 5ms. This is **not measured mux deadtime**, but illustrates why USB rail startup should be observed before switching sources. For a purely hypothetical 5ms without supply, I=280mA and Cbus 3.3->2.7V would require 2333uF *effective*. Actual system needs a powered BAT_REG3V3 until USB_REG3V3 qualifies, source-current-valid mux transfer, monitored 3V3_SYS/NRST and SD write integrity at battery 1.80V. Do not silently repopulate C_USB1/2 or call this a capacitor requirement.

## Model access and audit status

The [official TI TPS54202 page](https://www.ti.com/product/TPS54202) advertises **Unencrypted PSpice Transient Model Package Rev C, SLVMBJ5C.ZIP**. Network download from this environment failed. Original archive bytes **NOT obtained** and no simulator was run; a file-inspection gate executed without the ZIP and returned explicit `MODEL_BYTES_ABSENT`, `PSPICE_SIMULATION_EXECUTED=false`. That is a tooling blocker, not circuit FAIL. No substitute macro-model was fabricated. The executable full corner/result and model gate are contained with SHA256 manifest in the T25CU result ZIP, and a compact Git reproducible script preserves the calculation.

**NEXT EXECUTABLE ACTION:** after acquiring validated archive bytes, inspect ZIP member hashes/contents and actual subcircuit pin ordering before constructing new 5V start, 5.5V no-nuisance, bounded 12V line-pulse and source collapse at light load19mA and design280mA with actual source current. Keep BAT1.8V/current-conserving mux/3V3_SYS/NRST/SD gates independent. Do not run old invalid-model fixtures.

**BLOCKER REQUIRING USER:** none for research. No new purchase/Altium ECO/manufacturing acceptance. **FABRICATION HOLD.**
