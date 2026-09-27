#!/usr/bin/env python3
"""Simulate a bounded *behavioral* SD-enable rail, anchored to the live RevA sheets.

The capped source and time-varying switch conductance are scenario parameters,
NOT qualified TPS631000/AO3401A models. No board verdict is produced.
Requires scipy. Run from any directory; writes JSON to stdout.
"""
import hashlib
import json
import math
from pathlib import Path

from scipy.integrate import solve_ivp

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = {
    "01_POWER.SchDoc": "da2d005712c47000eb8c16157eca464d3fee4fe1",
    "03_MICROSD.SchDoc": "0793ee4aeae92fc5737796ce4631dac9770619f3",
}
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
BOOK_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"


def verify():
    out = {}
    for name, expected in EXPECTED.items():
        paths = [ROOT / name, ROOT / "current_schematics" / name]
        path = next((p for p in paths if p.is_file()), None)
        if path is None:
            raise FileNotFoundError(f"Missing live schematic {name}")
        b = path.read_bytes()
        sha = hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()
        if sha != expected:
            raise ValueError(f"Changed schematic {name}: got {sha}, re-audit required")
        out[name] = sha
    data = json.loads(BOOK.read_text(encoding="utf-8"))
    if data["source_workbook_sha256"] != BOOK_SHA:
        raise ValueError("Original purchased workbook SHA mismatch")
    cells = data["sheets"]["Power Calculations"]
    for addr, val in (("B6", 0.28), ("B8", 1.8)):
        hits = [r[addr]["value"] for r in cells if addr in r]
        if len(hits) != 1 or float(hits[0]) != val:
            raise ValueError(f"Workbook Power Calculations!{addr} changed")
    return out


def simulate(crail_uf, csd_uf, imax_a, tau_us, background_a=0.14, ron_ohm=0.05):
    """Two rail capacitors, a resistive switch and optimistic instant current cap."""
    if min(crail_uf, csd_uf, imax_a, ron_ohm, background_a) <= 0 or tau_us < 0:
        raise ValueError("invalid scenario")
    vreg = 3.3
    rsrc = 0.10  # T25AQ ideal fixture: 0.05 + 0.05 ohm
    rbackground = vreg / background_a  # 140mA T25AQ or illustrative 180mA preload
    rsdload = 33.0  # T25AQ hypothetical 100mA at 3V3; no measured card profile
    vpre = vreg * rbackground / (rbackground + rsrc)
    ipre = (vreg - vpre) / rsrc
    if imax_a < ipre:
        raise ValueError("scenario cannot maintain pre-event steady state")
    end = 600e-6

    def equations(t, y):
        rail, sd = y
        if tau_us == 0:
            fraction = 1.0
        else:
            fraction = -math.expm1(-t / (tau_us * 1e-6))
        iswitch = (rail - sd) * fraction / ron_ohm
        isource = min(imax_a, max(0.0, (vreg - rail) / rsrc))
        return [
            (isource - rail / rbackground - iswitch) / (crail_uf * 1e-6),
            (iswitch - sd / rsdload) / (csd_uf * 1e-6),
        ]

    t = [i * 0.1e-6 for i in range(6001)]
    sol = solve_ivp(equations, (0, end), (vpre, 0.0), method="Radau",
                    t_eval=t, rtol=1e-9, atol=1e-11, max_step=0.1e-6)
    if not sol.success or sol.y.shape != (2, len(t)):
        raise RuntimeError(f"integrator failed: {sol.message}")
    rail, sd = sol.y
    idx = int(rail.argmin())
    source_peak = max(min(imax_a, max(0.0, (vreg - float(v)) / rsrc)) for v in rail)
    first_sd_204 = next((round(t[i] * 1e6, 1) for i, v in enumerate(sd) if v >= 2.04), None)
    first_sd_27 = next((round(t[i] * 1e6, 1) for i, v in enumerate(sd) if v >= 2.7), None)
    return {
        "c_rail_uf_ASSUMED": crail_uf,
        "c_sd_uf_ASSUMED": csd_uf,
        "pre_event_background_at_3p3_a_ASSUMED": background_a,
        "post_event_total_at_3p3_a_ASSUMED": round(background_a + vreg / rsdload, 6),
        "source_current_ceiling_a_ASSUMED": imax_a,
        "conductance_63pct_tau_us_ASSUMED_NOT_GATE_TIME": tau_us,
        "pre_rail_v": round(vpre, 6),
        "min_rail_v": round(float(rail[idx]), 6),
        "min_rail_time_us": round(t[idx] * 1e6, 1),
        "source_peak_a_WITHIN_FIXTURE": round(source_peak, 6),
        "first_sd_at_2p04v_us": first_sd_204,
        "first_sd_at_2p7v_us": first_sd_27,
        "mcu_pdr_falling_max_2p04v_screen_FIXTURE_ONLY": "BELOW" if rail[idx] < 2.04 else "ABOVE",
    }


def main():
    sha = verify()
    scenarios = []
    # 10.4uF is TI's *recommended effective minimum*, not verified installed.
    # 47/54.1uF are only purchased part nameplates, not bias-qualified Ceff.
    for background in (0.14, 0.18):
        # With this hypothetical 100mA card fixture, background=180mA totals
        # purchased workbook's 280mA design envelope; OLED storage is omitted.
        ceilings = (0.5, 1.0, 1.5, 3.0, 100.0) if background == 0.14 else (1.5, 3.0)
        for crail in (10.4, 47.0):
            for csd in (27.05, 54.1):  # 50% nameplate is WHAT-IF, not a Ceff lower bound.
                for imax in ceilings:
                    for tau in (0.0, 10.0, 100.0):
                        scenarios.append(simulate(crail, csd, imax, tau, background_a=background))
    out = {
        "status": "EXECUTED_BOUNDED_BEHAVIORAL_SIMULATION_NO_REAL_HARDWARE_PASS",
        "source_sha": sha,
        "purchase_workbook_original_sha256": BOOK_SHA,
        "fixture": {
            "vreg_ideal_v": 3.3,
            "source_series_ohm_T25AQ": 0.10,
            "switch_on_ohm_T25AQ": 0.05,
            "pre_event_background_at_3p3_a_T25AQ": 0.14,
            "pre_event_background_at_3p3_a_280mA_post_event_scenario": 0.18,
            "OLED_on_rail_capacitance_not_in_280mA_scenario": True,
            "r_sd_fixture_ohm_T25AQ": 33,
            "c_sd_nameplate_uf_NOT_CEFF": 54.1,
            "c_sd_half_nameplate_uf_WHAT_IF_NOT_QUALIFIED": 27.05,
            "simulation_stop_us": 600,
            "sample_spacing_us": 0.1,
            "source_ceiling_is_instantaneous_and_optimistic": True,
            "gate_trajectory_is_NOT_AO3401A_or_BC847B": True,
            "no_TPS631000_TPS2116_USB_AA_or_real_card": True,
        },
        "cases": scenarios,
    }
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
