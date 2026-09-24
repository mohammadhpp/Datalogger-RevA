# T25Q v2: a time-bounded feasibility gate, NOT a board startup certification.
# TI vendor model runs in a detached Documents fixture; Altium files untouched.
$ErrorActionPreference = 'Stop'
$shaExpected = 'F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$documents = [Environment]::GetFolderPath('MyDocuments')
$work = Join-Path $documents "Datalogger_T25Q_v2_$stamp"
New-Item -ItemType Directory -Path $work -Force | Out-Null
$result = Join-Path $work 'T25Q_v2_Result.txt'
$zipPath = Join-Path $documents "Datalogger_T25Q_v2_Result_$stamp.zip"
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$pilotUs = 10.0
$fullUs = 12000.0
$pilotLimitSeconds = 90
$fullLimitSeconds = 600
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('T25Q v2 - OFFICIAL TI TPS631000 MODEL, ISOLATED FIXTURE ONLY')
$lines.Add('No Datalogger board startup / SD / OLED / battery / USB verdict from this script.')
$lines.Add("TIME: $(Get-Date -Format o)")
$lines.Add("WORKDIR: $work")
$lines.Add("TI source SHA256: $shaExpected")
$lines.Add('Fixture: ideal constant VIN=2.8V, TI example RLOAD=3.3ohm, project NOMINAL CIN=22uF, COUT=47uF, L=1uH and FB=510k/91k.')
$lines.Add('Nominal CIN/COUT are NOT qualified biased effective capacitances.')

function Add-Result([string]$key, [string]$value) {
    $script:lines.Add("$key : $value")
    Write-Host "$key : $value"
}

function Build-Deck([string]$file, [string]$modelRoot, [string]$tranEnd, [string]$printStep) {
    $deck = @'
T25Q vendor TPS631000 isolated startup feasibility, not project qualification
* TI sample VIN=2.8V and RLOAD=3.3ohm; project NOMINAL passives only.
.LIB "@ROOT@\TPS631000_SYMBOL.lib"
.LIB "@ROOT@\generic_blocks.lib"
.LIB "@ROOT@\dig_prim.lib"
.LIB "@ROOT@\dig_io.lib"
V_TEST VIN 0 PWL(0 2.8 1u 2.8 0.1m 2.8 12m 2.8)
C_IN VIN 0 22u
L1 LX1 LX2 1u
C_OUT VOUT 0 47u
R_FB_TOP VOUT FB 510k
R_FB_BOTTOM FB 0 91k
R_TI_EXAMPLE_LOAD VOUT 0 3.3
X_U_SYS VOUT LX2 LX1 VIN VIN 0 0 FB TPS631000_STARTUP PARAMS: SS=0
.TRAN 0 @STOP@ 0 @STEP@ SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN]) V([VOUT]) V([FB])
.PRINT TRAN V([VIN]) V([VOUT]) V([FB])
.END
'@
    $deck.Replace('@ROOT@', $modelRoot).Replace('@STOP@', $tranEnd).Replace('@STEP@', $printStep) |
        Set-Content -LiteralPath $file -Encoding Ascii
}

