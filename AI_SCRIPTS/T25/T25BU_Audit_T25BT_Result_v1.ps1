# T25BU v1: independent raw-table audit of the existing T25BT ZIP.
# PowerShell 5.1; no PSpice rerun, no CAD edit, no external packages.
param([Parameter(Mandatory=$true)][string]$ZipPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$culture = [Globalization.CultureInfo]::InvariantCulture
$num = '[+-]?\d+(?:\.\d+)?E[+-]\d+'
function Read-ZipText($entry) {
    $stream = $entry.Open()
    $reader = New-Object IO.StreamReader($stream)
    try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
}
function Parse-Rows([string]$part,[int]$columns) {
    $pattern = '(?m)^\s*' + (($num + '\s+') * ($columns - 1)) + $num + '\s*$'
    $rows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($match in [regex]::Matches($part,$pattern)) {
        $values = @([regex]::Matches($match.Value,$num) | ForEach-Object { [double]::Parse($_.Value,$culture) })
        if ($values.Count -eq $columns -and $values[0] -ge 0 -and $values[0] -le 40.001e-6) { $rows.Add($values) }
    }
    return ,$rows
}
function Range-Stats($items,[int]$col) {
    $values = @($items | ForEach-Object { $_[$col] })
    if ($values.Count -eq 0) { throw 'Missing waveform samples in a required interval' }
    $measure = $values | Measure-Object -Minimum -Maximum -Average
    return $measure
}
$zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ZipPath).Path)
try {
    $hash = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash
    Write-Output "T25BU_RAW_AUDIT_V1 ZIP_SHA256=$hash"
    $caseNames = @('VIN_1P8V','VIN_2P8V_CONTROL')
    $summaries = @($zip.Entries | Where-Object { $_.Name -eq 'T25BT_v1_Summary.txt' })
    if ($summaries.Count -eq 1) {
        Write-Output '--- ORIGINAL SUMMARY (not independent evidence) ---'
        Write-Output (Read-ZipText $summaries[0])
    }
    foreach ($caseName in $caseNames) {
        $matches = @($zip.Entries | Where-Object { $_.Name -eq ($caseName + '.out') })
        if ($matches.Count -ne 1) { throw "Expected one raw .out for $caseName; found $($matches.Count)" }
        $out = Read-ZipText $matches[0]
        $concluded = [regex]::IsMatch($out,'(?im)^\s*JOB CONCLUDED\s*$')
        $errors = [regex]::Matches($out,'(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)').Count
        $warnings = [regex]::Matches($out,'(?im)^\s*WARNING\(').Count
        $vh = [regex]::Match($out,'(?im)^\s*TIME\s+V\(VIN\)\s+V\(VOUT\)\s+V\(FB\)\s*$')
        $ch = [regex]::Match($out,'(?im)^\s*TIME\s+I\(V_TEST\)\s*$')
        if (-not $vh.Success -or -not $ch.Success -or $ch.Index -le $vh.Index) {
            throw "$caseName: separate V(VIN)/V(VOUT)/V(FB) and I(V_TEST) PRINT headers missing or reversed"
        }
        $voltage = Parse-Rows ($out.Substring($vh.Index,$ch.Index-$vh.Index)) 4
        $current = Parse-Rows ($out.Substring($ch.Index)) 2
        if ($voltage.Count -lt 1000 -or $current.Count -lt 1000) { throw "$caseName: insufficient independent raw tables, V=$($voltage.Count) I=$($current.Count)" }
        $pre = @($voltage | Where-Object { $_[0] -ge 7e-6 -and $_[0] -le 9.8e-6 })
        $post = @($voltage | Where-Object { $_[0] -ge 10e-6 -and $_[0] -le 40e-6 })
        $postCurrent = @($current | Where-Object { $_[0] -ge 10e-6 -and $_[0] -le 40e-6 })
        if ($pre.Count -lt 100 -or $post.Count -lt 500 -or $postCurrent.Count -lt 500) {
            throw "$caseName: missing required pre/post waveform samples"
        }
        $p = Range-Stats $pre 2
        $q = Range-Stats $post 2
        $iv = Range-Stats $postCurrent 1
        $vin = Range-Stats $post 1
        $preValid = $p.Minimum -ge 3.15 -and $p.Maximum -le 3.45 -and ($p.Maximum-$p.Minimum) -le 0.08
        $gate = if (-not $concluded -or $errors -gt 0) { 'SOLVER_INVALID' } elseif (-not $preValid) { 'PRESTATE_INVALID_REJECT_LOADSTEP' } else { 'PRESTATE_VALID_AUDIT_LOADSTEP_ONLY' }
        $sourcePeak = [math]::Max([math]::Abs($iv.Minimum),[math]::Abs($iv.Maximum))
        $line = @(
          "CASE=$caseName","GATE=$gate","CONCLUDED=$concluded","ERRORS=$errors","WARNINGS=$warnings",
          "V_ROWS=$($voltage.Count)","I_ROWS=$($current.Count)",
          ('PRE_MIN_V={0:F6}' -f $p.Minimum),('PRE_MAX_V={0:F6}' -f $p.Maximum),
          ('PRE_SPAN_V={0:F6}' -f ($p.Maximum-$p.Minimum)),
          ('POST_MIN_V={0:F6}' -f $q.Minimum),
          ('POST_END_V={0:F6}' -f $post[-1][2]),
          ('VIN_POST_MIN_V={0:F6}' -f $vin.Minimum),
          ('SOURCE_PEAK_ABS_A={0:F6}' -f $sourcePeak),
          'SOURCE_SIGN_IS_PSPICE_REFERENCE','NO_BOARD_PASS'
        ) -join '; '
        Write-Output $line
    }
} finally { $zip.Dispose() }
