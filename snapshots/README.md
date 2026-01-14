# Snapshots

This folder contains VM snapshots. Each snapshot is a point-in-time backup of the Windows VM state.

## Creating Snapshots

```bash
# From the project root
./scripts/snapshot.sh <name> "<description>"

# Example
./scripts/snapshot.sh clean-install "Fresh Windows with all dev tools"
./scripts/snapshot.sh before-refactor "About to refactor the auth module"
```

## Restoring Snapshots

```bash
# WARNING: This destroys the current VM state!
./scripts/restore.sh <snapshot_folder_name>

# Example
./scripts/restore.sh clean-install_2024-01-15_10-30-00
```

## Snapshot Contents

Each snapshot folder contains:
- `metadata.json` - Snapshot name, timestamp, description
- `disk.tar.gz` - Compressed VM disk image (large!)

## Best Practices

1. **Create snapshots before risky operations** - refactoring, installing new software, etc.
2. **Name snapshots descriptively** - you'll thank yourself later
3. **Keep only what you need** - snapshots are large (10-30GB each)
4. **Don't commit disk.tar.gz** - it's in .gitignore for a reason

## Storage

Snapshots are stored locally and NOT pushed to git (disk.tar.gz is gitignored).

To share a snapshot, manually copy the folder to another machine.
