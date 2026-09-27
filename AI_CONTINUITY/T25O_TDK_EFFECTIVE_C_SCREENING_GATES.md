# T25O — Exact TDK MLCC effective-capacitance screening gates

Date: 2026-09-24. Status: **manufacturer nominal/tolerance/temperature data qualified and retention thresholds computed; biased effective values and compliance remain OPEN**.

## Manufacturer and project inputs

| Exact project schematic part | Connected net and role (T25F) | TDK exact-part specification | TI TPS631000 Rev. C recommended effective minimum |
| --- | --- | --- | --- |
| `C2012X5R1A476M125AC` | `C_OUT` at `3V3_SYS` | [TDK part page](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1A476M125AC): **47 µF ±20%, 10 VDC, X5R ±15%, −55…85°C** | **10.4 µF** for 3.3 V output |
| `C2012X5R1V226M125AC` | `C_IN` at `VIN_MUX` | [TDK part page](https://product.tdk.com/en/search/capacitor/ceramic/mlcc/info?part_no=C2012X5R1V226M125AC): **22 µF ±20%, 35 VDC, X5R ±15%, −55…85°C** | **4.2 µF** across recommended 1.6–5.5 V input range |

TI source: [TPS631000 Rev. C](https://www.ti.com/lit/ds/symlink/tps631000.pdf), §5.3; §7.2.2.3 specifically says to account for MLCC DC bias in effective C. The 10 V and 35 V rated voltages establish voltage rating, **not effective capacitance at 3.3 V/actual VIN**.

## Executed algebra, with explicitly limited interpretation

Run `python AI_SCRIPTS/T25/T25O_MLCC_Effective_C_Gate_v1.py`. Let `B` denote verified DC-bias retention relative to nominal at the voltage of interest; `A` denote verified aging/other remaining retention. As an *illustrative multiplicative corner*, apply the part's **0.80 lower initial tolerance** and **0.85 lower X5R temperature factor** before solving the TI minimum: `Cscreen = Cnom × 0.80 × 0.85 × B × A`. This arithmetic is **not** a manufacturer's qualification that these factors combine independently or encompass the final minimum over service life. Temperature behavior under DC bias, aging, AC frequency, assembly stress, supply noise and measurement conditions need independent support.

| Part | Nameplate | Illustrative no-bias lower tolerance×temperature | TI effective minimum | Required verified `B×A` in this illustrative screen |
| --- | ---: | ---: | ---: | ---: |
| `C_OUT` | 47 µF | 31.96 µF | 10.4 µF at 3.3 V | **≥0.325407 = 32.54%** |
| `C_IN` | 22 µF | 14.96 µF | 4.2 µF at operating `VIN_MUX` | **≥0.280749 = 28.07%** |

This gives an exact target **for checking future sourced bias/aging factors under the stated arithmetic assumptions**; it is not evidence that the actual TDK parts meet it. TDK's reference DC-bias graph for `C_OUT` decreases as voltage rises; no validated numerical value at 3.3 V or PSpice model payload was retrieved (T25M). Likewise `C_IN` needs values across actual battery/USB-mux bias, up to the TI recommended input ceiling of 5.5 V if that operating case is claimed. No PSpice macromodel or real startup waveform is asserted by T25O.

## Operational next step

Obtain and qualify exact TDK voltage-dependent C model or measured biased capacitance under the selected voltage and temperature conditions, include aging where relevant, and feed verified numbers to T25M's `--c-eff-uf` startup accounting. Then run a **completed multi-ms** Windows PSpice TPS631000 startup, instrument `VIN_MUX`, `3V3_SYS` and inductor current, and only later apply verified SD/OLED load profiles. The user's board has no verified module/card current waveform, so no integrated transient PASS is entered. The Murata static L1 screen T25N likewise cannot substitute for these tests.

Canonical `01_POWER.SchDoc`, PCB and PcbLib unchanged. No fresh compile or DRC; last accepted physical T24 gate is 129/129 courtyards and Full Batch DRC 0 warnings / 0 violations.
