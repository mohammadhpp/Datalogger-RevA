# ASCII / Windows PowerShell 5.1. New USB-only model, no RevA PASS.
$ErrorActionPreference = 'Stop'
$engine = 'C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe'
$work = Join-Path ([Environment]::GetFolderPath('MyDocuments')) ('Datalogger_T25CF_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $work | Out-Null
$results = @()
$watch = [Diagnostics.Stopwatch]::StartNew()
$status = 'PREPARATION_FAILED'
function Get-VoutRows([string]$path) {
    $rows = New-Object System.Collections.Generic.List[object]
    $columns = @()
    foreach ($line in (Get-Content -LiteralPath $path)) {
        $tokens = @($line.Trim() -split '\s+' | Where-Object { $_ })
        if ($tokens.Count -eq 0) { continue }
        if ($tokens[0] -eq 'TIME') { $columns = @($tokens | Select-Object -Skip 1); continue }
        $idx = -1
        for ($j=0; $j -lt $columns.Count; $j++) {
            if ($columns[$j] -match '^V\(\[?VOUT\]?\)$') { $idx = $j }
        }
        # Read each PRINT table independently. Never consume the next row's TIME.
        if ($idx -lt 0 -or $tokens.Count -ne ($columns.Count+1)) { continue }
        $time = 0.0; $value = 0.0
        $style = [Globalization.NumberStyles]::Float
        $culture = [Globalization.CultureInfo]::InvariantCulture
        if ([double]::TryParse($tokens[0], $style, $culture, [ref]$time) -and
            [double]::TryParse($tokens[$idx+1], $style, $culture, [ref]$value)) {
            $rows.Add([pscustomobject]@{t=$time;v=$value})
        }
    }
    return $rows.ToArray()
}
try {
    if (!(Test-Path -LiteralPath $engine)) { throw "PSpice engine absent: $engine" }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $archive = Join-Path $work 'TI_slvmbj5.zip'
    $libHash = '2410B7F6F64162FFE6C3CA94565396870AA55E4CAFBECCD2382BC2471D933D3D'
    $cached = $null
    $docs = [Environment]::GetFolderPath('MyDocuments')
    $folders = @(Get-ChildItem -LiteralPath $docs -Directory -Filter 'Datalogger_T25CE_*' | Sort-Object LastWriteTime -Descending)
    foreach ($folder in $folders) {
        $candidate = Join-Path $folder.FullName 'TPS54202_TRANS.LIB'
        if ((Test-Path -LiteralPath $candidate) -and (Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash -eq $libHash) { $cached=$candidate; break }
    }
    if ($null -ne $cached) {
        Write-Host 'Reusing SHA256-verified official TI model from prior work folder.'
        Copy-Item -LiteralPath $cached -Destination (Join-Path $work 'TPS54202_TRANS.LIB')
    } else {
        Write-Host 'Downloading pinned official TI TPS54202 model...'
        Invoke-WebRequest -UseBasicParsing -Uri 'https://www.ti.com/lit/zip/slvmbj5' -OutFile $archive -TimeoutSec 60
        if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne '39E524BC2CC9A71A22E8AFB753CCC5F2F8EE16CA0F491763B52BA1EB9C16271B') { throw 'TI ZIP changed; stop for review.' }
        $vendor = Join-Path $work 'vendor'
        Expand-Archive -LiteralPath $archive -DestinationPath $vendor
        $libs = @(Get-ChildItem -LiteralPath $vendor -Recurse -Filter 'TPS54202_TRANS.LIB')
        if ($libs.Count -ne 1) { throw 'Expected exactly one official model library.' }
        if ((Get-FileHash -LiteralPath $libs[0].FullName -Algorithm SHA256).Hash -ne $libHash) { throw 'Official library hash mismatch.' }
        Copy-Item -LiteralPath $libs[0].FullName -Destination (Join-Path $work 'TPS54202_TRANS.LIB')
    }
    $names = @('PILOT_STARTUP_280mA_44uF','LOAD_280mA_CEFF_44uF','LOAD_280mA_CEFF_22uF','LOAD_19mA_CEFF_44uF','LOAD_19mA_CEFF_22uF','LOAD_0mA_CEFF_44uF','LOAD_0mA_CEFF_22uF')
    $status = 'RUNNING'
    Write-Host 'TI package profile: 20ns max step; ABSTOL=10n VNTOL=10u ITL1=1500 ITL2=400 ITL4=100.'
    Write-Host 'No model, electrical component, load or source waveform changed. No automatic retry.'
    foreach ($name in $names) {
        if ($watch.Elapsed.TotalSeconds -gt 900) { $status='TOTAL_TIMEOUT'; break }
        $cir = Join-Path $work ($name+'.cir')
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('T25CF_DECKS\'+$name+'.cir')) -Destination $cir
        Write-Host ('Running '+$name+' (240 second case limit)...')
        $proc = Start-Process -FilePath $engine -ArgumentList @('-r',('"'+$cir+'"')) -WorkingDirectory $work -PassThru -RedirectStandardOutput (Join-Path $work ($name+'.stdout.txt')) -RedirectStandardError (Join-Path $work ($name+'.stderr.txt'))
        $caseBudgetMs = [int][Math]::Min(240000, [Math]::Max(1, (900-$watch.Elapsed.TotalSeconds)*1000))
        $done = $proc.WaitForExit($caseBudgetMs)
        if (!$done) { $proc.Kill(); $proc.WaitForExit(); $status='CASE_TIMEOUT'; $results += [pscustomobject]@{case=$name;status=$status}; break }
        $proc.Refresh()
        $exitCode = $proc.ExitCode
        $out = Join-Path $work ($name+'.out')
        if (!(Test-Path -LiteralPath $out)) { $status='NO_OUTPUT'; $results += [pscustomobject]@{case=$name;status=$status;exit_code=$exitCode}; break }
        $raw = Get-Content -LiteralPath $out -Raw
        $rows = @(Get-VoutRows $out)
        $isPilot = $name -eq 'PILOT_STARTUP_280mA_44uF'
        $preLo = if ($isPilot) { .005 } else { .013 }
        $preHi = if ($isPilot) { .0059 } else { .014 }
        $endRequired = if ($isPilot) { .00599 } else { .0279 }
        $pre = @($rows | Where-Object { $_.t -ge $preLo -and $_.t -le $preHi })
        $min = $null; $max = $null
        if ($pre.Count) { $min=($pre | Measure-Object v -Minimum).Minimum; $max=($pre | Measure-Object v -Maximum).Maximum }
        $errors = @([regex]::Matches($raw,'(?im)^\s*(?:ERROR(?:\(|\s|--)|WARNING(?:\(|\s|--))')).Count
        $end = if ($rows.Count) { ($rows | Measure-Object t -Maximum).Maximum } else { 0 }
        $gate = $raw.Contains('JOB CONCLUDED') -and $errors -eq 0 -and $rows.Count -ge 1000 -and $end -ge $endRequired -and $pre.Count -ge 10 -and $min -ge (3.576*.95) -and $max -le (3.576*1.05)
        # Null ExitCode alone is not a solver failure (T25AB lesson).
        if ($null -ne $exitCode -and $exitCode -ne 0) { $gate=$false }
        $caseStatus = if ($gate) { 'VALID_NUMERICAL_FIXTURE_ONLY' } else { 'INVALID_OR_INCOMPLETE_FIXTURE_STOP' }
        $results += [pscustomobject]@{case=$name;status=$caseStatus;exit_code=$exitCode;rows=$rows.Count;end_s=$end;pre_rows=$pre.Count;pre_min_V=$min;pre_max_V=$max;solver_error_warning_count=$errors}
        if (!$gate) { $status=$caseStatus; break }
    }
    if ($results.Count -eq 7 -and @($results | Where-Object { $_.status -ne 'VALID_NUMERICAL_FIXTURE_ONLY' }).Count -eq 0) { $status='PILOT_AND_SIX_USB_FIXTURES_READY_FOR_INDEPENDENT_AUDIT' }
} catch {
    $_ | Out-String | Set-Content -LiteralPath (Join-Path $work 'preparation_error.txt') -Encoding ASCII
    Write-Host $_ -ForegroundColor Red
} finally {
    [pscustomobject]@{stage='T25CF';status=$status;scope='USB_ONLY_NO_BOARD_OR_TRANSFER_PASS';runtime_s=$watch.Elapsed.TotalSeconds;numerical_profile='TI_20ns_ABSTOL10n_VNTOL10u_ITL1_1500_ITL2_400_ITL4_100';cases=$results;work=$work;zip_sha256='39e524bc2cc9a71a22e8afb753ccc5f2f8ee16ca0f491763b52ba1eb9c16271b';lib_sha256='2410b7f6f64162ffe6c3ca94565396870aa55e4cafbeccd2382bc2471d933d3d'} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $work 'manifest.json') -Encoding UTF8
    $evidence = Join-Path $work 'result_evidence'
    New-Item -ItemType Directory -Path $evidence | Out-Null
    Get-ChildItem -LiteralPath $work -File | Where-Object { $_.Extension -in @('.cir','.out','.txt','.json') } | Copy-Item -Destination $evidence
    $zip = $work+'_Result.zip'
    Compress-Archive -Path (Join-Path $evidence '*') -DestinationPath $zip
    Write-Host ('Result ZIP: '+$zip) -ForegroundColor Green
    Write-Host 'DAT files and official library remain in the work folder. Upload the Result ZIP for independent audit.'
}

