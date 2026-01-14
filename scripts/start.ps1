# Start the Claude macOS Sandbox
# Usage: .\scripts\start.ps1

$ErrorActionPreference = "Stop"

Write-Host "Starting Claude macOS Sandbox..." -ForegroundColor Cyan

# Check if Docker is running
$dockerRunning = docker info 2>$null
if (-not $dockerRunning) {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if running in WSL2 (required for KVM)
Write-Host "Note: macOS VM requires KVM. On Windows, this runs through WSL2." -ForegroundColor Yellow
Write-Host "If you encounter KVM errors, ensure:" -ForegroundColor Yellow
Write-Host "  1. Virtualization is enabled in BIOS" -ForegroundColor Gray
Write-Host "  2. Docker Desktop is using WSL2 backend" -ForegroundColor Gray
Write-Host "  3. Nested virtualization is enabled for WSL" -ForegroundColor Gray
Write-Host ""

# Start the container
docker-compose up -d

# Wait for container to start
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Access Information" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "VNC (Remote Desktop):" -ForegroundColor White
Write-Host "  Address:  localhost:5999" -ForegroundColor Gray
Write-Host "  Use any VNC client (RealVNC, TightVNC, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "SSH (Command Line):" -ForegroundColor White
Write-Host "  Command: ssh user@localhost -p 50922" -ForegroundColor Gray
Write-Host "  Password: alpine (default)" -ForegroundColor Gray
Write-Host ""
Write-Host "First Boot:" -ForegroundColor Yellow
Write-Host "  - Takes 10-15 minutes for macOS installation" -ForegroundColor Gray
Write-Host "  - Complete the macOS setup wizard via VNC" -ForegroundColor Gray
Write-Host "  - Then run the setup script from shared folder" -ForegroundColor Gray
Write-Host ""
Write-Host "To view logs: docker-compose logs -f" -ForegroundColor Cyan
Write-Host "To stop: docker-compose down" -ForegroundColor Cyan
Write-Host ""
