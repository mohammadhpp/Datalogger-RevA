param()

$ErrorActionPreference = "Stop"

$Repo   = 'C:\#MHP FILES\DataLoger'
$Remote = 'localbackup'
$Branch = 'main'

function Fail([string]$Message) {
    Write-Host ""
    Write-Host "FAIL: $Message" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$gitCommand = Get-Command git.exe -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    Fail "git.exe was not found in PATH."
}
$GitExe = $gitCommand.Source

function RunGit([string[]]$GitArgs) {
    & $GitExe -C $Repo @GitArgs
    if ($LASTEXITCODE -ne 0) {
        Fail ("git " + ($GitArgs -join " "))
    }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Datalogger - ONE CLICK Git AutoSave v2.3" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $Repo)) {
    Fail "Project folder not found: $Repo"
}
if (-not (Test-Path -LiteralPath (Join-Path $Repo '.git'))) {
    Fail "Git repository not found in: $Repo"
}

$currentBranch = (& $GitExe -C $Repo branch --show-current).Trim()
if ($LASTEXITCODE -ne 0) { Fail "Cannot read current branch." }
if ($currentBranch -ne $Branch) {
    Fail "Current branch is '$currentBranch'; expected '$Branch'."
}

$remotes = @(& $GitExe -C $Repo remote)
if ($LASTEXITCODE -ne 0) { Fail "Cannot read Git remotes." }
if ($remotes -notcontains $Remote) {
    Fail "Remote '$Remote' is missing."
}

$statusLines = @(& $GitExe -C $Repo status --porcelain)
if ($LASTEXITCODE -ne 0) { Fail "Cannot read repository status." }

if ($statusLines.Count -eq 0) {
    Write-Host "No changes detected." -ForegroundColor Yellow
    Write-Host "Synchronizing localbackup..." -ForegroundColor Yellow
    RunGit @('push', $Remote, $Branch)
    RunGit @('push', $Remote, '--tags')
    Write-Host ""
    Write-Host "PASS: Working tree clean; localbackup synchronized." -ForegroundColor Green
    exit 0
}

Write-Host "Detected changes:" -ForegroundColor Yellow
$statusLines | ForEach-Object { Write-Host "  $_" }
Write-Host ""

$changedNames = @()
foreach ($line in $statusLines) {
    if ($line.Length -ge 4) {
        $name = $line.Substring(3).Trim()
        if ($name -match ' -> ') {
            $name = ($name -split ' -> ')[-1].Trim()
        }
        $changedNames += $name
    }
}

$uniqueNames = @($changedNames | Select-Object -Unique)
$previewNames = @($uniqueNames | Select-Object -First 5)
$nameText = $previewNames -join ', '
if ($uniqueNames.Count -gt 5) {
    $nameText += ", +$($uniqueNames.Count - 5) more"
}

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$commitMessage = "Auto checkpoint $stamp | $($uniqueNames.Count) file(s): $nameText"
if ($commitMessage.Length -gt 220) {
    $commitMessage = $commitMessage.Substring(0, 217) + "..."
}

Write-Host "Automatic commit:" -ForegroundColor Cyan
Write-Host "  $commitMessage"
Write-Host ""

RunGit @('add', '-A')

& $GitExe -C $Repo diff --cached --quiet
$cachedExit = $LASTEXITCODE

if ($cachedExit -eq 0) {
    Write-Host "No staged content after git add. Synchronizing backup only." -ForegroundColor Yellow
    RunGit @('push', $Remote, $Branch)
    RunGit @('push', $Remote, '--tags')
    Write-Host ""
    Write-Host "PASS." -ForegroundColor Green
    exit 0
}
elseif ($cachedExit -ne 1) {
    Fail "Could not verify staged changes."
}

RunGit @('commit', '-m', $commitMessage)
RunGit @('push', $Remote, $Branch)
RunGit @('push', $Remote, '--tags')

Write-Host ""
Write-Host "Latest checkpoint:" -ForegroundColor Yellow
RunGit @('log', '-1', '--oneline', '--decorate')

Write-Host ""
Write-Host "PASS: Changes committed and backed up automatically." -ForegroundColor Green
exit 0
