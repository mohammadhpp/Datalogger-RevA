#!/usr/bin/env python3
"""Read the user's T25AQ ZIP and inspect BOTH handoff gaps and load-enable peaks.

The 1 us .PRINT resolution and schematic fixture values never prove hardware.
"""
import argparse
import hashlib
import json
import re
import zipfile
from pathlib import Path

CASES = {
    "COUT_10P4U_GAP_10US": ("10.4u", 10),
    "COUT_10P4U_GAP_50US": ("10.4u", 50),
    "COUT_47U_NOMINAL_GAP_10US": ("47u", 10),
    "COUT_47U_NOMINAL_GAP_50US": ("47u", 50),
}
NUM = r"[+-]?\d+\.\d+E[+-]\d+"
ROW = re.compile(r"(?m)^\s*(" + r")\s+(".join([NUM] * 5) + r")\s*$")


def read_rows(log):
    return [tuple(map(float, match.groups())) for match in ROW.finditer(log)]


def stats(rows, lo_us, hi_us):
    window = [r for r in rows if lo_us <= round(r[0] * 1e6, 3) <= hi_us]
    if len(window) < 2:
        raise ValueError(f"Insufficient PRINT points {lo_us}-{hi_us}us")
    result = {"samples": len(window)}
    for col, name in enumerate(("3V3_SYS", "SD_VDD", "OLED_VDD"), start=1):
        minimum = min(window, key=lambda r: r[col])
        result[name] = {"min_v": minimum[col], "min_time_us": round(minimum[0] * 1e6, 3)}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("zip_path", type=Path)
    args = parser.parse_args()
    raw = args.zip_path.read_bytes()
    result = {"sha256": hashlib.sha256(raw).hexdigest(),
              "fixture_only": True, "hardware_pass": False, "cases": {}}
    with zipfile.ZipFile(args.zip_path) as archive:
        members = set(archive.namelist())
        expected = {f"{name}{suffix}" for name in CASES for suffix in (".cir", ".out", ".dat")}
        if not expected <= members:
            raise ValueError(f"Missing fixture files: {sorted(expected - members)}")
        summary = archive.read("T25AQ_v1_Result.txt").decode("utf-8-sig")
        if "STATUS=FOUR_CONDITIONAL_PSPICE_CASES_COMPLETED" not in summary:
            raise ValueError("Wrapper completion marker missing")
        for tag, (cap, gap_us) in CASES.items():
            deck = archive.read(f"{tag}.cir").decode("ascii")
            log = archive.read(f"{tag}.out").decode("latin-1")
            expected_ctl = f"{1000+gap_us}u 0 {1001+gap_us}u 3"
            if f"C_OUT 3V3_SYS 0 {cap}" not in deck or expected_ctl not in deck:
                raise ValueError(f"Fixture matrix mismatch: {tag}")
            if ("JOB CONCLUDED" not in log or "Total job time" not in log
                    or re.search(r"(?im)^\s*(?:ERROR\(|WARNING\(|FATAL|JOB ABORTED)", log)):
                raise ValueError(f"Solver not clean: {tag}")
            rows = read_rows(log)
            if len(rows) < 2250 or abs(rows[-1][0] - .00225) > .000001:
                raise ValueError(f"Short or truncated waveform: {tag}")
            baseline = [r[1] for r in rows if 900 <= r[0]*1e6 < 990]
            if len(baseline) < 80 or min(baseline) < 3.2:
                raise ValueError(f"Unsettled pre-handoff: {tag}")
            sd = stats(rows, 306, 340)
            oled = stats(rows, 506, 540)
            first = stats(rows, 1000, 1000+gap_us)
            second = stats(rows, 2000, 2000+gap_us)
            if any(abs(first[n]["min_v"]-second[n]["min_v"]) > .001 for n in ("3V3_SYS", "SD_VDD", "OLED_VDD")):
                raise ValueError(f"Handoff events do not match this fixture: {tag}")
            r = result["cases"][tag] = {
                "rows": len(rows), "settled_pre_3v3_v": min(baseline),
                "sd_enable_us306_340": sd, "oled_enable_us506_540": oled,
                "first_gap": first, "second_gap": second,
                "sd_enable_3v3_print_samples_below_2p04": sum(306 <= round(x[0]*1e6,3) <= 340 and x[1] < 2.04 for x in rows),
            }
            # A startup dip is a SEPARATE event, omitted by the original gap-only wrapper.
            assert r["sd_enable_us306_340"]["3V3_SYS"]["min_time_us"] < 315
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
