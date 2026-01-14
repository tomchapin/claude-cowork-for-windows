# CLAUDE.md

Instructions for Claude Code running inside the macOS Sandbox VM.

## Environment

You are running inside an isolated macOS Sonoma VM. This environment is:

- **Fully isolated** from the host system
- **Safe for experimentation** - the host can restore from snapshots if needed
- **Running with full permissions** (`--dangerously-skip-permissions`)

You have complete freedom to:
- Install any software via Homebrew
- Modify system settings
- Run any commands
- Access the internet
- Launch GUI applications (Chrome, VS Code, Xcode, etc.)

## Available Tools

| Tool | Purpose |
|------|---------|
| `brew` | Homebrew package manager |
| `chrome` | Google Chrome - web testing |
| `code` | VS Code - full IDE |
| `git` | Version control |
| `node` / `npm` | Node.js runtime |
| `cargo` / `rustc` | Rust toolchain |
| `trunk` | WASM bundler for Rust |
| `python3` | Python 3.11 |

## Claude Cowork

This VM enables **Claude Cowork** on Windows! Cowork is Anthropic's desktop app that only runs on macOS. By running this macOS VM, Windows users get full Cowork capabilities:

- Computer use (mouse, keyboard control)
- Screenshot capture
- Browser automation
- MCP server integration

If Cowork is installed, it runs alongside Claude Code CLI.

## Common Tasks

### Running a dev server and viewing in browser

```bash
# Start your dev server
trunk serve

# Open in Chrome
open -a "Google Chrome" http://localhost:8080
```

### Installing additional software

```bash
# Use Homebrew for CLI tools
brew install <package-name>

# Use Homebrew Cask for GUI apps
brew install --cask <app-name>
```

### File access

```bash
# Shared folder from host
ls /Volumes/shared/

# Or if mounted via SSHFS
ls /mnt/shared/
```

### SSH access (for automation)

The VM exposes SSH on port 50922 (mapped from internal 10022):
```bash
ssh user@localhost -p 50922
# Default password: alpine
```

## Snapshot Safety

The user can create snapshots before risky operations. If something goes wrong:

1. They restore the snapshot
2. The VM returns to its previous state
3. No harm done

Feel free to suggest: "You might want to create a snapshot before I do this" for operations that:
- Install system-level software
- Modify important configurations
- Run untested scripts
- Make sweeping changes

## Limitations

- **No direct host access** - You cannot access files outside this VM unless they're shared
- **Limited resources** - This VM has 8GB RAM and 4 CPU cores by default
- **Network isolation** - The VM has internet access but is isolated from host network
- **Performance** - GUI operations may be slightly slower than native macOS

## Best Practices

1. **Use the shared folder** for files that need to persist outside the VM
2. **Commit and push** important work to git remotes
3. **Document changes** so the user knows what was modified
4. **Suggest snapshots** before potentially destructive operations
5. **Use SSH for automation** when GUI isn't needed

## Quick Reference

```bash
# Check macOS version
sw_vers

# Check available disk space
df -h

# Check memory usage
top -l 1 | head -n 10

# Restart Finder (if GUI glitches)
killall Finder

# Open Finder to current directory
open .
```
