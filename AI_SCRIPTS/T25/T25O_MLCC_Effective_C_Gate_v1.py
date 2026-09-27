#!/usr/bin/env python3
"""Source-bound TDK/TI effective-C retention thresholds; no DC-bias model.

TDK exact-part pages: 47 uF/10 V and 22 uF/35 V, both +/-20% X5R.
TI TPS631000 Rev C section 5.3: COUT >= 10.4 uF at 3.3 V,
CIN >= 4.2 uF. Optional factors are user-supplied and never inferred.
"""

import argparse
import math

PARTS = (
    ("C_OUT", "C2012X5R1A476M125AC", 47.0, 10.4, "3.3 V"),
    ("C_IN", "C2012X5R1V226M125AC", 22.0, 4.2, "VIN_MUX bias"),
)
TOLERANCE_LOW = 0.80
X5R_TEMP_LOW = 0.85


def factor(s):
    v = float(s)
    if not math.isfinite(v) or not 0 < v <= 1:
        raise argparse.ArgumentTypeError("specify a finite retention factor in (0, 1]")
    return v


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cout-bias-factor", type=factor,
                    help="verified C_OUT bias retention relative to 0 V")
    ap.add_argument("--cin-bias-factor", type=factor,
                    help="verified C_IN bias retention at the specified input voltage")
    ap.add_argument("--age-factor", type=factor,
                    help="verified age retention; omitted means no aging verdict")
    a = ap.parse_args()
    print("T25O: static effective-C requirement algebra; NOT a model or board PASS")
    print("Multiplying independent 0.80 tolerance and 0.85 X5R temperature factors is an illustrative corner.")
    print("Aging, assembly stress, fixture and DC-bias worst-case values remain UNQUALIFIED unless supplied.")
    for name, mpn, nominal, minimum, voltage in PARTS:
        base = nominal * TOLERANCE_LOW * X5R_TEMP_LOW
        required_combined = minimum / base
        chosen_bias = a.cout_bias_factor if name == "C_OUT" else a.cin_bias_factor
        print(f"{name} {mpn}: nameplate={nominal:g}uF; assumed tolerance/temp corner={base:.3f}uF")
        print(f"  TI effective minimum={minimum:g}uF at {voltage}; required (bias x age x remaining factors) >= {required_combined:.6f} ({100*required_combined:.2f}%)")
        if chosen_bias is not None:
            if a.age_factor is None:
                print("  Bias factor supplied; aging unqualified: NO compliance verdict")
            else:
                estimate = base * chosen_bias * a.age_factor
                print(f"  supplied-factor illustrative C={estimate:.3f}uF; this is NOT a qualified worst case")
    print("No TDK numeric bias curve/model or worst-case aging bound is qualified; no compliance PASS.")


if __name__ == "__main__":
    main()
