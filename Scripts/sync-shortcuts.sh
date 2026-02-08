#!/bin/bash
set -euo pipefail

# Sync shortcut YAML files from shortcuts/ to Sources/KeyCat/Resources/Defaults/
# This script should be run before building to ensure bundled shortcuts are up-to-date.
# It can be invoked directly or via the SyncShortcuts SPM build plugin.

# Resolve project root: prefer PACKAGE_DIR (set by SPM plugin), else derive from script location
PROJECT_DIR="${PACKAGE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

SHORTCUTS_DIR="$PROJECT_DIR/shortcuts"
DEFAULTS_DIR="$PROJECT_DIR/Sources/KeyCat/Resources/Defaults"

if [ ! -d "$SHORTCUTS_DIR" ]; then
    echo "Warning: shortcuts/ directory not found. Skipping sync."
    exit 0
fi

# Ensure target directory exists
mkdir -p "$DEFAULTS_DIR"

SYNCED=0
for file in "$SHORTCUTS_DIR"/*.yaml "$SHORTCUTS_DIR"/*.yml; do
    [ -f "$file" ] || continue
    basename="$(basename "$file")"
    # Skip config.yaml
    [ "$basename" = "config.yaml" ] && continue
    dest="$DEFAULTS_DIR/$basename"
    # Only copy if source is newer than destination
    if [ ! -f "$dest" ] || [ "$file" -nt "$dest" ]; then
        cp "$file" "$dest"
        SYNCED=$((SYNCED + 1))
    fi
done

if [ "$SYNCED" -gt 0 ]; then
    echo "Synced $SYNCED shortcut file(s) to $DEFAULTS_DIR"
else
    echo "Shortcuts already up-to-date."
fi
