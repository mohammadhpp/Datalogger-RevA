# T25BT v1 - TPS631000 official encrypted model, steady-state initialized 19mA -> 280mA load-step.
# PowerShell 5.1 / PSpice 25.1. No CAD/BOM modification.
$ErrorActionPreference = 'Stop'

$expectedHash = 'F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BT_v1_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25BT_v1_Result_$stamp.zip"
$manifest = Join-Path $work 'T25BT_v1_Manifest.txt'
$summary = Join-Path $work 'T25BT_v1_Summary.txt'
$culture = [Globalization.CultureInfo]::InvariantCulture
$caseLimitSeconds = 600

New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25BT: official TPS631000 SS=1 load-step cross-check.'
Write-Host 'Cases: VIN=1.8V and 2.8V control; load 19mA -> TOTAL 280mA.'
Write-Host 'Wait for RESULT ZIP. No Altium files are modified.'

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) { throw "PSpice not found: $psp" }

    $vendorZip = Join-Path $work 'TI_SLVMDV2.zip'
    $verified = $null
    foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDV2*.zip' -File -ErrorAction SilentlyContinue)) {
        $h = (Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($h -eq $expectedHash) { $verified = $candidate.FullName; break }
    }
    if ($verified) {
        Copy-Item -LiteralPath $verified -Destination $vendorZip -Force
        $source = "USER_DOWNLOAD=$verified"
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDV2' -OutFile $vendorZip -UseBasicParsing
        $source = 'DIRECT_TI_HTTPS=https://www.ti.com/lit/zip/SLVMDV2'
    }

    $actualHash = (Get-FileHash -LiteralPath $vendorZip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) { throw "TI model archive hash mismatch: $actualHash" }

    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $vendorZip -DestinationPath $vendor -Force
    $modelRoot = Join-Path $vendor 'TPS631000_Encrypted'
    foreach ($leaf in @('TPS631000_SYMBOL.lib','generic_blocks.lib','dig_prim.lib','dig_io.lib')) {
        if (-not (Test-Path -LiteralPath (Join-Path $modelRoot $leaf) -PathType Leaf)) {
            throw "Missing TI model dependency: $leaf"
        }
    }

    $header = Get-Content -LiteralPath (Join-Path $modelRoot 'TPS631000_SYMBOL.lib') -Raw
    if ($header -notmatch '(?im)^\.SUBCKT\s+TPS631000_STARTUP\s+VOUT\s+LX2\s+LX1\s+VIN\s+EN\s+MODE\s+GND\s+FB') {
        throw 'TPS631000 subcircuit pin order differs from audited interface.'
    }
    if ($header -notmatch '(?i)PARAMS:\s*SS\s*=\s*0') {
        throw 'TPS631000 model no longer exposes the audited SS parameter.'
    }

    @(
      'T25BT v1 - OFFICIAL TI TPS631000 / SS=1 STEADY-STATE INITIALIZATION EXPERIMENT',
      "TIME=$(Get-Date -Format o)",
      "SOURCE=$source",
      "TI_SLVMDV2_SHA256=$actualHash",
      'Goal: restore the exact 19mA versus TOTAL 280mA load-step path after T25BF pre-state failure.',
      '19mA = older prototype observation, unknown bandwidth; NOT RevA background/peak.',
      '280mA = purchased workbook maximum design envelope; NOT measured peak.',
      'Official subckt exposes PARAMS: SS=0. This run changes INSTANCE SS to 1 for a steady-state initialization experiment.',
      'External COUT IC=3.3V and L1 IC are explicitly seeded.',
      'L1 IC seed is based only on the initial 19mA load with eta=0.80 and is NOT a measured current.',
      'VIN=1.8V seed I_L=43.54mA; VIN=2.8V seed I_L=27.99mA.',
      'L1 includes 32mOhm series DCR, the published max of the selected DFE322512F-1R0M=P2.',
      'CIN=22uF and COUT=47uF remain NAMEPLATE values; biased Ceff is still open.',
      'No TPS2116, AA path, SD capacitor event, card, OLED or OVP is included.',
      'A result is interpretable ONLY if the pre-step rail is regulated and stable.',
      'NO BOARD PASS / NO FABRICATION PASS.'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    $resultLines = New-Object System.Collections.Generic.List[string]
    foreach ($case in @(
        @{ Tag='VIN_1P8V'; Vin='1.8'; Ilic='0.04354' },
        @{ Tag='VIN_2P8V_CONTROL'; Vin='2.8'; Ilic='0.02799' }
    )) {
        $tag = $case.Tag
        $cir = Join-Path $work ($tag + '.cir')
        $out = Join-Path $work ($tag + '.out')
        $dat = Join-Path $work ($tag + '.dat')
        $console = Join-Path $work ($tag + '.console.txt')
        $stderr = Join-Path $work ($tag + '.stderr.txt')

        $deck = @'
T25BT TPS631000 SS=1 19mA-to-280mA load-step - no board verdict
.LIB "@ROOT@\TPS631000_SYMBOL.lib"
.LIB "@ROOT@\generic_blocks.lib"
.LIB "@ROOT@\dig_prim.lib"
.LIB "@ROOT@\dig_io.lib"

V_TEST VIN 0 @VIN@
C_IN VIN 0 22u

L1 LX1 LINT 1u IC=@ILIC@
R_L_DCR LINT LX2 0.032

C_OUT VOUT 0 47u IC=3.3
R_FB_TOP VOUT FB 510k
R_FB_BOTTOM FB 0 91k

I_LOAD VOUT 0 PWL(0 0.019 9.99u 0.019 10u 0.280 40u 0.280)

X_U_SYS VOUT LX2 LX1 VIN VIN 0 0 FB TPS631000_STARTUP PARAMS: SS=1

.TRAN 0 40u 0 10n SKIPBP
.OPTIONS ADVCONV
.OPTIONS SPEED_LEVEL=5

.PROBE64 V([VIN]) V([VOUT]) V([FB])
.PRINT TRAN V([VIN]) V([VOUT]) V([FB])
.PRINT TRAN I(V_TEST)
.END
'@
        $deck = $deck.Replace('@ROOT@',$modelRoot).Replace('@VIN@',$case.Vin).Replace('@ILIC@',$case.Ilic)
        $deck | Set-Content -LiteralPath $cir -Encoding Ascii

        Write-Host "Running $tag ..."
        $status = 'INCOMPLETE'
        try {
            $proc = Start-Process -FilePath $psp -ArgumentList @('-r',('"' + $cir + '"')) -WorkingDirectory $work -RedirectStandardOutput $console -RedirectStandardError $stderr -PassThru -NoNewWindow
            $watch = [Diagnostics.Stopwatch]::StartNew()
            while (-not $proc.WaitForExit(5000)) {
                Write-Host "$tag still running: $([int]$watch.Elapsed.TotalSeconds) / $caseLimitSeconds seconds"
                if ($watch.Elapsed.TotalSeconds -ge $caseLimitSeconds) {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                    $proc.WaitForExit(5000) | Out-Null
                    throw "$tag exceeded $caseLimitSeconds seconds"
                }
            }

            if (-not (Test-Path -LiteralPath $out -PathType Leaf)) { throw "$tag produced no OUT log" }
            $log = Get-Content -LiteralPath $out -Raw
            $errors = [regex]::Matches($log,'(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
            $warnings = [regex]::Matches($log,'(?im)^\s*WARNING\(').Count
            $job = $log -match '(?im)^\s*JOB CONCLUDED\s*$'
            if (-not $job -or $errors -gt 0) { throw "$tag incomplete: job=$job errors=$errors warnings=$warnings" }

            # Parse ONLY the voltage PRINT table. Current is deliberately left for independent raw audit.
            $num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
            $rows = [regex]::Matches($log,'(?m)^\s*('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')\s*$')
            $vr = New-Object System.Collections.Generic.List[object]
            foreach ($row in $rows) {
                $t = [double]::Parse($row.Groups[1].Value,$culture)
                $vin = [double]::Parse($row.Groups[2].Value,$culture)
                $vout = [double]::Parse($row.Groups[3].Value,$culture)
                $fb = [double]::Parse($row.Groups[4].Value,$culture)
                if ($t -le 40.01e-6) {
                    $vr.Add([pscustomobject]@{T=$t;VIN=$vin;VOUT=$vout;FB=$fb})
                }
            }
            if ($vr.Count -lt 1000 -or -not (Test-Path -LiteralPath $dat -PathType Leaf)) {
                throw "$tag insufficient waveform evidence: voltageRows=$($vr.Count)"
            }

            $pre = @($vr | Where-Object { $_.T -ge 7.0e-6 -and $_.T -le 9.8e-6 })
            $post = @($vr | Where-Object { $_.T -ge 10.0e-6 -and $_.T -le 40.0e-6 })
            if ($pre.Count -lt 100 -or $post.Count -lt 500) { throw "$tag insufficient gated samples" }

            $preMin = ($pre | Measure-Object VOUT -Minimum).Minimum
            $preMax = ($pre | Measure-Object VOUT -Maximum).Maximum
            $preAvg = ($pre | Measure-Object VOUT -Average).Average
            $postMin = ($post | Measure-Object VOUT -Minimum).Minimum
            $postEnd = $post[$post.Count-1].VOUT
            $preSpan = $preMax - $preMin

            $preValid = ($preMin -ge 3.15 -and $preMax -le 3.45 -and $preSpan -le 0.08)
            $status = if ($preValid) { 'PRESTATE_VALID_OFFICIAL_MODEL_TRACE' } else { 'PRESTATE_INVALID_REJECT_LOADSTEP' }

            $line = 'CASE='+$tag+
              '; STATUS='+$status+
              '; PRE_AVG='+[math]::Round($preAvg,6).ToString($culture)+'V'+
              '; PRE_MIN='+[math]::Round($preMin,6).ToString($culture)+'V'+
              '; PRE_MAX='+[math]::Round($preMax,6).ToString($culture)+'V'+
              '; PRE_SPAN='+[math]::Round($preSpan,6).ToString($culture)+'V'+
              '; POST_MIN='+[math]::Round($postMin,6).ToString($culture)+'V'+
              '; POST_END='+[math]::Round($postEnd,6).ToString($culture)+'V'+
              '; VOLTAGE_ROWS='+$vr.Count+
              '; WARNINGS='+$warnings+
              '; RAW_CURRENT_TABLE_MUST_BE_INDEPENDENTLY_AUDITED'+
              '; NO_BOARD_PASS'
            $resultLines.Add($line)
            Write-Host $line
        } catch {
            $line = 'CASE='+$tag+'; ERROR='+$_.Exception.Message.Replace(',',';')+'; NO_BOARD_PASS'
            $resultLines.Add($line)
            Write-Host $line
        }
    }

    @(
      'T25BT v1 result summary',
      'Do not interpret a load-step unless STATUS=PRESTATE_VALID_OFFICIAL_MODEL_TRACE.',
      'Raw .out current tables must be audited independently; generated summary intentionally does not parse source current.',
      $resultLines.ToArray()
    ) | Set-Content -LiteralPath $summary -Encoding UTF8

} catch {
    "GLOBAL_ERROR=$($_.Exception.Message)" | Set-Content -LiteralPath $summary -Encoding UTF8
} finally {
    $present = @(
      Get-ChildItem -LiteralPath $work -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -ne 'TI_SLVMDV2.zip' -and ($_.Extension -ne '.dat' -or $_.Length -le 30MB) } |
      Select-Object -ExpandProperty FullName
    )
    if ($present.Count -gt 0) { Compress-Archive -LiteralPath $present -DestinationPath $resultZip -Force }
    Write-Host "RESULT ZIP: $resultZip"
}