function Run-Phase([string]$name, [double]$stopUs, [int]$limitSeconds) {
    $cir = Join-Path $work "$name.cir"
    $std = Join-Path $work "$name.console.txt"
    $err = Join-Path $work "$name.stderr.txt"
    $out = Join-Path $work "$name.out"
    $arg = '"' + $cir + '"'
    $proc = Start-Process -FilePath $psp -ArgumentList @('-r', $arg) -WorkingDirectory $work -RedirectStandardOutput $std -RedirectStandardError $err -PassThru -NoNewWindow
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $timedOut = $false
    while (-not $proc.WaitForExit(5000)) {
        Write-Host "$name running: $([int]$watch.Elapsed.TotalSeconds) / $limitSeconds seconds"
        if ($watch.Elapsed.TotalSeconds -ge $limitSeconds) {
            $timedOut = $true
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            $proc.WaitForExit(5000) | Out-Null
            break
        }
    }
    $watch.Stop()
    $seconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
    if ($timedOut) { return @{ Ok=$false; Seconds=$seconds; Detail='TIME_LIMIT_EXCEEDED' } }
    if (-not (Test-Path -LiteralPath $out -PathType Leaf)) {
        return @{ Ok=$false; Seconds=$seconds; Detail='NO_OUT_LOG' }
    }
    $log = Get-Content -LiteralPath $out -Raw
    $errorsFound = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
    $warningCount = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
    $completed = $log -match '(?i)JOB\s+CONCLUDED' -and $log -match '(?i)Total job time'
    $lastTimeUs = -1.0
    $lastVout = [double]::NaN
    foreach ($m in [regex]::Matches($log, '(?m)^\s*(?<t>\d+\.\d+E[+-]\d+)\s+(?<vin>[+-]?\d+\.\d+E[+-]\d+)\s+(?<vout>[+-]?\d+\.\d+E[+-]\d+)')) {
        $tUs = [double]::Parse($m.Groups['t'].Value, [Globalization.CultureInfo]::InvariantCulture) * 1e6
        if ($tUs -ge $lastTimeUs) {
            $lastTimeUs = $tUs
            $lastVout = [double]::Parse($m.Groups['vout'].Value, [Globalization.CultureInfo]::InvariantCulture)
        }
    }
    $badExit = $null -ne $proc.ExitCode -and $proc.ExitCode -ne 0
    $ok = $completed -and $errorsFound -eq 0 -and $warningCount -eq 0 -and
        -not $badExit -and $lastTimeUs -ge ($stopUs - 0.001)
    $detail = "concluded=$completed errors=$errorsFound warnings=$warningCount exit=$($proc.ExitCode) last_time_us=$lastTimeUs last_VOUT_V=$lastVout"
    return @{ Ok=$ok; Seconds=$seconds; Detail=$detail }
}

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        $found = Get-Command psp_cmd.exe -ErrorAction SilentlyContinue
        if ($found) { $psp = $found.Source }
    }
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw 'PSpice psp_cmd.exe not found at the previously confirmed installation path or on PATH.'
    }
    Add-Result 'PSpice' $psp
    $vendorZip = Join-Path $work 'TI_SLVMDV2.zip'
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $verified = $null
    foreach ($file in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDV2*.zip' -File -ErrorAction SilentlyContinue)) {
        if ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToUpperInvariant() -eq $shaExpected) {
            $verified = $file.FullName
            break
        }
    }
    if ($verified) {
        Copy-Item -LiteralPath $verified -Destination $vendorZip
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDV2' -OutFile $vendorZip -UseBasicParsing
    }
    $actualSha = (Get-FileHash -LiteralPath $vendorZip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualSha -ne $shaExpected) { throw "TI ZIP hash mismatch ($actualSha); no simulation was run." }
    Expand-Archive -LiteralPath $vendorZip -DestinationPath (Join-Path $work 'vendor')
    $root = Join-Path $work 'vendor\TPS631000_Encrypted'
    foreach ($leaf in @('TPS631000_SYMBOL.lib','generic_blocks.lib','dig_prim.lib','dig_io.lib')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $leaf) -PathType Leaf)) {
            throw "Verified TI archive is missing $leaf"
        }
    }
    $modelHeader = Get-Content -LiteralPath (Join-Path $root 'TPS631000_SYMBOL.lib') -Raw
    if ($modelHeader -notmatch '(?im)^\.SUBCKT\s+TPS631000_STARTUP\s+VOUT\s+LX2\s+LX1\s+VIN\s+EN\s+MODE\s+GND\s+FB') {
        throw 'Official model subcircuit pin order differs from audited T25D pin order.'
    }
    Build-Deck (Join-Path $work 'Pilot_10us.cir') $root '10u' '10n'
    Add-Result 'Pilot' "10us, $pilotLimitSeconds-second limit"
    $pilot = Run-Phase 'Pilot_10us' $pilotUs $pilotLimitSeconds
    Add-Result 'Pilot evidence' "elapsed=$($pilot.Seconds)s; $($pilot.Detail)"
    if (-not $pilot.Ok) {
        Add-Result 'STATUS' 'NO_PASS - 10us pilot did not complete cleanly; full run skipped.'
    } else {
        $projection = [math]::Ceiling($pilot.Seconds * $fullUs / $pilotUs)
        Add-Result 'Simple linear full-run projection' "$projection seconds, heuristic ONLY; no runtime guarantee"
        if ($projection -gt $fullLimitSeconds) {
            Add-Result 'STATUS' "FULL_RUN_SKIPPED_SLOW_MODEL - projection exceeds $fullLimitSeconds seconds. No board startup verdict."
        } else {
            Build-Deck (Join-Path $work 'Full_12ms.cir') $root '12m' '2u'
            Add-Result 'Full run' "12ms fixture, maximum $fullLimitSeconds seconds"
            $full = Run-Phase 'Full_12ms' $fullUs $fullLimitSeconds
            Add-Result 'Full evidence' "elapsed=$($full.Seconds)s; $($full.Detail)"
            if ($full.Ok) {
                Add-Result 'STATUS' 'VENDOR_MODEL_FIXTURE_COMPLETED - 12ms data captured; board startup and rail regulation still need independent review.'
            } else {
                Add-Result 'STATUS' 'NO_PASS - 12ms fixture did not finish cleanly; no startup verdict.'
            }
        }
    }
} catch {
    Add-Result 'STATUS' "NO_PASS - $($_.Exception.Message)"
} finally {
    $lines.Add('The user-selected battery/USB impedance, TDK biased capacitance and actual card/OLED/firmware load profiles are unqualified.')
    $lines.Add('T24 physical DRC 0/0 predates T25; this fixture does not run Altium DRC.')
    $lines | Set-Content -LiteralPath $result -Encoding UTF8
    $files = @(Get-ChildItem -LiteralPath $work -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '\.(?:txt|cir|out)$' } | Select-Object -ExpandProperty FullName)
    foreach ($wave in (Get-ChildItem -LiteralPath $work -Filter '*.dat' -File -ErrorAction SilentlyContinue)) {
        if ($wave.Length -le 24MB) { $files += $wave.FullName }
    }
    Compress-Archive -LiteralPath $files -DestinationPath $zipPath -Force
    Write-Host "T25Q RESULT ZIP: $zipPath"
    Write-Host 'Send the ZIP; no PSpice menus or manual settings are required.'
}
