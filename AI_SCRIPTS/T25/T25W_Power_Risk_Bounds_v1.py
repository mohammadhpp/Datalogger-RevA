#!/usr/bin/env python3
"""Source-bounded RevA arithmetic screens; never a board transient simulator."""
from argparse import ArgumentParser
from decimal import Decimal
import json

D = Decimal
VOUT = D('3.3')
DESIGN_LOAD = D('0.280')
P_DESIGN = VOUT * DESIGN_LOAD
AA_PACK_LOADED = D('1.80')
CONVERTER_STARTUP_MIN = D('1.65')
OVP_UPPER_STATIC_TRIP = D('5.915721')
OVP_LOWER_STATIC_TRIP = D('5.600692')
PMUX_ABS_MAX = D('6.0')
PMUX_RECOMMENDED_MAX = D('5.5')
C_OUT_MIN_UF = D('10.4')
C_IN_MIN_UF = D('4.2')
SD_CAP_NOM_UF = D('54.1')
OLED_CAP_NOM_UF = D('10.1')


def positive_or_none(value, name):
    if value is None:
        return None
    number = D(str(value))
    if not number.is_finite() or number <= 0:
        raise ValueError(name + ' must be a finite number greater than zero')
    return number


def main():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument('--efficiency', help='Verified converter efficiency (0 < eta <= 1); otherwise leave unknown.')
    parser.add_argument('--cout-effective-uf', help='Qualified worst-case effective C_OUT, not nameplate.')
    parser.add_argument('--cin-effective-uf', help='Qualified worst-case effective C_IN, not nameplate.')
    parser.add_argument('--aa-path-ohms', help='Qualified AA holder/fuse/switch/mux/copper series path resistance.')
    parser.add_argument('--usb-rise-v-per-ms', help='Measured input rise slew near OVP trip.')
    parser.add_argument('--ovp-delay-us', help='Measured delay from worst-case trip to effective downstream isolation.')
    args = parser.parse_args()
    eta = positive_or_none(args.efficiency, 'efficiency')
    if eta is not None and eta > 1:
        parser.error('efficiency cannot exceed 1')
    cout = positive_or_none(args.cout_effective_uf, 'cout-effective-uf')
    cin = positive_or_none(args.cin_effective_uf, 'cin-effective-uf')
    aa_r = positive_or_none(args.aa_path_ohms, 'aa-path-ohms')
    rise = positive_or_none(args.usb_rise_v_per_ms, 'usb-rise-v-per-ms')
    delay = positive_or_none(args.ovp_delay_us, 'ovp-delay-us')
    if aa_r is not None and eta is None:
        parser.error('--aa-path-ohms also requires a verified --efficiency')
    if (rise is None) != (delay is None):
        parser.error('--usb-rise-v-per-ms and --ovp-delay-us must be supplied together')

    aa_headroom = AA_PACK_LOADED - CONVERTER_STARTUP_MIN
    max_path_r_at_steady_design = aa_headroom * CONVERTER_STARTUP_MIN / P_DESIGN
    ovp_headroom_mv = (PMUX_ABS_MAX - OVP_UPPER_STATIC_TRIP) * 1000
    result = {
        'status': 'ARITHMETIC_SCENARIOS_ONLY_NO_BOARD_SIMULATION_PASS',
        'sources': {
            'schdoc_git_blob': 'da2d005712c47000eb8c16157eca464d3fee4fe1',
            'project_reports': ['T25V_RECOVERED_DESIGN_BASIS_AND_GAPS_FA', 'T25F_POWER_SOURCE_LOAD_REQUIREMENTS_MATRIX', 'T25S_CONSOLIDATED_POWER_TREE_DESIGN_REVIEW'],
            'datasheets': ['TI TPS2116 Rev A section 6.1/6.3', 'TI TPS631000 Rev C sections 1, 5.3, 6.3.2'],
        },
        'ovp_static': {
            'project_min_trip_v': str(OVP_LOWER_STATIC_TRIP),
            'project_max_trip_v': str(OVP_UPPER_STATIC_TRIP),
            'pmux_recommended_max_v': str(PMUX_RECOMMENDED_MAX),
            'pmux_absolute_max_v': str(PMUX_ABS_MAX),
            'min_trip_above_recommended_max_mv': str((OVP_LOWER_STATIC_TRIP - PMUX_RECOMMENDED_MAX) * 1000),
            'max_trip_above_recommended_max_mv': str((OVP_UPPER_STATIC_TRIP - PMUX_RECOMMENDED_MAX) * 1000),
            'static_abs_max_headroom_mv': str(ovp_headroom_mv),
            'dynamic_outcome': 'OPEN: trip threshold alone cannot bound USB_VBUS_PROT overshoot',
        },
        'aa_conditional_steady_design_load': {
            'loaded_pack_v': str(AA_PACK_LOADED),
            'converter_startup_min_v': str(CONVERTER_STARTUP_MIN),
            'available_series_drop_mv': str(aa_headroom * 1000),
            'design_output_power_w': str(P_DESIGN),
            'optimistic_path_resistance_ceiling_ohm_at_eta_1': str(max_path_r_at_steady_design),
            'actual_startup_result': 'OPEN: load/efficiency/time and series impedance during ramp unknown',
        },
        'capacitor_effective_minima': {
            'cout_uf_at_3v3': str(C_OUT_MIN_UF),
            'cin_uf_at_vin_mux': str(C_IN_MIN_UF),
            'actual_parts_compliance': 'OPEN: exact bias/temperature/aging values unavailable',
        },
        'switched_branch_nameplate_accounting': {
            'sd_nominal_uf': str(SD_CAP_NOM_UF),
            'oled_nominal_uf': str(OLED_CAP_NOM_UF),
            'combined_nominal_charge_uc_if_disconnected_to_3v3': str((SD_CAP_NOM_UF + OLED_CAP_NOM_UF) * VOUT),
            'interpretation': 'Nominal charge identity only; not effective C, inrush, droop, converter response or measured SD/OLED current.',
        },
        'optional_scenarios': {},
    }
    optional = result['optional_scenarios']
    if eta is not None:
        r_limit = max_path_r_at_steady_design * eta
        optional['aa_at_supplied_efficiency'] = {
            'efficiency': str(eta),
            'conditional_series_r_max_ohm_at_1v65_and_280ma_out': str(r_limit),
            'observed_path_r_ohm': None if aa_r is None else str(aa_r),
            'steady_arithmetic_screen': 'INPUT_MISSING' if aa_r is None else ('BELOW_BOUND' if aa_r < r_limit else 'AT_OR_ABOVE_BOUND'),
            'note': 'Steady full-output loading at 1.65 V; never a converter cold-start PASS.',
        }
    if cout is not None or cin is not None:
        optional['qualified_capacitances'] = {
            'cout_effective_uf': None if cout is None else str(cout),
            'cout_minimum_screen': 'INPUT_MISSING' if cout is None else ('MEETS_MIN' if cout >= C_OUT_MIN_UF else 'BELOW_MIN'),
            'cin_effective_uf': None if cin is None else str(cin),
            'cin_minimum_screen': 'INPUT_MISSING' if cin is None else ('MEETS_MIN' if cin >= C_IN_MIN_UF else 'BELOW_MIN'),
            'note': 'Only a vendor/measurement-qualified worst-case effective C is admissible; no automatic rail PASS.',
        }
    if rise is not None and delay is not None:
        hypothetical = OVP_UPPER_STATIC_TRIP + rise * delay / D('1000')
        optional['usb_idealized_ramp'] = {
            'rise_v_per_ms': str(rise), 'isolation_delay_us': str(delay),
            'hypothetical_input_voltage_at_isolation_v': str(hypothetical),
            'static_plus_rise_vs_abs_max': 'EXCEEDS' if hypothetical >= PMUX_ABS_MAX else 'BELOW',
            'note': 'Pure VIN slew×delay sensitivity. USB_VBUS_PROT may differ due to OVP MOSFET, gate, capacitor and load; never an OVP PASS.',
        }
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
