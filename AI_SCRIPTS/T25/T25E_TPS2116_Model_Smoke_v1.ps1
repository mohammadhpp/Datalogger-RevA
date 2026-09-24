# T25E v1: isolated TI TPS2116 transient-model runtime smoke, no Altium edits.
# The TI sample documents VIN1=3.3 V, VIN2=5 V, IOUT=1 A, and 7 ms duration.
# The resistive 3.3-ohm load is an explicit test fixture (1 A at 3.3 V),
# not an assertion about the Datalogger load or the original TI netlist.
$ErrorActionPreference = 'Stop'
$expectedHash = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$documents = [Environment]::GetFolderPath('MyDocuments')
$work = Join-Path $documents "Datalogger_T25E_v1_$stamp"
New-Item -ItemType Directory -Path $work -Force | Out-Null
$archive = Join-Path $work 'SLVMDI4A.ZIP'
$deckPath = Join-Path $work 'T25E_TPS2116_Smoke.cir'
$outPath = Join-Path $work 'T25E_TPS2116_Smoke.out'
$datPath = Join-Path $work 'T25E_TPS2116_Smoke.dat'
$reportPath = Join-Path $work 'T25E_v1_Result.txt'
$consolePath = Join-Path $work 'PSpice_Console.txt'
$stderrPath = Join-Path $work 'PSpice_Stderr.txt'
$limitSeconds = 180
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$exitCode = $null

function Write-Result([string]$status, [string]$detail) {
    @(
        'T25E VERSION: v1',
        "T25E STATUS: $status",
        "TIME: $(Get-Date -Format o)",
        "WORKDIR: $work",
        "PSPICE: $psp",
        "PROCESS EXIT: $(if ($null -eq $exitCode) { 'unavailable' } else { $exitCode })",
        "DETAIL: $detail",
        'SCOPE: isolated TPS2116 PSpice model runtime; NOT board source-transfer or 3V3_SYS validation.',
        "SOURCE: official TI SLVMDI4 archive, ZIP SHA256 $expectedHash."
    ) | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Write-Host "`n$status : $detail"
    Write-Host "Result ZIP will be written in: $documents"
}

Write-Host 'T25E v1: TPS2116 isolated PSpice smoke. A fresh ZIP will be printed on completion.'
try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw "PSpice CLI not found at the user-observed path $psp. No simulation was run."
    }
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $verified = $null
    foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDI4*.zip' -File -ErrorAction SilentlyContinue)) {
        if ((Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash.ToUpperInvariant() -eq $expectedHash) {
            $verified = $candidate.FullName
            break
        }
    }
    if ($verified) {
        Copy-Item -LiteralPath $verified -Destination $archive
    } else {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDI4' -OutFile $archive -UseBasicParsing
        } catch {
            throw 'TI download failed. Put official SLVMDI4A.ZIP in Windows Downloads and rerun this v1 CMD.'
        }
    }
    $actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "TI archive hash mismatch: $actualHash; model was not executed."
    }
    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $archive -DestinationPath $vendor
    $model = Join-Path $vendor 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
    if (-not (Test-Path -LiteralPath $model -PathType Leaf)) {
        throw 'Verified vendor ZIP does not contain TPS2116_TRANS.LIB in its audited path.'
    }
    $modelText = Get-Content -LiteralPath $model -Raw
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'Vendor .SUBCKT pin order differs from the audited TPS2116 pin mapping.'
    }

    # Position: 1 GND, 2 MODE (physical 5), 3 PR1 (physical 4),
    # 4 ST (physical 8), 5 VIN1 (physical 3), 6 VIN2 (physical 6),
    # 7 VOUT_0 (physical 2), 8 VOUT_1 (physical 7).
    # MODE=VIN1 and PR1 30k/10k match 01_POWER.SchDoc. ST normally pulls
    # up to 3V3_SYS on the board; this isolated bench supplies 3.3 V instead.
    # VIN1/2 are TI-example levels, NOT the actual USB/battery waveforms.
    $deck = @'
