#!/bin/bash
# Start the Claude macOS Sandbox
# Usage: ./scripts/start.sh

set -e

echo -e "\033[36mStarting Claude macOS Sandbox...\033[0m"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "\033[31mERROR: Docker is not running. Please start Docker first.\033[0m"
    exit 1
fi

# Check KVM availability
if [ ! -e /dev/kvm ]; then
    echo -e "\033[33mWARNING: /dev/kvm not found. macOS VM requires KVM acceleration.\033[0m"
    echo "Ensure virtualization is enabled in your BIOS."
fi

# Start the container
docker-compose up -d

# Wait for container to start
sleep 5

echo ""
echo -e "\033[32m========================================\033[0m"
echo -e "\033[32m Access Information\033[0m"
echo -e "\033[32m========================================\033[0m"
echo ""
echo -e "\033[37mVNC (Remote Desktop):\033[0m"
echo "  Address:  localhost:5999"
echo "  Use any VNC client (RealVNC, TightVNC, etc.)"
echo ""
echo -e "\033[37mSSH (Command Line):\033[0m"
echo "  Command: ssh user@localhost -p 50922"
echo "  Password: alpine (default)"
echo ""
echo -e "\033[33mFirst Boot:\033[0m"
echo "  - Takes 10-15 minutes for macOS installation"
echo "  - Complete the macOS setup wizard via VNC"
echo "  - Then run the setup script from shared folder"
echo ""
echo -e "\033[36mTo view logs: docker-compose logs -f\033[0m"
echo -e "\033[36mTo stop: docker-compose down\033[0m"
echo ""
