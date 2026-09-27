# T25AM v1: two controlled Altium operating-point diagnostics.
# Windows PowerShell 5.1; ASCII deck; no CAD/BOM changes or Altium invocation.
$ErrorActionPreference = 'Stop'
$expectedZip = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$documents = [Environment]::GetFolderPath('MyDocuments')
$outDir = Join-Path $documents ("Datalogger_T25AM_Altium_OP_v1_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))

function Save-Text([string]$name, [string]$body) {
    [IO.File]::WriteAllText((Join-Path $outDir $name), ($body -replace "`r?`n", "`r`n"), [Text.Encoding]::ASCII)
}

try {
    $prior = @(Get-ChildItem -LiteralPath $documents -Directory -Filter 'Datalogger_T25AI_Altium_v1_*' |
        Sort-Object LastWriteTime -Descending | Where-Object {
            (Test-Path -LiteralPath (Join-Path $_.FullName '02_TPS2116_USB_UNPLUG_BAT_1p8.nsx') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $_.FullName 'vendor\TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $_.FullName 'SLVMDI4A.ZIP') -PathType Leaf)
        })
    if ($prior.Count -lt 1) { throw 'Verified T25AI source folder not found in Documents.' }
    $sourceDir = $prior[0].FullName
    $zip = Join-Path $sourceDir 'SLVMDI4A.ZIP'
    $found = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($found -ne $expectedZip) { throw "Official TI archive SHA256 mismatch: $found" }
    $modelPath = Join-Path $sourceDir 'vendor\TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
    $modelText = Get-Content -LiteralPath $modelPath -Raw -Encoding UTF8
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'TI subcircuit pin interface differs from audited source.'
    }
    foreach ($line in ($modelText -split "`r?`n")) {
        if ($line -match '[^\x00-\x7F]' -and -not $line.TrimStart().StartsWith('*')) {
            throw 'Active TI model statement contains non-ASCII data.'
        }
    }
    $modelAscii = [regex]::Replace($modelText, '[^\x00-\x7F]', '?').TrimEnd([char[]]@("`r", "`n"))
    $original = Get-Content -LiteralPath (Join-Path $sourceDir '02_TPS2116_USB_UNPLUG_BAT_1p8.nsx') -Raw -Encoding Ascii
    $libRef = [regex]::Match($original, '(?m)^\.LIB\s+"[^\r\n]+"\s*\r?$')
    if (-not $libRef.Success -or $original -notmatch '(?m)^\.TRAN 2u 20m 0 2u\s*$' -or
        $original -notmatch '(?m)^\.PRINT TRAN .* I\(V_BAT\)\s*$' -or
        $original -notmatch '(?m)^V_CTRL CONTROL 0 PWL\(0 1 1m 1 1\.0001m 0 20m 0\)\s*$' -or
        $original -notmatch '(?m)^X_PMUX 0 USB_VBUS_PROT PMUX_PR1 PMUX_ST USB_VBUS_PROT BAT_SW VIN_MUX VIN_MUX TPS2116_TRANS\s*$') {
        throw 'T25AI source deck differs from audited v1; refusing rewrite.'
    }
    $base = $original.Replace($libRef.Value, $modelAscii).Replace(' I(V_BAT)', '')
    $base = $base.Replace('.TRAN 2u 20m 0 2u', '.TRAN 1u 200u 0 1u')
    $ctrl = 'V_CTRL CONTROL 0 PWL(0 1 1m 1 1.0001m 0 20m 0)'
    if (($base.Split([string[]]@($ctrl), [StringSplitOptions]::None).Count - 1) -ne 1) {
        throw 'Unexpected V_CTRL stimulus count.'
    }
    $dc = $base.Replace($ctrl, 'V_CTRL CONTROL 0 DC 1 PWL(0 1 1m 1 1.0001m 0 20m 0)')
    $zeroTC = '(?m)^(C_U1_C4[ \t]+VOUT_0[ \t]+U1_GATE_1[ \t]+130p|C_U7_C4[ \t]+VOUT_0[ \t]+U7_GATE_1[ \t]+130p)[ \t]+TC=0,0[ \t]*\r?$'
    if ([regex]::Matches($dc, $zeroTC).Count -ne 2) {
        throw 'Expected two zero-temperature-coefficient gate capacitors not found.'
    }
    # Only omit TC=0,0 from the two warned gate capacitors. No value/node changes.
    $nominal = [regex]::Replace($dc, $zeroTC, '$1')
    New-Item -Path $outDir -ItemType Directory -Force | Out-Null
    Save-Text '06_TI_INLINE_DC1_KEEP_TC.nsx' $dc
    Save-Text '07_TI_INLINE_DC1_ZERO_TC_REMOVED.nsx' $nominal
    $readme = @'
T25AM v1 - Altium operating-point diagnostic, NOT power transfer validation.
Built from SHA-verified original TI ZIP and existing audited T25AI 1.8V deck.
Both files have the genuine TI model inline. Both stop at 200us BEFORE unplug.
Only voltage probes; no physical no-reset or 3V3 behavior can be inferred.

Run 06 in Altium, then capture Messages AND check that V(VIN_MUX) has a
numeric 0..200us waveform. If 06 fails, run 07 and capture its Messages.
If 06 gives a normal waveform, do not run 07; report the result.

06 changes ONLY V_CTRL by adding an explicit DC 1 before the same PWL.
07 is 06 with only TWO original TI model TC=0,0 annotations removed
from C_U1_C4 and C_U7_C4. Those zero temperature coefficients were already
ignored by Altium. Removing them is an Altium compatibility DIAGNOSTIC,
not an approved vendor model modification or physical transfer proof.

Never call a new .sdf tab alone a PASS. If both fail, stop; do not attempt a
20ms transfer or bypass the operating point until errors are understood.
'@
    Save-Text 'READ_ME_FIRST.txt' $readme
    Save-Text 'SOURCE_AND_LIMITS.txt' ("TI_ARCHIVE_SHA256=$found`nSOURCE_T25AI_FOLDER=$sourceDir`nPOWER_SCHDOC_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1`nALTIUM_RUN=NOT_PERFORMED")
    Write-Host "T25AM PREPARED (Altium NOT run): $outDir"
    Write-Host 'Run 06 first and inspect Messages and the waveform, then 07 only if 06 fails.'
} catch {
    Write-Error "T25AM PREPARATION FAILED: $($_.Exception.Message)"
    exit 1
}
