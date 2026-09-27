# T25AA v1 - Official TPS2116 PSpice 25.1 USB hard-unplug / 1.8V AA fixture.
# This is a real vendor-model simulation of the mux only, not the full board.
# All source, load and capacitor values below are declared test fixtures.
# PowerShell 5.1 ASCII source. No Altium/CAD or project files are changed.
$ErrorActionPreference = 'Stop'
$modelSha = '730DD922475B68183CB2D3ECAC3259C8F5637E6458764CED7F3FBC0C89DA80A7'
$psp = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$documents = [Environment]::GetFolderPath('MyDocuments')
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25AA_v1_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25AA_v1_Result_$stamp.zip"
$report = Join-Path $work 'T25AA_v1_Result.txt'
$manifest = Join-Path $work 'T25AA_v1_Manifest.txt'
$archive = Join-Path $work 'SLVMDI4A.ZIP'
$vendor = Join-Path $work 'vendor'
$model = Join-Path $vendor 'TPS2116_PSPICE_TRANS\TPS2116_TRANS.LIB'
$files = New-Object System.Collections.Generic.List[string]
$results = New-Object System.Collections.Generic.List[string]
$overall = 'NOT_RUN'

New-Item -ItemType Directory -Path $work -Force | Out-Null
Write-Host 'T25AA v1: verified TI vendor model; two bounded 3 ms transient runs.'
Write-Host 'This fixture does not certify battery/OVP/converter/3V3 hardware.'

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
        'T25AA v1 / real TI TPS2116 TRANS.LIB isolated model',
        "MODEL_SHA256=$modelSha",
        'LIVE_01_POWER_SCHDOC_BLOB=da2d005712c47000eb8c16157eca464d3fee4fe1',
        'VIN1=ideal 5V -> 0V hard-unplug fixture during 1.000-1.010 ms; not a measured USB waveform',
        'VIN2=ideal fixed 1.8V at TPS2116 pin; original historical 1.8V was loaded AA pack BEFORE board-path drops',
        'MODE=VIN1; PR1=30k/10k from live SchDoc; VOUT pins tied to VIN_MUX',
        'ST: historical R_ST_PU DNP initially; numeric 1G-ohm reference to GND only, not physical pull-up',
        'MUX load=3.3 ohm purely resistive; at 1.8V this draws 0.545A and 0.982W if VOUT reaches 1.8V',
        '3V3 design power=3.3V*0.28A=0.924W; actual converter efficiency/current are unknown',
        'C_IN tested 22uF nameplate and 4.2uF illustrative; neither is verified effective capacitance',
        'No actual USB path, fuse/holder ESR, TS431/PNP/PFET OVP, TPS631000 startup or SD/OLED load',
        'PSpice .TRAN 3ms; max runtime 120s per case; raw DAT included when <=24MiB'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    foreach ($case in @(@{ Tag = 'CIN_22U_NAMEPLATE'; Cap = '22u' },
                       @{ Tag = 'CIN_4P2U_ILLUSTRATION'; Cap = '4.2u' })) {
        $tag = $case.Tag
        $deckPath = Join-Path $work "$tag.cir"
        $outPath = Join-Path $work "$tag.out"
        $datPath = Join-Path $work "$tag.dat"
        $console = Join-Path $work "$tag.console.txt"
        $stderr = Join-Path $work "$tag.stderr.txt"
        $deck = @'
T25AA OFFICIAL TPS2116 hard-unplug FIXTURE - no full-board qualification
* Ideal 5V VIN1 hard-unplug 1.000-1.010ms; ideal fixed 1.8V VIN2.
* Actual 30k/10k PR1 and MODE=VIN1; 3.3-ohm fixture load.
* ST has 1G numeric leakage instead of unpopulated R_ST_PU.
.LIB "@MODEL@"
V_USB_FIXTURE VIN1 0 PWL(0 5 1m 5 1.01m 0 3m 0)
V_BAT_FIXTURE VIN2 0 1.8
R_PR_TOP VIN1 PR1 30k
R_PR_BOTTOM PR1 0 10k
R_ST_NUM ST 0 1G
X_U_PMUX 0 VIN1 PR1 ST VIN1 VIN2 VIN_MUX VIN_MUX TPS2116_TRANS
C_IN VIN_MUX 0 @CAP@
R_LOAD_FIXTURE VIN_MUX 0 3.3
.TRAN 0 3m 0 1u SKIPBP
.OPTIONS ADVCONV
.PROBE64 V([VIN1]) V([VIN2]) V([PR1]) V([VIN_MUX]) V([ST])
.PRINT TRAN V([VIN1]) V([VIN2]) V([PR1]) V([VIN_MUX]) V([ST])
.END
'@
        $deck.Replace('@MODEL@', $model).Replace('@CAP@', $case.Cap) |
            Set-Content -LiteralPath $deckPath -Encoding Ascii
        Write-Host "PSpice: $tag (120-second time limit)"
        $proc = Start-Process -FilePath $psp -ArgumentList @('-r', ('"' + $deckPath + '"')) `
            -WorkingDirectory $work -RedirectStandardOutput $console `
            -RedirectStandardError $stderr -PassThru -NoNewWindow
        $clock = [Diagnostics.Stopwatch]::StartNew()
        while (-not $proc.WaitForExit(2000)) {
            if ($clock.Elapsed.TotalSeconds -ge 120) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                $proc.WaitForExit(10000) | Out-Null
                throw "$tag exceeded 120s. No completed simulation."
            }
        }
        if (-not (Test-Path -LiteralPath $outPath -PathType Leaf)) {
            throw "$tag has no PSpice OUT log. See console/stderr."
        }
        $log = Get-Content -LiteralPath $outPath -Raw
        $errors = [regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
        $warnings = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
        if ($proc.ExitCode -ne 0 -or $errors -gt 0 -or $warnings -gt 0 -or
            $log -notmatch '(?im)^\s*JOB CONCLUDED\s*$' -or
            $log -notmatch '(?i)Total job time') {
            throw "$tag solver incomplete: exit=$($proc.ExitCode), errors=$errors, warnings=$warnings."
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
        $finalVin1 = 0.0
        $finalVin2 = 0.0
        $finalVout = 0.0
        foreach ($row in $rows) {
            $time = [double]::Parse($row.Groups[1].Value, $culture)
            $vin1 = [double]::Parse($row.Groups[2].Value, $culture)
            $vin2 = [double]::Parse($row.Groups[3].Value, $culture)
            $vout = [double]::Parse($row.Groups[5].Value, $culture)
            if ($time -ge 0.001 -and $time -le 0.003001) { $after.Add($vout) }
            $finalVin1 = $vin1
            $finalVin2 = $vin2
            $finalVout = $vout
        }
        if ($after.Count -lt 100) {
            throw "$tag no transfer-window data; rows=$($rows.Count)."
        }
        $minVout = ($after | Measure-Object -Minimum).Minimum
        $line = "CASE=$tag; STATUS=MODEL_TRACE_CAPTURED; rows=$($rows.Count); " +
            "post1ms_VIN_MUX_min=$([math]::Round($minVout,6))V; " +
            "final_VIN1=$([math]::Round($finalVin1,6))V; " +
            "final_VIN2=$([math]::Round($finalVin2,6))V; " +
            "final_VIN_MUX=$([math]::Round($finalVout,6))V; seconds=$([math]::Round($clock.Elapsed.TotalSeconds,2))"
        $results.Add($line)
        Write-Host $line
        if ($minVout -lt 1.65) {
            $results.Add("CASE=$tag; FLAG=VIN_MUX_BELOW_1P65_IN_THIS_IDEAL_FIXTURE")
        }
        foreach ($f in @($deckPath, $outPath, $console, $stderr)) { $files.Add($f) }
        if ((Get-Item -LiteralPath $datPath).Length -le 24MB) { $files.Add($datPath) }
    }
    $overall = 'TWO_VENDOR_MODEL_FIXTURES_COMPLETED'
} catch {
    $overall = 'NO_COMPLETE_TWO_CASE_RESULT'
    $results.Add("ERROR=$($_.Exception.Message)")
} finally {
    @(
        'T25AA v1 - isolated REAL TI TPS2116 vendor-model PSpice simulation',
        "STATUS=$overall",
        "TIME=$(Get-Date -Format o)",
        "MODEL_SHA256=$modelSha",
        'INTERPRETATION: numerical traces are conditional fixture evidence, never a real AA startup or integrated 3V3 PASS.',
        'INTERPRETATION: VIN_MUX <1.65V here flags possible risk; >=1.65V here does not prove physical safe startup.',
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
