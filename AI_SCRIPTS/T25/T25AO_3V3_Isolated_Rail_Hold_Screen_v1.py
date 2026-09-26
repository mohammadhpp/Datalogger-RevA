#!/usr/bin/env python3
"""Conditional C_OUT-only 3V3 hold-up screen for RevA, not a circuit simulation.

Examples (from the repository root):
  python AI_SCRIPTS/T25/T25AO_3V3_Isolated_Rail_Hold_Screen_v1.py
  python AI_SCRIPTS/T25/T25AO_3V3_Isolated_Rail_Hold_Screen_v1.py \
    --gap-us 10 --v-floor-v 3.0 --cout-eff-uf 12

The second command is an HYPOTHETICAL sensitivity scenario. The CLI values
are never presented as measured, accepted reset thresholds, or hardware PASS.
"""
import argparse
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
SOURCE_BOOK_SHA256 = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
SCHDOC_GIT_BLOB = "da2d005712c47000eb8c16157eca464d3fee4fe1"
V_RAIL_V = 3.3  # purchased workbook design rail, not a verified actual waveform
TI_RECOMMENDED_COUT_EFF_MIN_UF = 10.4  # TI TPS631000 Rev C, section 5.3
TDK_COUT_NAMEPLATE_UF = 47.0  # exact part C2012X5R1A476M125AC


def cell(book, sheet, address):
    rows = book["sheets"][sheet]
    matches = [row[address]["value"] for row in rows if address in row]
    if len(matches) != 1:
        raise ValueError(f"Missing/duplicate workbook cell {sheet}!{address}")
    return matches[0]


def optional_positive(value, name):
    if value is None:
        return None
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"{name} must be finite and >0")
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gap-us", type=float, help="Scenario: time with ZERO converter output current")
    parser.add_argument("--v-floor-v", type=float, help="Scenario: allowed lowest 3V3 rail voltage (not an accepted BOR threshold)")
    parser.add_argument("--cout-eff-uf", type=float, help="Scenario: output capacitance actually effective at 3V3")
    args = parser.parse_args()
    try:
        gap = optional_positive(args.gap_us, "gap-us")
        floor = optional_positive(args.v_floor_v, "v-floor-v")
        effective = optional_positive(args.cout_eff_uf, "cout-eff-uf")
        if floor is not None and floor >= V_RAIL_V:
            raise ValueError("v-floor-v must be lower than 3.3V")
        book = json.loads(BOOK.read_text(encoding="utf-8"))
        if book["source_workbook_sha256"] != SOURCE_BOOK_SHA256:
            raise ValueError("historical purchase workbook identity mismatch")
        load = float(cell(book, "Power Calculations", "B6"))
        battery = float(cell(book, "Power Calculations", "B8"))
        start = float(cell(book, "Power Calculations", "B10"))
        usb = float(cell(book, "OVP Calc v0.17", "B5"))
        if (load, battery, start, usb) != (0.280, 1.80, 1.65, 5.50):
            raise ValueError("book changed: source limits require renewed audit")
    except (ValueError, KeyError, OSError, TypeError) as exc:
        parser.error(str(exc))

    # If the converter delivers absolutely zero, all current must come from
    # C_OUT. For constant current I and constant effective C: dV/dt=-I/C.
    # Numerical units: (A / uF) = V / us.
    def slope_mv_per_us(c_uf):
        return 1000 * load / c_uf

    result = {
        "status": "CONDITIONAL_RAIL_ONLY_SCREEN_NO_NO_RESET_OR_HARDWARE_PASS",
        "source": {"power_schdoc_git_blob": SCHDOC_GIT_BLOB,
                   "purchase_workbook_sha256": SOURCE_BOOK_SHA256,
                   "ti_tps631000_datasheet": "SLVSFH3C Rev C section 5.3",
                   "tdk_exact_cout_mpn": "C2012X5R1A476M125AC"},
        "locked_design_envelope": {"rail_start_assumed_v": V_RAIL_V,
                                   "total_rail_design_current_a": load,
                                   "battery_loaded_min_v": battery,
                                   "converter_startup_strictly_above_v": start,
                                   "usb_no_nuisance_v": usb},
        "model_assumptions": [
            "Fully charged C_OUT at 3.3V at the beginning of a specified gap",
            "Zero current delivered by TPS631000 over the entire specified gap",
            "Constant 280mA total rail draw throughout the gap (not a measured transient)",
            "Constant effective capacitance over the droop, no ESR or inductance",
            "No SD/OLED extra inrush beyond 280mA and no other storage added",
        ],
        "distinct_nodes_do_not_add_capacitance":
            "C_USB1 at USB_VBUS_PROT; C_IN at VIN_MUX; C_OUT at 3V3_SYS. Converter dynamics separate them.",
        "reference_capacitances_not_proof_installed": {
            "ti_recommended_effective_min_uf_NOT_VERIFIED_INSTALLED": TI_RECOMMENDED_COUT_EFF_MIN_UF,
            "ti_min_reference_droop_mv_per_us_if_zero_converter_current":
                slope_mv_per_us(TI_RECOMMENDED_COUT_EFF_MIN_UF),
            "tdk_exact_part_NAMEPLATE_uf_NOT_EFFECTIVE": TDK_COUT_NAMEPLATE_UF,
            "nameplate_illustration_droop_mv_per_us_if_zero_converter_current":
                slope_mv_per_us(TDK_COUT_NAMEPLATE_UF),
        },
        "unknown_for_no_reset": [
            "Actual biased, aged, populated C_OUT effective capacitance",
            "Maximum no-power interval including TPS2116 and converter response",
            "Minimum allowed rail at MCU BOR, SD during write, OLED and other active loads",
            "Actual rail current profile, converter current and transient control",
        ],
    }
    if gap is not None and floor is not None:
        delta_v = V_RAIL_V - floor
        needed = load * gap / delta_v
        result["hypothetical_scenario"] = {
            "zero_converter_current_gap_us": gap,
            "scenario_rail_floor_v_NOT_QUALIFIED": floor,
            "required_constant_effective_COUT_uf_for_equality_NO_MARGIN": needed,
            "condition": "Ceff strictly greater than required for positive margin in this simplified case",
        }
    elif gap is not None or floor is not None:
        result["hypothetical_scenario"] = "Supply BOTH gap-us and v-floor-v to calculate a requirement; no default accepted floor/gap."
    if effective is not None:
        scenario = result.setdefault("hypothetical_scenario", {})
        if not isinstance(scenario, dict):
            scenario = {"note": scenario}
            result["hypothetical_scenario"] = scenario
        scenario["scenario_COUT_eff_uf_NOT_VERIFIED"] = effective
        scenario["scenario_droop_mv_per_us"] = slope_mv_per_us(effective)
        if gap is not None:
            scenario["scenario_end_rail_v_if_zero_converter_current"] = V_RAIL_V - load * gap / effective
        if floor is not None and gap is not None:
            scenario["ideal_cap_only_above_floor"] = scenario["scenario_end_rail_v_if_zero_converter_current"] > floor
        scenario["verdict"] = "SENSITIVITY_ONLY_NOT_HARDWARE_PASS"
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
