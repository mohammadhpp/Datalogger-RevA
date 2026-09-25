#!/usr/bin/env python3
"""Read-only continuity guard for Datalogger RevA Git checkout (Python stdlib)."""
import argparse
import json
from pathlib import Path
import sys

REQUIRED = [
    'AI_START_HERE.md',
    'AI_CONTINUITY/CURRENT_HANDOFF.md',
    'AI_CONTINUITY/DECISIONS_AND_CONSTRAINTS.md',
    'AI_CONTINUITY/LESSONS_LEARNED.md',
    'AI_CONTINUITY/HISTORY.md',
    'AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md',
    'AI_CONTINUITY/UPDATE_PROTOCOL.md',
    'AI_CONTINUITY/T25V_RECOVERED_DESIGN_BASIS_AND_GAPS_FA.md',
    'AI_CONTINUITY/T25V_RECOVERED_BLOCK_DOCUMENT_TEXT.md',
    'AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json',
    'AI_CONTINUITY/SOURCE_ARCHIVE_REGISTRY_2026-09-25.json',
    'DATALOGER_RevA.PcbDoc',
    'Datalogger_RevA_Clean.PcbLib',
] + [f'{n:02d}_{name}.SchDoc' for n,name in enumerate((
    'POWER','MCU_CORE','MICROSD','NAVIGATION','RTC','OLED_SHT3X','EXPANSION'),1)]


def main():
    ap = argparse.ArgumentParser(description='Check continuity/source evidence; does not change files or upload archives.')
    ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[2])
    args=ap.parse_args();root=args.root;failures=[]
    for relative in REQUIRED:
        if not (root/relative).is_file():failures.append('MISSING '+relative)
    if failures:
        for message in failures: print('FAIL:',message)
        return 2
    start=(root/'AI_START_HERE.md').read_text(encoding='utf-8-sig')
    hand=(root/'AI_CONTINUITY/CURRENT_HANDOFF.md').read_text(encoding='utf-8-sig')
    reg=json.loads((root/'AI_CONTINUITY/SOURCE_ARCHIVE_REGISTRY_2026-09-25.json').read_text(encoding='utf-8-sig'))
    bom=json.loads((root/'AI_CONTINUITY/T25V_PURCHASE_BOM_V017_CELL_EXPORT.json').read_text(encoding='utf-8-sig'))
    if 'SOURCE_ARCHIVE_REGISTRY_2026-09-25.json' not in start: failures.append('AI_START_HERE does not link the source registry')
    if hand.count('## CURRENT EXACT POINT')!=1:failures.append('CURRENT_HANDOFF must have exactly one live CURRENT EXACT POINT')
    if len(hand)>20000:failures.append('CURRENT_HANDOFF exceeds 20k characters and risks truncation')
    if not ('19 mA' in hand and '280 mA' in hand):failures.append('CURRENT_HANDOFF lacks corrected 19mA sample / 280mA design provenance')
    if len(reg.get('archive_assets',[]))!=3:failures.append('Expected T22, T23 and curated archive records')
    else:
        assets=reg['archive_assets']
        if assets[0].get('sha256')!='22502ef489575150f849f394d5db9e67546c592243e48c0e49deb7ff9983a96b':failures.append('T22 full backup hash changed')
        if assets[1].get('sha256')!='1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea':failures.append('T23 stage backup hash changed')
        if any(a.get('git_full_payload_status')!='NOT_TRACKED' for a in assets):failures.append('Registry incorrectly claims full archive is in GitHub; verify actual blobs before changing status')
        if sum(a['path'].lower().endswith('.pdf') for a in assets[0]['members'])!=30:failures.append('T22 PDF entry count drift')
    if len(bom.get('sheets',{}))!=14:failures.append('Historical purchase BOM must contain 14 sheets')
    rows=bom.get('sheets',{}).get('Power Calculations',[])
    cell=next((row['B6']['value'] for row in rows if 'B6' in row),None)
    if cell!=0.28:failures.append(f'Power Calculations B6 expected 0.28 A; got {cell!r}')
    if failures:
        for message in failures:print('FAIL:',message)
        return 2
    print('PASS: source registry, full-backup hashes, 14-tab 280mA BOM, one live handoff and current design file presence.')
    print('ARCHIVES: full binary ZIPs are NOT in GitHub; do not delete the only original on this basis.')
    return 0

if __name__=='__main__':sys.exit(main())
