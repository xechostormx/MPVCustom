# commit.ps1
<#
.SYNOPSIS
  Quick “stage-all, commit & push” helper for your MPVCustom repo.
.DESCRIPTION
  Shows git status, prompts for a commit message, then asks for Y/N confirmation
  before staging everything (git add -A .), committing, and pushing to origin/main.
#>

[CmdletBinding()]
param()

Write-Host "=== MPVCustom Quick Commit Helper ===" -ForegroundColor Cyan

# Ensure we’re in a Git repo
if (-not (Test-Path ".git")) {
    Write-Error "This folder is not a Git repository."
    exit 1
}

# Show current status
Write-Host "`n--- Git Status ---`n" -ForegroundColor Cyan
git status

# Prompt for commit message
do {
    $commitMsg = Read-Host "`nEnter commit message (short, imperative)"
    if ([string]::IsNullOrWhiteSpace($commitMsg)) {
        Write-Warning "Commit message cannot be empty."
    }
} while ([string]::IsNullOrWhiteSpace($commitMsg))

# Confirm full staging + commit + push
do {
    $confirm = Read-Host "`nProceed with staging ALL changes, commit and push? [Y/N]"
} while ($confirm -notmatch '^[YyNn]$')

if ($confirm -match '^[Nn]') {
    Write-Host "`nOperation cancelled." -ForegroundColor Yellow
    Read-Host -Prompt "`nPress ENTER to exit"
    exit 0
}

# Stage everything
Write-Host "`nStaging all changes…" -ForegroundColor Cyan
git add -A .

# Commit
Write-Host "`nCommitting…" -ForegroundColor Cyan
git commit -m "$commitMsg"

# Push
Write-Host "`nPushing to origin/main…" -ForegroundColor Cyan
git push origin main

Write-Host "`n✅ Commit and push complete!" -ForegroundColor Green

# Pause so window stays open
Read-Host -Prompt "`nPress ENTER to exit"
