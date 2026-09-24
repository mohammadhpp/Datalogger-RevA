# T25D v2: discover the PSpice engine, then run the isolated model smoke.
# This script does not open or modify the Datalogger Altium project.
$ErrorActionPreference = 'Stop'
$expectedHash = 'F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "Datalogger_T25D_$stamp"
New-Item -ItemType Directory -Path $work -Force | Out-Null
$report = Join-Path $work 'T25D_Result.txt'
$zip = Join-Path $work 'SLVMDV2.ZIP'
$cir = Join-Path $work 'T25D_TPS631000_Smoke.cir'
$consoleLog = Join-Path $work 'PSpice_Console.txt'
$diagnostic = Join-Path $work 'T25D_Install_Diagnostic.txt'

function Write-Result([string]$status, [string]$detail) {
    @(
        "T25D STATUS: $status",
        "TIME: $(Get-Date -Format o)",
        "WORKDIR: $work",
        "PSPICE: $psp",
        "DETAIL: $detail",
        'SCOPE: TI model runtime smoke, not Datalogger startup/load-step qualification.',
        'SOURCE: SLVMDV2.ZIP SHA256 F55C75639AD5B62C5437EC114301905FE6C63408CDB689825EB542C095ECD946.'
    ) | Set-Content -LiteralPath $report -Encoding UTF8
    Write-Host "`n$status : $detail"
    Write-Host "Report: $report"
}

try {
    # Confirmed by the user's 2026-09-24 Windows search screenshot.
    $candidates = @('C:\Cadence\OrCADX_25.1\tools\bin\psp_cmd.exe')
    $scanRoots = @()
    $notes = @('T25D PSpice installation discovery (read-only)',
               'No license keys, serials or environment variable values are collected.')
    $notes += 'CDS_INST_DIR: ' + $(if ($env:CDS_INST_DIR) { 'present' } else { 'absent' })
    $notes += 'CDS_LIC_FILE: ' + $(if ($env:CDS_LIC_FILE) { 'present' } else { 'absent' })
    if ($env:CDS_INST_DIR) { $scanRoots += $env:CDS_INST_DIR }
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem)) {
        # Search Cadence/OrCAD/SPB installation roots, not arbitrary user files.
        $scanRoots += @(
            (Join-Path $drive.Root 'Cadence'),
            (Join-Path $drive.Root 'Program Files\Cadence'),
            (Join-Path $drive.Root 'Program Files (x86)\Cadence')
        )
        foreach ($dir in (Get-ChildItem -LiteralPath $drive.Root -Directory -ErrorAction SilentlyContinue)) {
            if ($dir.Name -match '^(?:SPB[_-]|OrCAD|Cadence)') { $scanRoots += $dir.FullName }
        }
    }
    foreach ($regKey in @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    )) {
        foreach ($entry in (Get-ChildItem -Path $regKey -ErrorAction SilentlyContinue)) {
            $product = Get-ItemProperty -LiteralPath $entry.PSPath -ErrorAction SilentlyContinue
            if ($product.DisplayName -match 'Cadence|OrCAD|PSpice|Allegro') {
                $notes += "Installed product: $($product.DisplayName) $($product.DisplayVersion)"
                if ($product.InstallLocation) { $scanRoots += $product.InstallLocation }
            }
        }
    }
    foreach ($menu in @(
        [Environment]::GetFolderPath('CommonStartMenu'),
        [Environment]::GetFolderPath('StartMenu')
    )) {
        if (-not $menu -or -not (Test-Path -LiteralPath $menu)) { continue }
        try { $shell = New-Object -ComObject WScript.Shell } catch {
            $notes += 'Start shortcut inspection unavailable; continuing with other installation evidence.'
            continue
        }
        foreach ($link in (Get-ChildItem -LiteralPath $menu -Recurse -File -Filter '*.lnk' -ErrorAction SilentlyContinue)) {
            if ($link.Name -notmatch 'Cadence|OrCAD|PSpice|Allegro') { continue }
            try { $target = $shell.CreateShortcut($link.FullName).TargetPath } catch { continue }
            if ($target) {
                $notes += "Start shortcut: $($link.Name) -> $target"
                if ($target -match '(?i)psp_cmd\.exe$') { $candidates += $target }
                $scanRoots += (Split-Path (Split-Path $target -Parent) -Parent)
            }
        }
    }
    foreach ($capture in (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^(?:capture|pspice|psp_cmd)$' })) {
        if ($capture.Path) {
            $notes += "Running $($capture.ProcessName): $($capture.Path)"
            $scanRoots += (Split-Path (Split-Path $capture.Path -Parent) -Parent)
        }
    }
    foreach ($name in @('psp_cmd.exe', 'pspice.exe')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) {
            $notes += "PATH $name : $($command.Source)"
            if ($name -eq 'psp_cmd.exe') { $candidates += $command.Source }
        }
    }
    $roots = @($scanRoots | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } |
        Sort-Object -Unique)
    $notes += "Eligible installation roots: $($roots.Count)"
    foreach ($root in $roots) {
        if (@($candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }).Count -gt 0) {
            $notes += 'Recursive search skipped: PSpice executable found directly.'
            break
        }
        $notes += "SEARCH: $root"
        Write-Host "Searching PSpice installation under $root ..."
        $candidates += @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'psp_cmd.exe' -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName)
    }
    $psp = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
        Select-Object -Unique | Select-Object -First 1
    $notes += "psp_cmd.exe: $(if ($psp) { $psp } else { 'NOT FOUND in inspected roots' })"
    if (-not $psp) {
        foreach ($root in $roots) {
            $other = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'pspice.exe' -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty FullName)
            foreach ($match in $other) { $notes += "Other PSpice executable: $match" }
        }
        $notes | Set-Content -LiteralPath $diagnostic -Encoding UTF8
        throw 'psp_cmd.exe not found after expanded read-only discovery. See T25D_Install_Diagnostic.txt; simulation was NOT run.'
    }
    $notes | Set-Content -LiteralPath $diagnostic -Encoding UTF8

    # Prefer a verified official download already present in Downloads. If it
    # is absent, fetch it from TI. This avoids committing a vendor ZIP to Git.
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $previous = Get-ChildItem -LiteralPath $downloads -Filter 'SLVMDV2*.zip' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($previous) {
        Copy-Item -LiteralPath $previous.FullName -Destination $zip
    } else {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMDV2' -OutFile $zip -UseBasicParsing
        } catch {
            throw 'Automatic TI download failed. Download SLVMDV2.ZIP from https://www.ti.com/lit/zip/SLVMDV2 into Windows Downloads, then run this script again.'
        }
    }
    $actualHash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "TI ZIP SHA256 differs from audited archive: $actualHash. Stop and re-audit; do not run an unknown model."
    }
    $vendor = Join-Path $work 'vendor'
    Expand-Archive -LiteralPath $zip -DestinationPath $vendor
    $root = Join-Path $vendor 'TPS631000_Encrypted'
    foreach ($file in @('TPS631000_SYMBOL.lib', 'generic_blocks.lib', 'dig_prim.lib', 'dig_io.lib')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $file))) {
            throw "Missing TI model dependency: $file"
        }
    }

    # Use the real project L, input/output C and feedback resistors. The 2.8 V
    # source and 3.3-ohm load are explicitly from TI's distributed sample,
    # only to establish model/runtime operation; NOT measured board conditions.
    $deck = @'
