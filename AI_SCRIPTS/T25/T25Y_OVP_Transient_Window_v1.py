#!/usr/bin/env python3
"""T25Y conditional OVP timing windows. Not a circuit simulation or PASS.

Run from the repository root (Python 3 stdlib only):
  python AI_SCRIPTS/T25/T25Y_OVP_Transient_Window_v1.py

Only the historic, source-traced OVP trip maximum is loaded from the
Git-readable purchase workbook export. No USB impedance, capacitor DC bias,
component reaction time or current profile is silently assigned.
"""
import json
import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BOOK = ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json"
BOOK_SHA256 = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"
ARCHIVE_SHA256 = "22502ef489575150f849f394d5db9e67546c592243e48c0e49deb7ff9983a96b"
V_ABSOLUTE_MAX = 6.0  # TI TPS2116 absolute VIN maximum, not recommended 5.5 V
V_FAULT = 12.0  # historic P9 injected-fault fixture, not a measured USB source
V_PRE = 5.5  # nominal illustration: protected node initially at 5.5 V


def cell(sheet, address):
    for row in sheet:
        if address in row:
            return row[address]["value"]
    raise ValueError("missing workbook cell: " + address)


def isolated_zener_gate(v_source, r_gate=10000.0, temp_c=25.0):
    """DC-only nominal vendor zener model, no PNP, hysteresis or MOS gate.

    Diodes BZT52C6V2.spice.txt: VZ=5.14 V, DR IS=6.65f A, RS=2.30 ohm,
    N=1.49; D1 reverse leakage/capacitance omitted. No process corners.
    """
    isat = 6.65e-15
    vt = 8.617333262e-5 * (temp_c + 273.15)

    def v_zener(i):
        return 5.14 + 1.49 * vt * math.log1p(i / isat) + 2.30 * i

    lo, hi = 0.0, max(v_source / r_gate, 0.0)
    for _ in range(120):
        i = (lo + hi) / 2.0
        if i > max((v_source - v_zener(i)) / r_gate, 0.0):
            hi = i
        else:
            lo = i
    i = (lo + hi) / 2.0
    return i, v_zener(i)


def run():
    book = json.loads(BOOK.read_text(encoding="utf-8"))
    assert book["source_workbook_sha256"] == BOOK_SHA256
    assert book["source_archive_sha256"] == ARCHIVE_SHA256
    sheet = book["sheets"]["OVP Calc v0.17"]
    trip = float(cell(sheet, "B9"))
    vmax = float(cell(sheet, "B7"))
    assert vmax == V_ABSOLUTE_MAX and V_PRE < trip < vmax < V_FAULT
    margin = vmax - trip
    # Ramp pass-through: protected node = input while the pass FET remains on.
    # S is a FIXTURE slope, not actual source slew or measured turn-off time.
    # deltaV = S * t, so the nominal threshold-to-limit interval is deltaV/S.
    # Step RC: Vprot(t) = Vf + (Vpre-Vf)*exp(-t/(R*C)) with a FET kept ON.
    # t_limit/(R*C) = -ln((Vf-Vlimit)/(Vf-Vpre)).
    step_factor = -math.log((V_FAULT - vmax) / (V_FAULT - V_PRE))
    print("T25Y conditional OVP timing screen - NOT SIMULATION OR HARDWARE PASS")
    print("workbook v0.17 B9 = %.10f V; B7 = %.1f V" % (trip, vmax))
    print("Delta to TPS2116 absolute VIN maximum: %.9f V" % margin)
    print("Ramp gate: t_limit_seconds = %.9f / S_V_per_second" % margin)
    print("Illustrative slopes only, not real chargers:")
    for slope in (0.1, 1.0, 10.0):  # V/ms, purely declared fixtures
        print("  %.1f V/ms -> %.6f us" % (slope, margin * 1000 / slope))
    print("Step gate: initial %.1f V -> hypothetical %.1f V; ON-state RC factor = %.9f" %
          (V_PRE, V_FAULT, step_factor))
    print("  t_to_6V = %.9f * R_total_ohm * C_effective_farads" % step_factor)
    print("Illustration ONLY (Rtotal is assumed, and 22u/44u are unqualified NAMEPLATES):")
    for population, c_nom in (("C_USB1 POP, C_USB2 DNP", 22e-6),
                              ("C_USB1 + C_USB2 POP", 44e-6)):
        for r_assumed in (2.0, 10.0):
            print("  %-27s R=%.1f ohm, Cnom=%2.0f uF -> %.6f us" %
                  (population, r_assumed, c_nom * 1e6,
                   1e6 * step_factor * r_assumed * c_nom))
    print("These times assume a completely ON linear RC switch, no load, and")
    print("an ideal source. No Rtotal, Ceff, turnoff time or current has been")
    print("measured for the actual assembly. Fault protection remains OPEN.")
    current, clamp = isolated_zener_gate(V_FAULT)
    print("Isolated vendor ZENER DC submodel at 25 C, VIN=12 V, Rgate=10k:")
    print("  Iz=%.6f mA; Vsource-Vgate=%.6f V; Vgate=%.6f V" %
          (1000 * current, clamp, V_FAULT - clamp))
    print("  Compared with a 10 V MAGNITUDE screen, difference %.6f V" %
          (10.0 - clamp))
    print("  ONLY in this disconnected PNP/Rhyst, DC fixture.")
    print("  FOSAN PDF prints '+10 V'; negative VGS absolute rating is")
    print("  NOT explicit there. This difference is NOT a qualified margin.")
    print("  No Zener lot/temp bounds or complete OVP switching validated.")


if __name__ == "__main__":
    run()
