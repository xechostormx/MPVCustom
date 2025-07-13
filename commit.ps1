# commit.ps1
<#
.SYNOPSIS
  Interactive commit-and-push helper for your MPVCustom repo.
.DESCRIPTION
  Prompts for a Conventional-Commit–style message, stages all changes,
  then commits and pushes to origin/main.
  Place this script in the root of D:\MPV and run it via PowerShell.
#>

[CmdletBinding()]
param()

Write-Host "=== MPVCustom Commit Helper Starting ===" -ForegroundColor Cyan

try {
    # 1) Ensure we’re in a Git repo
    if (-not (Test-Path ".git")) {
        throw "This folder is not a Git repository."
    }

    # 2) Show current changes
    Write-Host "`n--- Git Status ---`n" -ForegroundColor Cyan
    git status

    # 3) Select commit type
    $types = @{
        "1" = "feat"
        "2" = "fix"
        "3" = "docs"
        "4" = "chore"
        "5" = "update"
    }

    Write-Host "`nSelect commit type:`n" -ForegroundColor Cyan
    foreach ($key in $types.Keys) {
        Write-Host "  [$key] $($types[$key])"
    }
    $typeChoice = Read-Host "`nEnter number (default 5)"
    $type = if ($types.ContainsKey($typeChoice)) { $types[$typeChoice] } else { "update" }

    # 4) Prompt for commit description
    do {
        $description = Read-Host "`nCommit message (short, imperative tense)"
        if ([string]::IsNullOrWhiteSpace($description)) {
            Write-Warning "Commit message cannot be empty."
        }
    } while ([string]::IsNullOrWhiteSpace($description))

    # Build the commit message
    $commitMsg = "$($type): $description"

    Write-Host "`nCommit message will be:`n  $commitMsg`n" -ForegroundColor Green

    # 5) Confirm
    $confirm = Read-Host "Proceed with staging, commit and push? (Y/n)"
    if ($confirm -match '^[Nn]') {
        Write-Host "`nAborted." -ForegroundColor Yellow
        return
    }

    # 6) Stage changes (all new, modified, deleted)
    Write-Host "`nStaging files…" -ForegroundColor Cyan
    git add -A .

    # 7) Commit
    Write-Host "`nCommitting…" -ForegroundColor Cyan
    git commit -m "$commitMsg"

    # 8) Push
    Write-Host "`nPushing to origin/main…" -ForegroundColor Cyan
    git push origin main

    Write-Host "`n✅ Commit and push complete!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host
    Read-Host -Prompt "Press ENTER to exit"
}
