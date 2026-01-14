#!/bin/bash
# Claude macOS Sandbox - Development Environment Setup
# Run this script after first macOS boot to install all dev tools
#
# Usage:
#   chmod +x /Volumes/shared/setup-dev-environment.sh
#   /Volumes/shared/setup-dev-environment.sh
#
# After completion, create a snapshot to preserve this state!

set -e

echo "========================================"
echo " Claude macOS Sandbox Setup"
echo "========================================"
echo ""

# ============================================
# Install Xcode Command Line Tools
# ============================================
echo "[1/7] Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "  Please complete the Xcode CLI installation popup, then re-run this script."
    exit 0
else
    echo "  Xcode CLI already installed, skipping."
fi

# ============================================
# Install Homebrew
# ============================================
echo "[2/7] Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "  Homebrew already installed, skipping."
fi

# ============================================
# Core Tools
# ============================================
echo "[3/7] Installing core tools..."
brew install --cask google-chrome
brew install --cask visual-studio-code
brew install --cask iterm2
brew install git wget curl jq

# ============================================
# Node.js
# ============================================
echo "[4/7] Installing Node.js..."
brew install node@20
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# ============================================
# Claude Code CLI
# ============================================
echo "[5/7] Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code

# ============================================
# Rust Toolchain
# ============================================
echo "[6/7] Installing Rust toolchain..."
if ! command -v rustc &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    # Add WASM target
    rustup target add wasm32-unknown-unknown

    # Install trunk for WASM bundling
    cargo install trunk
else
    echo "  Rust already installed, skipping."
fi

# ============================================
# Python
# ============================================
echo "[7/7] Installing Python..."
brew install python@3.11

# ============================================
# VS Code Extensions
# ============================================
echo ""
echo "Installing VS Code extensions..."
code --install-extension rust-lang.rust-analyzer
code --install-extension ms-python.python
code --install-extension esbenp.prettier-vscode
code --install-extension bradlc.vscode-tailwindcss

# ============================================
# Enable SSH for remote access
# ============================================
echo ""
echo "Enabling SSH access..."
sudo systemsetup -setremotelogin on 2>/dev/null || echo "  (Run manually: System Settings > General > Sharing > Remote Login)"

# ============================================
# Summary
# ============================================
echo ""
echo "========================================"
echo " Setup Complete!"
echo "========================================"
echo ""
echo "Installed:"
echo "  - Chrome, VS Code, iTerm2"
echo "  - Git, Node.js 20, npm"
echo "  - Claude Code CLI"
echo "  - Rust + cargo + trunk (WASM)"
echo "  - Python 3.11"
echo ""
echo "Next steps:"
echo "  1. Restart Terminal (or run: source ~/.zprofile)"
echo "  2. Set your API key:"
echo "     export ANTHROPIC_API_KEY='your-key-here'"
echo "     echo 'export ANTHROPIC_API_KEY=\"your-key\"' >> ~/.zprofile"
echo "  3. Configure git:"
echo "     git config --global user.name 'Your Name'"
echo "     git config --global user.email 'you@example.com'"
echo "  4. CREATE A SNAPSHOT! (This is your clean baseline)"
echo ""
echo "To use Claude Code:"
echo "  claude                              # Normal mode"
echo "  claude --dangerously-skip-permissions  # Full access mode"
echo ""
echo "To use Claude Cowork (the reason we're here!):"
echo "  Install from: https://claude.ai/download"
echo "  This macOS VM enables Cowork on Windows!"
echo ""
