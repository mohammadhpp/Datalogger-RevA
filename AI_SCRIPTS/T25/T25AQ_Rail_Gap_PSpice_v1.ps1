# T25AQ v1: actual PSpice numerical simulation of explicitly hypothetical rail gaps.
# ASCII-only PowerShell 5.1. No CAD/BOM files or installed libraries are modified.
$ErrorActionPreference = 'Stop'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25AQ_v1_$stamp"
$zip = Join-Path $documents "Datalogger_T25AQ_v1_Result_$stamp.zip"
$report = Join-Path $work 'T25AQ_v1_Result.txt'
$manifest = Join-Path $work 'T25AQ_v1_Manifest.txt'
$results = New-Object System.Collections.Generic.List[string]
$done = 0
New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25AQ: PSpice isolated output-rail gap and switched SD/OLED scenario.'
Write-Host 'Four cases, 60-second limit PER case. Always wait for RESULT ZIP.'

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw "PSpice engine not found: $psp"
    }
    @(
        'T25AQ v1 - isolated reduced-order PSpice sensitivity simulation; NO HARDWARE PASS',
        'AUTHORITATIVE_POWER_SCHDOC_GIT_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1',
        'V3V3 scenario regulator ramps 0->3.3V over 100us; C_OUT=47uF TDK nameplate, but its actual DC-biased effective C is UNKNOWN.',
        'C_OUT=10.4uF second scenario is TI TPS631000 minimum recommended effective value; actual installed C is NOT verified to meet it.',
        'Actual SD_VDD capacitor nameplate 22+22+10+0.1=54.1uF, OLED_VDD 10+0.1=10.1uF; their effective values are UNKNOWN.',
        'SD/OLED branch resistors are SCENARIO load allocations 100mA/40mA at 3.3V, with 140mA baseline: TOTAL 280mA at 3.3V.',
        'Those branch allocations are NOT measured card or four-pin OLED currents. Resistive loads decrease with droop and are optimistic against constant current.',
        'Illustrative 50mOhm ideal switches and 50mOhm source resistor are NOT AO3401A or TPS631000 validated models.',
        'Regulator source is ideal 3.3V and disconnected for 10us or 50us around 1ms and 2ms; neither gap is a measured nor guaranteed TPS2116/TPS631000 response.',
        'SD switch enables at 0.31ms, OLED at 0.51ms. Both are on during both regulator gaps.',
        'Regulator source missing during a gap forces zero converter delivery; ideal reconnection is NOT a real startup or recovery transient.',
        'USB insertion/removal are represented ONLY by separate output-delivery interruptions; actual VIN_MUX, C_USB1, C_IN, AA source impedance, OVP, TPS2116, TPS631000 and firmware are NOT simulated.',
        'S_RAIL values: RON=0.05ohm, ROFF=1Gohm, VON=2V, VOFF=1V. Branch local capacitors remain separate.',
        'PSpice complete JOB CONCLUDED and printed >=1500 samples required; numerically computed minima must not be labeled board PASS.',
        'STM32G070KBT6 falling PDR max 2.04V at its own VDD pin; conventional microSD VDD floor 2.7V at SD_VDD; WEO 2.8V is conditional bare-panel logic floor, NOT confirmed four-pin module.',
        '19mA was an earlier prototype DMM average with different MCU; 280mA is the v0.17 purchase workbook design envelope, not measured RevA peak.',
        'Existing vendor TPS2116 model handoff discrepancy and VIN2=1.8V/fast USB fall warning remain OPEN; NO FABRICATION PASS.'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii
    $cases = @(
        @{ Tag='COUT_10P4U_GAP_10US'; Cap='10.4u'; Gap=10 },
        @{ Tag='COUT_10P4U_GAP_50US'; Cap='10.4u'; Gap=50 },
        @{ Tag='COUT_47U_NOMINAL_GAP_10US'; Cap='47u'; Gap=10 },
        @{ Tag='COUT_47U_NOMINAL_GAP_50US'; Cap='47u'; Gap=50 }
    )
    $culture = [Globalization.CultureInfo]::InvariantCulture
    foreach ($case in $cases) {
        $tag = $case.Tag
        try {
            $deckPath = Join-Path $work "$tag.cir"
            $outPath = Join-Path $work "$tag.out"
            $datPath = Join-Path $work "$tag.dat"
            $console = Join-Path $work "$tag.console.txt"
            $stderr = Join-Path $work "$tag.stderr.txt"
            $gap1End = (1000 + $case.Gap).ToString($culture) + 'u'
            $gap2End = (2000 + $case.Gap).ToString($culture) + 'u'
            $deck = @'
T25AQ hypothetical downstream rail gap and switched branch loads
* NOT an integrated TPS2116/TPS631000 model or RevA hardware qualification.
V_REG REG_SRC 0 PWL(0 0 100u 3.3 2250u 3.3)
R_REG REG_SRC REG_PATH 0.05
S_REG REG_PATH 3V3_SYS REG_CTL 0 S_RAIL
V_REG_CTL REG_CTL 0 PWL(0 3 999u 3 1000u 0 @GAP1@ 0 @GAP1PLUS@ 3 1999u 3 2000u 0 @GAP2@ 0 @GAP2PLUS@ 3 2250u 3)
C_OUT 3V3_SYS 0 @COUT@
R_BACKGROUND 3V3_SYS 0 23.571428571
S_SD 3V3_SYS SD_VDD SD_CTL 0 S_RAIL
V_SD_CTL SD_CTL 0 PWL(0 0 300u 0 310u 3 2250u 3)
C_SD_HF SD_VDD 0 0.1u
C_SD_MID SD_VDD 0 10u
C_SD_BULK1 SD_VDD 0 22u
C_SD_BULK2 SD_VDD 0 22u
R_SD_FIXTURE SD_VDD 0 33
S_OLED 3V3_SYS OLED_VDD OLED_CTL 0 S_RAIL
V_OLED_CTL OLED_CTL 0 PWL(0 0 500u 0 510u 3 2250u 3)
C_OLED_HF OLED_VDD 0 0.1u
C_OLED_BULK OLED_VDD 0 10u
R_OLED_FIXTURE OLED_VDD 0 82.5
.MODEL S_RAIL VSWITCH(RON=0.05 ROFF=1G VON=2 VOFF=1)
.TRAN 0 2250u 0 1u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([3V3_SYS]) V([SD_VDD]) V([OLED_VDD]) V([REG_CTL])
.PRINT TRAN V([3V3_SYS]) V([SD_VDD]) V([OLED_VDD]) V([REG_CTL])
.END
'@
            $gap1Plus = (1000 + $case.Gap + 1).ToString($culture) + 'u'
            $gap2Plus = (2000 + $case.Gap + 1).ToString($culture) + 'u'
            $deck = $deck.Replace('@COUT@', $case.Cap).Replace('@GAP1PLUS@', $gap1Plus).Replace('@GAP2PLUS@', $gap2Plus).Replace('@GAP1@', $gap1End).Replace('@GAP2@', $gap2End)
            $deck | Set-Content -LiteralPath $deckPath -Encoding Ascii
            Write-Host "Simulating $tag (60-second wall limit) ..."
            $proc = Start-Process -FilePath $psp -ArgumentList @('-r', ('"' + $deckPath + '"')) -WorkingDirectory $work -RedirectStandardOutput $console -RedirectStandardError $stderr -PassThru -NoNewWindow
            $clock = [Diagnostics.Stopwatch]::StartNew()
            while (-not $proc.WaitForExit(1000)) {
                if ($clock.Elapsed.TotalSeconds -ge 60) {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                    $proc.WaitForExit(5000) | Out-Null
                    throw 'PSpice exceeded the 60-second limit; inspect the packaged logs.'
                }
            }
            if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) { throw 'No PSpice OUT log; see console and stderr.' }
            $log = Get-Content -LiteralPath $outPath -Raw
            $errors = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
            $warnings = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
            $proc.Refresh()
            $exitCode = $null
            try { $exitCode = $proc.ExitCode } catch { $exitCode = $null }
            if (($null -ne $exitCode -and $exitCode -ne 0) -or $errors -gt 0 -or $warnings -gt 0 -or
                $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$' -or $log -notmatch '(?i)Total job time') {
                throw "PSpice incomplete: exit=$exitCode errors=$errors warnings=$warnings."
            }
            $num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
            $rowPattern = '(?m)^\s*(' + $num + ')\s+(' + $num + ')\s+(' + $num + ')\s+(' + $num + ')\s+(' + $num + ')'
            $rows = [regex]::Matches($log, $rowPattern)
            if ($rows.Count -lt 1500 -or -not (Test-Path -LiteralPath $datPath -PathType Leaf) -or (Get-Item -LiteralPath $datPath).Length -le 128) {
                throw "Missing waveform samples or DAT file: rows=$($rows.Count)"
            }
            $window1 = New-Object System.Collections.Generic.List[object]
            $window2 = New-Object System.Collections.Generic.List[object]
            $pre1 = New-Object System.Collections.Generic.List[double]
            $lastTime = 0.0
            foreach ($row in $rows) {
                $t = [double]::Parse($row.Groups[1].Value, $culture)
                $v3 = [double]::Parse($row.Groups[2].Value, $culture)
                $vsd = [double]::Parse($row.Groups[3].Value, $culture)
                $voled = [double]::Parse($row.Groups[4].Value, $culture)
                if ($t -ge 0.0009 -and $t -lt 0.00099) { $pre1.Add($v3) }
                $sample = [pscustomobject]@{ Rail=$v3; Sd=$vsd; Oled=$voled }
                if ($t -ge 0.001 -and $t -le (0.001 + $case.Gap * 1.0e-6)) { $window1.Add($sample) }
                if ($t -ge 0.002 -and $t -le (0.002 + $case.Gap * 1.0e-6)) { $window2.Add($sample) }
                $lastTime = $t
            }
            if ($pre1.Count -lt 60 -or $window1.Count -lt 8 -or $window2.Count -lt 8 -or $lastTime -lt 0.00224) {
                throw "Prestate/gap/stop sampling incomplete: pre=$($pre1.Count) gap1=$($window1.Count) gap2=$($window2.Count) last=$lastTime"
            }
            $preMin = ($pre1 | Measure-Object -Minimum).Minimum
            if ($preMin -lt 3.2) { throw "Invalid settled pre-gap 3V3: minimum=$preMin" }
            foreach ($pair in @(@('GAP1',$window1), @('GAP2',$window2))) {
                $values = @(
                    [math]::Round(($pair[1] | Measure-Object -Property Rail -Minimum).Minimum,6).ToString($culture),
                    [math]::Round(($pair[1] | Measure-Object -Property Sd -Minimum).Minimum,6).ToString($culture),
                    [math]::Round(($pair[1] | Measure-Object -Property Oled -Minimum).Minimum,6).ToString($culture)
                )
                $line = "CASE=$tag; EVENT=$($pair[0]); SAMPLES=$($pair[1].Count); MIN_3V3_SYS=$($values[0])V; MIN_SD_VDD=$($values[1])V; MIN_OLED_VDD=$($values[2])V; CONDITIONAL_ONLY; NO_HARDWARE_PASS"
                $results.Add($line)
                Write-Host $line
            }
            $done++
        } catch {
            $line = "CASE=$tag; ERROR=$($_.Exception.Message); NO_HARDWARE_PASS"
            $results.Add($line)
            Write-Host $line
        }
    }
} catch {
    $results.Add("ERROR=$($_.Exception.Message); NO_HARDWARE_PASS")
} finally {
    $status = if ($done -eq 4) { 'FOUR_CONDITIONAL_PSPICE_CASES_COMPLETED' } else { "INCOMPLETE_${done}_OF_4" }
    @(
        'T25AQ v1 - actual PSpice engine / conditional output-gap fixture',
        "STATUS=$status",
        "TIME=$(Get-Date -Format o)",
        'This sim uses named rail topology and nameplate/local capacitor examples; it excludes real mux/converter, AA/USB transients, card/module currents and write integrity.',
        'The 2.04V MCU PDR, 2.7V conventional SD and 2.8V conditional WEO panel references are NOT acceptance of hypothetical gap durations.',
        $results.ToArray()
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    $present = @(Get-ChildItem -LiteralPath $work -File | Where-Object { $_.Extension -ne '.dat' -or $_.Length -le 24MB } | Select-Object -ExpandProperty FullName)
    Compress-Archive -LiteralPath $present -DestinationPath $zip -Force
    Write-Host "STATUS: $status"
    Write-Host "RESULT ZIP: $zip"
    Write-Host 'Upload this ZIP for solver/waveform review. Do not infer board PASS from scenario output.'
}
