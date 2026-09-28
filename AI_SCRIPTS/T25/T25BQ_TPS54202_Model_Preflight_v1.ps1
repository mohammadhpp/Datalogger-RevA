# T25BQ v1 - official TI TPS54202 model package preflight.
# ASCII-only PowerShell 5.1. No PSpice run and no Altium/BOM modification.
$ErrorActionPreference = 'Stop'

$documents = [Environment]::GetFolderPath('MyDocuments')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$work = Join-Path $documents "Datalogger_T25BQ_Model_Preflight_v1_$stamp"
$resultZip = Join-Path $documents "Datalogger_T25BQ_Model_Preflight_v1_Result_$stamp.zip"
$tiZip = Join-Path $work 'TI_SLVMBJ5C.zip'
$expand = Join-Path $work 'vendor'
$manifest = Join-Path $work 'T25BQ_Model_Preflight_v1_Manifest.txt'
$inventory = Join-Path $work 'T25BQ_Model_Preflight_v1_Inventory.csv'
$headers = Join-Path $work 'T25BQ_Model_Preflight_v1_Subckt_Headers.txt'

New-Item -ItemType Directory -Path $work -Force | Out-Null

function Copy-Or-DownloadTiZip {
    foreach ($f in (Get-ChildItem -LiteralPath $downloads -Filter 'SLVMBJ5C*.zip' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)) {
        if ($f.Length -gt 1024) {
            Copy-Item -LiteralPath $f.FullName -Destination $tiZip -Force
            return "DOWNLOADS=$($f.FullName)"
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://www.ti.com/lit/zip/SLVMBJ5C' -OutFile $tiZip -UseBasicParsing
    return 'DIRECT_TI_HTTPS=https://www.ti.com/lit/zip/SLVMBJ5C'
}

try {
    $source = Copy-Or-DownloadTiZip
    if (-not (Test-Path -LiteralPath $tiZip -PathType Leaf)) { throw 'TI ZIP not acquired.' }

    $zipSize = (Get-Item -LiteralPath $tiZip).Length
    $zipHash = (Get-FileHash -LiteralPath $tiZip -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($zipSize -lt 1024) { throw "TI ZIP too small: $zipSize bytes" }

    Expand-Archive -LiteralPath $tiZip -DestinationPath $expand -Force
    $files = @(Get-ChildItem -LiteralPath $expand -File -Recurse)
    if ($files.Count -lt 1) { throw 'TI archive expanded to zero files.' }

    @(
        'T25BQ v1 - TPS54202 official TI model preflight',
        "TIME=$(Get-Date -Format o)",
        "SOURCE=$source",
        "TI_PACKAGE=SLVMBJ5C",
        "TI_ZIP_SIZE=$zipSize",
        "TI_ZIP_SHA256=$zipHash",
        "EXPANDED_FILE_COUNT=$($files.Count)",
        'EXPECTED_PRODUCT=TPS54202',
        'NO_PSPICE_RUN',
        'NO_ALTIUM_CHANGE',
        'NO_BOM_CHANGE',
        'FABRICATION_HOLD'
    ) | Set-Content -LiteralPath $manifest -Encoding UTF8

    'RelativePath,Bytes,SHA256' | Set-Content -LiteralPath $inventory -Encoding Ascii
    foreach ($f in $files | Sort-Object FullName) {
        $rel = $f.FullName.Substring($expand.Length).TrimStart('\')
        $h = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
        ('"{0}",{1},{2}' -f $rel.Replace('"','""'),$f.Length,$h) |
            Add-Content -LiteralPath $inventory -Encoding Ascii
    }

    $allHeaders = New-Object 'System.Collections.Generic.List[string]'
    foreach ($f in $files) {
        if ($f.Extension -match '^\.(lib|cir|inc|mod|txt|spi|sp|ckt)$') {
            try {
                $txt = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
                $matches = [regex]::Matches($txt,'(?im)^\s*\.SUBCKT\s+[^\r\n]+')
                foreach ($m in $matches) {
                    $rel = $f.FullName.Substring($expand.Length).TrimStart('\')
                    $allHeaders.Add($rel + [char]9 + $m.Value.Trim())
                }
            } catch {}
        }
    }

    if ($allHeaders.Count -eq 0) {
        'NO_VISIBLE_SUBCKT_HEADERS_FOUND' | Set-Content -LiteralPath $headers -Encoding UTF8
    } else {
        $allHeaders | Set-Content -LiteralPath $headers -Encoding UTF8
    }

    $modelCandidates = @($files | Where-Object {
        $_.Name -match '(?i)TPS54202|TRANS|PSPICE' -or $_.Extension -match '^\.(lib|cir|inc|mod)$'
    })
    Add-Content -LiteralPath $manifest -Encoding UTF8 -Value "MODEL_CANDIDATE_COUNT=$($modelCandidates.Count)"
    foreach ($m in $modelCandidates | Sort-Object FullName) {
        $rel = $m.FullName.Substring($expand.Length).TrimStart('\')
        Add-Content -LiteralPath $manifest -Encoding UTF8 -Value "MODEL_CANDIDATE=$rel"
    }

    $evidenceFiles = @($manifest,$inventory,$headers,$tiZip)
    foreach ($f in $files) {
        if ($f.Length -le 5MB) { $evidenceFiles += $f.FullName }
    }
    Compress-Archive -LiteralPath $evidenceFiles -DestinationPath $resultZip -Force
    Write-Host "RESULT ZIP: $resultZip"
} catch {
    "GLOBAL_ERROR=$($_.Exception.Message)" | Set-Content -LiteralPath $manifest -Encoding UTF8
    Compress-Archive -LiteralPath $manifest -DestinationPath $resultZip -Force
    Write-Host "RESULT ZIP (ERROR): $resultZip"
}
