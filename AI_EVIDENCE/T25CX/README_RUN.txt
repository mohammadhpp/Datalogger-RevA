T25CX pre-fab power handoff evidence gate

1. Run offline validator software unit tests:
   python T25CX_Trace_Qualification_v1.py --selftest --output T25CX_VALIDATOR_UNIT_TESTS.json
   python T25CX_Independent_Audit_v1.py

2. DO NOT use old TPS2116/TPS2121 invalid vendor-model data to claim system PASS.
3. Once a qualified full-current model or future instrumented hardware trace exists,
   use the CSV/metadata templates (first row gives exact probe names), and execute:
   python T25CX_Trace_Qualification_v1.py --trace qualified.csv --metadata qualified_meta.json --output verdict.json

VDD/NRST MCU, SD_VDD and SD writes must be witnessed independently.
"CONDITIONAL_SCREEN_PASS" never means hardware PASS.
Current board is mux-before-TPS631000; proposed dual-regulated inputs are UNAPPLIED.
This package does not modify Altium or order components. FABRICATION HOLD.
