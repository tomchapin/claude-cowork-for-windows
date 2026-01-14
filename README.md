# Claude Cowork for Windows

Run **Claude Cowork** on Windows by running macOS in a Docker container.

## The Problem

[Claude Cowork](https://claude.ai/download) is Anthropic's desktop application that enables Claude to control your computer - taking screenshots, moving the mouse, typing, and automating complex workflows. It's incredibly powerful.

**But Cowork only runs on macOS.**

## The Solution

Run a full macOS virtual machine inside Docker on your Windows PC. Connect via VNC, install Cowork, and you're done.

```
┌──────────────────────────────────────────┐
│  Your Windows PC                         │
│  ┌────────────────────────────────────┐  │
│  │  Docker Desktop (WSL2)             │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │  macOS Sonoma VM             │  │  │
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

- **Windows 10/11** with Docker Desktop
- **Virtualization enabled** in BIOS (Intel VT-x / AMD-V)
- **8GB RAM** for the VM
- **64GB disk space**

Check virtualization:
```powershell
systeminfo | findstr /i "Virtualization"
# Should show: Virtualization Enabled In Firmware: Yes
```

## Quick Start

### 1. Clone and start

```powershell
git clone https://github.com/tomchapin/claude-cowork-for-windows.git
cd claude-cowork-for-windows
docker-compose up -d
```

### 2. Wait for macOS to install

First boot takes ~15 minutes. Watch progress:
```powershell
docker-compose logs -f
```

### 3. Connect via VNC

Download [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) (free) and connect to:
```
localhost:5999
```

Complete the macOS setup wizard.

### 4. Install Cowork

Inside macOS:
1. Open Safari → https://claude.ai/download
2. Download and install the macOS app
3. Sign in

**Done! You now have Claude Cowork on Windows.**

## Usage

```powershell
# Start
docker-compose up -d

# Stop (preserves state)
docker-compose down

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

## Troubleshooting

**"KVM not available"**
1. Enable virtualization in BIOS
2. Ensure Docker uses WSL2 backend
3. Run `wsl --update`

**Slow boot**
First boot is slow. Subsequent boots take 1-2 minutes.

**Can't connect VNC**
Wait for macOS to fully boot. Check `docker-compose logs -f`.

## Bonus: Dev Environment

Run the setup script inside macOS for a full dev environment:
```bash
chmod +x /Volumes/shared/setup-dev-environment.sh
/Volumes/shared/setup-dev-environment.sh
```

Installs: Chrome, VS Code, Git, Node.js, Rust, Python, Claude Code CLI.

## Legal

Running macOS in a VM is against Apple's EULA unless on Apple hardware. For personal/educational use only.

## Credits

- [sickcodes/Docker-OSX](https://github.com/sickcodes/Docker-OSX)
- [Anthropic Claude](https://claude.ai)

## License

MIT
