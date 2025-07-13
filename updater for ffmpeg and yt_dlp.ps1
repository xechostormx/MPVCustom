# update.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Turn off PowerShell's blue progress bar
$ProgressPreference = 'SilentlyContinue'

# Paths
$RepoRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$DllsDir  = Join-Path $RepoRoot 'dlls'
$TmpDir   = Join-Path $env:TEMP    'ffmpeg_update'

# GitHub API Endpoints
$YtdlpApi  = 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest'
$FfmpegApi = 'https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest'

function Update-YtDlp {
    Write-Host '→ Updating yt-dlp…'
    $rel = Invoke-RestMethod -Uri $YtdlpApi
    $asset = $rel.assets |
             Where-Object { $_.name -eq 'yt-dlp.exe' } |
             Select-Object -First 1

    if (-not $asset) {
        Throw "No yt-dlp.exe asset found in release $($rel.tag_name)"
    }

    $dlUrl = $asset.browser_download_url
    $dest  = Join-Path $RepoRoot 'yt-dlp.exe'

    Write-Host "  Downloading $($asset.name) from $dlUrl"
    Invoke-WebRequest -Uri $dlUrl -OutFile $dest -UseBasicParsing

    Write-Host "  Updated yt-dlp to $($rel.tag_name)"
    return $rel.tag_name
}

function Update-FFmpeg {
    Write-Host '→ Updating FFmpeg…'
    $rel = Invoke-RestMethod -Uri $FfmpegApi
    $asset = $rel.assets |
             Where-Object { $_.name -match 'win64-gpl.zip$' } |
             Select-Object -First 1

    if (-not $asset) {
        Throw "No win64-gpl.zip asset found in release $($rel.tag_name)"
    }

    $dlUrl   = $asset.browser_download_url
    $zipFile = Join-Path $TmpDir $asset.name

    if (Test-Path $TmpDir) { Remove-Item $TmpDir -Recurse -Force }
    New-Item -ItemType Directory -Path $TmpDir | Out-Null

    Write-Host "  Downloading $($asset.name) from $dlUrl"
    Invoke-WebRequest -Uri $dlUrl -OutFile $zipFile -UseBasicParsing

    Expand-Archive -Path $zipFile -DestinationPath $TmpDir

    $binDir = Get-ChildItem $TmpDir -Recurse -Directory |
              Where-Object { Test-Path "$($_.FullName)\ffmpeg.exe" } |
              Select-Object -First 1

    Copy-Item (Join-Path $binDir.FullName 'ffmpeg.exe')  -Destination $RepoRoot -Force
    Copy-Item (Join-Path $binDir.FullName 'ffprobe.exe') -Destination $RepoRoot -Force

    if (-not (Test-Path $DllsDir)) {
        New-Item -ItemType Directory -Path $DllsDir | Out-Null
    }
    Get-ChildItem $binDir.FullName -Filter '*.dll' | ForEach-Object {
        Copy-Item $_.FullName -Destination $DllsDir -Force
    }

    Remove-Item $TmpDir -Recurse -Force

    Write-Host "  Updated FFmpeg to $($rel.tag_name)"
    return $rel.tag_name
}

# Run updates
$ytTag = Update-YtDlp
$ffTag = Update-FFmpeg

Write-Host "✅ Update complete."

# Pause so the window stays open
Write-Host
Write-Host "Press any key to exit..."
[System.Console]::ReadKey($true) | Out-Null
