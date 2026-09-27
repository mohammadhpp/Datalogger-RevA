# T25R v1 - Fetch and inspect official TDK C2012 DC-bias PSpice archive.
# Windows PowerShell 5.1; ASCII source. No Altium or PSpice design writes.
$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$documents = [Environment]::GetFolderPath('MyDocuments')
if ([string]::IsNullOrWhiteSpace($documents)) { $documents = Join-Path $env:USERPROFILE 'Documents' }
$root = Join-Path $documents ('Datalogger_T25R_v1_' + $stamp)
$resultZip = Join-Path $documents ('Datalogger_T25R_v1_Result_' + $stamp + '.zip')
New-Item -ItemType Directory -Path $root -Force | Out-Null
$report = Join-Path $root 'T25R_v1_Result.txt'
$evidence = Join-Path $root 'T25R_v1_Matches.txt'
$vendorZip = Join-Path $root 'TDK_C2012_PSpice_vendor.zip'
$verifiedVendorZip = $false
$sourceUrl = 'https://product.tdk.com/system/files/dam/technicalsupport/tvcl/pspice/capacitor_mlcc_com_general_c2012_pspice.zip'
$parts = @('C2012X5R1A476M125AC', 'C2012X5R1V226M125AC')
$log = New-Object 'System.Collections.Generic.List[string]'
$hits = @{}
foreach ($part in $parts) { $hits[$part] = 0 }
function Add-Log([string] $message) {
    $script:log.Add($message)
    Write-Host $message
}
try {
    Add-Log 'T25R v1 - official TDK C2012 PSpice archive provenance check'
    Add-Log ('Date: ' + (Get-Date -Format o))
    Add-Log ('Source: ' + $sourceUrl)
    Add-Log ('C_OUT: ' + $parts[0] + ' nominal 47uF; C_IN: ' + $parts[1] + ' nominal 22uF')
    Add-Log 'No effective capacitance, bias curve, or board simulation PASS is assumed.'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $client = New-Object System.Net.WebClient
    try { $client.DownloadFile($sourceUrl, $vendorZip) } finally { $client.Dispose() }
    $size = (Get-Item -LiteralPath $vendorZip).Length
    if ($size -lt 128 -or $size -gt 100MB) { throw ('Unexpected archive size: ' + $size) }
    $stream = [IO.File]::OpenRead($vendorZip)
    try {
        $magic = New-Object byte[] 4
        $read = $stream.Read($magic, 0, 4)
        if ($read -ne 4 -or $magic[0] -ne 80 -or $magic[1] -ne 75) {
            throw 'Downloaded data is not a ZIP archive.'
        }
    } finally { $stream.Close() }
    Add-Log ('Archive bytes: ' + $size)
    Add-Log ('Archive SHA256: ' + (Get-FileHash -LiteralPath $vendorZip -Algorithm SHA256).Hash)
    $unpacked = Join-Path $root 'extracted'
    Expand-Archive -LiteralPath $vendorZip -DestinationPath $unpacked -Force
    $verifiedVendorZip = $true
    $files = @(Get-ChildItem -LiteralPath $unpacked -File -Recurse)
    Add-Log ('Archive file count: ' + $files.Count)
    if ($files.Count -gt 15000) { throw 'Unexpected archive file count.' }
    $matchLines = New-Object 'System.Collections.Generic.List[string]'
    foreach ($file in $files) {
        if ($file.Length -gt 20MB -or $file.Length -lt 1) { continue }
        if ($file.Extension -notin @('.lib', '.txt', '.cir', '.mod', '.sub', '.model', '.sp', '.spi')) { continue }
        $relative = $file.FullName.Substring($unpacked.Length + 1)
        foreach ($part in $parts) {
            $found = @(Select-String -LiteralPath $file.FullName -SimpleMatch -Pattern $part -ErrorAction Stop | Select-Object -First 8)
            foreach ($m in $found) {
                $hits[$part]++
                $line = $m.Line.Trim()
                if ($line.Length -gt 300) { $line = $line.Substring(0, 300) + ' ...' }
                $matchLines.Add($part + ' | ' + $relative + ':' + $m.LineNumber + ' | ' + $line)
            }
        }
    }
    if ($matchLines.Count -gt 0) {
        [IO.File]::WriteAllLines($evidence, [string[]] $matchLines, [Text.Encoding]::UTF8)
    } else {
        [IO.File]::WriteAllText($evidence, 'No exact part-number string found in scanned text files.', [Text.Encoding]::UTF8)
    }
    foreach ($part in $parts) { Add-Log ($part + ' matching lines: ' + $hits[$part]) }
    if ($hits[$parts[0]] -gt 0 -and $hits[$parts[1]] -gt 0) {
        Add-Log 'STATUS: EXACT_PART_STRINGS_FOUND_IN_VENDOR_ARCHIVE; model syntax and Ceff still require review.'
    } else {
        Add-Log 'STATUS: EXACT_PART_STRINGS_NOT_BOTH_FOUND; no substitute model is inferred.'
    }
} catch {
    Add-Log ('STATUS: FETCH_OR_INSPECTION_FAILED; ' + $_.Exception.Message)
} finally {
    try {
        [IO.File]::WriteAllLines($report, [string[]] $log, [Text.Encoding]::UTF8)
        $items = @($report)
        if (Test-Path -LiteralPath $evidence) { $items += $evidence }
        if ($verifiedVendorZip -and (Test-Path -LiteralPath $vendorZip)) {
            if ((Get-Item -LiteralPath $vendorZip).Length -le 25MB) {
                $items += $vendorZip
            } else {
                Add-Content -LiteralPath $report -Value 'Vendor ZIP larger than 25 MB; omitted from result ZIP.'
            }
        }
        Compress-Archive -LiteralPath $items -DestinationPath $resultZip -Force
        Write-Host ('RESULT ZIP: ' + $resultZip)
    } catch {
        Write-Host ('PACKAGING FAILED: ' + $_.Exception.Message)
        Write-Host ('Evidence folder: ' + $root)
    }
}
