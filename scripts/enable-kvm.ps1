# Enable KVM for WSL2 on Windows
# Run this script as Administrator if you encounter permission issues
#
# This script:
# 1. Creates/updates .wslconfig with nested virtualization settings
# 2. Restarts WSL
# 3. Loads KVM modules
# 4. Verifies KVM is available

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Enable KVM for WSL2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Detect CPU vendor
$cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
$isAMD = $cpu.Name -like "*AMD*"
$isIntel = $cpu.Name -like "*Intel*"

Write-Host "Detected CPU: $($cpu.Name)" -ForegroundColor Gray

if (-not $isAMD -and -not $isIntel) {
    Write-Host "WARNING: Could not detect CPU vendor. Assuming AMD." -ForegroundColor Yellow
    $isAMD = $true
}

# Step 1: Create/update .wslconfig
Write-Host ""
Write-Host "[1/3] Configuring .wslconfig..." -ForegroundColor Green

$wslConfigPath = "$env:USERPROFILE\.wslconfig"

if ($isAMD) {
    $wslConfig = @"
[wsl2]
nestedVirtualization=true
kernelCommandLine=amd_iommu=on iommu=pt kvm.ignore_msrs=1 kvm-amd.nested=1
"@
} else {
    $wslConfig = @"
[wsl2]
nestedVirtualization=true
kernelCommandLine=kvm.ignore_msrs=1 kvm-intel.nested=1
"@
}

# Check if file exists and has different content
$existingConfig = ""
if (Test-Path $wslConfigPath) {
    $existingConfig = Get-Content $wslConfigPath -Raw
}

if ($existingConfig -ne $wslConfig) {
    $wslConfig | Out-File -FilePath $wslConfigPath -Encoding utf8 -NoNewline
    Write-Host "  Created/updated $wslConfigPath" -ForegroundColor Gray
} else {
    Write-Host "  .wslconfig already configured correctly" -ForegroundColor Gray
}

# Step 2: Restart WSL
Write-Host ""
Write-Host "[2/3] Restarting WSL..." -ForegroundColor Green

wsl --shutdown
Start-Sleep -Seconds 3
Write-Host "  WSL restarted" -ForegroundColor Gray

# Step 3: Load KVM modules
Write-Host ""
Write-Host "[3/3] Loading KVM modules..." -ForegroundColor Green

try {
    if ($isAMD) {
        wsl -d docker-desktop -e sh -c "modprobe kvm && modprobe kvm-amd" 2>$null
    } else {
        wsl -d docker-desktop -e sh -c "modprobe kvm && modprobe kvm-intel" 2>$null
    }
    Write-Host "  KVM modules loaded" -ForegroundColor Gray
} catch {
    Write-Host "  Warning: Could not load KVM modules automatically" -ForegroundColor Yellow
}

# Verify KVM is available
Write-Host ""
Write-Host "Verifying KVM..." -ForegroundColor Green

$kvmCheck = wsl -d docker-desktop -e sh -c "ls /dev/kvm 2>/dev/null && echo 'OK'" 2>$null

if ($kvmCheck -like "*OK*") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " SUCCESS! KVM is now available" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: docker-compose up -d" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " KVM not yet available" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This may be because:" -ForegroundColor White
    Write-Host "  1. BIOS virtualization (SVM/VT-x) is not enabled" -ForegroundColor Gray
    Write-Host "  2. IOMMU is not enabled in BIOS" -ForegroundColor Gray
    Write-Host "  3. Docker Desktop needs to be restarted" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Try these steps:" -ForegroundColor White
    Write-Host "  1. Restart Docker Desktop" -ForegroundColor Gray
    Write-Host "  2. If still not working, check BIOS settings:" -ForegroundColor Gray
    Write-Host "     - Enable SVM (AMD) or VT-x (Intel)" -ForegroundColor Gray
    Write-Host "     - Enable IOMMU" -ForegroundColor Gray
    Write-Host "  3. Run this script again after BIOS changes" -ForegroundColor Gray
}

Write-Host ""
