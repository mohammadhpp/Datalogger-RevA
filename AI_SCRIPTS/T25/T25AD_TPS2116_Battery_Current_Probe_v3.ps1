# T25AD v3 - Probe TI TPS2116 VIN2 source current across USB collapse.
# Diagnose v2 capacitor hold-up and datasheet's fast-collapse VIN2>=2.5V rule.
# All source, load and capacitor values below are declared test fixtures.
# PowerShell 5.1 ASCII source. No Altium/CAD or project files are changed.
$ErrorActionPreference = 'Stop'
$modelSha = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25AD_v3_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25AD_v3_Result_$stamp.zip"
$report = Join-Path $work 'T25AD_v3_Result.txt'
$manifest = Join-Path $work 'T25AD_v3_Manifest.txt'
$archive = Join-Path $work 'SLVMDI4A.ZIP'
$vendor = Join-Path $work 'vendor'
$model = Join-Path $vendor 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
$files = New-Object System.Collections.Generic.List[string]
$results = New-Object System.Collections.Generic.List[string]
$overall = 'NOT_RUN'

New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25AD v3: VIN2 source-current probe with fast/slow source-collapse controls.'
Write-Host 'Each official TI model case is limited to 90 seconds. No hardware PASS.'

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw "PSpice not found: $psp"
    }
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $verified = $null
    if (Test-Path -LiteralPath $downloads -PathType Container) {
        foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDI4*.zip' -File -ErrorAction SilentlyContinue)) {
            if ((Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash.ToUpperInvariant() -eq $modelSha) {
                $verified = $candidate.FullName
                break
            }
        }
    }
    if ($verified) {
        Copy-Item -LiteralPath $verified -Destination $archive
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        try {
            Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDI4' -OutFile $archive -UseBasicParsing
        } catch {
            throw 'Official TI model download failed. A previous verified SLVMDI4A.ZIP in Downloads allows an offline rerun.'
        }
    }
    $foundSha = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($foundSha -ne $modelSha) {
        throw "TI model SHA256 mismatch: $foundSha; execution stopped."
    }
    Expand-Archive -LiteralPath $archive -DestinationPath $vendor
    if (-not (Test-Path -LiteralPath $model -PathType Leaf)) {
        throw 'Audited TPS2116_TRANS.LIB path absent in official archive.'
    }
    $modelText = Get-Content -LiteralPath $model -Raw
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS2116_TRANS\s+GND\s+MODE\s+PR1\s+ST\s+VIN1\s+VIN2\s+VOUT_0\s+VOUT_1\s*$') {
        throw 'Vendor model interface changed; do not run with unchecked pin mapping.'
    }

    @(
        'T25AD v3 / TI TPS2116 isolated source-current diagnostic',
        "MODEL_SHA256=$modelSha",
        'LIVE_01_POWER_SCHDOC_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1',
        'T25AB v2 light 3ms output resembles passive 22uF/330ohm discharge; battery source current was not probed',
        'VIN1=ideal 5V -> 0V over 10us FAST or 100us SLOW from 1ms; neither is measured USB',
        'TI TPS2116 datasheet 7.4.1: if collapsing supply slew exceeds 1V/10us, other input requires >=2.5V to avoid possible reset',
        'VIN2=ideal fixed 1.8V or 3.0V at IC; no AA pack impedance or voltage sag',
        'MODE=VIN1; PR1=30k/10k from live SchDoc; VOUT pins tied to VIN_MUX',
        'ST=1G numeric ground approximates DNP in light cases; 10k to independent 3.3V bench in heavy cases is DIAGNOSTIC ONLY',
        'Loads 330ohm light and 3.3ohm heavy are fixture values, not actual converter startup/load law',
        'C_IN=22uF nameplate in light cases; 4.2uF heavy is only illustrative, actual effective capacitance unknown',
        'PSpice source current I(V_BAT_FIXTURE) is positive into source; delivered current is -I(V_BAT_FIXTURE)',
        'Check stable 0.8-0.95ms pre-unplug VOUT, first crossing VIN2+0.1V, then late VOUT/current',
        'TI E2E on TPS2116 priority-mode model reports unexpected model VIN2-start behavior vs physical device',
        'No actual USB path, AA impedance, OVP, TPS631000, 3V3 or SD/OLED load simulation',
        'PSpice .TRAN <=15ms, max step 2us; 90-second wall limit per case; logs and DAT <=24MiB included'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    $stPullup = @'
V_ST_BENCH ST_SUPPLY 0 3.3
R_ST_BENCH ST_SUPPLY ST 10k
'@
    $cases = @(
        @{ Tag='LIGHT_1P8_FAST_DNP_15MS'; Cap='22u'; Load='330'; Vin2='1.8'; St='R_ST_NUM ST 0 1G'; FallEnd='1.01m'; Stop='15m'; StopSeconds=0.015 },
        @{ Tag='LIGHT_3P0_FAST_DNP_8MS'; Cap='22u'; Load='330'; Vin2='3'; St='R_ST_NUM ST 0 1G'; FallEnd='1.01m'; Stop='8m'; StopSeconds=0.008 },
        @{ Tag='HEAVY_1P8_FAST_PU_5MS'; Cap='4.2u'; Load='3.3'; Vin2='1.8'; St=$stPullup; FallEnd='1.01m'; Stop='5m'; StopSeconds=0.005 },
        @{ Tag='HEAVY_1P8_SLOW_PU_5MS'; Cap='4.2u'; Load='3.3'; Vin2='1.8'; St=$stPullup; FallEnd='1.1m'; Stop='5m'; StopSeconds=0.005 },
        @{ Tag='HEAVY_3P0_FAST_PU_5MS'; Cap='4.2u'; Load='3.3'; Vin2='3'; St=$stPullup; FallEnd='1.01m'; Stop='5m'; StopSeconds=0.005 }
    )
    $completed = 0
    foreach ($case in $cases) {
        $tag = $case.Tag
        try {
        $deckPath = Join-Path $work "$tag.cir"
        $outPath = Join-Path $work "$tag.out"
        $datPath = Join-Path $work "$tag.dat"
        $console = Join-Path $work "$tag.console.txt"
        $stderr = Join-Path $work "$tag.stderr.txt"
        $deck = @'
T25AD TPS2116 VIN2 source current and collapse-slope probe
* Explicit test-only VIN2 / ST / load / C_IN variants. Not a hardware PASS.
.LIB "@MODEL@"
V_USB_FIXTURE VIN1 0 PWL(0 5 1m 5 @FALL_END@ 0 @STOP@ 0)
V_BAT_FIXTURE VIN2 0 @VIN2@
R_PR_TOP VIN1 PR1 30k
R_PR_BOTTOM PR1 0 10k
@ST@
X_U_PMUX 0 VIN1 PR1 ST VIN1 VIN2 VIN_MUX VIN_MUX TPS2116_TRANS
C_IN VIN_MUX 0 @CAP@
R_LOAD_FIXTURE VIN_MUX 0 @LOAD@
.TRAN 0 @STOP@ 0 2u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN1]) V([VIN2]) V([VIN_MUX]) I(V_BAT_FIXTURE)
.PRINT TRAN V([VIN1]) V([VIN2]) V([PR1]) V([VIN_MUX]) I(V_BAT_FIXTURE)
.END
'@
        $deck.Replace('@MODEL@', $model).Replace('@CAP@', $case.Cap).Replace('@VIN2@', $case.Vin2).Replace('@LOAD@', $case.Load).Replace('@ST@', $case.St).Replace('@FALL_END@', $case.FallEnd).Replace('@STOP@', $case.Stop) |
            Set-Content -LiteralPath $deckPath -Encoding Ascii
        Write-Host "PSpice source-current probe: $tag (90-second time limit)"
        $proc = Start-Process -FilePath $psp -ArgumentList @('-r', ('"' + $deckPath + '"')) `
            -WorkingDirectory $work -RedirectStandardOutput $console `
            -RedirectStandardError $stderr -PassThru -NoNewWindow
        $clock = [Diagnostics.Stopwatch]::StartNew()
        while (-not $proc.WaitForExit(2000)) {
            if ($clock.Elapsed.TotalSeconds -ge 90) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                $proc.WaitForExit(10000) | Out-Null
                throw "$tag exceeded 90s. No completed simulation."
            }
        }
        if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) {
            throw "$tag has no PSpice OUT log. See console/stderr."
        }
        $log = Get-Content -LiteralPath $outPath -Raw
        $errors = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
        $warnings = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
        $proc.Refresh()
        $exitCode = $null
        try { $exitCode = $proc.ExitCode } catch { $exitCode = $null }
        if (($null -ne $exitCode -and $exitCode -ne 0) -or $errors -gt 0 -or $warnings -gt 0 -or
            $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$' -or
            $log -notmatch '(?i)Total job time') {
            throw "$tag solver incomplete: exit=$exitCode, errors=$errors, warnings=$warnings."
        }
        # Five PRINT columns after TIME; column 6 is I(V_BAT_FIXTURE).
        $number = '[+-]?\d+\.\d+E[+-]\d+'
        $rowPattern = '(?m)^\s*(' + $number + ')\s+(' + $number + ')\s+(' +
            $number + ')\s+(' + $number + ')\s+(' + $number + ')\s+(' + $number + ')'
        $rows = [regex]::Matches($log, $rowPattern)
        if ($rows.Count -lt 250 -or -not (Test-Path -LiteralPath $datPath -PathType Leaf) -or
            (Get-Item -LiteralPath $datPath).Length -le 128) {
            throw "$tag missing useful PRINT/DAT data: rows=$($rows.Count)."
        }
        $culture = [Globalization.CultureInfo]::InvariantCulture
        $pre = New-Object System.Collections.Generic.List[double]
        $lateVout = New-Object System.Collections.Generic.List[double]
        $lateBattery = New-Object System.Collections.Generic.List[double]
        $finalVin1 = 0.0
        $finalVin2 = 0.0
        $finalVout = 0.0
        $firstCrossingMs = $null
        $peakBatteryAfterCrossing = $null
        $minAfter = [double]::PositiveInfinity
        $lastTime = 0.0
        foreach ($row in $rows) {
            $time = [double]::Parse($row.Groups[1].Value, $culture)
            $vin1 = [double]::Parse($row.Groups[2].Value, $culture)
            $vin2 = [double]::Parse($row.Groups[3].Value, $culture)
            $vout = [double]::Parse($row.Groups[5].Value, $culture)
            $delivered = -[double]::Parse($row.Groups[6].Value, $culture)
            if ($time -ge 0.0008 -and $time -le 0.00095) { $pre.Add($vout) }
            if ($time -ge 0.001) {
                if ($vout -lt $minAfter) { $minAfter = $vout }
                if ($null -eq $firstCrossingMs -and $vout -le ($vin2 + 0.1)) { $firstCrossingMs = $time * 1000 }
                if ($null -ne $firstCrossingMs -and ($null -eq $peakBatteryAfterCrossing -or $delivered -gt $peakBatteryAfterCrossing)) {
                    $peakBatteryAfterCrossing = $delivered
                }
            }
            if ($time -ge ($case.StopSeconds - 0.0002)) {
                $lateVout.Add($vout)
                $lateBattery.Add($delivered)
            }
            $finalVin1 = $vin1
            $finalVin2 = $vin2
            $finalVout = $vout
            $lastTime = $time
        }
        if ($pre.Count -lt 50 -or $lateVout.Count -lt 50 -or $lateBattery.Count -lt 50 -or
            $lastTime -lt ($case.StopSeconds - 0.00001)) {
            throw "$tag missing pre/late windows or full requested stop time; rows=$($rows.Count); last=$lastTime."
        }
        $preAvg = ($pre | Measure-Object -Average).Average
        $lateVoutAvg = ($lateVout | Measure-Object -Average).Average
        $lateDeliveredAvg = ($lateBattery | Measure-Object -Average).Average
        $validPre = ($preAvg -ge 4.5 -and ($pre | Measure-Object -Minimum).Minimum -ge 4.5)
        $status = if (-not $validPre) {
            'NO_VALID_PRESTATE'
        } elseif ($null -eq $firstCrossingMs) {
            'NO_CROSSING_OF_VIN2_PLUS_0P1V'
        } elseif ($lateDeliveredAvg -gt 0.0005 -and $lateVoutAvg -ge (([double]$case.Vin2) * 0.8)) {
            'LATE_BATTERY_DELIVERY_IN_THIS_FIXTURE'
        } else {
            'NO_CONFIRMED_LATE_BATTERY_DELIVERY_IN_THIS_FIXTURE'
        }
        $crossLabel = if ($null -eq $firstCrossingMs) { 'NONE' } else { [string][math]::Round($firstCrossingMs,4) }
        $peakLabel = if ($null -eq $peakBatteryAfterCrossing) { 'NONE' } else { [string][math]::Round($peakBatteryAfterCrossing,7) }
        $line = "CASE=$tag; STATUS=$status; rows=$($rows.Count); " +
            "pre0p8to0p95ms_mean=$([math]::Round($preAvg,6))V; " +
            "cross_VOUT_below_VIN2plus0p1_ms=$crossLabel; " +
            "late0p2ms_VOUT_mean=$([math]::Round($lateVoutAvg,6))V; " +
            "late0p2ms_battery_delivered_mean=$([math]::Round($lateDeliveredAvg,7))A; " +
            "battery_delivered_peak_after_crossing=${peakLabel}A; " +
            "post1ms_min=$([math]::Round($minAfter,6))V; " +
            "final_VIN1=$([math]::Round($finalVin1,6))V; " +
            "final_VIN2=$([math]::Round($finalVin2,6))V; " +
            "final_VIN_MUX=$([math]::Round($finalVout,6))V; seconds=$([math]::Round($clock.Elapsed.TotalSeconds,2))"
        $results.Add($line)
        Write-Host $line
        if (-not $validPre) {
            $results.Add("CASE=$tag; FLAG=INVALID_PRE_UNPLUG_STATE; DO_NOT_INFER_HANDOFF")
        } elseif ($null -eq $firstCrossingMs) {
            $results.Add("CASE=$tag; FLAG=CAPACITOR_HAS_NOT_REACHED_BACKUP_VOLTAGE; NO_HANDOFF_VERDICT")
        } elseif ($status -ne 'LATE_BATTERY_DELIVERY_IN_THIS_FIXTURE') {
            $results.Add("CASE=$tag; FLAG=NO_SETTLED_BATTERY_DELIVERY_IN_VENDOR_MODEL_FIXTURE")
        }
        foreach ($f in @($deckPath, $outPath, $console, $stderr)) { $files.Add($f) }
        if ((Get-Item -LiteralPath $datPath).Length -le 24MB) { $files.Add($datPath) }
        $completed++
        } catch {
            $results.Add("CASE=$tag; ERROR=$($_.Exception.Message)")
            Write-Host "Case failed: $tag - $($_.Exception.Message)"
        }
    }
    $overall = if ($completed -eq $cases.Count) {
        'FIVE_VENDOR_MODEL_SOURCE_CURRENT_TRACES_CAPTURED'
    } else {
        "PARTIAL_SOURCE_CURRENT_TRACES_$($completed)_OF_$($cases.Count)"
    }
} catch {
    $overall = 'SOURCE_CURRENT_PROBE_INCOMPLETE'
    $results.Add("ERROR=$($_.Exception.Message)")
} finally {
    @(
        'T25AD v3 - isolated TI TPS2116 source-current and slew diagnostic',
        "STATUS=$overall",
        "TIME=$(Get-Date -Format o)",
        "MODEL_SHA256=$modelSha",
        'INTERPRETATION: numerical traces are conditional fixture evidence, never a real AA startup or integrated 3V3 PASS.',
        'INTERPRETATION: positive delivered current means negative SPICE I(V_BAT_FIXTURE); raw PRINT and DAT retained.',
        'INTERPRETATION: stable pre-unplug output and crossing of VIN2+0.1V required before assessing backup current.',
        'INTERPRETATION: TI warns VIN2<2.5V can allow reset if the other input collapses faster than 1V/10us; actual USB slew not measured.',
        'INTERPRETATION: TI has documented unexpected VIN2-first behavior in TPS2116 SPICE vs physical device; even solver success cannot certify hardware.',
        $results.ToArray()
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    $files.Add($report)
    if (Test-Path -LiteralPath $manifest -PathType Leaf) { $files.Add($manifest) }
    foreach ($pattern in @('*.cir','*.out','*.console.txt','*.stderr.txt','*.dat')) {
        foreach ($f in @(Get-ChildItem -LiteralPath $work -File -Filter $pattern -ErrorAction SilentlyContinue)) {
            if ($f.Extension -ne '.dat' -or $f.Length -le 24MB) {
                if (-not $files.Contains($f.FullName)) { $files.Add($f.FullName) }
            }
        }
    }
    $present = @($files.ToArray() | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    Compress-Archive -LiteralPath $present -DestinationPath $resultZip -Force
    Write-Host "STATUS: $overall"
    Write-Host "RESULT ZIP: $resultZip"
    Write-Host 'Share this ZIP for waveform interpretation. Do not treat solver completion as hardware PASS.'
}
