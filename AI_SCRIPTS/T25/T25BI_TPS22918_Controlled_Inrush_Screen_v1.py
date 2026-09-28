#!/usr/bin/env python3
"""
T25BI TPS22918 controlled-inrush screen for Datalogger RevA.

Purpose:
- Map TI TPS22918 typical CT rise-time table at VIN=3.3 V to the existing
  nominal SD local capacitance (54.1 uF).
- Calculate capacitor-only inrush using TI's I=C*dV/dt relation for the
  10%-to-90% rise interval.
- Show remaining current headroom only for the explicit T25BH sensitivity
  source ceilings (0.5/1.0/1.5 A) and background loads (19/280 mA).
- Check a nominal QOD discharge time using the datasheet's 35-ohm maximum
  RPD at VIN=3.3 V.

This is a bounded engineering screen, NOT a hardware model and NOT a PASS.
TPS22918 rise-time table values are typical at 25 C and were measured with
CL=0.1 uF, CIN=1 uF, RL=10 ohm. Actual RevA behavior with 54.1 uF, the
TPS631000, the microSD card, PCB parasitics and temperature remains to be
verified with the official TI PSpice model and/or hardware.
"""

from math import log

VIN = 3.3
CSD_UF = 54.1
DV_10_90 = 0.8 * VIN
RPD_MAX_OHM_3V3 = 35.0
SD_RAMP_MIN_US = 100.0
SD_RAMP_MAX_US = 35000.0

# TI TPS22918 datasheet Rev C, Table 2, VIN=3.3 V, typical 25 C.
CT_RISE_US = {
    0: 95,
    220: 455,
    470: 850,
    1000: 1680,
    2200: 3580,
    4700: 7980,
    10000: 17505,
}

BACKGROUND_A = [0.019, 0.280]
SOURCE_CEILING_A = [0.5, 1.0, 1.5]
PREFERRED_CT_PF = 4700


def cap_inrush_a(c_uf: float, rise_us: float) -> float:
    return (c_uf * 1e-6) * DV_10_90 / (rise_us * 1e-6)


def qod_time_to_v_s(v0: float, vtarget: float, r_ohm: float, c_uf: float) -> float:
    return r_ohm * c_uf * 1e-6 * log(v0 / vtarget)


def main() -> None:
    print("T25BI TPS22918 CONTROLLED-INRUSH SCREEN")
    print("STATUS: ANALYSIS_ONLY / NO_CAD_CHANGE / NO_BOARD_PASS")
    print(f"VIN={VIN:.3f} V, CSD nominal={CSD_UF:.3f} uF, dV(10-90)={DV_10_90:.3f} V")
    print()
    print("CT(pF)  tR_typ_3V3(us)  cap-only inrush(mA)  SD-ramp-window-screen")
    for ct_pf, rise_us in CT_RISE_US.items():
        i_ma = cap_inrush_a(CSD_UF, rise_us) * 1e3
        in_window = SD_RAMP_MIN_US <= rise_us <= SD_RAMP_MAX_US
        print(f"{ct_pf:6d}  {rise_us:15.1f}  {i_ma:20.3f}  {'IN' if in_window else 'OUT'}")

    selected_rise_us = CT_RISE_US[PREFERRED_CT_PF]
    selected_i = cap_inrush_a(CSD_UF, selected_rise_us)
    print()
    print(f"PREFERRED INITIAL SCREEN: CT={PREFERRED_CT_PF/1000:.1f} nF")
    print(f"TI typical 10-90 rise at 3.3 V: {selected_rise_us/1000:.3f} ms")
    print(f"Nominal capacitor-only inrush: {selected_i*1e3:.3f} mA")
    print("NOTE: This does not include microSD startup/operating current.")

    print()
    print("T25BH sensitivity headroom after background + cap-only inrush:")
    for bg in BACKGROUND_A:
        for ceiling in SOURCE_CEILING_A:
            headroom = ceiling - bg - selected_i
            print(
                f"background={bg*1e3:6.1f} mA, source ceiling={ceiling:3.1f} A"
                f" -> residual={headroom*1e3:8.3f} mA"
            )

    t05 = qod_time_to_v_s(VIN, 0.5, RPD_MAX_OHM_3V3, CSD_UF)
    print()
    print(
        "Nominal QOD decay screen with VIN held at 3.3 V, "
        f"RPD={RPD_MAX_OHM_3V3:.0f} ohm, CSD={CSD_UF:.1f} uF:"
    )
    print(f"time 3.3 V -> 0.5 V = {t05*1e3:.3f} ms")
    print("This is an RC screen only; it is not a power-loss model.")

    print()
    print("MANDATORY INTERPRETATION:")
    print("- TPS22918 has NO adjustable current limit; it controls capacitive inrush by slew.")
    print("- TI Table 2 values are typical, not guaranteed min/max for the RevA load.")
    print("- Actual card current remains an independent OPEN risk.")
    print("- Fabrication Hold remains until the redesign is approved and validated.")


if __name__ == "__main__":
    main()
