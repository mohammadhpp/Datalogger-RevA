#!/usr/bin/env python3
"""Numerical *fixture* for the SD local-capacitor charging event.

The old prototype 19mA reading is not RevA background current. 280mA is
the purchased workbook's design load, not a measured peak. This sweep
isolates capacitor charge with NO card current, OLED current or converter
control loop. The source ceilings/gate ramps are HYPOTHETICAL.
"""
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BLOBS = {
    "01_POWER.SchDoc": "da2d005712c47000eb8c16157eca464d3fee4fe1",
    "03_MICROSD.SchDoc": "0793ee4aeae92fc5737796ce4631dac9770619f3",
}
PURCHASE_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"


def verify_sources():
    for name, sha in BLOBS.items():
        path = next((p for p in (ROOT / name, ROOT / "current_schematics" / name)
                     if p.is_file()), None)
        if path is None:
            raise FileNotFoundError(name)
        data = path.read_bytes()
        got = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if got != sha:
            raise ValueError(f"{name}: live schematic changed")
    book = json.loads((ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json").read_text())
    if book["source_workbook_sha256"] != PURCHASE_SHA:
        raise ValueError("purchase workbook changed")
    cells = book["sheets"]["Power Calculations"]
    def cell(k):
        found = [r[k]["value"] for r in cells if k in r]
        if len(found) != 1:
            raise ValueError(k)
        return found[0]
    if (cell("B5"), cell("B6"), cell("B8")) != (3.3, .28, 1.8):
        raise ValueError("purchased workbook design assumption changed")


def run(bg_ma, ceiling_a, tau_us, dt_us=.05, trace=True):
    """Explicit RK4 for capped ideal source/2 cap state, 0 to 1500 us."""
    if bg_ma not in (19.0, 280.0) or ceiling_a not in (.5, 1., 1.5) or tau_us not in (0., 100.):
        raise ValueError("unexpected fixture scenario")
    c_rail, c_sd = 47e-6, 54.1e-6  # ONLY nameplate scenarios; DC-biased values unknown
    r_source, r_switch = .10, .05  # ONLY T25AQ fixture, not qualified components
    bg_a = bg_ma / 1000
    y = (3.3 - r_source * bg_a, 0.)
    n = int(round(1500 / dt_us))
    t_step = dt_us * 1e-6
    samples = []
    min_v, min_t = y[0], 0.
    first_sd_27 = None
    final_rising = None

    def rhs(t, x):
        vr, vs = x
        fraction = 1. if tau_us == 0. else -math.expm1(-t / (tau_us * 1e-6))
        isrc = min(ceiling_a, max(0., (3.3 - vr) / r_source))
        icharge = (vr - vs) * fraction / r_switch
        return (isrc - bg_a - icharge) / c_rail, icharge / c_sd

    def sample(i):
        nonlocal min_v, min_t, first_sd_27, final_rising
        t_us = i * dt_us
        vr, vs = y
        if vr < min_v:
            min_v, min_t = vr, t_us
        if first_sd_27 is None and vs >= 2.7:
            first_sd_27 = t_us
        if i == n:
            final_rising = rhs(t_us * 1e-6, y)[0]
        if trace and (i % round(.5 / dt_us) == 0 and t_us <= 200.
                      or i % round(5. / dt_us) == 0 and t_us > 200.):
            samples.append([round(t_us, 2), round(vr, 6), round(vs, 6)])

    sample(0)
    for i in range(n):
        t = i * t_step
        k1 = rhs(t, y)
        mid = (y[0] + t_step * k1[0] / 2, y[1] + t_step * k1[1] / 2)
        k2 = rhs(t + t_step / 2, mid)
        mid = (y[0] + t_step * k2[0] / 2, y[1] + t_step * k2[1] / 2)
        k3 = rhs(t + t_step / 2, mid)
        end = (y[0] + t_step * k3[0], y[1] + t_step * k3[1])
        k4 = rhs(t + t_step, end)
        y = (y[0] + t_step * (k1[0] + 2*k2[0] + 2*k3[0] + k4[0]) / 6,
             y[1] + t_step * (k1[1] + 2*k2[1] + 2*k3[1] + k4[1]) / 6)
        if not all(math.isfinite(v) and -.001 <= v <= 3.5 for v in y):
            raise RuntimeError(f"integrator unstable in case {bg_ma}, {ceiling_a}, {tau_us}, {i}")
        sample(i + 1)
    if abs(final_rising) > 1000:
        raise RuntimeError("source not settled by 1.5 ms; extend window")
    return {
        "background_ma_ASSUMED": bg_ma,
        "source_ceiling_a_ASSUMED_NOT_TI_RATING": ceiling_a,
        "switch_conductance_tau_us_ASSUMED_NOT_GATE_TIMING": tau_us,
        "pre_rail_v": round(3.3-r_source*bg_a, 6),
        "min_rail_v": round(min_v, 6),
        "min_rail_time_us": round(min_t, 3),
        "first_SD_VDD_at_2p7V_us_ONLY_NO_CARD": None if first_sd_27 is None else round(first_sd_27, 3),
        "end_rail_v_at_1500us": round(y[0], 6),
        "end_SD_v_at_1500us": round(y[1], 6),
        "below_2p04V_PDR_SCREEN_FIXTURE_ONLY": min_v < 2.04,
        "trace_columns": ["time_us", "3V3_SYS_v", "SD_VDD_v"],
        "samples": samples,
    }


def main():
    verify_sources()
    cases = [run(bg, ceiling, tau)
             for bg in (19., 280.)
             for ceiling in (.5, 1., 1.5)
             for tau in (0., 100.)]
    assert len(cases) == 12
    for bg, ceiling, tau in ((19., .5, 0.), (280., 1., 100.), (280., 1.5, 0.)):
        regular = next(x["min_rail_v"] for x in cases if x["background_ma_ASSUMED"]==bg and x["source_ceiling_a_ASSUMED_NOT_TI_RATING"]==ceiling and x["switch_conductance_tau_us_ASSUMED_NOT_GATE_TIMING"]==tau)
        finer = run(bg, ceiling, tau, dt_us=.025, trace=False)["min_rail_v"]
        if abs(regular - finer) > .003:
            raise RuntimeError(f"solver convergence failed: {regular}, {finer}")
    print(json.dumps({
        "status": "EXECUTED_CONDITIONAL_SD_CAPACITOR_ONLY_SENSITIVITY_NO_BOARD_PASS",
        "provenance": {"schematic_git_blob_sha": BLOBS,
                       "original_purchase_workbook_sha256": PURCHASE_SHA,
                       "19mA": "older prototype readout; bandwidth unknown; NOT RevA background",
                       "280mA": "purchase BOM design envelope; NOT measured peak"},
        "circuit": {"source_ideal_v": 3.3, "source_series_ohm_T25AQ_ASSUMED": .10,
                    "source_ceiling_instantaneous_ASSUMED": True,
                    "SD_switch_on_ohm_T25AQ_ASSUMED": .05,
                    "rail_cout_nameplate_uf_NOT_CEFF": 47,
                    "sd_local_cap_nameplate_uf_NOT_CEFF": 54.1,
                    "card_DC_and_startup_load_EXCLUDED": True,
                    "OLED_and_other_RevA_load_EXCLUDED": True,
                    "real_TPS631000_TPS2116_gate_driver_EXCLUDED": True,
                    "solve_duration_us": 1500, "rk4_dt_us": .05,
                    "selected_convergence_checked_at_dt_us": .025},
        "cases": cases,
    }, indent=2))


if __name__ == "__main__":
    main()
