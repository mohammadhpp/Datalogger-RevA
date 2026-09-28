#!/usr/bin/env python3
"""Audit T25BF official TPS631000 short-window traces without trusting wrapper labels."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
from zipfile import ZipFile

NUM = r"[+-]?\d+(?:\.\d+)?E[+-]\d+"
ROW = re.compile(r"^\s*(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")", re.M)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("zip_path", type=Path)
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    raw = args.zip_path.read_bytes()
    member_sha = {}
    unsafe = []
    cases = []
    with ZipFile(args.zip_path) as zf:
        infos = zf.infolist()
        names = set(zf.namelist())
        for info in infos:
            name = info.filename
            q = PurePosixPath(name.replace("\\", "/"))
            mode = (info.external_attr >> 16) & 0o170000
            if q.is_absolute() or ".." in q.parts or info.is_dir() or mode == 0o120000:
                unsafe.append(name)
            member_sha[name] = digest(zf.read(name))
        for tag in ("VIN_1P8V", "VIN_2P8V_CONTROL"):
            out_name = tag + ".out"
            text = zf.read(out_name).decode("latin1")
            rows = [tuple(map(float, m.groups())) for m in ROW.finditer(text)]
            pre = [r for r in rows if 8e-6 <= r[0] <= 9.8e-6]
            post = [r for r in rows if 10e-6 <= r[0] <= 20e-6]
            errors = len(re.findall(r"(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)", text))
            warnings = len(re.findall(r"(?im)^\s*WARNING\(", text))
            job = bool(re.search(r"(?im)^\s*JOB CONCLUDED\s*$", text))
            runtime = re.search(r"Total job time \(using Solver 1\)\s*=\s*([0-9.]+)", text)
            complete = bool(job and errors == 0 and warnings == 0 and len(rows) >= 1900 and rows[-1][0] >= 19.99e-6 and tag + ".dat" in names)
            pre_min = min(r[2] for r in pre)
            pre_max = max(r[2] for r in pre)
            post_min = min(r[2] for r in post)
            post_end = post[-1][2]
            pre_i = sum(abs(r[4]) for r in pre) / len(pre)
            post_i = sum(abs(r[4]) for r in post) / len(post)
            pre_valid = 3.135 <= pre_min and pre_max <= 3.465
            cases.append({
                "case": tag,
                "job_concluded": job,
                "errors": errors,
                "warnings": warnings,
                "printed_rows": len(rows),
                "runtime_seconds": None if not runtime else float(runtime.group(1)),
                "trace_complete": complete,
                "pre_VOUT_min_V": pre_min,
                "pre_VOUT_max_V": pre_max,
                "pre_abs_input_current_avg_A": pre_i,
                "post_VOUT_min_V": post_min,
                "post_VOUT_end_V": post_end,
                "post_abs_input_current_avg_A": post_i,
                "regulated_3V3_prestate_valid": pre_valid,
                "load_step_interpretation_valid": bool(complete and pre_valid),
            })
    valid = [c for c in cases if c["load_step_interpretation_valid"]]
    result = {
        "status": f"{len(cases)}_OFFICIAL_MODEL_TRACES_COMPLETE_{len(valid)}_VALID_LOADSTEP_PRESTATES_NO_BOARD_PASS",
        "archive": {
            "file_name": args.zip_path.name,
            "bytes": len(raw),
            "sha256": digest(raw),
            "members": len(member_sha),
            "uncompressed_bytes": sum(i.file_size for i in infos),
            "unsafe_members": unsafe,
        },
        "cases": cases,
        "interpretation": "Both official encrypted-model jobs completed, but neither had a regulated 3.3V pre-event state. Post-step voltages are not valid load-step response evidence. The 1.8V trace drew only sub-mA input current in the prewindow; the short precharged run did not bypass internal startup state. This is a fixture/model-state limitation, not proof of board failure.",
        "member_sha256": member_sha,
    }
    rendered = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0 if len(cases) == 2 and not valid and all(c["trace_complete"] for c in cases) else 2


if __name__ == "__main__":
    raise SystemExit(main())
