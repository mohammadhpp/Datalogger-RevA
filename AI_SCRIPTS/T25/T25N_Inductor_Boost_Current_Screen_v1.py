#!/usr/bin/env python3
"""TI Eq. 3 boost-mode steady-state inductor-current arithmetic; not a transient model.

All operating-point inputs are required. The 4.8 A / 3.8 A / 32 mOhm part
numbers are from Murata's reference specification for DFE322512F-1R0M=P2.
See AI_CONTINUITY/T25N_MURATA_INDUCTOR_SOURCE_AUDIT.md for limits.
"""

import argparse
import math

VOUT_V = 3.3
MURATA_ISAT_A = 4.8  # DC current for 30% loss of initial L, not a hard peak-current limit.
TI_RECOMMENDED_HEADROOM = 1.2


def positive(value):
    result = float(value)
    if not math.isfinite(result) or result <= 0:
        raise argparse.ArgumentTypeError("enter a finite number greater than zero")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vin-v", required=True, type=positive)
    parser.add_argument("--iout-a", required=True, type=positive)
    parser.add_argument("--efficiency", required=True, type=positive)
    parser.add_argument("--l-uh", required=True, type=positive)
    parser.add_argument("--fsw-mhz", required=True, type=positive)
    args = parser.parse_args()
    if args.vin_v >= VOUT_V:
        parser.error("TI Eq. 3 as used here applies to boost mode: VIN < 3.3 V")
    if args.efficiency > 1:
        parser.error("efficiency must not exceed 1")
    d = (VOUT_V - args.vin_v) / VOUT_V
    average_a = args.iout_a / (args.efficiency * (1 - d))
    half_ripple_a = args.vin_v * d / (2 * args.l_uh * args.fsw_mhz)
    peak_a = average_a + half_ripple_a
    recommended_isat_a = TI_RECOMMENDED_HEADROOM * peak_a
    print("T25N: TI Eq. 3 steady-state boost calculation; board startup/load-step OPEN")
    print(f"VIN={args.vin_v:.3f} V, VOUT={VOUT_V:.3f} V, IOUT={args.iout_a:.3f} A")
    print(f"Assumed efficiency={args.efficiency:.3f}, L={args.l_uh:.3f} uH, f={args.fsw_mhz:.3f} MHz")
    print(f"Boost duty (ideal)={d:.6f}; input/inductor average={average_a:.4f} A")
    print(f"Half ripple={half_ripple_a:.4f} A; calculated inductor peak={peak_a:.4f} A")
    print(f"TI 20% saturation headroom target={recommended_isat_a:.4f} A")
    print(f"Murata DC 30%-L-loss current={MURATA_ISAT_A:.1f} A; ratio={MURATA_ISAT_A/recommended_isat_a:.3f}")
    print("DC 30%-L-loss rating, operating-L/thermal curve, IC current limit and actual board loads are distinct gates.")
    print("NO hardware PASS / NO startup, switched-load or transient claim.")


if __name__ == "__main__":
    main()
