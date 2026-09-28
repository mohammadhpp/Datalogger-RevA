# T25BJ v2 - official TI TPS22918 bounded transient sweep.
# ASCII-only PowerShell 5.1. No Altium or BOM files are modified.
$ErrorActionPreference = 'Stop'

$expectedTiZipHash = 'C3CFE13A6AA72AFE2FCA9DEC791A6DD4D9B591B6C136C16FAC910F74E153CF00'
$expectedModelHash = 'DE4D6521D9E6AE4C6352D52FE26BFFC16A9B5AD91C3CFAC6E75E9EF5B1545FBA'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BJ_Sweep_v2_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25BJ_Sweep_v2_Result_$stamp.zip"
$manifest = Join-Path $work 'T25BJ_v2_Manifest.txt'
$summary = Join-Path $work 'T25BJ_v2_Summary.csv'
$modelZip = Join-Path $work 'TI_SLVMBI6.zip'
$modelRoot = Join-Path $work 'vendor'
$caseLimitSeconds = 90
$culture = [Globalization.CultureInfo]::InvariantCulture

New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25BJ v2: official TPS22918 model sweep.'
Write-Host 'Wait for RESULT ZIP. No Altium files are modified.'

function Get-TiZip {
    param([string]$Destination)
    $preflight = Get-ChildItem -LiteralPath $documents -Filter 'Datalogger_T25BJ_Model_Preflight_v1_Result_*.zip' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($preflight) {
        $tmp = Join-Path $work 'preflight_extract'
        Expand-Archive -LiteralPath $preflight.FullName -DestinationPath $tmp -Force
        $nested = Get-ChildItem -LiteralPath $tmp -Filter 'TI_SLVMBI6.zip' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($nested) {
            Copy-Item -LiteralPath $nested.FullName -Destination $Destination -Force
            return "PREFLIGHT_RESULT=$($preflight.FullName)"
        }
    }

    foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMBI6*.zip' -File -ErrorAction SilentlyContinue)) {
        $h = (Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($h -eq $expectedTiZipHash) {
            Copy-Item -LiteralPath $candidate.FullName -Destination $Destination -Force
            return "USER_DOWNLOAD=$($candidate.FullName)"
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMBI6' -OutFile $Destination -UseBasicParsing
    return 'DIRECT_TI_HTTPS=https://www.ti.com/lit/zip/SLVMBI6'
}

try {
    if (-not (Test-Path -LiteralPath $psp -PathType Leaf)) {
        throw "PSpice not found: $psp"
    }

    $sourceMode = Get-TiZip -Destination $modelZip
    $actualTiHash = (Get-FileHash -LiteralPath $modelZip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualTiHash -ne $expectedTiZipHash) {
        throw "TI ZIP hash mismatch: $actualTiHash"
    }

    Expand-Archive -LiteralPath $modelZip -DestinationPath $modelRoot -Force
    $model = Get-ChildItem -LiteralPath $modelRoot -Filter 'TPS22918_TRANS.LIB' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $model) { throw 'TPS22918_TRANS.LIB missing from TI package.' }

    $actualModelHash = (Get-FileHash -LiteralPath $model.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualModelHash -ne $expectedModelHash) {
        throw "TPS22918 model hash mismatch: $actualModelHash"
    }

    $modelText = Get-Content -LiteralPath $model.FullName -Raw
    if ($modelText -notmatch '(?im)^\.SUBCKT\s+TPS22918_TRANS\s+VIN\s+ON\s+CT\s+VOUT\s+QOD\s+GND\s*$') {
        throw 'TPS22918 subcircuit pin order differs from audited interface.'
    }

    @(
        'T25BJ v2 - official TI TPS22918 bounded sweep',
        "TIME=$(Get-Date -Format o)",
        "SOURCE=$sourceMode",
        "TI_ZIP_SHA256=$actualTiHash",
        "MODEL_SHA256=$actualModelHash",
        'SUBCKT=TPS22918_TRANS VIN ON CT VOUT QOD GND',
        'VIN fixture = ideal 3.3V source through 0.1ohm; no current limit.',
        'VIN local bypass = 1uF.',
        'CT = 2.2nF, 4.7nF, 10nF at nominal CSD=54.1uF.',
        'Extra CSD sensitivity = 27.05uF at CT=4.7nF.',
        'Load stimuli are resistors equivalent to 0/100/200/400mA at 3.3V.',
        'ON rises at 0.1ms and falls at 25.1ms. Total transient = 35ms.',
        'This fixture validates load-switch behavior only.',
        'NO TPS631000 / NO TPS2116 / NO REAL CARD MODEL / NO BOARD PASS.',
        'CAD_UNCHANGED / FABRICATION_HOLD'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    'Case,CT_nF,CSD_uF,Load_mA_at_3V3,Status,Rise10_90_ms,T_to_2V7_ms,VIN_min_V,I_source_peak_A,VOUT_preoff_V,QOD_to_0V5_ms,Rows,Warnings,Errors' |
        Set-Content -LiteralPath $summary -Encoding Ascii

    $cases = New-Object System.Collections.Generic.List[object]
    foreach ($ct in @(2.2,4.7,10.0)) {
        foreach ($load in @(0,100,200,400)) {
            $cases.Add([pscustomobject]@{ Ct=$ct; Csd=54.1; Load=$load })
        }
    }
    foreach ($load in @(0,100,200,400)) {
        $cases.Add([pscustomobject]@{ Ct=4.7; Csd=27.05; Load=$load })
    }

    $completed = 0
    foreach ($case in $cases) {
        $ctTag = $case.Ct.ToString('0.0',$culture).Replace('.','P')
        $csdTag = $case.Csd.ToString('0.00',$culture).Replace('.','P')
        $tag = 'CT_' + $ctTag + 'n_CSD_' + $csdTag + 'u_LOAD_' + $case.Load + 'mA'

        $cir = Join-Path $work ($tag + '.cir')
        $out = Join-Path $work ($tag + '.out')
        $console = Join-Path $work ($tag + '.console.txt')
        $stderr = Join-Path $work ($tag + '.stderr.txt')
        $loadR = if ($case.Load -eq 0) { '1G' } else { (3.3 / ($case.Load / 1000.0)).ToString('0.############',$culture) }

        $deck = @'
T25BJ official TPS22918 controlled-inrush fixture - NO BOARD PASS
.LIB "@MODEL@"
V_SRC SRC 0 3.3
R_SRC SRC VIN 0.1
C_IN VIN 0 1u
V_ON ON 0 PULSE(0 3.3 100u 1u 1u 25m 50m)
C_CT CT 0 @CT@n
C_SD VOUT 0 @CSD@u
R_CARD VOUT 0 @RLOAD@
X_SW VIN ON CT VOUT VOUT 0 TPS22918_TRANS
.TRAN 0 35m 0 5u
.OPTIONS ADVCONV
.PROBE64 V([SRC]) V([VIN]) V([VOUT]) V([ON]) V([CT])
.PRINT TRAN V([SRC]) V([VIN]) V([VOUT]) V([ON]) V([CT]) I(V_SRC)
.END
'@

        $deck = $deck.Replace('@MODEL@',$model.FullName).
            Replace('@CT@',$case.Ct.ToString('0.############',$culture)).
            Replace('@CSD@',$case.Csd.ToString('0.############',$culture)).
            Replace('@RLOAD@',$loadR)
        $deck | Set-Content -LiteralPath $cir -Encoding Ascii

        Write-Host "Running $tag ..."
        $status = 'INCOMPLETE'
        $rise = ''
        $t27 = ''
        $vinMin = ''
        $ipeak = ''
        $preoff = ''
        $qod = ''
        $rowCount = 0
        $warnings = -1
        $errors = -1

        try {
            $proc = Start-Process -FilePath $psp -ArgumentList @('-r',('"' + $cir + '"')) -WorkingDirectory $work -RedirectStandardOutput $console -RedirectStandardError $stderr -PassThru -NoNewWindow
            $watch = [Diagnostics.Stopwatch]::StartNew()
            while (-not $proc.WaitForExit(2000)) {
                if ($watch.Elapsed.TotalSeconds -ge $caseLimitSeconds) {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                    $proc.WaitForExit(5000) | Out-Null
                    throw "$tag exceeded $caseLimitSeconds seconds"
                }
            }

            if (-not (Test-Path -LiteralPath $out -PathType Leaf)) {
                throw "$tag produced no OUT log"
            }

            $log = Get-Content -LiteralPath $out -Raw
            $errors = [regex]::Matches($log,'(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
            $warnings = [regex]::Matches($log,'(?im)^\s*WARNING\(').Count
            if ($errors -gt 0 -or $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$') {
                throw "$tag incomplete: errors=$errors warnings=$warnings"
            }

            $num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
            $rows = [regex]::Matches($log,'(?m)^\s*('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')\s+('+$num+')')
            $rowCount = $rows.Count
            if ($rowCount -lt 5000) {
                throw "$tag insufficient PRINT rows: $rowCount"
            }

            $samples = New-Object System.Collections.Generic.List[object]
            foreach ($row in $rows) {
                $samples.Add([pscustomobject]@{
                    T = [double]::Parse($row.Groups[1].Value,$culture)
                    SRC = [double]::Parse($row.Groups[2].Value,$culture)
                    VIN = [double]::Parse($row.Groups[3].Value,$culture)
                    VOUT = [double]::Parse($row.Groups[4].Value,$culture)
                    ON = [double]::Parse($row.Groups[5].Value,$culture)
                    CT = [double]::Parse($row.Groups[6].Value,$culture)
                    ISRC = [math]::Abs([double]::Parse($row.Groups[7].Value,$culture))
                })
            }

            $afterOn = @($samples | Where-Object { $_.T -ge 0.0001 -and $_.T -lt 0.0251 })
            $preOff = @($samples | Where-Object { $_.T -ge 0.0240 -and $_.T -lt 0.0250 })
            $afterOff = @($samples | Where-Object { $_.T -ge 0.0251 })

            $cross10 = $afterOn | Where-Object { $_.VOUT -ge 0.33 } | Select-Object -First 1
            $cross90 = $afterOn | Where-Object { $_.VOUT -ge 2.97 } | Select-Object -First 1
            $cross27 = $afterOn | Where-Object { $_.VOUT -ge 2.70 } | Select-Object -First 1
            $cross05 = $afterOff | Where-Object { $_.VOUT -le 0.50 } | Select-Object -First 1

            if ($cross10 -and $cross90) {
                $rise = (($cross90.T - $cross10.T) * 1000.0).ToString('0.######',$culture)
            }
            if ($cross27) {
                $t27 = (($cross27.T - 0.0001) * 1000.0).ToString('0.######',$culture)
            }

            $vinMinVal = ($afterOn | Measure-Object -Property VIN -Minimum).Minimum
            $iPeakVal = ($afterOn | Measure-Object -Property ISRC -Maximum).Maximum
            $preoffVal = ($preOff | Measure-Object -Property VOUT -Average).Average
            $vinMin = ([double]$vinMinVal).ToString('0.######',$culture)
            $ipeak = ([double]$iPeakVal).ToString('0.######',$culture)
            $preoff = ([double]$preoffVal).ToString('0.######',$culture)

            if ($cross05) {
                $qod = (($cross05.T - 0.0251) * 1000.0).ToString('0.######',$culture)
            }

            if (-not $cross90) {
                $status = 'NO_90PCT_BEFORE_OFF'
            } elseif (-not $cross05) {
                $status = 'NO_QOD_0P5_BY_35MS'
            } else {
                $status = 'TRACE_COMPLETE'
            }

            $completed++
        } catch {
            $status = 'ERROR_' + ($_.Exception.Message.Replace(',',';'))
            Write-Host $status
        }

        $line = @(
            $tag,
            $case.Ct.ToString('0.###',$culture),
            $case.Csd.ToString('0.###',$culture),
            $case.Load,
            $status,
            $rise,
            $t27,
            $vinMin,
            $ipeak,
            $preoff,
            $qod,
            $rowCount,
            $warnings,
            $errors
        ) -join ','
        Add-Content -LiteralPath $summary -Encoding Ascii -Value $line
        Write-Host $line
    }

    Add-Content -LiteralPath $manifest -Encoding Ascii -Value "COMPLETED_CASES=$completed"
    Add-Content -LiteralPath $manifest -Encoding Ascii -Value "TOTAL_CASES=$($cases.Count)"
    Add-Content -LiteralPath $manifest -Encoding Ascii -Value 'Interpretation rule: TRACE_COMPLETE is a fixture-completion label, never a board PASS.'

} catch {
    "GLOBAL_ERROR=$($_.Exception.Message)" | Add-Content -LiteralPath $manifest -Encoding Ascii
} finally {
    $present = @(
        Get-ChildItem -LiteralPath $work -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -ne 'TI_SLVMBI6.zip' -and
            $_.Extension -ne '.dat'
        } |
        Select-Object -ExpandProperty FullName
    )

    if ($present.Count -gt 0) {
        Compress-Archive -LiteralPath $present -DestinationPath $resultZip -Force
    }

    Write-Host "RESULT ZIP: $resultZip"
}
