#!/usr/bin/env python3
"""Conditional USB OVP shutoff budget, never a complete circuit simulation.

Run from the Git checkout with Python 3:
    python AI_SCRIPTS/T25/T25Z_OVP_Shutoff_Budget_v1.py

Optional scenario, with independently qualified inputs (units in the names):
    python AI_SCRIPTS/T25/T25Z_OVP_Shutoff_Budget_v1.py \
      --ceff-min-uf 10 --source-current-max-ma 100 \
      --cutoff-max-us 5 --source-slew-max-v-per-ms 1

This tool never labels the physical hardware PASS. It derives necessary
conditional budgets for the TPS2116 VIN1 absolute limit using the historic
analytical upper trip. An actual cutoff waveform and source characterization
are required to validate the assumptions.
"""
import argparse
import json
import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
EXPECTED_BOOK_SHA256 = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
EXPECTED_ARCHIVE_SHA256 = "22502ef489575150f849f394d5db9e67546c592243e48c0e49deb7ff9983a96b"


def source_trip_and_absolute():
    book = json.loads(BOOK.read_text(encoding="utf-8"))
    if book["source_workbook_sha256"] != EXPECTED_BOOK_SHA256:
        raise ValueError("unexpected workbook identity")
    if book["source_archive_sha256"] != EXPECTED_ARCHIVE_SHA256:
        raise ValueError("unexpected source ZIP identity")
    sheet = book["sheets"]["OVP Calc v0.17"]

    def value(address):
        matches = [row[address]["value"] for row in sheet if address in row]
        if len(matches) != 1:
            raise ValueError("missing/duplicate workbook cell " + address)
        return float(matches[0])

    trip, absolute = value("B9"), value("B7")
    if not (5.5 < trip < absolute == 6.0):
        raise ValueError("unexpected historical OVP boundary")
    return trip, absolute


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--ceff-min-uf", type=float, help="MEASURED/qualified minimum installed VIN1 capacitance, microfarad")
    p.add_argument("--source-current-max-ma", type=float, help="PROVEN maximum current into VIN1 during fault, milliampere")
    p.add_argument("--cutoff-max-us", type=float, help="PROVEN maximum time from upper trip to stopped VIN1 charging, microsecond")
    p.add_argument("--source-slew-max-v-per-ms", type=float, help="PROVEN maximum USB fault ramp, V/ms")
    a = p.parse_args()
    names = ("ceff_min_uf", "source_current_max_ma", "cutoff_max_us", "source_slew_max_v_per_ms")
    for name in names:
        v = getattr(a, name)
        if v is not None and (not math.isfinite(v) or v <= 0):
            p.error("all supplied quantities must be finite and positive")
    count_supplied = sum(getattr(a, name) is not None for name in names)
    if count_supplied not in (0, len(names)):
        p.error("supply all four scenario inputs or none; partial scenarios are unsupported")
    trip, vmax = source_trip_and_absolute()
    dv = vmax - trip
    print("T25Z OVP conditional budget - NOT FULL CIRCUIT SIMULATION / NO HARDWARE PASS")
    print("Historic workbook B9=%.10f V, B7=%.1f V; headroom=%.9f V" % (trip, vmax, dv))
    print("Current-limited charging, no guaranteed helpful VIN1 load:")
    print("  delay_max_us < Ceff_min_uF * %.9f / I_into_VIN1_max_mA * 1000" % dv)
    print("  I_into_VIN1_max_mA < Ceff_min_uF * %.9f * 1000 / delay_max_us" % dv)
    print("Ramp pass-through until cutoff: slew_max_V_per_ms * delay_max_us < %.9f * 1000" % dv)
    print("These bounds use a ZERO safety reserve at 6 V; equality is NOT an acceptable design margin.")
    if count_supplied == 0:
        print("Scenario inputs absent: no physical protection verdict generated.")
        print("Illustrations only: C=22/44 uF represent C_USB2 DNP/POP NAMEPLATES, not Ceff minima;")
        print("1/10/100 us are hypothetical cutoff times, not verified board response.")
        for delay in (1, 10, 100):
            i22 = 22 * dv * 1000 / delay
            i44 = 44 * dv * 1000 / delay
            slew = dv * 1000 / delay
            print("  %3d us: Imax<%9.3f/%9.3f mA (22/44 uF), slew<%8.3f V/ms" %
                  (delay, i22, i44, slew))
        return
    current = a.source_current_max_ma
    delay = a.cutoff_max_us
    ceff = a.ceff_min_uf
    slope = a.source_slew_max_v_per_ms
    current_peak_bound = trip + current * delay / (ceff * 1000)
    ramp_peak_bound = trip + slope * delay / 1000
    print("Conditional scenario: Ceff_min=%.6g uF, I_into_VIN1_max=%.6g mA," % (ceff, current))
    print("  cutoff_max=%.6g us, source_slew_max=%.6g V/ms" % (delay, slope))
    print("  Charge-limited bound: VIN1 <= %.8f V ; mathematical <6 V: %s" %
          (current_peak_bound, current_peak_bound < vmax))
    print("  Ramp pass-through bound: VIN1 <= %.8f V ; mathematical <6 V: %s" %
          (ramp_peak_bound, ramp_peak_bound < vmax))
    print("  Scope: separate fault shapes; do not combine into a measured combined waveform.")
    print("  No guaranteed Ceff/source current/cutoff/slew inputs have been supplied for this board.")
    print("  Physical OVP remains OPEN even when a hypothetical inequality is true.")


if __name__ == "__main__":
    main()
