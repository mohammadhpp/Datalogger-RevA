param()

$ErrorActionPreference = "Stop"

$BackupRepo = 'C:\#MHP FILES\GitRepos\DataLoger.git'
$DefaultTarget = 'C:\#MHP FILES\DataLoger_Restored'
$Branch = 'main'

function Fail($msg) {
    Write-Host ""
    Write-Host "ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Datalogger - Git Disaster Restore" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $BackupRepo)) {
    Fail "Local Git backup was not found: $BackupRepo"
}

# Verify the backup repository before restoring.
& git --git-dir=$BackupRepo rev-parse --verify "refs/heads/$Branch" *> $null
if ($LASTEXITCODE -ne 0) {
    Fail "Branch '$Branch' does not exist in the backup repository."
}

$head = (& git --git-dir=$BackupRepo rev-parse --short "refs/heads/$Branch").Trim()
if ($LASTEXITCODE -ne 0) {
    Fail "Could not read backup HEAD."
}

Write-Host "Backup repository: $BackupRepo"
Write-Host "Backup main HEAD:  $head"
Write-Host ""

$targetInput = Read-Host "Restore destination [$DefaultTarget]"
if ([string]::IsNullOrWhiteSpace($targetInput)) {
    $Target = $DefaultTarget
} else {
    $Target = $targetInput.Trim('"')
}

if (Test-Path -LiteralPath $Target) {
    $items = Get-ChildItem -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($items) {
        Fail "Destination already exists and is not empty: $Target`nChoose another folder. Existing data will never be overwritten."
    }
}

Write-Host ""
Write-Host "Restoring to: $Target" -ForegroundColor Yellow
$confirm = Read-Host "Continue? [Y/N]"
if ($confirm -notmatch '^(?i)y(es)?$') {
    Write-Host "Restore cancelled."
    Read-Host "Press Enter to close"
    exit 0
}

& git clone --branch $Branch $BackupRepo $Target
if ($LASTEXITCODE -ne 0) {
    Fail "git clone failed."
}

Write-Host ""
Write-Host "Verifying restored repository..." -ForegroundColor Yellow

$status = & git -C $Target status --porcelain
if ($LASTEXITCODE -ne 0) {
    Fail "Restored repository could not be verified."
}

if ($status) {
    Fail "Restored repository is not clean. Unexpected working-tree changes were detected."
}

$restoredHead = (& git -C $Target rev-parse --short HEAD).Trim()
if ($LASTEXITCODE -ne 0) {
    Fail "Could not read restored HEAD."
}

if ($restoredHead -ne $head) {
    Fail "Restore HEAD mismatch. Backup=$head Restored=$restoredHead"
}

$required = @(
    'DATALOGER_final.PrjPcb',
    '01_POWER.SchDoc',
    '02_MCU_CORE.SchDoc',
    '03_MICROSD.SchDoc',
    '04_NAVIGATION.SchDoc',
    '05_RTC.SchDoc',
    'Datalogger_RevA_Clean.SchLib',
    'Datalogger_RevA_Clean.PcbLib',
    '.gitignore',
    '.gitattributes'
)

$missing = @()
foreach ($file in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $Target $file))) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Fail ("Restore completed but required files are missing:`n - " + ($missing -join "`n - "))
}

Write-Host ""
Write-Host "PASS: Restore completed and verified." -ForegroundColor Green
Write-Host "Restored HEAD: $restoredHead"
Write-Host "Location:      $Target"
Write-Host ""
Write-Host "Open this project in Altium:"
Write-Host (Join-Path $Target 'DATALOGER_final.PrjPcb') -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close"
