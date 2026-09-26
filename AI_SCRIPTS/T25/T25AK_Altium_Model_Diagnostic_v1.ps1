# T25AK v1: isolate Altium outer-deck, TI .LIB loading, and TI parser/runtime.
# PS 5.1, ASCII source. No CAD/BOM modification, no simulator invoked here.
$ErrorActionPreference = 'Stop'
$expectedZip = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = Join-Path $documents "Datalogger_T25AK_Altium_Diagnostic_v1_$stamp"

function Save-Deck([string]$name, [string]$body) {
    $target = Join-Path $outDir $name
    [IO.File]::WriteAllText($target, ($body -replace "`r?`n", "`r`n"), [Text.Encoding]::ASCII)
}

try {
    $prior = @(Get-ChildItem -LiteralPath $documents -Directory -Filter 'Datalogger_T25AI_Altium_v1_*' |
        Sort-Object LastWriteTime -Descending | Where-Object {
            (Test-Path -LiteralPath (Join-Path $_.FullName '02_TPS2116_USB_UNPLUG_BAT_1p8.nsx') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $_.FullName 'SLVMDI4A.ZIP') -PathType Leaf)
        })
    if ($prior.Count -eq 0) { throw 'No prior complete T25AI folder in Documents; please do not use the historical T23 ZIP.' }
    $sourceDir = $prior[0].FullName
    $zip = Join-Path $sourceDir 'SLVMDI4A.ZIP'
    $model = Join-Path $sourceDir 'vendor\TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
    $sourceDeck = Join-Path $sourceDir '02_TPS2116_USB_UNPLUG_BAT_1p8.nsx'
    $found = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($found -ne $expectedZip) { throw "TI official ZIP SHA256 changed: $found" }
    if (-not (Test-Path -LiteralPath $model -PathType Leaf)) { throw 'TI extracted model missing' }
    $modelText = Get-Content -LiteralPath $model -Raw -Encoding UTF8
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'TI interface changed; stop before pin-map assumptions.'
    }
    foreach ($line in ($modelText -split "`r?`n")) {
        if ($line -match '[^\x00-\x7F]' -and -not $line.TrimStart().StartsWith('*')) {
            throw 'Non-ASCII character in active model code; cannot safely create Altium ANSI netlist.'
        }
    }
    # The official ZIP has a non-ASCII dash in a comment only. ASCII substitution
    # keeps all electrical model statements untouched and Altium's ANSI encoding.
    $modelAscii = [regex]::Replace($modelText, '[^\x00-\x7F]', '?').TrimEnd([char[]]@("`r", "`n"))
    $deck = Get-Content -LiteralPath $sourceDeck -Raw -Encoding Ascii
    $include = [regex]::Match($deck, '(?m)^\.LIB\s+"[^\r\n]+"\s*\r?$')
    if (-not $include.Success -or $deck -notmatch '(?m)^\.TRAN 2u 20m 0 2u\s*$' -or
        $deck -notmatch '(?m)^\.PRINT TRAN .* I\(V_BAT\)\s*$' -or
        $deck -notmatch '(?m)^X_PMUX 0 USB_VBUS_PROT PMUX_PR1 PMUX_ST USB_VBUS_PROT BAT_SW VIN_MUX VIN_MUX TPS2116_TRANS\s*$') {
        throw 'Prior T25AI deck differs from the audited v1; refusing ambiguous rewrite.'
    }
    $deck = $deck.Replace(' I(V_BAT)', '')
    $deck = $deck.Replace('.TRAN 2u 20m 0 2u', '.TRAN 1u 200u 0 1u')
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    $dummy = @'
* FAKE subcircuit ONLY for simulator syntax test. Never represents TPS2116.
.SUBCKT TPS2116_TRANS GND MODE PR1 ST VIN1 VIN2 VOUT_0 VOUT_1
R_FAKE_USB_ONLY VIN1 VOUT_0 50m
.ENDS TPS2116_TRANS
'@
    Save-Deck '03_OUTER_SYNTAX_FAKE_DEVICE.nsx' $deck.Replace($include.Value, $dummy.TrimEnd([char[]]@("`r", "`n")))
    Save-Deck '04_TI_LIB_PATH_VOLTAGE_ONLY.nsx' $deck
    Save-Deck '05_TI_MODEL_INLINE_VOLTAGE_ONLY.nsx' $deck.Replace($include.Value, $modelAscii)

    $readme = @'
T25AK v1 - diagnostics, NOT validation of real TPS2116 behavior.
Source: latest T25AI 1.8V deck in Documents and verified original TI ZIP.
All cases end at 200us, BEFORE USB disconnect at 1ms.
Battery source-current output I(V_BAT) removed in ALL three controls.

Run in Altium as standalone .nsx (activate tab, Simulate > Run Simulation):
03: fake resistor-only subcircuit; tests OUTER netlist, no TI model.
    This file can NEVER prove battery selection or hardware function.
04: same netlist with external TI .LIB path; tests model link and parser.
05: same netlist with TI model INLINE; tests link/path separately.

First run 03; if it works, run 04. Run 05 only if 04 does not work.
For the first failure, save Altium Messages/error text, current active tab,
and whether an .sdf was generated. If 04 works, report it; previous 20ms
fixture may have had a current-probe or runtime problem, still unqualified.
No RC/3V3/transfer/no-reset/factory release can be certified from these.
'@
    Save-Deck 'READ_ME_FIRST.txt' $readme
    $manifest = @(
        'T25AK v1 / prepared only; Altium NOT run by this script',
        "SOURCE_T25AI_FOLDER=$sourceDir",
        "TI_ARCHIVE_SHA256=$found",
        'ORIGINAL_POWER_SCHDOC_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1',
        'ALL diagnostic .TRAN files: 200us pilot, prior event at 1ms not reached',
        'FAKE model: syntax diagnostic only; no valid transfer behavior'
    ) -join "`r`n"
    Save-Deck 'SOURCE_AND_LIMITS.txt' $manifest
    Write-Host "T25AK PREPARED (no Altium run): $outDir"
    Write-Host 'Open 03_OUTER_SYNTAX_FAKE_DEVICE.nsx in Altium, then Simulate > Run Simulation.'
} catch {
    Write-Error "T25AK PREPARATION FAILED: $($_.Exception.Message)"
    exit 1
}
