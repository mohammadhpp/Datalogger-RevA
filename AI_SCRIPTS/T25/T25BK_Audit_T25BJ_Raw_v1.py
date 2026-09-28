#!/usr/bin/env python3
"""
T25BK independent auditor for T25BJ TPS22918 raw PSpice result ZIP.

The v2 PowerShell summary parser was invalid because PSpice emitted the six
voltage columns and I(V_SRC) in separate PRINT tables. This auditor parses
those tables independently and never trusts T25BJ_v2_Summary.csv.

Usage:
    python T25BK_Audit_T25BJ_Raw_v1.py <Datalogger_T25BJ_Sweep_v2_Result_*.zip>
"""
from __future__ import annotations
import csv
import hashlib
import re
import sys
import zipfile
from pathlib import Path

NUM = r"[+-]?\d+(?:\.\d+)?E[+-]\d+"
SIX = re.compile(
    r"^\s*(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")\s+"
    r"(" + NUM + r")\s+(" + NUM + r")\s+(" + NUM + r")\s*$"
)
TWO = re.compile(r"^\s*(" + NUM + r")\s+(" + NUM + r")\s*$")
CASE = re.compile(r"CT_([0-9P]+)n_CSD_([0-9P]+)u_LOAD_(\d+)mA\.out$", re.I)

ON_T = 0.0001
OFF_T = 0.0251

def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def first_time(rows, col, threshold, ge=True):
    for r in rows:
        if (r[col] >= threshold) if ge else (r[col] <= threshold):
            return r[0]
    return None

def parse_out(text: str):
    vi = text.find("TIME        V(SRC)")
    ci = text.find("TIME        I(V_SRC)", vi + 1)
    if vi < 0 or ci < 0:
        raise ValueError("separate PSpice PRINT tables not found")
    vrows = []
    for line in text[vi:ci].splitlines():
        m = SIX.match(line)
        if m:
            vrows.append(tuple(float(x) for x in m.groups()))
    crows = []
    for line in text[ci:].splitlines():
        m = TWO.match(line)
        if m:
            crows.append(tuple(float(x) for x in m.groups()))
    if not vrows or not crows:
        raise ValueError("no numeric waveform rows")
    return vrows, crows

def audit_case(name: str, text: str):
    m = CASE.search(name)
    if not m:
        raise ValueError("case filename not recognized")
    ct = float(m.group(1).replace("P", "."))
    csd = float(m.group(2).replace("P", "."))
    load = int(m.group(3))
    v, cur = parse_out(text)
    on = [r for r in v if ON_T <= r[0] < OFF_T]
    pre = [r for r in v if 0.024 <= r[0] < 0.025]
    off = [r for r in v if r[0] >= OFF_T]
    cur_on = [r for r in cur if ON_T <= r[0] < OFF_T]
    t10 = first_time(on, 3, 0.33, True)
    t90 = first_time(on, 3, 2.97, True)
    t27 = first_time(on, 3, 2.70, True)
    tq = first_time(off, 3, 0.50, False)
    errors = len(re.findall(r"(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)", text))
    warnings = len(re.findall(r"(?im)^\s*WARNING\(", text))
    concluded = bool(re.search(r"(?im)^\s*JOB CONCLUDED\s*$", text))
    return {
        "case": name[:-4],
        "ct_nF": ct,
        "csd_uF": csd,
        "load_mA_at_3V3": load,
        "job_concluded": concluded,
        "warnings": warnings,
        "errors": errors,
        "voltage_rows": len(v),
        "current_rows": len(cur),
        "rise10_90_ms": "" if t10 is None or t90 is None else (t90 - t10) * 1000,
        "time_to_2V7_ms": "" if t27 is None else (t27 - ON_T) * 1000,
        "vin_min_V": min(r[2] for r in on),
        "source_peak_abs_A": max(abs(r[1]) for r in cur_on),
        "vout_preoff_V": sum(r[3] for r in pre) / len(pre),
        "qod_to_0V5_ms": "" if tq is None else (tq - OFF_T) * 1000,
    }

def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: python T25BK_Audit_T25BJ_Raw_v1.py result.zip")
    path = Path(sys.argv[1])
    data = path.read_bytes()
    rows = []
    with zipfile.ZipFile(path) as z:
        for name in sorted(z.namelist()):
            if name.lower().endswith(".out") and CASE.search(name):
                rows.append(audit_case(name, z.read(name).decode("utf-8", errors="replace")))
    if len(rows) != 16:
        raise SystemExit(f"expected 16 cases, found {len(rows)}")
    if not all(r["job_concluded"] and r["warnings"] == 0 and r["errors"] == 0 for r in rows):
        raise SystemExit("one or more raw PSpice cases did not conclude cleanly")
    fields = list(rows[0].keys())
    writer = csv.DictWriter(sys.stdout, fieldnames=fields)
    print(f"# ZIP_SHA256={sha256_bytes(data)}")
    writer.writeheader()
    writer.writerows(rows)

if __name__ == "__main__":
    main()
