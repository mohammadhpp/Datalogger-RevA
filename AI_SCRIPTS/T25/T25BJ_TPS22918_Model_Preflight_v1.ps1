# T25BJ v1 - acquire and audit official TI TPS22918 unencrypted PSpice package.
# ASCII-only PowerShell 5.1. No PSpice simulation and no Altium/BOM files are changed.
$ErrorActionPreference = 'Stop'
$documents = [Environment]::GetFolderPath('MyDocuments')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BJ_Model_Preflight_v1_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25BJ_Model_Preflight_v1_Result_$stamp.zip"
$inventory = Join-Path $work 'T25BJ_Model_Inventory.txt'
$subckts = Join-Path $work 'T25BJ_Subckt_Headers.txt'
$manifest = Join-Path $work 'T25BJ_Manifest.txt'
$vendorZip = Join-Path $work 'TI_SLVMBI6.zip'
$vendor = Join-Path $work 'vendor'
New-Item -ItemType Directory -Path $work -Force | Out-Null

Write-Host 'T25BJ: acquiring official TI TPS22918 unencrypted PSpice package.'
Write-Host 'No PSpice run is performed. Wait for RESULT ZIP.'

try {
    $verifiedSource = $null
    foreach ($candidate in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMBI6*.zip' -File -ErrorAction SilentlyContinue)) {
        $verifiedSource = $candidate.FullName
        break
    }

    if ($verifiedSource) {
        Copy-Item -LiteralPath $verifiedSource -Destination $vendorZip
        $sourceMode = "USER_DOWNLOAD=$verifiedSource"
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMBI6' -OutFile $vendorZip -UseBasicParsing
        $sourceMode = 'DIRECT_TI_HTTPS=https://www.ti.com/lit/zip/SLVMBI6'
    }

    if (-not (Test-Path -LiteralPath $vendorZip -PathType Leaf)) { throw 'TI package missing after acquisition.' }
    $zipHash = (Get-FileHash -LiteralPath $vendorZip -Algorithm SHA256).Hash.ToUpperInvariant()
    $zipSize = (Get-Item -LiteralPath $vendorZip).Length
    Expand-Archive -LiteralPath $vendorZip -DestinationPath $vendor -Force

    $allFiles = @(Get-ChildItem -LiteralPath $vendor -Recurse -File)
    if ($allFiles.Count -eq 0) { throw 'Expanded TI package contains no files.' }

    @(
        'T25BJ v1 - TPS22918 official model package preflight',
        "TIME=$(Get-Date -Format o)",
        "SOURCE=$sourceMode",
        "ZIP_SHA256=$zipHash",
        "ZIP_SIZE_BYTES=$zipSize",
        "EXPANDED_FILE_COUNT=$($allFiles.Count)",
        'TI product page identifies SLVMBI6A as TPS22918 Unencrypted PSpice Transient Model Package.',
        'NO_PSPICE_RUN / NO_CAD_CHANGE / NO_BOARD_PASS / FABRICATION_HOLD'
    ) | Set-Content -LiteralPath $manifest -Encoding Ascii

    $invLines = New-Object System.Collections.Generic.List[string]
    foreach ($f in ($allFiles | Sort-Object FullName)) {
        $rel = $f.FullName.Substring($vendor.Length).TrimStart('\')
        $h = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
        $invLines.Add(("{0}{1}{2}{1}{3}" -f $rel,[char]9,$f.Length,$h))
    }
    $invLines | Set-Content -LiteralPath $inventory -Encoding Ascii

    $textExt = @('.lib','.cir','.inc','.txt','.mod','.mdl','.sp','.spi','.spice')
    $headerLines = New-Object System.Collections.Generic.List[string]
    foreach ($f in $allFiles) {
        if ($textExt -notcontains $f.Extension.ToLowerInvariant()) { continue }
        if ($f.Length -gt 4MB) { continue }
        try {
            $raw = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
            $rel = $f.FullName.Substring($vendor.Length).TrimStart('\')
            $hits = [regex]::Matches($raw,'(?im)^\s*\.SUBCKT\s+[^\r\n]+')
            if ($hits.Count -gt 0 -or $raw -match '(?i)TPS22918') {
                $headerLines.Add("===== $rel =====")
                foreach ($m in $hits) { $headerLines.Add($m.Value.Trim()) }
                $headerLines.Add('')
            }
        } catch {
            # Binary/non-text file with a text-looking extension: inventory still records it.
        }
    }
    if ($headerLines.Count -eq 0) {
        $headerLines.Add('NO_SUBCKT_HEADERS_FOUND')
    }
    $headerLines | Set-Content -LiteralPath $subckts -Encoding Ascii

    $modelCandidates = @($allFiles | Where-Object {
        $_.Extension -match '(?i)^\.(lib|cir|inc|mod|mdl|sp|spi|spice)$'
    })
    Add-Content -LiteralPath $manifest -Encoding Ascii -Value "MODEL_TEXT_FILE_COUNT=$($modelCandidates.Count)"
    foreach ($f in $modelCandidates) {
        $rel = $f.FullName.Substring($vendor.Length).TrimStart('\')
        Add-Content -LiteralPath $manifest -Encoding Ascii -Value "MODEL_FILE=$rel"
    }

    Compress-Archive -LiteralPath @($manifest,$inventory,$subckts,$vendorZip) -DestinationPath $resultZip -Force
    Write-Host "ZIP_SHA256: $zipHash"
    Write-Host "EXPANDED_FILE_COUNT: $($allFiles.Count)"
    Write-Host "RESULT ZIP: $resultZip"
} catch {
    "GLOBAL_ERROR=$($_.Exception.Message)" | Set-Content -LiteralPath $manifest -Encoding Ascii
    Compress-Archive -LiteralPath $manifest -DestinationPath $resultZip -Force
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Host "RESULT ZIP: $resultZip"
}
