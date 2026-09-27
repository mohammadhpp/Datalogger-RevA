#!/usr/bin/env python3
"""Conditional USB-unplug energy accounting from the purchased design.

This is an intentionally simple screening model, NOT a TPS2116/TPS631000
simulation, and never a hardware qualification. Run from the Git checkout:
  python AI_SCRIPTS/T25/T25AH_Hard_Unplug_Envelope_v1.py
Optional independently qualified inputs: --eta-min, --cusb1-eff-uf,
--cin-eff-uf and --gap-max-us. No assumed hardware values are defaulted.
"""
import argparse
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
EXPECTED_BOOK_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
P_OUTPUT_W = 3.3 * 0.280
PR1_REF_MIN_V = 0.92
PR1_REF_MAX_V = 1.08
R_TOP_NOM_OHM = 30000.0
R_TOP_TOL = 0.01
R_BOTTOM_NOM_OHM = 10000.0
R_BOTTOM_TOL = 0.005
TI_FAST_COLLAPSE_LIMIT_V_PER_US = 0.1  # 1V / 10us, TPS2116 Rev A section 7.4
TI_CIN_EFF_MIN_UF = 4.2  # Component recommendation, not installed C_IN value
TI_TSW_TYP_AT_1P8_US = 17.7  # TI-specific RL=10ohm / CL=10uF fixture, not max


def book_value(sheet, address, book):
    rows = book["sheets"][sheet]
    matches = [row[address]["value"] for row in rows if address in row]
    if len(matches) != 1:
        raise ValueError("missing/duplicate workbook cell: " + sheet + "!" + address)
    return matches[0]


