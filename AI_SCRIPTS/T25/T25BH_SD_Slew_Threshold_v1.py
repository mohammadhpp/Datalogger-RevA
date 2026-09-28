#!/usr/bin/env python3
"""Bounded conditional SD-capacitor slew threshold analysis.

This is deliberately NOT a board or TPS631000 switching model.  It reuses
the T25AZ two-capacitor fixture and finds the minimum hypothetical switch
conductance-ramp time constant that keeps 3V3_SYS at or above the 2.04 V
MCU PDR screen.  Card current, OLED current, effective DC-biased
capacitance, converter dynamics and the real gate driver remain excluded.
"""
import argparse
import json
import math
from pathlib import Path

BLOBS = {
    "01_POWER.SchDoc": "da2d005712c47000eb8c16157eca464d3fee4fe1",
    "03_MICROSD.SchDoc": "0793ee4aeae92fc5737796ce4631dac9770619f3",
}
PURCHASE_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
SCREEN_V = 2.04


def simulate(bg_ma, ceiling_a, tau_us, dt_us=0.05):
    """RK4 solution of the exact T25AZ fixture, long enough to settle."""
    c_rail, c_sd = 47e-6, 54.1e-6
    r_source, r_switch = 0.10, 0.05
    bg_a = bg_ma / 1000.0
    y = (3.3 - r_source * bg_a, 0.0)
    duration_us = max(1500.0, 12.0 * tau_us + 500.0)
    n = int(math.ceil(duration_us / dt_us))
    h = dt_us * 1e-6
    min_v, min_t = y[0], 0.0
    first_sd_27 = None

    def rhs(t, x):
        vr, vs = x
        fraction = 1.0 if tau_us == 0.0 else -math.expm1(-t / (tau_us * 1e-6))
        isrc = min(ceiling_a, max(0.0, (3.3 - vr) / r_source))
        icharge = (vr - vs) * fraction / r_switch
        return (isrc - bg_a - icharge) / c_rail, icharge / c_sd

    for i in range(n):
        t = i * h
        k1 = rhs(t, y)
        m1 = (y[0] + h*k1[0]/2, y[1] + h*k1[1]/2)
        k2 = rhs(t + h/2, m1)
        m2 = (y[0] + h*k2[0]/2, y[1] + h*k2[1]/2)
        k3 = rhs(t + h/2, m2)
        e = (y[0] + h*k3[0], y[1] + h*k3[1])
        k4 = rhs(t + h, e)
        y = (y[0] + h*(k1[0] + 2*k2[0] + 2*k3[0] + k4[0])/6,
             y[1] + h*(k1[1] + 2*k2[1] + 2*k3[1] + k4[1])/6)
        t_us = (i + 1) * dt_us
        if not all(math.isfinite(v) and -0.001 <= v <= 3.5 for v in y):
            raise RuntimeError(f"integrator unstable: bg={bg_ma}, cap={ceiling_a}, tau={tau_us}")
        if y[0] < min_v:
            min_v, min_t = y[0], t_us
        if first_sd_27 is None and y[1] >= 2.7:
            first_sd_27 = t_us

    dvdt = rhs(n*h, y)[0]
    if abs(dvdt) > 1000.0 or abs(y[0] - y[1]) > 0.001:
        raise RuntimeError(f"fixture not settled: bg={bg_ma}, cap={ceiling_a}, tau={tau_us}")
    return {
        "min_rail_v": min_v,
        "min_rail_time_us": min_t,
        "first_SD_VDD_at_2p7V_us_ONLY_NO_CARD": first_sd_27,
        "duration_us": n * dt_us,
        "end_rail_v": y[0],
        "end_sd_v": y[1],
    }


