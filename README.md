# Claude Cowork for Windows

Run **Claude Cowork** on Windows by running macOS in a Docker container.

## The Problem

[Claude Cowork](https://claude.ai/download) is Anthropic's desktop application that enables Claude to control your computer - taking screenshots, moving the mouse, typing, and automating complex workflows. It's incredibly powerful.

**But Cowork only runs on macOS.**

## The Solution

Run a full macOS virtual machine inside Docker on your Windows PC. Connect via VNC, complete the macOS setup, install Cowork, and you're done.

```
┌──────────────────────────────────────────┐
│  Your Windows PC                         │
│  ┌────────────────────────────────────┐  │
│  │  Docker Desktop (WSL2)             │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │  macOS VM                    │  │  │
│  │  │  ┌────────────────────────┐  │  │  │
│  │  │  │    Claude Cowork       │  │  │  │
│  │  │  └────────────────────────┘  │  │  │
│  │  └──────────────────────────────┘  │  │
│  └────────────────────────────────────┘  │
│                    ▲                     │
│         VNC Viewer (port 5999)           │
└──────────────────────────────────────────┘
```

## Requirements

- **Windows 10/11** with Docker Desktop (WSL2 backend)
- **Virtualization enabled** in BIOS (Intel VT-x / AMD-V/SVM)

**Recommended specs:**
- 8GB+ RAM available for the VM (4GB minimum, but will be slow)
- 64GB+ free disk space (can work with less)

Check virtualization:
```powershell
systeminfo | findstr /i "Virtualization"
# Should show: Virtualization Enabled In Firmware: Yes
```

## Quick Start

### 1. Enable KVM (required for macOS virtualization)

Run the included setup script:
```powershell
.\scripts\enable-kvm.ps1
```

Or manually: see [KVM Troubleshooting](#kvm-not-available-error) below.

### 2. Clone and start

```powershell
git clone https://github.com/tomchapin/claude-cowork-for-windows.git
cd claude-cowork-for-windows
docker-compose up -d
```

### 3. Wait for macOS to download and boot

First boot takes ~15-20 minutes (downloads macOS, then installs). Watch progress:
```powershell
docker-compose logs -f
```

### 4. Connect via VNC

Use any VNC client (all free and open source):
- **[TigerVNC](https://tigervnc.org/)** - Recommended, clean and fast
- **[TightVNC](https://www.tightvnc.com/)** - Classic and reliable
- **[UltraVNC](https://uvnc.com/)** - Feature-rich

Connect to:
```
localhost:5999
```

### 5. Complete macOS setup

Follow the macOS setup wizard:
- Select your country/region
- Skip Apple ID (or sign in)
- Create a user account
- Complete remaining setup steps

### 6. Install Claude Code CLI

Once macOS is set up, open **Terminal** (Cmd+Space, type "Terminal") and run:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (run the command it tells you, or):
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Node.js
brew install node

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

### 7. Install Claude Cowork (Desktop App)

1. Open **Safari** in macOS
2. Go to https://claude.ai/download
3. Download and install the macOS app
4. Sign in with your Anthropic account

**Done! You now have Claude Cowork on Windows.**

## Usage

```powershell
# Start
docker-compose up -d

# Stop (preserves state)
docker-compose down

# View logs
docker-compose logs -f

# Fresh start (deletes everything)
docker-compose down -v
```

### Snapshots

Save VM state before experiments:

```bash
./scripts/snapshot.sh my-snapshot "Description"
./scripts/restore.sh my-snapshot_2024-01-15_10-30-00
```

## Access

| Method | Address | Password |
|--------|---------|----------|
| VNC | localhost:5999 | (none) |
| SSH | localhost:50922 | alpine |

## Optional: Full Dev Environment

For a complete development setup (VS Code, Git, Rust, Python, etc.), run the included setup script inside macOS Terminal:

```bash
# Copy from shared folder and run
cp /Volumes/shared/setup-dev-environment.sh ~/
chmod +x ~/setup-dev-environment.sh
~/setup-dev-environment.sh
```

## Troubleshooting

### KVM not available error

If you see `error gathering device information while adding custom device "/dev/kvm"`, KVM needs to be enabled:

**Quick fix - run the helper script:**
```powershell
.\scripts\enable-kvm.ps1
```

**Manual fix:**

1. **Create/edit `%USERPROFILE%\.wslconfig`:**

   For AMD CPUs:
   ```ini
   [wsl2]
   nestedVirtualization=true
   kernelCommandLine=amd_iommu=on iommu=pt kvm.ignore_msrs=1 kvm-amd.nested=1
   ```

   For Intel CPUs:
   ```ini
   [wsl2]
   nestedVirtualization=true
   kernelCommandLine=kvm.ignore_msrs=1 kvm-intel.nested=1
   ```

2. **Restart WSL:**
   ```powershell
   wsl --shutdown
   ```

3. **Load KVM modules:**
   ```powershell
   # For AMD:
   wsl -d docker-desktop -e sh -c "modprobe kvm && modprobe kvm-amd"

   # For Intel:
   wsl -d docker-desktop -e sh -c "modprobe kvm && modprobe kvm-intel"
   ```

4. **If still not working, check BIOS settings:**
   - Enable **SVM** (AMD) or **VT-x** (Intel)
   - Enable **IOMMU** (may be called AMD-Vi or VT-d)
   - Save and reboot

### Slow boot

First boot is slow (~15-20 min) because it downloads macOS. Subsequent boots take 1-2 minutes.

### Can't connect VNC

Wait for macOS to fully boot. Check `docker-compose logs -f` to see boot progress.

### Shared folder not visible

The `./shared` folder mounts inside the container at `/mnt/shared`. To access it from macOS, you may need to use SSH/SFTP or configure file sharing.

## Legal

Running macOS in a VM is against Apple's EULA unless on Apple hardware. For personal/educational use only.

## Credits

- [sickcodes/Docker-OSX](https://github.com/sickcodes/Docker-OSX)
- [Anthropic Claude](https://claude.ai)

## License

MIT
