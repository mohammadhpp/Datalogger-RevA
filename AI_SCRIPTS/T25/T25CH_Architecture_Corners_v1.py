#!/usr/bin/env python3
"""Static tolerance proof and conditional energy/source budgets; no board PASS.

Uses documented datasheet limits, existing resistor types and explicitly declared
scenarios. It neither executes nor substitutes any failed vendor macro-model.
"""
import csv
import itertools
import json
import math
from pathlib import Path


def regulator(vfb, rt, rb, top_tol, bot_tol):
    values = [v * (1 + top / bot) for v, top, bot in itertools.product(
        vfb, (rt * (1-top_tol), rt * (1+top_tol)),
        (rb * (1-bot_tol), rb * (1+bot_tol)))]
    return {"min_V": min(values), "nom_V": sum(vfb)/2 * (1+rt/rb),
            "max_V": max(values)}


def divider_window(usb_min, floor, tolerance):
    # Vthreshold = Vref * (1 + Rtop/Rbottom). Leakage and dynamics excluded.
    lo = (floor/.92-1) * (1+tolerance)/(1-tolerance)
    hi = (usb_min/1.08-1) * (1-tolerance)/(1+tolerance)
    return dict(USB_static_min_V=usb_min, rail_floor_V=floor,
                resistor_tolerance=tolerance, k_nom_min=lo, k_nom_max=hi,
                feasible_ignoring_leakage=lo <= hi)


def main():
    root = Path(__file__).resolve().parents[2]
    out = root / 'AI_EVIDENCE/T25CH'
    out.mkdir(parents=True, exist_ok=True)
    usb = regulator((.581, .611), 91000, 20000, .01, .005)
    battery = regulator((.495, .505), 510000, 91000, .01, .01)
    windows = [divider_window(usb['min_V'], floor, tol)
               for floor, tol in itertools.product((2.7, 2.72, 3.0), (0., .001, .005))]
    # Worst slow-fall corner with existing two-10k / one-10k PR divider.
    pr_min = .92 * (1 + 19900/10050)
    pr_max = 1.08 * (1 + 20100/9950)
    # Another proposed 18k 1% / 10k 0.5% divider has ample attach margin
    # but would keep selecting a sustained 2.65V USB rail at the low corner.
    pr18_min = .92 * (1 + 17820/10050)
    pr18_max = 1.08 * (1 + 18180/9950)
    counterexamples = {
        'old_20k_over_10k_PR_min_V': pr_min,
        'old_20k_over_10k_PR_max_V': pr_max,
        'old_divider_attach_failure_margin_V': usb['min_V']-pr_max,
        '18k_over_10k_PR_min_V': pr18_min,
        '18k_over_10k_PR_max_V': pr18_max,
        'sustained_USB_plateau_V': 2.65,
        'at_low_threshold_corner_USB_still_selected': 2.65 > pr18_min,
        'plateau_below_SD_rail_reference': 2.65 < 2.7,
        'automatic_highest_voltage_cannot_guarantee_USB_priority':
            usb['min_V'] < battery['max_V'],
    }
    # This is an energy budget for a total powerless interval, including
    # detection, mux gap and backup recovery. No interval is guaranteed here.
    energy = []
    for load, start, interval, cap in itertools.product(
            (.019, .280), (usb['min_V'], 2.86), (31.2, 75., 200.), (10.4, 22., 47., 100.)):
        power = 3.3*load
        radicand = start*start - 2*power*interval*1e-6/(cap*1e-6)
        end = math.sqrt(radicand) if radicand >= 0 else None
        energy.append(dict(load_at_3V3_A=load, start_scenario_V=start,
                           total_no_source_interval_us=interval, Ceff_scenario_uF=cap,
                           energy_only_end_V=end,
                           above_2p72V_scenario=end is not None and end >= 2.72,
                           required_Ceff_to_2p72V_uF=2*power*interval*1e-6/
                               (start*start-2.72**2)*1e6))
    source = []
    # 1.65V is recommended startup floor; these are power-balance sensitivities,
    # not a datasheet efficiency/current guarantee at 1.80V loaded AA pack.
    for load, eta in itertools.product((.019, .280), (.70, .80, .90)):
        p = 3.3*load
        current_at_floor = p/(eta*1.65)
        total_r = .15/current_at_floor
        source.append(dict(load_at_3V3_A=load, eta_scenario=eta,
            upstream_pack_current_at_1p65V_A=current_at_floor,
            upstream_total_resistance_budget_ohm=total_r,
            upstream_external_R_if_mux_R_0p066_scenario_ohm=total_r-.066,
            downstream_external_R_if_output_mux_R_0p059_scenario_ohm=
                .15/((p+load*load*.059)/(eta*1.65))))
    for name, rows in [('divider_windows', windows), ('hold_up_budget', energy),
                       ('battery_source_budget', source)]:
        with (out/(name+'.csv')).open('w', newline='') as f:
            w = csv.DictWriter(f, fieldnames=rows[0]);w.writeheader();w.writerows(rows)
    result = dict(status='ACTUAL_TEST_WITH_RAW_EVIDENCE',
        scope='STATIC_CORNER_PROOF_AND_CONDITIONAL_ENERGY_ONLY_NO_BOARD_PASS',
        vendor_model_route='BLOCKED_NO_RERUN', fabrication_hold=True,
        USB_91k_20k_static=usb, retained_battery_510k_91k_static=battery,
        divider_windows=windows, counterexamples=counterexamples,
        candidate_TPS3823_33=dict(falling_threshold_min_V=2.86,
            falling_threshold_max_V=3.00, release_hysteresis_typ_V=.030,
            release_delay_ms=[120, 200, 300], assertion_delay_typ_us=25,
            assertion_delay_guaranteed_max_us=None,
            source='TI SLVS165O, -40..85C electrical limits; timing test at 25C',
            exact_Iran_listing='https://lionelectronic.ir/products/5418-TPS3823-33DBVR',
            listing_stock_observed_2026_10_06=1300, selected=False),
        standby=dict(battery_FB_divider_nom_uA=battery['nom_V']/601000*1e6,
            TPS631000_VOUT_IQ_typ_uA=8., TPS631000_VIN_IQ_typ_uA=.15,
            warning='Different pin currents and test conditions; NOT pack-current guarantee.'),
        energy_cases=energy, source_cases=source,
        exclusions=['No actual mux gap or backup recovery is qualified.',
            '2.72V is an illustrative 20mV allowance above SD rail 2.7V, not a qualified switch drop.',
            '31.2us = 25us typical supervisor plus 6.2us typical mux; not maximum.',
            '75/200us are declared total-gap sensitivities, not manufacturer limits.',
            'Energy excludes ESR, wiring, RCB sequencing and real load profile.',
            'Regulator static corners exclude ripple, load transients and FB leakage.',
            'RON table is tested at 200mA; its use at other currents here is a scenario.',
            '19 mA old prototype observation; 280 mA historical design envelope.',
            'A sustained low selected source cannot be fixed with finite hold-up capacitance.'])
    (out/'architecture_screen.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(USB=usb, battery=battery, windows=len(windows),
        energy_cases=len(energy), source_cases=len(source),
        window_2p7V_0p5pct=windows[2], counterexamples=counterexamples),indent=2))


if __name__ == '__main__':
    main()
