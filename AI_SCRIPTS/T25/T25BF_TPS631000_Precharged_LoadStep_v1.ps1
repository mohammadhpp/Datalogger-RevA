# T25BF v1 - official encrypted TI TPS631000 short precharged load-step fixture.
# ASCII-only PowerShell 5.1. No Altium, BOM or installed library file is changed.
$ErrorActionPreference = 'Stop'
$expectedHash = 'F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BF_v1_$stamp"
$resultPath = Join-Path $work 'T25BF_v1_Result.txt'
$manifestPath = Join-Path $work 'T25BF_v1_Manifest.txt'
$resultZip = Join-Path $documents "Datalogger_T25BF_v1_Result_$stamp.zip"
$lines = New-Object System.Collections.Generic.List[string]
$completed = 0
$culture = [Globalization.CultureInfo]::InvariantCulture
$caseLimitSeconds = 240
New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25BF: two official-model cases. Wait for RESULT ZIP.'

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) { throw "PSpice not found: $psp" }
    @(
        'T25BF v1 - OFFICIAL TI TPS631000 ENCRYPTED MODEL / PRECHARGED SHORT WINDOW',
        "TI SLVMDV2 ZIP SHA256=$expectedHash",
        'Cases: ideal VIN=1.8V project corner and VIN=2.8V TI-example control.',
        'Output load is an ideal constant-current step from 19mA to TOTAL 280mA at 10us.',
        '19mA is an old-prototype reading; 280mA is the workbook design envelope.',
        'COUT=47uF and CIN=22uF are NAMEPLATE values, not verified biased Ceff.',
        'L=1uH is ideal; DCR, capacitor ESR/ESL and PCB parasitics are excluded.',
        'COUT starts at 3.3V only to probe a short load-step window; internal encrypted model state is not a proven steady operating point.',
        'No TPS2116, AA impedance, OVP, SD capacitor, card, OLED or gate driver is included.',
        'This is NOT full startup, source handoff, no-reset proof or fabrication PASS.'
    ) | Set-Content -LiteralPath $manifestPath -Encoding Ascii

    $vendorZip = Join-Path $work 'TI_SLVMDV2.zip'
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $verified = $null
    foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDV2*.zip' -File -ErrorAction SilentlyContinue)) {
        if ((Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash.ToUpperInvariant() -eq $expectedHash) {
            $verified = $candidate.FullName
            break
        }
    }
    if ($verified) {
        Copy-Item -LiteralPath $verified -Destination $vendorZip
    } else {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDV2' -OutFile $vendorZip -UseBasicParsing
        } catch {
            throw 'TI download failed. Put official SLVMDV2.ZIP in Windows Downloads and rerun T25BF.'
        }
    }
    $actualHash = (Get-FileHash -LiteralPath $vendorZip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) { throw "TI archive hash mismatch: $actualHash" }
    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $vendorZip -DestinationPath $vendor
    $modelRoot = Join-Path $vendor 'TPS631000_Encrypted'
    foreach ($leaf in @('TPS631000_SYMBOL.lib','generic_blocks.lib','dig_prim.lib','dig_io.lib')) {
        if (-not (Test-Path -LiteralPath (Join-Path $modelRoot $leaf) -PathType Leaf)) { throw "Missing TI model dependency: $leaf" }
    }
    $header = Get-Content -LiteralPath (Join-Path $modelRoot 'TPS631000_SYMBOL.lib') -Raw
    if ($header -notmatch '(?im)^\.SUBCKT\s+TPS631000_STARTUP\s+VOUT\s+LX2\s+LX1\s+VIN\s+EN\s+MODE\s+GND\s+FB') {
        throw 'Official TPS631000 subcircuit pin order differs from audited interface.'
    }

    foreach ($case in @(
        @{ Tag='VIN_1P8V'; Vin='1.8' },
        @{ Tag='VIN_2P8V_CONTROL'; Vin='2.8' }
    )) {
        $tag = $case.Tag
        try {
            $cir = Join-Path $work ($tag + '.cir')
            $out = Join-Path $work ($tag + '.out')
            $dat = Join-Path $work ($tag + '.dat')
            $console = Join-Path $work ($tag + '.console.txt')
            $stderr = Join-Path $work ($tag + '.stderr.txt')
            $deck = @'
T25BF official TPS631000 precharged short load-step - no board verdict
.LIB "@ROOT@\TPS631000_SYMBOL.lib"
.LIB "@ROOT@\generic_blocks.lib"
.LIB "@ROOT@\dig_prim.lib"
.LIB "@ROOT@\dig_io.lib"
V_TEST VIN 0 @VIN@
C_IN VIN 0 22u
L1 LX1 LX2 1u
C_OUT VOUT 0 47u IC=3.3
R_FB_TOP VOUT FB 510k
R_FB_BOTTOM FB 0 91k
I_LOAD VOUT 0 PWL(0 0.019 9.99u 0.019 10u 0.280 20u 0.280)
X_U_SYS VOUT LX2 LX1 VIN VIN 0 0 FB TPS631000_STARTUP PARAMS: SS=0
.TRAN 0 20u 0 10n SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN]) V([VOUT]) V([FB])
.PRINT TRAN V([VIN]) V([VOUT]) V([FB]) I(V_TEST)
.END
'@
            $deck.Replace('@ROOT@',$modelRoot).Replace('@VIN@',$case.Vin) | Set-Content -LiteralPath $cir -Encoding Ascii
            Write-Host "Running $tag (maximum $caseLimitSeconds seconds) ..."
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
            if ($errors -gt 0 -or $warnings -gt 0 -or $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$') {
                throw "$tag incomplete: errors=$errors warnings=$warnings"
            }
            $num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
            $rows = [regex]::Matches($log,'(?m)^\s*('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')')
            if ($rows.Count -lt 1900 -or -not (Test-Path -LiteralPath $dat -PathType Leaf)) {
                throw "$tag missing waveform evidence: rows=$($rows.Count)"
            }
            $preV = New-Object System.Collections.Generic.List[double]
            $preI = New-Object System.Collections.Generic.List[double]
            $postV = New-Object System.Collections.Generic.List[double]
            $postI = New-Object System.Collections.Generic.List[double]
            $lastTime = 0.0
            foreach ($row in $rows) {
                $t = [double]::Parse($row.Groups[1].Value,$culture)
                $vout = [double]::Parse($row.Groups[3].Value,$culture)
                $iin = [math]::Abs([double]::Parse($row.Groups[5].Value,$culture))
                if ($t -ge 8.0e-6 -and $t -le 9.8e-6) { $preV.Add($vout); $preI.Add($iin) }
                if ($t -ge 10.0e-6 -and $t -le 20.0e-6) { $postV.Add($vout); $postI.Add($iin) }
                $lastTime = $t
            }
            if ($lastTime -lt 19.99e-6 -or $preV.Count -lt 150 -or $postV.Count -lt 900) {
                throw "$tag sampling incomplete: pre=$($preV.Count) post=$($postV.Count) last=$lastTime"
            }
            $preMin = ($preV | Measure-Object -Minimum).Minimum
            $preMax = ($preV | Measure-Object -Maximum).Maximum
            $postMin = ($postV | Measure-Object -Minimum).Minimum
            $postEnd = $postV[$postV.Count-1]
            $preIavg = ($preI | Measure-Object -Average).Average
            $postIavg = ($postI | Measure-Object -Average).Average
            $preClass = if ($preMin -ge 3.0 -and $preMax -le 3.6) { 'PRECHARGED_WINDOW_HELD' } else { 'PRECHARGED_WINDOW_NOT_HELD' }
            $line = 'CASE='+$tag+'; '+$preClass+'; PRE_VOUT_MIN='+[math]::Round($preMin,6).ToString($culture)+'V; POST_VOUT_MIN='+[math]::Round($postMin,6).ToString($culture)+'V; POST_VOUT_END='+[math]::Round($postEnd,6).ToString($culture)+'V; PRE_ABS_IIN_AVG='+[math]::Round($preIavg,6).ToString($culture)+'A; POST_ABS_IIN_AVG='+[math]::Round($postIavg,6).ToString($culture)+'A; MODEL_TRACE_ONLY; NO_BOARD_PASS'
            $lines.Add($line)
            Write-Host $line
            $completed++
        } catch {
            $line = 'CASE='+$tag+'; ERROR='+$_.Exception.Message+'; NO_BOARD_PASS'
            $lines.Add($line)
            Write-Host $line
        }
    }
} catch {
    $lines.Add('GLOBAL_ERROR='+$_.Exception.Message+'; NO_BOARD_PASS')
} finally {
    $status = if ($completed -eq 2) { 'TWO_OFFICIAL_MODEL_TRACES_COMPLETED' } else { 'INCOMPLETE_' + $completed + '_OF_2' }
    @(
        'T25BF v1 - official TPS631000 precharged short load-step result',
        "STATUS=$status",
        "TIME=$(Get-Date -Format o)",
        'A precharged output capacitor does not initialize inaccessible encrypted controller states.',
        'Review input current and pre-event VOUT before interpreting the load step.',
        'No full startup, SD capacitor, source handoff, no-reset or fabrication verdict.',
        $lines.ToArray()
    ) | Set-Content -LiteralPath $resultPath -Encoding UTF8
    $present = @(Get-ChildItem -LiteralPath $work -File | Where-Object { $_.Name -ne 'TI_SLVMDV2.zip' -and ($_.Extension -ne '.dat' -or $_.Length -le 24MB) } | Select-Object -ExpandProperty FullName)
    Compress-Archive -LiteralPath $present -DestinationPath $resultZip -Force
    Write-Host "STATUS: $status"
    Write-Host "RESULT ZIP: $resultZip"
}
