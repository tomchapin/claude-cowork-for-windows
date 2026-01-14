# Restore a snapshot
# Usage: .\scripts\restore.ps1 -SnapshotName "clean-install_2026-01-13_18-30-00"

param(
    [Parameter(Mandatory=$false)]
    [string]$SnapshotName
)

$ErrorActionPreference = "Stop"

$volumeName = "claude-cowork-macos-storage"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$snapshotsDir = Join-Path $scriptDir "..\snapshots"

# If no snapshot specified, list available ones
if (-not $SnapshotName) {
    Write-Host "Usage: .\scripts\restore.ps1 -SnapshotName <snapshot_name>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Available snapshots:" -ForegroundColor Cyan

    if (Test-Path $snapshotsDir) {
        $snapshots = Get-ChildItem -Path $snapshotsDir -Directory
        if ($snapshots.Count -eq 0) {
            Write-Host "  (none)" -ForegroundColor Gray
        } else {
            foreach ($snap in $snapshots) {
                $metadataPath = Join-Path $snap.FullName "metadata.json"
                if (Test-Path $metadataPath) {
                    $metadata = Get-Content $metadataPath | ConvertFrom-Json
                    Write-Host "  $($snap.Name)" -ForegroundColor White
                    if ($metadata.description) {
                        Write-Host "    $($metadata.description)" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "  $($snap.Name)" -ForegroundColor White
                }
            }
        }
    } else {
        Write-Host "  (none)" -ForegroundColor Gray
    }
    exit 0
}

$snapshotDir = Join-Path $snapshotsDir $SnapshotName

# Verify snapshot exists
if (-not (Test-Path $snapshotDir)) {
    Write-Host "ERROR: Snapshot '$SnapshotName' not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Available snapshots:" -ForegroundColor Cyan
    if (Test-Path $snapshotsDir) {
        Get-ChildItem -Path $snapshotsDir -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    } else {
        Write-Host "  (none)" -ForegroundColor Gray
    }
    exit 1
}

$backupFile = Join-Path $snapshotDir "disk.tar.gz"
if (-not (Test-Path $backupFile)) {
    Write-Host "ERROR: Snapshot backup file not found." -ForegroundColor Red
    exit 1
}

Write-Host "Restoring snapshot: $SnapshotName" -ForegroundColor Cyan
Write-Host "WARNING: This will DESTROY the current VM state!" -ForegroundColor Red
$confirm = Read-Host "Are you sure? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

# Stop and remove current container
Write-Host "Stopping and removing current VM..." -ForegroundColor Yellow
Push-Location (Join-Path $scriptDir "..")
docker-compose down -v
Pop-Location

# Recreate volume and restore
Write-Host "Restoring from backup (this may take a while)..." -ForegroundColor Yellow
docker volume create $volumeName
docker run --rm `
    -v "${volumeName}:/target" `
    -v "${snapshotDir}:/backup:ro" `
    alpine tar xzf /backup/disk.tar.gz -C /target

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Snapshot Restored" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Restored: $SnapshotName"
Write-Host ""
Write-Host "To start the VM: docker-compose up -d" -ForegroundColor Cyan
