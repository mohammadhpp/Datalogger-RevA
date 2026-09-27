#!/usr/bin/env python3
"""Read-only continuity guard for Datalogger RevA Git checkout (Python stdlib)."""
import argparse
import json
import os
from pathlib import Path
import sys
from urllib.request import Request, urlopen

REQUIRED = [
    'AI_START_HERE.md',
    'AI_CONTINUITY/CURRENT_HANDOFF.md',
    'AI_CONTINUITY/DECISIONS_AND_CONSTRAINTS.md',
    'AI_CONTINUITY/LESSONS_LEARNED.md',
    'AI_CONTINUITY/HISTORY.md',
    'AI_CONTINUITY/CHAT_MANAGEMENT_RULE.md',
    'AI_CONTINUITY/UPDATE_PROTOCOL.md',
    'AI_CONTINUITY/T25_EXECUTION_TO_RESULT_RULE_FA.md',
    'AI_CONTINUITY/T25V_RECOVERED_DESIGN_BASIS_AND_GAPS_FA.md',
    'AI_CONTINUITY/T25W_PRE_FAB_POWER_RISK_BOUNDS_FA.md',
    'AI_SCRIPTS/T25/T25W_Power_Risk_Bounds_v1.py',
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
    ap.add_argument('--verify-release', action='store_true', help='Query the private GitHub Release API and compare all three asset sizes and digests (requires GITHUB_TOKEN).')
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
    if 'T25_EXECUTION_TO_RESULT_RULE_FA.md' not in start:failures.append('AI_START_HERE does not link the T25 execution rule')
    for marker in ('**NEXT EXECUTABLE ACTION:**','**BLOCKER REQUIRING USER:**'):
        if marker not in hand:failures.append('CURRENT_HANDOFF lacks explicit execution dependency: '+marker)
    if len(hand)>20000:failures.append('CURRENT_HANDOFF exceeds 20k characters and risks truncation')
    if not ('19 mA' in hand and '280 mA' in hand):failures.append('CURRENT_HANDOFF lacks corrected 19mA sample / 280mA design provenance')
    if len(reg.get('archive_assets',[]))!=3:failures.append('Expected T22, T23 and curated archive records')
    else:
        assets=reg['archive_assets']
        if assets[0].get('sha256')!='22502ef489575150f849f394d5db9e67546c592243e48c0e49deb7ff9983a96b':failures.append('T22 full backup hash changed')
        if assets[1].get('sha256')!='1576ed0e29aa6f59926ab778dca46ab8aef43207b080da867b8cb1cce2c6cdea':failures.append('T23 stage backup hash changed')
        if any(a.get('git_full_payload_status')!='NOT_TRACKED' for a in assets):failures.append('Registry incorrectly claims full archive binaries are tracked in Git main')
        release=reg.get('github_release',{})
        expected_tag='continuity-archives-2026-09-25'
        if release.get('tag')!=expected_tag:failures.append('Historical GitHub Release tag missing or changed')
        for asset in assets:
            entry=asset.get('github_release_asset',{})
            reported=entry.get('user_windows_restore_check',{})
            if reported.get('sha256_matches_registry') is not True or reported.get('opened') is not True:failures.append('User-confirmed restored ZIP hash/opening record missing: '+asset['label'])
            if entry.get('state')!='uploaded':failures.append('Release asset upload status missing: '+asset['label'])
            if entry.get('size_bytes')!=asset.get('bytes'):failures.append('Release asset size mismatches original: '+asset['label'])
            if entry.get('github_computed_digest')!='sha256:'+asset['sha256']:failures.append('Release asset digest mismatches original: '+asset['label'])
            url=entry.get('download_url','')
            if not url.startswith('https://github.com/mohammadhpp/Datalogger-RevA/releases/download/'+expected_tag+'/') or not url.endswith('/'+entry.get('file_name','')):failures.append('Release URL/tag mismatch: '+asset['label'])
        if sum(a['path'].lower().endswith('.pdf') for a in assets[0]['members'])!=30:failures.append('T22 PDF entry count drift')
    if len(bom.get('sheets',{}))!=14:failures.append('Historical purchase BOM must contain 14 sheets')
    rows=bom.get('sheets',{}).get('Power Calculations',[])
    cell=next((row['B6']['value'] for row in rows if 'B6' in row),None)
    if cell!=0.28:failures.append(f'Power Calculations B6 expected 0.28 A; got {cell!r}')
    if args.verify_release and not failures:
        token=os.environ.get('GITHUB_TOKEN')
        if not token:
            failures.append('GITHUB_TOKEN needed to inspect the private GitHub Release')
        else:
            tag=reg['github_release']['tag']
            url='https://api.github.com/repos/mohammadhpp/Datalogger-RevA/releases/tags/'+tag
            req=Request(url, headers={'Accept':'application/vnd.github+json', 'Authorization':'Bearer '+token, 'User-Agent':'Datalogger-RevA-continuity-guard', 'X-GitHub-Api-Version':'2022-11-28'})
            try:
                with urlopen(req, timeout=30) as response:
                    live=json.load(response)
                if live.get('draft') or not live.get('prerelease'):
                    failures.append('Historical backup Release is no longer published as a pre-release')
                online={a['name']:a for a in live.get('assets',[])}
                for asset in reg['archive_assets']:
                    expected=asset['github_release_asset']
                    found=online.get(expected['file_name'])
                    if not found:
                        failures.append('Missing GitHub Release asset: '+expected['file_name'])
                    elif (found.get('state')!='uploaded' or found.get('size')!=asset['bytes']
                          or found.get('digest')!='sha256:'+asset['sha256']):
                        failures.append('GitHub Release asset size/digest mismatch: '+expected['file_name'])
            except Exception as exc:
                failures.append('Could not verify private GitHub Release: '+str(exc))
    if failures:
        for message in failures:print('FAIL:',message)
        return 2
    print('PASS: source registry, full-backup hashes, 14-tab 280mA BOM, one live handoff and current design file presence.')
    print('ARCHIVES: three full ZIPs are absent from Git main; '+('live GitHub Release asset metadata confirmed.' if args.verify_release else 'Release assets are indexed; remote not queried.')+' This check does not download/extract ZIP contents.')
    return 0

if __name__=='__main__':sys.exit(main())
