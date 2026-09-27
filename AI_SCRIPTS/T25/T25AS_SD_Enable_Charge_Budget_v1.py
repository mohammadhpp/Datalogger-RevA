#!/usr/bin/env python3
"""Source-anchored SD turn-on charge budget; conditional only, not a circuit simulation.

Run at the repository root with Python 3. Requires no installed packages.
Without parameters, reports two declared capacitor references and two T25AQ
fixture time settings. Never treats a fixture time or nameplate C as measured.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
BOOK_ORIGINAL_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
POWER_BLOB = "da2d005712c47000eb8c16157eca464d3fee4fe1"
SD_BLOB = "0793ee4aeae92fc5737796ce4631dac9770619f3"
SD_CAP_NAMEPLATE_UF = 22 + 22 + 10 + 0.1
TI_COUT_MIN_EFFECTIVE_REFERENCE_UF = 10.4
TDK_COUT_NAMEPLATE_UF = 47.0
MCU_PDR_FALLING_MAX_V = 2.04


def verified_blob(filename, expected):
    for parent in (ROOT, ROOT / "current_schematics"):
        p = parent / filename
        if p.is_file():
            data = p.read_bytes()
            digest = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
            if digest != expected:
                raise ValueError(f"{p}: source changed; review required, got {digest}")
            return str(p)
    raise FileNotFoundError(f"current {filename} missing; no calculation without a live source")


def book_cell(book, sheet, address):
    values = [row[address]["value"] for row in book["sheets"][sheet] if address in row]
    if len(values) != 1:
        raise ValueError(f"Missing/duplicate {sheet}!{address}")
    return float(values[0])


def positive(value, name):
    if value is not None and (not math.isfinite(value) or value <= 0):
        raise ValueError(f"{name} must be finite and positive")
    return value


def budget(cout_uf, csd_uf, vpre_v, floor_v, iload_a, time_us=None, isource_a=None):
    """Constant-capacitance node charge: input Q - load Q >= final stored Q."""
    q_sd_to_floor_uc = csd_uf * floor_v
    q_main_reserve_uc = cout_uf * (vpre_v - floor_v)
    q_needed_uc = q_sd_to_floor_uc - q_main_reserve_uc
    result = {
        "rail_capacitance_assumed_effective_uf": cout_uf,
        "sd_capacitance_assumed_effective_uf": csd_uf,
        "main_rail_cap_charge_above_floor_uc": q_main_reserve_uc,
        "sd_cap_charge_from_zero_to_floor_uc": q_sd_to_floor_uc,
        "source_charge_deficit_excluding_background_uc_CAN_BE_NEGATIVE": q_needed_uc,
    }
    if time_us is not None:
        result["assumed_time_to_charge_sd_to_floor_us_NOT_GATE_PULSE"] = time_us
        result["required_average_source_current_a_ignoring_esr_control_margin"] = max(
            0.0, iload_a + q_needed_uc / time_us
        )
    if isource_a is not None:
        result["assumed_average_source_current_a_NOT_VERIFIED"] = isource_a
        if q_needed_uc <= 0 and isource_a >= iload_a:
            result["required_min_charge_time_us_under_this_ideal_model"] = 0.0
        elif q_needed_uc > 0 and isource_a > iload_a:
            result["required_min_charge_time_us_under_this_ideal_model"] = (
                q_needed_uc / (isource_a - iload_a)
            )
        elif q_needed_uc > 0:
            result["required_min_charge_time_us_under_this_ideal_model"] = "UNBOUNDED"
        else:
            result["required_min_charge_time_us_under_this_ideal_model"] = "NO_MINIMUM; WHEN_SOURCE_BELOW_LOAD_STORAGE_SETS_A_MAXIMUM_TIME"
    result["hardware_verdict"] = "NOT_QUALIFIED_NO_FABRICATION_PASS"
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--cout-eff-uf", type=float, help="Input only when qualified: installed effective C at 3V3")
    p.add_argument("--sd-eff-uf", type=float, help="Input only when qualified: total SD branch effective C")
    p.add_argument("--charge-us", type=float, help="Input only when qualified: time SD_VDD reaches specified voltage after switch onset")
    p.add_argument("--source-a", type=float, help="Input only when qualified: available converter output CURRENT AVERAGE during charge")
    args = p.parse_args()
    try:
        for name in ("cout_eff_uf", "sd_eff_uf", "charge_us", "source_a"):
            positive(getattr(args, name), name)
        source = {"01_POWER": verified_blob("01_POWER.SchDoc", POWER_BLOB),
                  "03_MICROSD": verified_blob("03_MICROSD.SchDoc", SD_BLOB)}
        book = json.loads(BOOK.read_text(encoding="utf-8"))
        if book["source_workbook_sha256"] != BOOK_ORIGINAL_SHA:
            raise ValueError("Purchased workbook identity mismatch")
        iload = book_cell(book, "Power Calculations", "B6")
        if (iload, book_cell(book, "Power Calculations", "B8"),
                book_cell(book, "Power Calculations", "B10")) != (0.28, 1.8, 1.65):
            raise ValueError("Locked power inputs changed; re-audit required")
    except (ValueError, OSError, KeyError, TypeError) as exc:
        p.error(str(exc))

    vpre = 3.3  # design target; actual pre-event T25AQ fixture rail was 3.286V
    floor = MCU_PDR_FALLING_MAX_V  # at MCU VDD, not accepted SD operating floor
    out = {
        "status": "T25AS_CONDITIONAL_CHARGE_ACCOUNTING_NOT_NEW_PSPICE_OR_BOARD_PASS",
        "verified_live_sources": source,
        "source_blobs": {"01_POWER": POWER_BLOB, "03_MICROSD": SD_BLOB},
        "purchase_workbook_original_sha256": BOOK_ORIGINAL_SHA,
        "reference_mcu_pdr_max_falling_v": floor,
        "initial_rail_v_ASSUMED": vpre,
        "constant_background_load_a_DESIGN_ENVELOPE_NOT_REAL_WAVEFORM": iload,
        "sd_branch_cap_sum_uf_NAMEPLATE_NOT_CEFF": SD_CAP_NAMEPLATE_UF,
        "sd_branch_nameplate_charge_to_3p3_uc": SD_CAP_NAMEPLATE_UF * vpre,
        "references": {
            "ti_tps631000_recommended_min_effective_output_uf_NOT_VERIFIED_INSTALLED": TI_COUT_MIN_EFFECTIVE_REFERENCE_UF,
            "tdk_exact_part_47uf_NAMEPLATE_NOT_EFFECTIVE": TDK_COUT_NAMEPLATE_UF,
        },
        "fixture_examples_UNQUALIFIED": {
            f"cout_{cout:g}uf_{time:g}us": budget(cout, SD_CAP_NAMEPLATE_UF, vpre, floor, iload, time_us=time)
            for cout in (TI_COUT_MIN_EFFECTIVE_REFERENCE_UF, TDK_COUT_NAMEPLATE_UF)
            for time in (10.0, 50.0)
        },
        "missing_for_release": [
            "Installed worst-case effective C_OUT and C_SD including bias, temperature and age",
            "Actual Q_SD gate voltage vs time from real 10k/100k/BC847B/AO3401A driver",
            "Converter available output current vs time at BAT_SW=1.8V and USB transitions",
            "SD_VDD voltage and MCU pin VDD/NRST during switching with real firmware and card",
            "Other local rail capacitances and voltage drops; SD card dynamic current",
        ],
    }
    if any(getattr(args, name) is not None for name in ("cout_eff_uf", "sd_eff_uf", "charge_us", "source_a")):
        if args.cout_eff_uf is None or args.sd_eff_uf is None:
            p.error("custom case needs BOTH qualified --cout-eff-uf and --sd-eff-uf")
        out["user_supplied_conditional_case"] = budget(
            args.cout_eff_uf, args.sd_eff_uf, vpre, floor, iload,
            time_us=args.charge_us, isource_a=args.source_a)
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
