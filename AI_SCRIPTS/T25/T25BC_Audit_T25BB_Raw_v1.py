#!/usr/bin/env python3
"""Audit T25BB raw PSpice logs and compare valid cases with T25AZ."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
from zipfile import ZipFile

NUM = r"[+-]?\d+(?:\.\d+)?E[+-]\d+"
ROW = re.compile(r"^\s*(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")", re.M)
TAG = re.compile(r"BG_(19|280)mA_IMAX_(0P5|1P0|1P5)A_TAU_(0|100)us")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("zip_path", type=Path)
    ap.add_argument("--t25az", type=Path, default=Path("AI_EVIDENCE/T25AZ/T25AZ_SD_charge_19_vs_280_2026-09-27.json"))
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()

    raw = args.zip_path.read_bytes()
    t25az = json.loads(args.t25az.read_text(encoding="utf-8"))
    reference = {
        (int(c["background_ma_ASSUMED"]), float(c["source_ceiling_a_ASSUMED_NOT_TI_RATING"]), int(c["switch_conductance_tau_us_ASSUMED_NOT_GATE_TIMING"])): c
        for c in t25az["cases"]
    }

    cases = []
    member_hashes = {}
    unsafe = []
    with ZipFile(args.zip_path) as zf:
        infos = zf.infolist()
        uncompressed_bytes = sum(info.file_size for info in infos)
        for info in infos:
            name = info.filename
            norm = PurePosixPath(name.replace("\\", "/"))
            mode = (info.external_attr >> 16) & 0o170000
            if norm.is_absolute() or ".." in norm.parts or info.is_dir() or mode == 0o120000:
                unsafe.append(name)
            member_hashes[name] = sha256(zf.read(name))

        out_names = sorted(n for n in zf.namelist() if n.endswith(".out"))
        for name in out_names:
            match = TAG.search(name)
            if not match:
                raise SystemExit(f"Unexpected OUT name: {name}")
            bg = int(match.group(1))
            imax = float(match.group(2).replace("P", "."))
            tau = int(match.group(3))
            text = zf.read(name).decode("latin1")
            rows = [tuple(map(float, item.groups())) for item in ROW.finditer(text)]
            pre = [r for r in rows if 0.0009 <= r[0] <= 0.0009998]
            post = [r for r in rows if 0.001 <= r[0] <= 0.0025]
            errors = len(re.findall(r"(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)", text))
            warnings = len(re.findall(r"(?im)^\s*WARNING\(", text))
            job = bool(re.search(r"(?im)^\s*JOB CONCLUDED\s*$", text))
            pseudo = "Starting pseudo-transient algorithm." in text
            dat_name = name[:-4] + ".dat"
            solver_ok = bool(job and errors == 0 and warnings == 0 and len(rows) >= 12000 and rows[-1][0] >= 0.002499 and dat_name in zf.namelist())
            pre_ok = bool(pre and min(r[1] for r in pre) > 3.25 and max(r[2] for r in pre) < 0.01 and max(r[3] for r in pre) < 0.001)
            event_ok = bool(post and max(r[3] for r in post) > 0.99)
            valid = bool(solver_ok and pre_ok and event_ok and not pseudo)
            minimum = min(post, key=lambda r: r[1]) if post else None
            first_27 = next((r for r in post if r[2] >= 2.7), None)
            ref = reference[(bg, imax, tau)]
            min_v = minimum[1] if minimum else None
            min_us = (minimum[0] - 0.001) * 1e6 if minimum else None
            sd_us = (first_27[0] - 0.001) * 1e6 if first_27 else None
            cases.append({
                "case": Path(name).stem,
                "background_mA_assumed": bg,
                "source_ceiling_A_assumed": imax,
                "conductance_tau_us_assumed": tau,
                "solver_job_concluded": job,
                "solver_errors": errors,
                "solver_warnings": warnings,
                "printed_rows": len(rows),
                "pseudo_transient_invoked": pseudo,
                "prestate": {
                    "sample_count": len(pre),
                    "rail_min_V": min((r[1] for r in pre), default=None),
                    "sd_max_V": max((r[2] for r in pre), default=None),
                    "control_max_V": max((r[3] for r in pre), default=None),
                    "valid": pre_ok,
                },
                "valid_for_crosscheck": valid,
                "min_3V3_SYS_V": min_v,
                "min_after_enable_us": min_us,
                "sd_to_2p7V_us": sd_us,
                "T25AZ_min_V": ref["min_rail_v"],
                "T25AZ_min_difference_mV": None if min_v is None else (min_v - ref["min_rail_v"]) * 1000,
                "T25AZ_sd_to_2p7V_us": ref["first_SD_VDD_at_2p7V_us_ONLY_NO_CARD"],
                "T25AZ_sd_time_difference_us": None if sd_us is None else sd_us - ref["first_SD_VDD_at_2p7V_us_ONLY_NO_CARD"],
            })

    valid = [c for c in cases if c["valid_for_crosscheck"]]
    invalid = [c for c in cases if not c["valid_for_crosscheck"]]
    result = {
        "status": f"{len(valid)}_VALID_{len(invalid)}_INVALID_PRESTATE_NO_BOARD_PASS",
        "archive": {
            "file_name": args.zip_path.name,
            "bytes": len(raw),
            "sha256": sha256(raw),
            "members": len(member_hashes),
            "unsafe_members": unsafe,
            "uncompressed_bytes": uncompressed_bytes,
        },
        "summary": {
            "expected_cases": 12,
            "solver_completed_cases": sum(c["solver_job_concluded"] for c in cases),
            "valid_crosscheck_cases": len(valid),
            "invalid_crosscheck_cases": len(invalid),
            "invalid_case_names": [c["case"] for c in invalid],
            "max_abs_valid_min_difference_mV": max(abs(c["T25AZ_min_difference_mV"]) for c in valid),
            "max_abs_valid_sd_time_difference_us": max(abs(c["T25AZ_sd_time_difference_us"]) for c in valid if c["T25AZ_sd_time_difference_us"] is not None),
            "interpretation": "Two 19mA/0.5A cases invoked PSpice pseudo-transient and had the SD control already active before 1ms. Their reported 3.298V minima are invalid. Ten cases independently cross-check T25AZ within print precision. Conditional fixture only; no board or fabrication pass."
        },
        "cases": cases,
        "member_sha256": member_hashes,
    }
    rendered = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0 if len(valid) == 10 and len(invalid) == 2 else 2


if __name__ == "__main__":
    raise SystemExit(main())
