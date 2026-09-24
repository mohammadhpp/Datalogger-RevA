# T25G v1: isolated priority-mode switching fixture for the TI TPS2116 model.
# No board-level source, battery ESR, USB OVP, converter, or real device load.
# The chosen source ramp and 330-ohm load are explicit fixtures, not Datalogger data.
$ErrorActionPreference = 'Stop'
$expectedHash = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$documents = [Environment]::GetFolderPath('MyDocuments')
$work = Join-Path $documents "Datalogger_T25G_v1_$stamp"
New-Item -ItemType Directory -Path $work -Force | Out-Null
$archive = Join-Path $work 'SLVMDI4A.ZIP'
$deckPath = Join-Path $work 'T25G_Priority_Fixture.cir'
$outPath = Join-Path $work 'T25G_Priority_Fixture.out'
$datPath = Join-Path $work 'T25G_Priority_Fixture.dat'
$reportPath = Join-Path $work 'T25G_v1_Result.txt'
$consolePath = Join-Path $work 'PSpice_Console.txt'
$stderrPath = Join-Path $work 'PSpice_Stderr.txt'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$limitSeconds = 180
$exitCode = $null

function Write-Result([string]$status, [string]$detail) {
    @(
        'T25G VERSION: v1',
        "T25G STATUS: $status",
        "TIME: $(Get-Date -Format o)",
        "WORKDIR: $work",
        "PSPICE: $psp",
        "PROCESS EXIT: $(if ($null -eq $exitCode) { 'unavailable' } else { $exitCode })",
        "DETAIL: $detail",
        'SCOPE: isolated TPS2116 priority fixture; no Datalogger transfer or 3V3 rail qualification.',
        "MODEL SOURCE SHA256: $expectedHash"
    ) | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Write-Host "`n$status : $detail"
}

Write-Host 'T25G v1: isolated TPS2116 priority fixture, PSpice bounded to three minutes.'
try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw "PSpice CLI not found at $psp. No simulation was run."
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
            throw 'TI download failed. Put official SLVMDI4A.ZIP in Windows Downloads and rerun the v1 CMD.'
        }
    }
    $actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "Official model archive hash mismatch: $actualHash. No model was executed."
    }
    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $archive -DestinationPath $vendor
    $model = Join-Path $vendor 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
    if (-not (Test-Path -LiteralPath $model -PathType Leaf)) { throw 'TPS2116_TRANS.LIB missing in audited path.' }
    $modelText = Get-Content -LiteralPath $model -Raw
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'Official TPS2116 subcircuit pin order differs from audited interface.'
    }

    # TI VREF typical 1.0 V and schematic PR1 divider 30k / 10k put the
    # static typical VIN1 boundary at 4.0 V. The explicit 5->3.3->5 V PWL
    # crosses this boundary; the 3 V VIN2 is a declared fixture supply.
    # Both VOUT interface pins join the board's VIN_MUX. ST on the board
    # pulls to downstream 3V3_SYS; isolated ST_SUPPLY substitutes for it.
    $deck = @'
T25G TPS2116 priority fixture - NOT a Datalogger board transient
* Fixture VIN1 PWL 5->3.3->5 V; VIN2 3 V; 330 ohm test load only.
* Project MODE=VIN1, PR1=30k/10k, ST=10k but surrogate ST_SUPPLY=3.3 V.
.LIB "@MODEL@"
V_USB_FIXTURE VIN1 0 PWL(0 5 1m 5 2m 3.3 4m 3.3 5m 5 8m 5)
V_BAT_FIXTURE VIN2 0 3
R_PR1_TOP VIN1 PR1 30k
R_PR1_BOTTOM PR1 0 10k
V_ST_BENCH ST_SUPPLY 0 3.3
R_ST ST_SUPPLY ST 10k
X_U_PMUX 0 VIN1 PR1 ST VIN1 VIN2 VOUT VOUT TPS2116_TRANS
C_MUX_IN VOUT 0 22u
R_SMALL_FIXTURE_LOAD VOUT 0 330
.TRAN 0 8m 0 10u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN1]) V([VIN2]) V([PR1]) V([VOUT]) V([ST])
.PRINT TRAN V([VIN1]) V([VIN2]) V([PR1]) V([VOUT]) V([ST])
.END
'@
    $deck.Replace('@MODEL@', $model) | Set-Content -LiteralPath $deckPath -Encoding Ascii
    $quotedDeck = '"' + $deckPath + '"'
    $proc = Start-Process -FilePath $psp -ArgumentList @('-r', $quotedDeck) -WorkingDirectory $work -RedirectStandardOutput $consolePath -RedirectStandardError $stderrPath -PassThru -NoNewWindow
    $clock = [Diagnostics.Stopwatch]::StartNew()
    while (-not $proc.WaitForExit(10000)) {
        $elapsed = [int]$clock.Elapsed.TotalSeconds
        Write-Host "PSpice still running: $elapsed / $limitSeconds seconds"
        if ($elapsed -ge $limitSeconds) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            $proc.WaitForExit(10000) | Out-Null
            throw "TIME_LIMIT_EXCEEDED at $elapsed seconds; no fixture PASS."
        }
    }
    $exitCode = $proc.ExitCode
    if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) {
        throw 'No simulator .out log; see console and stderr files.'
    }
    $log = Get-Content -LiteralPath $outPath -Raw
    $failures = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)')
    $warnings = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
    $printedRows = [regex]::Matches($log, '(?m)^\s*[+-]?\d+\.\d+E[+-]\d+\s+[+-]?\d+\.\d+E[+-]\d+\s+[+-]?\d+\.\d+E[+-]\d+').Count
    $wavePresent = (Test-Path -LiteralPath $datPath -PathType Leaf) -and ((Get-Item -LiteralPath $datPath).Length -gt 128)
    if (($null -ne $exitCode -and $exitCode -ne 0) -or $failures.Count -gt 0 -or $warnings -gt 0 -or
        $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$' -or $log -notmatch '(?i)Total job time' -or
        $printedRows -lt 3 -or -not $wavePresent) {
        throw "Runtime evidence incomplete: exit=$exitCode, failures=$($failures.Count), warnings=$warnings, print rows=$printedRows, DAT=$wavePresent. Review .out."
    }
    Write-Result 'FIXTURE_TRACE_CAPTURE_PASS' "PSpice completed; $printedRows printed rows, raw DAT, zero errors/warnings. Source-selection behavior needs independent waveform review."
} catch {
    Write-Result 'NO_PASS' $_.Exception.Message
} finally {
    $resultZip = Join-Path $documents "Datalogger_T25G_v1_Result_$stamp.zip"
    $files = @($reportPath, $consolePath, $stderrPath, $deckPath, $outPath) |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
    if ((Test-Path -LiteralPath $datPath -PathType Leaf) -and
        (Get-Item -LiteralPath $datPath).Length -le 24MB) { $files += $datPath }
    Compress-Archive -LiteralPath $files -DestinationPath $resultZip -Force
    Write-Host "Send this ZIP for review: $resultZip"
}