T25D TPS631000 model smoke - not an engineering PASS
* TI example stimulus: VIN=2.8V, RLOAD=3.3 ohm; project nominal passives only.
.LIB "@ROOT@\TPS631000_SYMBOL.lib"
.LIB "@ROOT@\generic_blocks.lib"
.LIB "@ROOT@\dig_prim.lib"
.LIB "@ROOT@\dig_io.lib"
V_TEST VIN 0 PWL(0 2.8 1u 2.8 0.1m 2.8 0.6m 2.8)
C_IN VIN 0 22u
L1 LX1 LX2 1u
C_OUT VOUT 0 47u
R_FB_TOP VOUT FB 510k
R_FB_BOTTOM FB 0 91k
R_TI_EXAMPLE_LOAD VOUT 0 3.3
X_U_SYS VOUT LX2 LX1 VIN VIN 0 0 FB TPS631000_STARTUP PARAMS: SS=0
.TRAN 0 0.6m 0 10n SKIPBP
.OPTIONS ADVCONV
.PROBE64 V(VIN) V(VOUT) V(FB)
.END
'@
    $deck.Replace('@ROOT@', $root) | Set-Content -LiteralPath $cir -Encoding Ascii

    Push-Location $work
    try {
        & $psp '-r' $cir *> $consoleLog
        $exit = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    $out = Join-Path $work 'T25D_TPS631000_Smoke.out'
    if (-not (Test-Path -LiteralPath $out)) {
        throw "PSpice did not write an .out log (process exit code: $exit). See PSpice_Console.txt."
    }
    $log = Get-Content -LiteralPath $out -Raw
    $errors = @([regex]::Matches($log, '(?im)^\s*(?:ERROR\(|FATAL|JOB ABORTED)'))
    $warningCount = [regex]::Matches($log, '(?im)^\s*WARNING\(').Count
    if ($exit -ne 0 -or $errors.Count -gt 0 -or $log -notmatch '(?i)Total job time') {
        throw "Simulation did not complete cleanly. Exit=$exit, failure markers=$($errors.Count), warnings=$warningCount. Read .out."
    }
    Write-Result 'MODEL_RUNTIME_SMOKE_PASS' "PSpice completed; warnings=$warningCount. This is NOT 3V3_SYS startup or load-step qualification."
} catch {
    Write-Result 'NO_PASS' $_.Exception.Message
} finally {
    $outputZip = Join-Path (Split-Path $work -Parent) "Datalogger_T25D_Result_$stamp.zip"
    $files = @($report, $diagnostic, $consoleLog, $cir, (Join-Path $work 'T25D_TPS631000_Smoke.out')) |
        Where-Object { Test-Path -LiteralPath $_ }
    Compress-Archive -LiteralPath $files -DestinationPath $outputZip -Force
    Write-Host "Send this ZIP for review: $outputZip"
}
