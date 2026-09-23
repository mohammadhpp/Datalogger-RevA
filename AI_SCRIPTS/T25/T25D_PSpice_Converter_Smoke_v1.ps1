# T25D: isolated TPS631000 model/runtime smoke test for full Cadence PSpice.
# This script does not open or modify the Datalogger Altium project.
$ErrorActionPreference = 'Stop'
$expectedHash = 'F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "Datalogger_T25D_$stamp"
New-Item -ItemType Directory -Path $work -Force | Out-Null
$report = Join-Path $work 'T25D_Result.txt'
$zip = Join-Path $work 'SLVMDV2.ZIP'
$cir = Join-Path $work 'T25D_TPS631000_Smoke.cir'
$consoleLog = Join-Path $work 'PSpice_Console.txt'

function Write-Result([string]$status, [string]$detail) {
    @(
        "T25D STATUS: $status",
        "TIME: $(Get-Date -Format o)",
        "WORKDIR: $work",
        "PSPICE: $psp",
        "DETAIL: $detail",
        'SCOPE: TI model runtime smoke, not Datalogger startup/load-step qualification.',
        'SOURCE: SLVMDV2.ZIP SHA256 F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946.'
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    Write-Host "`n$status : $detail"
    Write-Host "Report: $report"
}

try {
    $candidates = @()
    if ($env:CDS_INST_DIR) {
        $candidates += (Join-Path $env:CDS_INST_DIR 'tools\pspice\psp_cmd.exe')
    }
    foreach ($base in @('C:\Cadence', 'C:\Program Files\Cadence')) {
        if (Test-Path -LiteralPath $base) {
            foreach ($installation in (Get-ChildItem -LiteralPath $base -Directory -ErrorAction SilentlyContinue)) {
                $candidates += (Join-Path $installation.FullName 'tools\pspice\psp_cmd.exe')
            }
        }
    }
    $pathCommand = Get-Command 'psp_cmd.exe' -ErrorAction SilentlyContinue
    if ($pathCommand) { $candidates += $pathCommand.Source }
    $psp = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $psp) {
        throw 'psp_cmd.exe not found in the Cadence installation. Capture CIS alone does not prove the simulator is installed; send the result file.'
    }

    # Prefer a verified official download already present in Downloads. If it
    # is absent, fetch it from TI. This avoids committing a vendor ZIP to Git.
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $previous = Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDV2*.zip' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($previous) {
        Copy-Item -LiteralPath $previous.FullName -Destination $zip
    } else {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDV2' -OutFile $zip -UseBasicParsing
        } catch {
            throw 'Automatic TI download failed. Download SLVMDV2.ZIP from https://www.ti.com/lit/zip/SLVMDV2 into Windows Downloads, then run this script again.'
        }
    }
    $actualHash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "TI ZIP SHA256 differs from audited archive: $actualHash. Stop and re-audit; do not run an unknown model."
    }
    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $zip -DestinationPath $vendor
    $root = Join-Path $vendor 'TPS631000_Encrypted'
    foreach ($file in @('TPS631000_SYMBOL.lib', 'generic_blocks.lib', 'dig_prim.lib', 'dig_io.lib')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $file))) {
            throw "Missing TI model dependency: $file"
        }
    }

    # Use the real project L, input/output C and feedback resistors. The 2.8 V
    # source and 3.3-ohm load are explicitly from TI's distributed sample,
    # only to establish model/runtime operation; NOT measured board conditions.
    $deck = @'
T25D TPS631000 model smoke - not an engineering PASS
* TI example stimulus: VIN=2.8V, RLOAD=3.3 ohm; project nominal passives only.
.LIB "@ROOT@\TPS631000_SYMBOL.lib"
.LIB "@ROOT@\generic_blocks.lib"
.LIB "@ROOT@\dig_prim.lib"
.LIB "@ROOT@\dig_io.lib"
V_TEST VIN 0 PWL(0 2.8 1u 2.8 0.1m 2.8 0.6m 2.8)
C_IN VIN 0 22u
L1 LX1 LX2 1u
C_OUT VOUT 0 47u
R_FB_TOP VOUT FB 510k
R_FB_BOTTOM FB 0 91k
R_TI_EXAMPLE_LOAD VOUT 0 3.3
X_U_SYS VOUT LX2 LX1 VIN VIN 0 0 FB TPS631000_STARTUP PARAMS: SS=0
.TRAN 0 0.6m 0 10n SKIPBP
.OPTIONS ADVCONV
.PROBE64 V(VIN) V(VOUT) V(FB)
.END
'@
    $deck.Replace('@ROOT@', $root) | Set-Content -LiteralPath $cir -Encoding Ascii

    Push-Location $work
    try {
        & $psp '-r' $cir *> $consoleLog
        $exit = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    $out = Join-Path $work 'T25D_TPS631000_Smoke.out'
    if (-not (Test-Path -LiteralPath $out)) {
        throw "PSpice did not write an .out log (process exit code: $exit). See PSpice_Console.txt."
    }
    $log = Get-Content -LiteralPath $out -Raw
    $errors = @([regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)'))
    $warningCount = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
    if ($exit -ne 0 -or $errors.Count -gt 0 -or $log -notmatch '(?i)Total job time') {
        throw "Simulation did not complete cleanly. Exit=$exit, failure markers=$($errors.Count), warnings=$warningCount. Read .out."
    }
    Write-Result 'MODEL_RUNTIME_SMOKE_PASS' "PSpice completed; warnings=$warningCount. This is NOT 3V3_SYS startup or load-step qualification."
} catch {
    Write-Result 'NO_PASS' $_.Exception.Message
} finally {
    $outputZip = Join-Path (Split-Path $work -Parent) "Datalogger_T25D_Result_$stamp.zip"
    $files = @($report, $consoleLog, $cir, (Join-Path $work 'T25D_TPS631000_Smoke.out')) |
        Where-Object { Test-Path -LiteralPath $_ }
    Compress-Archive -LiteralPath $files -DestinationPath $outputZip -Force
    Write-Host "Send this ZIP for review: $outputZip"
}