T25E TPS2116 isolated vendor-model runtime smoke - not board qualification
* TI sample levels: VIN1=3.3V, VIN2=5V, target 1A at 3.3V.
* Fixture RLOAD=3.3ohm by Ohm's law; not a measured Datalogger load.
.LIB "@MODEL@"
V_TI_VIN1 VIN1 0 3.3
V_TI_VIN2 VIN2 0 5
R_PR1_TOP VIN1 PR1 30k
R_PR1_BOTTOM PR1 0 10k
V_ST_BENCH ST_SUPPLY 0 3.3
R_ST ST_SUPPLY ST 10k
X_U_PMUX 0 VIN1 PR1 ST VIN1 VIN2 VOUT VOUT TPS2116_TRANS
C_MUX_IN VOUT 0 22u
R_TI_FIXTURE_LOAD VOUT 0 3.3
.TRAN 0 7m 0 10u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN1]) V([VIN2]) V([VOUT]) V([PR1]) V([ST])
.PRINT TRAN V([VIN1]) V([VIN2]) V([VOUT]) V([PR1]) V([ST])
.END
'@
    $deck.Replace('@MODEL@', $model) | Set-Content -LiteralPath $deckPath -Encoding Ascii
    Write-Host "T25E v1: PSpice 7 ms TI-sample-duration transient, process capped at $limitSeconds seconds."
    $quotedDeck = '"' + $deckPath + '"'
    $proc = Start-Process -FilePath $psp -ArgumentList @('-r', $quotedDeck) -WorkingDirectory $work -RedirectStandardOutput $consolePath -RedirectStandardError $stderrPath -PassThru -NoNewWindow
    $clock = [Diagnostics.Stopwatch]::StartNew()
    while (-not $proc.WaitForExit(10000)) {
        $elapsed = [int]$clock.Elapsed.TotalSeconds
        Write-Host "PSpice still running: $elapsed / $limitSeconds seconds"
        if ($elapsed -ge $limitSeconds) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            $proc.WaitForExit(10000) | Out-Null
            throw "TIME_LIMIT_EXCEEDED at $elapsed seconds; no model runtime PASS."
        }
    }
    $exitCode = $proc.ExitCode
    if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) {
        throw 'No simulator .out log; inspect PSpice_Console.txt and PSpice_Stderr.txt.'
    }
    $log = Get-Content -LiteralPath $outPath -Raw
    $failures = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)')
    $warnings = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
    $printedRows = [regex]::Matches($log, '(?m)^\s*[+-]?\d+\.\d+E[+-]\d+\s+[+-]?\d+\.\d+E[+-]\d+\s+[+-]?\d+\.\d+E[+-]\d+').Count
    $wavePresent = (Test-Path -LiteralPath $datPath -PathType Leaf) -and ((Get-Item -LiteralPath $datPath).Length -gt 128)
    if (($null -ne $exitCode -and $exitCode -ne 0) -or $failures.Count -gt 0 -or $warnings -gt 0 -or
        $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$' -or $log -notmatch '(?i)Total job time' -or
        $printedRows -lt 2 -or -not $wavePresent) {
        throw "Runtime evidence incomplete: exit=$exitCode, failures=$($failures.Count), warnings=$warnings, print rows=$printedRows, DAT=$wavePresent. Review .out."
    }
    Write-Result 'MODEL_RUNTIME_SMOKE_PASS' "PSpice concluded with $printedRows printed voltage rows, raw DAT, zero warnings/errors. Project transfer remains unverified."
} catch {
    Write-Result 'NO_PASS' $_.Exception.Message
} finally {
    $resultZip = Join-Path $documents "Datalogger_T25E_v1_Result_$stamp.zip"
    $files = @($reportPath, $consolePath, $stderrPath, $deckPath, $outPath) |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
    if ((Test-Path -LiteralPath $datPath -PathType Leaf) -and
        (Get-Item -LiteralPath $datPath).Length -le 24MB) { $files += $datPath }
    Compress-Archive -LiteralPath $files -DestinationPath $resultZip -Force
    Write-Host "Send this ZIP for review: $resultZip"
}
