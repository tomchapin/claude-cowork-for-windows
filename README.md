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

### 2. Wait for macOS to boot

First boot takes ~15 minutes (macOS installation). Watch progress:
```powershell
docker-compose logs -f
```

### 3. Connect via VNC

Use any VNC client (all free and open source):
- **[TigerVNC](https://tigervnc.org/)** - Recommended, clean and fast
- **[TightVNC](https://www.tightvnc.com/)** - Classic and reliable
- **[UltraVNC](https://uvnc.com/)** - Feature-rich

Connect to:
```
localhost:5999
```

### 4. Complete macOS setup

Follow the macOS setup wizard:
- Select your country/region
- Skip Apple ID (or sign in)
- Create a user account
- Complete remaining setup steps

### 5. Install Claude Code CLI

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

### 6. Install Claude Cowork (Desktop App)

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

**"KVM not available"**
1. Enable virtualization in BIOS
2. Ensure Docker Desktop uses WSL2 backend
3. Run `wsl --update`

**Slow boot**
First boot is slow (~15 min). Subsequent boots take 1-2 minutes.

**Can't connect VNC**
Wait for macOS to fully boot. Check `docker-compose logs -f`.

**Shared folder not visible**
The `./shared` folder mounts inside the container at `/mnt/shared`. To access it from macOS, you may need to use SSH/SFTP or configure file sharing.

## Legal

Running macOS in a VM is against Apple's EULA unless on Apple hardware. For personal/educational use only.

## Credits

- [sickcodes/Docker-OSX](https://github.com/sickcodes/Docker-OSX)
- [Anthropic Claude](https://claude.ai)

## License

MIT