def positive(value, label):
    if value is None:
        return None
    v = float(value)
    if not math.isfinite(v) or v <= 0:
        raise ValueError(label + " must be finite and positive")
    return v


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--eta-min", type=float, help="Qualified minimum converter efficiency during transition")
    p.add_argument("--cusb1-eff-uf", type=float, help="Qualified installed minimum effective C_USB1 at 3.64-5.50V")
    p.add_argument("--cin-eff-uf", type=float, help="Qualified installed minimum effective C_IN at 1.65-4.37V")
    p.add_argument("--gap-max-us", type=float, help="Qualified maximum time of unavailable mux power path")
    a = p.parse_args()
    try:
        eta = positive(a.eta_min, "eta-min")
        c_usb = positive(a.cusb1_eff_uf, "cusb1-eff-uf")
        c_in = positive(a.cin_eff_uf, "cin-eff-uf")
        gap = positive(a.gap_max_us, "gap-max-us")
        if eta is not None and eta > 1:
            raise ValueError("eta-min cannot exceed 1")
        if (c_usb is not None or c_in is not None or gap is not None) and eta is None:
            raise ValueError("qualified capacitance/gap inputs require --eta-min")
        book = json.loads(BOOK.read_text(encoding="utf-8"))
        if book["source_workbook_sha256"] != EXPECTED_BOOK_SHA:
            raise ValueError("unrecognized historical purchase workbook identity")
        v_usb = float(book_value("OVP Calc v0.17", "B5", book))
        v_bat = float(book_value("Power Calculations", "B8", book))
        load_a = float(book_value("Power Calculations", "B6", book))
        v_start_min = float(book_value("Power Calculations", "B10", book))
        c_usb_nom = float(book_value("Power P9 BOM", "C9", book).split("uF")[0])
        if (v_usb, v_bat, load_a, v_start_min, c_usb_nom) != (5.5, 1.8, .28, 1.65, 22):
            raise ValueError("source workbook quantities changed; review circuit before applying this model")
    except (ValueError, OSError, KeyError, TypeError) as e:
        p.error(str(e))

    # The highest PR1 threshold causes the earliest USB->battery command during a fall.
    pr1_max = PR1_REF_MAX_V * (1 + R_TOP_NOM_OHM * (1 + R_TOP_TOL) /
                              (R_BOTTOM_NOM_OHM * (1 - R_BOTTOM_TOL)))
    pr1_min = PR1_REF_MIN_V * (1 + R_TOP_NOM_OHM * (1 - R_TOP_TOL) /
                              (R_BOTTOM_NOM_OHM * (1 + R_BOTTOM_TOL)))
    if not 3.63 < pr1_min < 3.65 or not 4.36 < pr1_max < 4.38:
        p.error("unexpected priority-divider corner")
    # In microfarad, watt, volt, and microseconds the 1e-6 factors cancel.
    def reservoir_us(c_uf, v_hi, v_lo, efficiency):
        return efficiency * c_uf * (v_hi*v_hi - v_lo*v_lo) / (2 * P_OUTPUT_W)

    # The lower PR1 corner is the LAST transfer: smaller VIN1 gives faster
    # constant-power discharge and less C_IN energy to the 1.65V screen.
    # The upper PR1 corner is the FIRST transfer: less C_USB1 time before it.
    c_usb_needed_eta1 = P_OUTPUT_W / (pr1_min * TI_FAST_COLLAPSE_LIMIT_V_PER_US)
    output = {
        "verdict": "CONDITIONAL_SCREEN_ONLY_NO_VENDOR_MODEL_NO_HARDWARE_PASS",
        "source": {"power_schdoc_git_blob": "da2d005712c47000eb8c16157eca464d3fee4fe1",
                   "workbook_sha256": EXPECTED_BOOK_SHA,
                   "ti_tps2116_section": "7.4, 7.6.1, 6.6",
                   "ti_tps631000_section": "features; section 5.3"},
        "design_gate": {"battery_pack_loaded_v": v_bat, "design_3v3_load_a": load_a,
                        "design_output_w": P_OUTPUT_W, "usb_no_nuisance_v": v_usb,
                        "converter_startup_strictly_above_v": v_start_min,
                        "startup_total_path_drop_strictly_below_v": v_bat-v_start_min,
                        "pr1_falling_upper_static_corner_v": pr1_max,
                        "pr1_lower_static_corner_v": pr1_min},
        "ti_condition": {"fast_fall_boundary_v_per_us": TI_FAST_COLLAPSE_LIMIT_V_PER_US,
                         "alternate_supply_required_v_if_faster": 2.5,
                         "battery_meets_fast_collapse_condition": v_bat >= 2.5,
                         "typical_sw_us_not_a_guaranteed_max": TI_TSW_TYP_AT_1P8_US},
        "isolated_USB_VBUS_PROT_cap_only": {
            "historic_C_USB1_nameplate_uf_not_Ceff": c_usb_nom,
            "ceff_needed_at_pr1_lower_for_fall_slower_than_TI_boundary_uf":
                "%.9g / eta" % c_usb_needed_eta1,
            "illustrative_nameplate_and_eta1_5p5_to_earliest_pr1_upper_us":
                reservoir_us(c_usb_nom, v_usb, pr1_max, 1),
            "unmodeled": "USB source sink impedance, upstream MOSFET path, OVP currents, actual Ceff and extra input loads"},
        "isolated_VIN_MUX_cap_only": {
            "ti_min_effective_CIN_uf_not_verified_installed": TI_CIN_EFF_MIN_UF,
            "historic_CIN_nameplate_uf_not_Ceff": 22.0,
            "illustrative_ti_min_CIN_eta1_latest_pr1_lower_to_1p65_us":
                reservoir_us(TI_CIN_EFF_MIN_UF, pr1_min, v_start_min, 1),
            "illustrative_nameplate_CIN_eta1_latest_pr1_lower_to_1p65_us":
                reservoir_us(22.0, pr1_min, v_start_min, 1),
            "unmodeled": "Actual energy flow, C_OUT rail buffering, converter control, battery supply and RCB waiting time"},
        "optional_qualified_inputs": {},
    }
    q = output["optional_qualified_inputs"]
    if eta is not None:
        q["eta_min"] = eta
        q["required_USB_Ceff_uf_if_only_regulator_draws"] = c_usb_needed_eta1 / eta
    if c_usb is not None:
        q["qualified_USB_Ceff_uf"] = c_usb
        q["conditional_USB_fall_at_latest_pr1_lower_v_per_us"] = P_OUTPUT_W / (eta*c_usb*pr1_min)
        q["conditional_USB_to_earliest_pr1_upper_us"] = reservoir_us(c_usb, v_usb, pr1_max, eta)
    if c_in is not None:
        q["qualified_CIN_Ceff_uf"] = c_in
        q["conditional_CIN_reservoir_to_1p65_us"] = reservoir_us(c_in, pr1_min, v_start_min, eta)
    if gap is not None:
        q["qualified_gap_max_us"] = gap
        q["required_CIN_Ceff_uf_if_isolated_constant_power"] = (
            2*P_OUTPUT_W*gap / (eta*(pr1_min*pr1_min - v_start_min*v_start_min)))
        if c_in is not None:
            q["simplified_gap_energy_screen"] = ("ENOUGH_IN_IDEAL_ENERGY_MODEL" if
                q["conditional_CIN_reservoir_to_1p65_us"] > gap else "NOT_ENOUGH_IN_IDEAL_ENERGY_MODEL")
    print(json.dumps(output, indent=2, ensure_ascii=True))


if __name__ == "__main__":
    main()