def threshold(bg_ma, ceiling_a, dt_us=0.05):
    zero = simulate(bg_ma, ceiling_a, 0.0, dt_us)
    if zero["min_rail_v"] >= SCREEN_V:
        return 0.0, zero
    low, high = 0.0, 100.0
    high_result = simulate(bg_ma, ceiling_a, high, dt_us)
    while high_result["min_rail_v"] < SCREEN_V:
        low, high = high, high * 2.0
        if high > 10000.0:
            raise RuntimeError("no bounded threshold at or below 10 ms")
        high_result = simulate(bg_ma, ceiling_a, high, dt_us)
    while high - low > 0.125:
        mid = (low + high) / 2.0
        result = simulate(bg_ma, ceiling_a, mid, dt_us)
        if result["min_rail_v"] >= SCREEN_V:
            high, high_result = mid, result
        else:
            low = mid
    return high, high_result


def rounded_result(bg, cap, tau, sim):
    t27 = sim["first_SD_VDD_at_2p7V_us_ONLY_NO_CARD"]
    return {
        "background_ma_ASSUMED": bg,
        "source_ceiling_a_ASSUMED_NOT_TI_RATING": cap,
        "minimum_conductance_tau_us_FOR_2p04V_SCREEN_FIXTURE_ONLY": round(tau, 3),
        "min_rail_v_at_threshold": round(sim["min_rail_v"], 6),
        "min_rail_time_us": round(sim["min_rail_time_us"], 3),
        "SD_2p7V_time_us_ONLY_NO_CARD": None if t27 is None else round(t27, 3),
        "SD_reaches_2p7V_within_3ms_observation": t27 is not None and t27 <= 3000.0,
        "settling_window_us": round(sim["duration_us"], 3),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    cases = []
    for bg in (19.0, 280.0):
        for cap in (0.5, 1.0, 1.5):
            tau, result = threshold(bg, cap, 0.05)
            # Selected all-case convergence guard at half step size.
            fine = simulate(bg, cap, tau, 0.025)
            if abs(result["min_rail_v"] - fine["min_rail_v"]) > 0.003:
                raise RuntimeError("RK4 convergence guard failed")
            cases.append(rounded_result(bg, cap, tau, result))

    payload = {
        "status": "EXECUTED_CONDITIONAL_SD_SLEW_THRESHOLD_NO_BOARD_PASS",
        "provenance": {
            "schematic_git_blob_sha": BLOBS,
            "original_purchase_workbook_sha256": PURCHASE_SHA,
            "parent_fixture": "T25AZ; same differential equations and nominal values",
            "19mA": "older prototype readout; bandwidth unknown; NOT RevA background",
            "280mA": "purchase BOM design envelope; NOT measured peak",
        },
        "screen": {
            "rail_floor_v": SCREEN_V,
            "meaning": "MCU PDR comparison screen only; not a complete system acceptance criterion",
        },
        "fixture": {
            "source_ideal_v": 3.3,
            "source_series_ohm_ASSUMED": 0.10,
            "source_ceiling_instantaneous_ASSUMED": [0.5, 1.0, 1.5],
            "SD_switch_on_ohm_ASSUMED": 0.05,
            "rail_cout_nameplate_uf_NOT_CEFF": 47.0,
            "sd_local_cap_nameplate_uf_NOT_CEFF": 54.1,
            "conductance_ramp": "1-exp(-t/tau); tau is NOT MOSFET gate timing",
            "card_DC_and_startup_load_EXCLUDED": True,
            "OLED_and_other_RevA_load_EXCLUDED": True,
            "real_TPS631000_TPS2116_gate_driver_EXCLUDED": True,
            "rk4_dt_us": 0.05,
            "convergence_check_dt_us": 0.025,
            "threshold_resolution_us": 0.125,
            "3ms": "observation label only; no acceptance deadline is asserted",
        },
        "cases": cases,
        "interpretation": (
            "These values are conditional design targets for limiting the SD capacitor inrush. "
            "They cannot be mapped to the existing AO3401A/BC847B network without a validated "
            "gate/driver model and effective capacitances, and they do not prove board pass."
        ),
    }
    text = json.dumps(payload, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text, encoding="utf-8")
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
