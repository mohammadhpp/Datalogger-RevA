# T25AB v2 - Diagnose T25AA v1's unpowered VIN_MUX BEFORE USB unplug.
# Official TI TPS2116 vendor model; matrix separates load, ST and VIN2.
# All source, load and capacitor values below are declared test fixtures.
# PowerShell 5.1 ASCII source. No Altium/CAD or project files are changed.
$ErrorActionPreference = 'Stop'
$modelSha = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25AB_v2_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25AB_v2_Result_$stamp.zip"
$report = Join-Path $work 'T25AB_v2_Result.txt'
$manifest = Join-Path $work 'T25AB_v2_Manifest.txt'
$archive = Join-Path $work 'SLVMDI4A.ZIP'
$vendor = Join-Path $work 'vendor'
$model = Join-Path $vendor 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
$files = New-Object System.Collections.Generic.List[string]
$results = New-Object System.Collections.Generic.List[string]
$overall = 'NOT_RUN'

New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25AB v2: diagnostic six-case matrix after T25AA v1 invalid pre-unplug steady state.'
Write-Host 'Each official TI model case is limited to 45 seconds. No hardware PASS.'

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
        'T25AB v2 / diagnostic real TI TPS2116 TRANS.LIB isolated model',
        "MODEL_SHA256=$modelSha",
        'LIVE_01_POWER_SCHDOC_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1',
        'T25AA v1 actual 22u/3.3ohm/1.8V/DNP-numeric case NEVER reached steady 5V output before unplug',
        'VIN1=ideal 5V -> 0V hard-unplug during 1.000-1.010 ms; source waveform is not measured USB',
        'VIN2=ideal fixed 1.8V at IC in test cases; independent 3.0V control only; no AA path drops',
        'MODE=VIN1; PR1=30k/10k from live SchDoc; VOUT pins tied to VIN_MUX',
        'ST=1G numeric ground for initial DNP cases; separate 10k to independent 3.3V bench source is CONTROL ONLY and not approved board population',
        'Loads 330ohm prior T25G control, 3.3ohm heavy fixture; neither is an actual converter current law',
        'C_IN=22uF nameplate except one 4.2uF illustrative sensitivity case; actual effective C unknown',
        'Check BOTH pre-unplug 0.8-0.95ms VOUT and after-unplug output; no interpretation of dip without steady pre-state',
        'TI E2E on TPS2116 priority-mode model reports unexpected model VIN2-start behavior vs physical device',
        'No actual USB path, AA impedance, OVP, TPS631000, 3V3 or SD/OLED load simulation',
        'PSpice .TRAN 3ms; 45-second wall limit per case; all output logs and DAT <=24MiB included'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    $stPullup = @'
