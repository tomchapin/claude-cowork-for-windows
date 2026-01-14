#!/bin/bash
# Create a snapshot of the current VM state
# Usage: ./scripts/snapshot.sh <name> [description]

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/snapshot.sh <name> [description]"
    echo "Example: ./scripts/snapshot.sh clean-dev-environment 'Fresh install with all tools'"
    exit 1
fi

NAME="$1"
DESCRIPTION="${2:-}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SNAPSHOT_NAME="${NAME}_${TIMESTAMP}"
VOLUME_NAME="claude-cowork-macos-storage"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SNAPSHOT_DIR="${SCRIPT_DIR}/../snapshots/${SNAPSHOT_NAME}"

echo -e "\033[36mCreating snapshot: ${SNAPSHOT_NAME}\033[0m"

# Stop the VM gracefully first
echo -e "\033[33mStopping VM for consistent snapshot...\033[0m"
docker-compose down

# Create snapshots directory
mkdir -p "${SNAPSHOT_DIR}"

# Create metadata file
cat > "${SNAPSHOT_DIR}/metadata.json" << EOF
{
    "name": "${NAME}",
    "timestamp": "${TIMESTAMP}",
    "description": "${DESCRIPTION}",
    "volumeName": "${VOLUME_NAME}"
}
EOF

# Create the actual backup
echo -e "\033[33mBacking up volume (this may take a while)...\033[0m"
docker run --rm \
    -v ${VOLUME_NAME}:/source:ro \
    -v "${SNAPSHOT_DIR}":/backup \
    alpine tar czf /backup/disk.tar.gz -C /source .

echo ""
echo -e "\033[32m========================================\033[0m"
echo -e "\033[32m Snapshot Created\033[0m"
echo -e "\033[32m========================================\033[0m"
echo ""
echo "Name: ${SNAPSHOT_NAME}"
echo "Location: snapshots/${SNAPSHOT_NAME}/"
echo "Size: $(du -h "${SNAPSHOT_DIR}/disk.tar.gz" | cut -f1)"
echo ""
echo -e "\033[36mTo restart the VM: docker-compose up -d\033[0m"
