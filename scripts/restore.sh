#!/bin/bash
# Restore a snapshot
# Usage: ./scripts/restore.sh <snapshot_name>

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/restore.sh <snapshot_name>"
    echo ""
    echo "Available snapshots:"
    ls -1 "$(dirname "$0")/../snapshots" 2>/dev/null || echo "  (none)"
    exit 1
fi

SNAPSHOT_NAME="$1"
VOLUME_NAME="claude-cowork-macos-storage"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SNAPSHOT_DIR="${SCRIPT_DIR}/../snapshots/${SNAPSHOT_NAME}"

if [ ! -d "${SNAPSHOT_DIR}" ]; then
    echo -e "\033[31mERROR: Snapshot '${SNAPSHOT_NAME}' not found.\033[0m"
    echo ""
    echo "Available snapshots:"
    ls -1 "${SCRIPT_DIR}/../snapshots" 2>/dev/null || echo "  (none)"
    exit 1
fi

if [ ! -f "${SNAPSHOT_DIR}/disk.tar.gz" ]; then
    echo -e "\033[31mERROR: Snapshot backup file not found.\033[0m"
    exit 1
fi

echo -e "\033[36mRestoring snapshot: ${SNAPSHOT_NAME}\033[0m"
echo -e "\033[31mWARNING: This will DESTROY the current VM state!\033[0m"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Stop and remove current container
echo -e "\033[33mStopping and removing current VM...\033[0m"
docker-compose down -v

# Recreate volume and restore
echo -e "\033[33mRestoring from backup (this may take a while)...\033[0m"
docker volume create ${VOLUME_NAME}
docker run --rm \
    -v ${VOLUME_NAME}:/target \
    -v "${SNAPSHOT_DIR}":/backup:ro \
    alpine tar xzf /backup/disk.tar.gz -C /target

echo ""
echo -e "\033[32m========================================\033[0m"
echo -e "\033[32m Snapshot Restored\033[0m"
echo -e "\033[32m========================================\033[0m"
echo ""
echo "Restored: ${SNAPSHOT_NAME}"
echo ""
echo -e "\033[36mTo start the VM: docker-compose up -d\033[0m"
