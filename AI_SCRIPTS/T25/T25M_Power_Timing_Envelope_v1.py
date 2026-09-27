#!/usr/bin/env python3
"""Source-bound startup timing/charge accounting, never a TPS631000 transient model.

Sources: TI TPS631000 Rev C Table 5.3/5.5 and project T25F exact C_OUT MPN.
The user-supplied OLED panel PDF does not supply the actual carrier load.
"""

import argparse

VOUT_V = 3.3  # Project rail target; nominal feedback calculation is ~3.302 V.
EN_TYP_MS = 0.87  # TI typ at its table conditions; no minimum published.
EN_MAX_MS = 1.50
RAMP_MIN_MS = 6.42
RAMP_TYP_MS = 7.55
RAMP_MAX_MS = 8.68
TI_COUT_MIN_UF = 10.4  # TI recommended effective capacitance at VOUT=3.3 V.
PROJECT_COUT_NAMEPLATE_UF = 47.0  # Exact TDK project part, NOT its effective C.


def cap_accounting(cap_uf: float) -> tuple[float, float, float]:
    if cap_uf <= 0:
        raise ValueError("effective capacitance must be positive")
    charge_uc = cap_uf * VOUT_V
    energy_uj = 0.5 * cap_uf * VOUT_V**2
    average_ma = charge_uc / RAMP_TYP_MS  # 1 uC/ms = 1 mA
    return charge_uc, energy_uj, average_ma


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--c-eff-uf", type=float, help="measured/vendor effective C_OUT at 3.3 V, uF"
    )
    args = parser.parse_args()
    cases = [("TI effective minimum", TI_COUT_MIN_UF),
             ("project nameplate only", PROJECT_COUT_NAMEPLATE_UF)]
    if args.c_eff_uf is not None:
        cases.append(("supplied effective value", args.c_eff_uf))
    print("T25M SOURCE-BOUND ACCOUNTING; NOT A BOARD STARTUP OR LOAD-STEP PASS")
    print(f"TI enable delay typical {EN_TYP_MS:.2f} ms; maximum {EN_MAX_MS:.2f} ms; no minimum specified")
    print(f"TI ramp min/typ/max {RAMP_MIN_MS:.2f}/{RAMP_TYP_MS:.2f}/{RAMP_MAX_MS:.2f} ms")
    print(f"typical-condition sequence {EN_TYP_MS+RAMP_TYP_MS:.2f} ms; maximum-plus-maximum {EN_MAX_MS+RAMP_MAX_MS:.2f} ms")
    print("C_OUT case                    C(uF)  Q(uC)   E(uJ)   Iavg(mA)*")
    for label, c in cases:
        q, e, avg = cap_accounting(c)
        print(f"{label:30} {c:6.2f} {q:7.2f} {e:8.2f} {avg:10.3f}")
    print("* Capacitor charge / TI typical ramp duration; NOT peak, converter input or actual waveform.")
    print("47 uF is unqualified at 3.3 V; OLED/SD startup load, switch slew and source impedance unknown.")


if __name__ == "__main__":
    main()