V_ST_BENCH ST_SUPPLY 0 3.3
R_ST_BENCH ST_SUPPLY ST 10k
'@
    $cases = @(
        @{ Tag='LIGHT_ST_PULLUP_VIN2_1P8'; Cap='22u'; Load='330'; Vin2='1.8'; St=$stPullup },
        @{ Tag='LIGHT_ST_DNP_VIN2_1P8'; Cap='22u'; Load='330'; Vin2='1.8'; St='R_ST_NUM ST 0 1G' },
        @{ Tag='HEAVY_ST_PULLUP_VIN2_1P8'; Cap='22u'; Load='3.3'; Vin2='1.8'; St=$stPullup },
        @{ Tag='HEAVY_ST_DNP_VIN2_1P8'; Cap='22u'; Load='3.3'; Vin2='1.8'; St='R_ST_NUM ST 0 1G' },
        @{ Tag='LIGHT_ST_PULLUP_VIN2_3P0'; Cap='22u'; Load='330'; Vin2='3'; St=$stPullup },
        @{ Tag='HEAVY_ST_PULLUP_VIN2_1P8_C4P2'; Cap='4.2u'; Load='3.3'; Vin2='1.8'; St=$stPullup }
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
T25AB TPS2116 diagnostic - check steady output BEFORE hard-unplug
* Explicit test-only VIN2 / ST / load / C_IN variants. Not a hardware PASS.
.LIB "@MODEL@"
V_USB_FIXTURE VIN1 0 PWL(0 5 1m 5 1.01m 0 3m 0)
V_BAT_FIXTURE VIN2 0 @VIN2@
R_PR_TOP VIN1 PR1 30k
R_PR_BOTTOM PR1 0 10k
@ST@
X_U_PMUX 0 VIN1 PR1 ST VIN1 VIN2 VIN_MUX VIN_MUX TPS2116_TRANS
C_IN VIN_MUX 0 @CAP@
R_LOAD_FIXTURE VIN_MUX 0 @LOAD@
.TRAN 0 3m 0 1u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN1]) V([VIN2]) V([PR1]) V([VIN_MUX]) V([ST])
.PRINT TRAN V([VIN1]) V([VIN2]) V([PR1]) V([VIN_MUX]) V([ST])
.END
'@
        $deck.Replace('@MODEL@', $model).Replace('@CAP@', $case.Cap).Replace('@VIN2@', $case.Vin2).Replace('@LOAD@', $case.Load).Replace('@ST@', $case.St) |
            Set-Content -LiteralPath $deckPath -Encoding Ascii
        Write-Host "PSpice diagnostic: $tag (45-second time limit)"
        $proc = Start-Process -FilePath $psp -ArgumentList @('-r', ('"' + $deckPath + '"')) `
            -WorkingDirectory $work -RedirectStandardOutput $console `
            -RedirectStandardError $stderr -PassThru -NoNewWindow
        $clock = [Diagnostics.Stopwatch]::StartNew()
        while (-not $proc.WaitForExit(2000)) {
            if ($clock.Elapsed.TotalSeconds -ge 45) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                $proc.WaitForExit(10000) | Out-Null
                throw "$tag exceeded 45s. No completed simulation."
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
        # The official T25G runtime evidence has five PRINT columns after TIME.
        $number = '[+-]?\d+\.\d+E[+-]\d+'
        $rowPattern = '(?m)^\s*(' + $number + ')\s+(' + $number + ')\s+(' +
            $number + ')\s+(' + $number + ')\s+(' + $number + ')\s+(' + $number + ')'
        $rows = [regex]::Matches($log, $rowPattern)
        if ($rows.Count -lt 250 -or -not (Test-Path -LiteralPath $datPath -PathType Leaf) -or
            (Get-Item -LiteralPath $datPath).Length -le 128) {
            throw "$tag missing useful PRINT/DAT data: rows=$($rows.Count)."
        }
        $culture = [Globalization.CultureInfo]::InvariantCulture
        $after = New-Object System.Collections.Generic.List[double]
        $pre = New-Object System.Collections.Generic.List[double]
        $post = New-Object System.Collections.Generic.List[double]
        $finalVin1 = 0.0
        $finalVin2 = 0.0
        $finalVout = 0.0
        foreach ($row in $rows) {
            $time = [double]::Parse($row.Groups[1].Value, $culture)
            $vin1 = [double]::Parse($row.Groups[2].Value, $culture)
            $vin2 = [double]::Parse($row.Groups[3].Value, $culture)
            $vout = [double]::Parse($row.Groups[5].Value, $culture)
            if ($time -ge 0.0008 -and $time -le 0.00095) { $pre.Add($vout) }
            if ($time -ge 0.001 -and $time -le 0.003001) { $after.Add($vout) }
            if ($time -ge 0.0028 -and $time -le 0.003001) { $post.Add($vout) }
            $finalVin1 = $vin1
            $finalVin2 = $vin2
            $finalVout = $vout
        }
        if ($after.Count -lt 100 -or $pre.Count -lt 100 -or $post.Count -lt 100) {
            throw "$tag missing pre/post transfer windows; rows=$($rows.Count)."
        }
        $minVout = ($after | Measure-Object -Minimum).Minimum
        $preAvg = ($pre | Measure-Object -Average).Average
        $postAvg = ($post | Measure-Object -Average).Average
        $validPre = ($preAvg -ge 4.5 -and ($pre | Measure-Object -Minimum).Minimum -ge 4.5)
        $status = if ($validPre) { 'PRE_UNPLUG_5V_ESTABLISHED' } else { 'PRE_UNPLUG_NOT_ESTABLISHED_NO_TRANSFER_CLAIM' }
        $line = "CASE=$tag; STATUS=$status; rows=$($rows.Count); " +
            "pre0p8to0p95ms_mean=$([math]::Round($preAvg,6))V; " +
            "post2p8to3ms_mean=$([math]::Round($postAvg,6))V; " +
            "post1ms_min=$([math]::Round($minVout,6))V; " +
            "final_VIN1=$([math]::Round($finalVin1,6))V; " +
            "final_VIN2=$([math]::Round($finalVin2,6))V; " +
            "final_VIN_MUX=$([math]::Round($finalVout,6))V; seconds=$([math]::Round($clock.Elapsed.TotalSeconds,2))"
        $results.Add($line)
        Write-Host $line
        if ($validPre) {
            if ($minVout -lt 1.65) {
                $results.Add("CASE=$tag; FLAG=TRANSFER_WINDOW_VIN_MUX_BELOW_1P65_IDEAL_FIXTURE_ONLY")
            }
            if ($postAvg -lt (([double]$case.Vin2) * 0.85)) {
                $results.Add("CASE=$tag; FLAG=NO_SETTLED_VIN2_TRANSFER_IN_VENDOR_MODEL_FIXTURE")
            }
        } else {
            $results.Add("CASE=$tag; FLAG=NO_VALID_PRE_UNPLUG_STATE; DO_NOT_INTERPRET_HANDOFF_DIP")
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
        'SIX_VENDOR_MODEL_DIAGNOSTIC_TRACES_CAPTURED'
    } else {
        "PARTIAL_DIAGNOSTIC_TRACES_$($completed)_OF_$($cases.Count)"
    }
} catch {
    $overall = 'DIAGNOSTIC_MATRIX_INCOMPLETE'
    $results.Add("ERROR=$($_.Exception.Message)")
} finally {
    @(
        'T25AB v2 - isolated TI TPS2116 model diagnostic matrix',
        "STATUS=$overall",
        "TIME=$(Get-Date -Format o)",
        "MODEL_SHA256=$modelSha",
        'INTERPRETATION: numerical traces are conditional fixture evidence, never a real AA startup or integrated 3V3 PASS.',
        'INTERPRETATION: first establish a stable pre-unplug 5V output; without it a transfer dip has no meaning.',
        'INTERPRETATION: TI has documented unexpected VIN2-first behavior in TPS2116 SPICE vs physical device; even solver success cannot certify hardware.',
        $results.ToArray()
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    $files.Add($report)
    if (Test-Path -LiteralPath $manifest -PathType Leaf) { $files.Add($manifest) }
    foreach ($pattern in @('*.cir','*.out','*.console.txt','*.stderr.txt')) {
        foreach ($f in @(Get-ChildItem -LiteralPath $work -File -Filter $pattern -ErrorAction SilentlyContinue)) {
            if (-not $files.Contains($f.FullName)) { $files.Add($f.FullName) }
        }
    }
    $present = @($files.ToArray() | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    Compress-Archive -LiteralPath $present -DestinationPath $resultZip -Force
    Write-Host "STATUS: $overall"
    Write-Host "RESULT ZIP: $resultZip"
    Write-Host 'Share this ZIP for waveform interpretation. Do not treat solver completion as hardware PASS.'
}
