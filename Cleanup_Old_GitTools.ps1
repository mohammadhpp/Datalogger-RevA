$Repo = 'C:\#MHP FILES\DataLoger'

$junk = @(
    'Datalogger_Git_AutoSave_v2.1.zip',
    'README_AutoSave_v2.txt',
    'README_AutoSave_v2_1.txt',
    'README_AutoSave_v2_2.txt',
    'README_GitTools.txt'
)

foreach ($name in $junk) {
    $p = Join-Path $Repo $name
    if (Test-Path -LiteralPath $p) {
        Remove-Item -LiteralPath $p -Force
        Write-Host "Removed: $name"
    }
}

Write-Host "Cleanup complete."
