#!/usr/bin/env python3
"""Recompute RevA output-current evidence without treating a design ceiling as a measured peak.

The partial fixed-load subtotal deliberately excludes unqualified SD, OLED,
logic-switching and optional expansion loads. Run in the repository checkout;
JSON to stdout. Does not edit the project.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POWER_BLOB = "da2d005712c47000eb8c16157eca464d3fee4fe1"
SD_BLOB = "0793ee4aeae92fc5737796ce4631dac9770619f3"
BOOK_SHA = "88e1e826ebef3ea638586de88447075ffe6630a642eb6f1c1e5eec6bb13a99b4"


def check():
    for name, expected in (("01_POWER.SchDoc", POWER_BLOB), ("03_MICROSD.SchDoc", SD_BLOB)):
        path = next((p for p in (ROOT / name, ROOT / "current_schematics" / name) if p.is_file()), None)
        if path is None:
            raise FileNotFoundError(name)
        data = path.read_bytes()
        actual = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if actual != expected:
            raise ValueError(f"{name}: schematic source changed; re-audit before calculation")
    book = json.loads((ROOT / "AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json").read_text())
    if book["source_workbook_sha256"] != BOOK_SHA:
        raise ValueError("Purchase BOM source changed")
    rows = book["sheets"]["Power Calculations"]
    def cell(addr):
        return next(row[addr]["value"] for row in rows if addr in row)
    assert (cell("B5"), cell("B6"), cell("B8")) == (3.3, .28, 1.8)
    return {"voltage_v": cell("B5"), "design_ceiling_a": cell("B6"), "battery_loaded_v": cell("B8")}


def main():
    base = check()
    v, ceiling_ma, observed_ma = base["voltage_v"], base["design_ceiling_a"] * 1000, 19.
    # Conditional datasheet modes; not a complete simultaneous worst case:
    # ST DS12766 rev 3, table 24: flash run Range 1 16/64 MHz max @85C, peripherals disabled.
    # Sensirion SHT3x-DIS, sec. 2.1: 1.5mA max *while measuring*, bare sensor, heater excluded.
    # Analog Devices DS3231, Electrical Characteristics: temp conversion 575uA max at VCC=3.63V.
    # Project OLED/SHT3x block: two effective 1.371k bus pull-ups, VOL=0.4V;
    # simultaneous low states ONLY; actual duty factor not claimed.
    pullups_ma = 2 * (v - 0.4) / 1.371  # mA because V/kOhm
    fixed_16 = 3.0 + 1.5 + .575 + pullups_ma
    fixed_64 = 8.4 + 1.5 + .575 + pullups_ma
    sd_cap_uf = 22 + 22 + 10 + .1
    oled_cap_uf = 10 + .1
    def branch(cap):
        return {
            "nameplate_uf_NOT_BIASED_CEFF": cap,
            "charge_uc_if_0_to_3p3v_NAMEPLATE_ONLY": round(cap * v, 5),
            "average_charge_current_ma_if_1ms_NAMEPLATE_ONLY": round(cap * v, 5),
            "average_charge_current_ma_if_0p1ms_NAMEPLATE_ONLY": round(cap * v * 10, 5),
        }
    print(json.dumps({
        "status": "PARTIAL_EVIDENCE_BASED_CURRENT_RECALCULATION__NO_ACTUAL_PEAK_CLAIM",
        "design_envelope": {
            "3v3_design_load_ma_NOT_MEASURED_PEAK": ceiling_ma,
            "observed_old_prototype_ma_CAPTURE_BANDWIDTH_UNKNOWN": observed_ma,
            "ratio_ceiling_to_observed": round(ceiling_ma / observed_ma, 5),
            "output_power_w_at_design_ceiling": round(v * ceiling_ma / 1000, 5),
            "ideal_1p8v_input_ma_at_design_ceiling_LOWER_BOUND": round(v * ceiling_ma / 1.8, 5),
            "actual_battery_input_ma": "UNKNOWN: efficiency, source ESR and operating mode",
        },
        "partial_known_3v3_load_ma_WITH_CONDITION_MISMATCH": {
            "MCU_flash_run_16MHz_max_at85C_no_peripherals": 3.0,
            "MCU_flash_run_64MHz_max_at85C_no_peripherals_ALTERNATE": 8.4,
            "bare_SHT3x_measuring_max_heater_off": 1.5,
            "DS3231_temp_conversion_max_at3p63V": .575,
            "both_I2C_lines_low_2p12mA_each_SCENARIO": round(pullups_ma, 5),
            "16MHz_partial_sum_NOT_DEVICE_PEAK": round(fixed_16, 5),
            "64MHz_partial_sum_NOT_DEVICE_PEAK": round(fixed_64, 5),
            "remaining_to_280mA_16MHz_NOT_CARD_ALLOWANCE": round(ceiling_ma - fixed_16, 5),
            "remaining_to_280mA_64MHz_NOT_CARD_ALLOWANCE": round(ceiling_ma - fixed_64, 5),
            "excluded": ["unknown unbranded microSD idle/write/inrush", "unknown four-pin OLED module input at all pixels on",
                         "MCU peripherals/GPIO", "74HC125D/74HC4066D switching", "power-path quiescent draw",
                         "sensor-module electronics/heater", "expansion current", "capacitor charging"],
        },
        "nameplate_switched_capacitor_charge_ONLY_NOT_DEVICE_CURRENT": {
            "SD_VDD": branch(sd_cap_uf), "OLED_VDD": branch(oled_cap_uf),
            "both_if_enabled_simultaneously": branch(sd_cap_uf + oled_cap_uf),
        },
        "400mA_in_microSD_block_PDF": "Switch-drop sizing example, NOT measured current, and NOT a compatible whole-system 280mA guarantee",
        "source_urls": {
            "ST_MCU": "https://www.st.com/resource/en/datasheet/stm32g070rb.pdf",
            "Sensirion_sensor": "https://sensirion.com/media/documents/213E6A3B/63A5A569/Datasheet_SHT3x_DIS.pdf",
            "ADI_RTC": "https://www.analog.com/media/en/technical-documentation/data-sheets/ds3231.pdf",
            "OLED_user_document": "ChatGPT Library 6ce9958b2ddbf8913aec06c1a6201e59.pdf: bare WEO012864V, not exact 4-pin module",
            "MicroSD_design": "Datalogger_MicroSD_Final_BOM_RevA_v1.3_FA.pdf page 4",
        },
    }, indent=2))


if __name__ == "__main__":
    main()
