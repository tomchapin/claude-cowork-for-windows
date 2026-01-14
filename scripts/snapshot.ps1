# Create a snapshot of the current VM state
# Usage: .\scripts\snapshot.ps1 -Name "clean-dev-environment" -Description "Fresh install"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [string]$Description = ""
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$snapshotName = "${Name}_${timestamp}"
$volumeName = "claude-cowork-macos-storage"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$snapshotDir = Join-Path $scriptDir "..\snapshots\$snapshotName"

Write-Host "Creating snapshot: $snapshotName" -ForegroundColor Cyan

# Stop the VM gracefully first
Write-Host "Stopping VM for consistent snapshot..." -ForegroundColor Yellow
Push-Location (Join-Path $scriptDir "..")
docker-compose down
Pop-Location

# Create snapshots directory if it doesn't exist
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

# Create metadata file
$metadata = @{
    name = $Name
    timestamp = $timestamp
    description = $Description
    volumeName = $volumeName
} | ConvertTo-Json

$metadata | Out-File -FilePath (Join-Path $snapshotDir "metadata.json") -Encoding UTF8

# Create the actual backup using Docker
Write-Host "Backing up volume (this may take a while)..." -ForegroundColor Yellow
$snapshotDirUnix = $snapshotDir -replace '\\', '/' -replace '^([A-Za-z]):', '/$1'
docker run --rm `
    -v "${volumeName}:/source:ro" `
    -v "${snapshotDir}:/backup" `
    alpine tar czf /backup/disk.tar.gz -C /source .

# Get backup size
$backupFile = Join-Path $snapshotDir "disk.tar.gz"
$size = (Get-Item $backupFile).Length / 1MB

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Snapshot Created" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Name: $snapshotName"
Write-Host "Location: snapshots\$snapshotName\"
Write-Host "Size: $([math]::Round($size, 2)) MB"
Write-Host ""
Write-Host "To restart the VM: docker-compose up -d" -ForegroundColor Cyan
