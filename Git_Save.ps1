param()

$ErrorActionPreference = "Stop"

$Repo         = 'C:\#MHP FILES\DataLoger'
$LocalRemote  = 'localbackup'
$OnlineRemote = 'github'
$Branch       = 'main'

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

function RunGitRequired([string[]]$GitArgs) {
    & $GitExe -C $Repo @GitArgs
    if ($LASTEXITCODE -ne 0) {
        Fail ("git " + ($GitArgs -join " "))
    }
}

function RunGitOnline([string[]]$GitArgs) {
    & $GitExe -C $Repo @GitArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARN: GitHub synchronization failed: git $($GitArgs -join ' ')" -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Sync-FromGitHubSafe {
    Write-Host "Checking GitHub for incoming updates..." -ForegroundColor Yellow

    & $GitExe -C $Repo fetch $OnlineRemote --prune --tags
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARN: GitHub fetch failed. Continuing with local backup protection." -ForegroundColor Yellow
        return $false
    }

    $remoteRef = "$OnlineRemote/$Branch"
    $localHead = (& $GitExe -C $Repo rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { Fail "Cannot read local HEAD." }

    $remoteHead = (& $GitExe -C $Repo rev-parse $remoteRef).Trim()
    if ($LASTEXITCODE -ne 0) { Fail "Cannot read $remoteRef after fetch." }

    if ($localHead -eq $remoteHead) {
        Write-Host "GitHub is already aligned with local HEAD." -ForegroundColor DarkGray
        return $true
    }

    & $GitExe -C $Repo merge-base --is-ancestor HEAD $remoteRef
    $localIsAncestor = $LASTEXITCODE

    if ($localIsAncestor -eq 0) {
        $statusBeforeSync = @(& $GitExe -C $Repo status --porcelain)
        if ($LASTEXITCODE -ne 0) { Fail "Cannot read working tree before GitHub fast-forward." }

        $stashCreated = $false
        if ($statusBeforeSync.Count -gt 0) {
            $stashStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Write-Host "Temporarily protecting local edits before GitHub fast-forward..." -ForegroundColor Yellow
            & $GitExe -C $Repo stash push --include-untracked -m "Git_Save v2.5.1 pre-sync $stashStamp"
            if ($LASTEXITCODE -ne 0) {
                Fail "Could not protect local edits before GitHub synchronization."
            }
            $stashCreated = $true
        }

        Write-Host "Fast-forwarding local main from GitHub..." -ForegroundColor Yellow
        RunGitRequired @('merge', '--ff-only', $remoteRef)

        if ($stashCreated) {
            Write-Host "Restoring protected local edits..." -ForegroundColor Yellow
            & $GitExe -C $Repo stash pop
            if ($LASTEXITCODE -ne 0) {
                Fail "GitHub fast-forward completed, but restoring local edits caused a conflict. Git stopped safely; resolve the working tree before continuing."
            }
        }

        Write-Host "Incoming GitHub updates integrated safely." -ForegroundColor Green
        return $true
    }
    elseif ($localIsAncestor -ne 1) {
        Fail "Could not compare local HEAD with GitHub."
    }

    & $GitExe -C $Repo merge-base --is-ancestor $remoteRef HEAD
    $remoteIsAncestor = $LASTEXITCODE

    if ($remoteIsAncestor -eq 0) {
        Write-Host "Local main is ahead of GitHub; it will be pushed after checkpointing." -ForegroundColor DarkGray
        return $true
    }
    elseif ($remoteIsAncestor -ne 1) {
        Fail "Could not compare GitHub with local HEAD."
    }

    Fail "Local main and GitHub main have diverged. Automatic merge is intentionally blocked to protect Altium/binary project files. Resolve the divergence once, then Git_Save.cmd will resume one-click operation."
}

function Sync-Backups {
    Write-Host "Synchronizing local backup..." -ForegroundColor Yellow
    RunGitRequired @('push', $LocalRemote, $Branch)
    RunGitRequired @('push', $LocalRemote, '--tags')

    Write-Host "Synchronizing GitHub backup..." -ForegroundColor Yellow
    $githubBranchOk = RunGitOnline @('push', $OnlineRemote, $Branch)
    $githubTagsOk   = RunGitOnline @('push', $OnlineRemote, '--tags')

    if ($githubBranchOk -and $githubTagsOk) {
        return $true
    }
    return $false
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Datalogger - ONE CLICK Git AutoSave v2.5.1" -ForegroundColor Cyan
Write-Host "   Auto Pull + Commit + Dual Backup + Tags" -ForegroundColor Cyan
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
if ($remotes -notcontains $LocalRemote) {
    Fail "Required remote '$LocalRemote' is missing."
}
if ($remotes -notcontains $OnlineRemote) {
    Fail "Required remote '$OnlineRemote' is missing."
}

$githubFetchOk = Sync-FromGitHubSafe
Write-Host ""

$statusLines = @(& $GitExe -C $Repo status --porcelain)
if ($LASTEXITCODE -ne 0) { Fail "Cannot read repository status." }

if ($statusLines.Count -eq 0) {
    Write-Host "No local changes detected." -ForegroundColor Yellow
    $githubOk = Sync-Backups
    Write-Host ""
    if ($githubOk) {
        Write-Host "PASS: Local repo, localbackup, GitHub and tags are synchronized." -ForegroundColor Green
    }
    else {
        Write-Host "PARTIAL PASS: Local backup is safe; GitHub synchronization needs attention." -ForegroundColor Yellow
    }
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

# Keep the commit message independent of raw path text.
# Git porcelain may quote filenames that contain spaces or special characters;
# embedding those quotes in a native git.exe argument can be re-tokenized by
# legacy Windows PowerShell argument passing and turn parts of the message into
# accidental pathspecs. The changed-file list is already preserved by Git.
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$commitMessage = "Auto checkpoint $stamp | $($uniqueNames.Count) file(s)"

Write-Host "Automatic commit:" -ForegroundColor Cyan
Write-Host "  $commitMessage"
Write-Host ""

RunGitRequired @('add', '-A')

& $GitExe -C $Repo diff --cached --quiet
$cachedExit = $LASTEXITCODE

if ($cachedExit -eq 0) {
    Write-Host "No staged content after git add. Synchronizing backups only." -ForegroundColor Yellow
    $githubOk = Sync-Backups
    Write-Host ""
    if ($githubOk) {
        Write-Host "PASS: Local repo, localbackup, GitHub and tags are synchronized." -ForegroundColor Green
    }
    else {
        Write-Host "PARTIAL PASS: Local backup is safe; GitHub synchronization needs attention." -ForegroundColor Yellow
    }
    exit 0
}
elseif ($cachedExit -ne 1) {
    Fail "Could not verify staged changes."
}

RunGitRequired @('commit', '-m', $commitMessage)
$githubOk = Sync-Backups

Write-Host ""
Write-Host "Latest checkpoint:" -ForegroundColor Yellow
RunGitRequired @('log', '-1', '--oneline', '--decorate')

Write-Host ""
if ($githubOk) {
    Write-Host "PASS: One-click sync complete: local repo + localbackup + GitHub + tags." -ForegroundColor Green
}
else {
    Write-Host "PARTIAL PASS: Changes committed and backed up locally; GitHub synchronization needs attention." -ForegroundColor Yellow
}
exit 0
