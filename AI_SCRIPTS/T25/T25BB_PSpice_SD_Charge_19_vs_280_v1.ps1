# T25BB v1 - corrected actual PSpice execution of a bounded capacitor-charge fixture.
# ASCII-only PowerShell 5.1. No Altium, BOM or installed library file is changed.
# T25BA v1 stopped at ORPSIM-15142 because the ABM-driven rail lacked a DC topology path.
# This unique stage adds a 1G rail reference and preserves every case result independently.
$ErrorActionPreference = 'Stop'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BB_v1_$stamp"
$zip = Join-Path $documents "Datalogger_T25BB_v1_Result_$stamp.zip"
$report = Join-Path $work 'T25BB_v1_Result.txt'
$manifest = Join-Path $work 'T25BB_v1_Manifest.txt'
$result = New-Object System.Collections.Generic.List[string]
$completed = 0
$culture = [Globalization.CultureInfo]::InvariantCulture
New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25BB: 12 corrected small PSpice cases. Wait for RESULT ZIP.'

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) { throw "PSpice not found: $psp" }
    @(
        'T25BB v1 - ACTUAL PSPICE ENGINE / CORRECTED CONDITIONAL CAPACITOR-ONLY FIXTURE',
        'T25BA v1 stopped at ORPSIM-15142: ABM rail was rejected as floating during DC topology check.',
        'T25BB adds R_RAIL_DC=1G only as a DC reference; at 3.3V it draws 3.3nA.',
        '19mA = old-prototype display reading with unknown bandwidth; NOT RevA peak/background.',
        '280mA = purchased workbook maximum design load; NOT measured peak.',
        'C_OUT=47uF and C_SD=54.1uF are NAMEPLATE values, NOT biased Ceff.',
        'No microSD card current, OLED, TPS631000, TPS2116, AA/USB dynamics or real gate driver.',
        'Source ceilings 0.5/1/1.5A are INSTANT HYPOTHETICAL limits, NOT TI ratings at VIN=1.8V.',
        'Conductance controls 0/100us are scenarios, NOT AO3401A/BC847B gate timing.',
        '2.04V is only the STM32G070 maximum falling PDR screening threshold.',
        'NO BOARD PASS / NO FABRICATION PASS.'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    foreach ($bgmA in @(19,280)) {
        foreach ($imax in @(0.5,1.0,1.5)) {
            foreach ($tau in @(0,100)) {
                $tag = 'BG_' + $bgmA + 'mA_IMAX_' + $imax.ToString('0.0',$culture).Replace('.','P') + 'A_TAU_' + $tau + 'us'
                try {
                    $deckPath = Join-Path $work ($tag + '.cir')
                    $outPath = Join-Path $work ($tag + '.out')
                    $datPath = Join-Path $work ($tag + '.dat')
                    $console = Join-Path $work ($tag + '.console.txt')
                    $stderr = Join-Path $work ($tag + '.stderr.txt')
                    $ibg = ($bgmA / 1000.0).ToString('0.000',$culture)
                    $imaxText = $imax.ToString('0.0',$culture)
                    if ($tau -eq 0) {
                        $control = 'V_CTL CTL 0 PWL(0 0 999.9u 0 1000u 1 2500u 1)'
                    } else {
                        $control = 'V_CTL CTL 0 PWL(0 0 1000u 0 1010u .095163 1025u .221199 1050u .393469 1100u .632121 1200u .864665 1300u .950213 1500u .993262 2500u 1)'
                    }
                    $deck = @'
T25BB corrected conditional SD capacitor-charge fixture - no board verdict
G_SOURCE 0 3V3_SYS VALUE={LIMIT((3.3-V(3V3_SYS))/0.1,0,@IMAX@)}
R_RAIL_DC 3V3_SYS 0 1G
I_BACKGROUND 3V3_SYS 0 @IBG@
C_OUT 3V3_SYS 0 47u
@CONTROL@
G_SD 3V3_SYS SD_VDD VALUE={V(CTL)*(V(3V3_SYS)-V(SD_VDD))/0.05}
C_SD SD_VDD 0 54.1u
R_SD_LEAK SD_VDD 0 1G
.TRAN 0 2500u 0 0.2u
.OPTIONS ADVCONV
.PROBE64 V([3V3_SYS]) V([SD_VDD]) V([CTL])
.PRINT TRAN V([3V3_SYS]) V([SD_VDD]) V([CTL])
.END
'@
                    $deck = $deck.Replace('@IMAX@',$imaxText).Replace('@IBG@',$ibg).Replace('@CONTROL@',$control)
                    $deck | Set-Content -LiteralPath $deckPath -Encoding Ascii
                    Write-Host "Running $tag ..."
                    $proc = Start-Process -FilePath $psp -ArgumentList @('-r',('"' + $deckPath + '"')) -WorkingDirectory $work -RedirectStandardOutput $console -RedirectStandardError $stderr -PassThru -NoNewWindow
                    $clock = [Diagnostics.Stopwatch]::StartNew()
                    while (-not $proc.WaitForExit(500)) {
                        if ($clock.Elapsed.TotalSeconds -ge 45) {
                            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                            $proc.WaitForExit(3000) | Out-Null
                            throw "$tag exceeded 45 seconds"
                        }
                    }
                    if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) { throw "$tag produced no OUT log" }
                    $log = Get-Content -LiteralPath $outPath -Raw
                    $errors = [regex]::Matches($log,'(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
                    $warnings = [regex]::Matches($log,'(?im)^\s*WARNING\(').Count
                    if ($errors -gt 0 -or $warnings -gt 0 -or $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$') {
                        throw "$tag incomplete: errors=$errors warnings=$warnings"
                    }
                    $num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
                    $rows = [regex]::Matches($log,'(?m)^\s*('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')')
                    if ($rows.Count -lt 2000 -or -not (Test-Path -LiteralPath $datPath -PathType Leaf)) {
                        throw "$tag missing waveform evidence: rows=$($rows.Count)"
                    }
                    $minRail = [double]::PositiveInfinity
                    $minTime = 0.0
                    $first27 = $null
                    $lastTime = 0.0
                    foreach ($row in $rows) {
                        $t = [double]::Parse($row.Groups[1].Value,$culture)
                        $rail = [double]::Parse($row.Groups[2].Value,$culture)
                        $sd = [double]::Parse($row.Groups[3].Value,$culture)
                        if ($t -ge 0.001 -and $t -le 0.0025 -and $rail -lt $minRail) {
                            $minRail = $rail
                            $minTime = $t
                        }
                        if ($null -eq $first27 -and $t -ge 0.001 -and $sd -ge 2.7) { $first27 = $t }
                        $lastTime = $t
                    }
                    if ($lastTime -lt 0.00249 -or [double]::IsInfinity($minRail)) { throw "$tag waveform ended early" }
                    $sdTime = if ($null -eq $first27) { 'NOT_REACHED' } else { [math]::Round(($first27-0.001)*1e6,2).ToString($culture) }
                    $line = 'CASE='+$tag+'; MIN_3V3_SYS='+[math]::Round($minRail,6).ToString($culture)+'V; MIN_AFTER_ENABLE_US='+[math]::Round(($minTime-0.001)*1e6,2).ToString($culture)+'; SD_TO_2P7V_US='+$sdTime+'; CONDITIONAL_ONLY; NO_BOARD_PASS'
                    $result.Add($line)
                    Write-Host $line
                    $completed++
                } catch {
                    $line = 'CASE='+$tag+'; ERROR='+$_.Exception.Message+'; NO_BOARD_PASS'
                    $result.Add($line)
                    Write-Host $line
                }
            }
        }
    }
} catch {
    $result.Add('GLOBAL_ERROR='+$_.Exception.Message+'; NO_BOARD_PASS')
} finally {
    $status = if ($completed -eq 12) { 'TWELVE_CONDITIONAL_PSPICE_CASES_COMPLETED' } else { 'INCOMPLETE_' + $completed + '_OF_12' }
    @(
        'T25BB v1 - corrected PSpice 25.1 execution result',
        "STATUS=$status",
        "TIME=$(Get-Date -Format o)",
        'T25BA floating-node topology failure fixed by a 1G rail DC reference.',
        'This isolates nameplate capacitor charge and compares two assumed backgrounds.',
        'It excludes real converter/mux/gate/card/OLED behavior and cannot release fabrication.',
        $result.ToArray()
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    $present = @(Get-ChildItem -LiteralPath $work -File | Where-Object { $_.Extension -ne '.dat' -or $_.Length -le 24MB } | Select-Object -ExpandProperty FullName)
    Compress-Archive -LiteralPath $present -DestinationPath $zip -Force
    Write-Host "STATUS: $status"
    Write-Host "RESULT ZIP: $zip"
}
