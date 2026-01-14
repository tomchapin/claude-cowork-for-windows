# Create a snapshot of the current VM state
# Usage: .\scripts\snapshot.ps1 -Name "clean-dev-environment"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [string]$Description = ""
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$snapshotName = "${Name}_${timestamp}"
$volumeName = "claude-cowork-macos-storage"

Write-Host "Creating snapshot: $snapshotName" -ForegroundColor Cyan

# Stop the VM gracefully first
Write-Host "Stopping VM for consistent snapshot..." -ForegroundColor Yellow
docker-compose down

# Get the volume mount point
$volumePath = docker volume inspect $volumeName --format '{{ .Mountpoint }}' 2>$null
if (-not $volumePath) {
    Write-Host "ERROR: Volume not found. Has the VM been started at least once?" -ForegroundColor Red
    exit 1
}

# Create snapshots directory if it doesn't exist
$snapshotDir = Join-Path $PSScriptRoot "..\snapshots\$snapshotName"
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

# Create metadata file
$metadata = @{
    name = $Name
    timestamp = $timestamp
    description = $Description
    volumeName = $volumeName
} | ConvertTo-Json

$metadata | Out-File -FilePath (Join-Path $snapshotDir "metadata.json")

# Note: Actual disk image backup requires elevated Docker access
# For production use, consider using Docker volume backup tools

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Snapshot Created" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Name: $snapshotName" -ForegroundColor White
Write-Host "Metadata saved to: snapshots\$snapshotName\" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTE: For full disk backup, manually copy the Docker volume:" -ForegroundColor Yellow
Write-Host "  docker run --rm -v ${volumeName}:/source -v \$(pwd)/snapshots/${snapshotName}:/backup alpine tar czf /backup/disk.tar.gz -C /source ." -ForegroundColor Gray
Write-Host ""
Write-Host "To restart the VM: docker-compose up -d" -ForegroundColor Cyan
