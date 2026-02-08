#!/bin/bash
set -euo pipefail

# Sync shortcut YAML files from shortcuts/ to Sources/KeyCat/Resources/Defaults/
# This script should be run before building to ensure bundled shortcuts are up-to-date.

cd "$(dirname "$0")/.."

SHORTCUTS_DIR="shortcuts"
DEFAULTS_DIR="Sources/KeyCat/Resources/Defaults"

if [ ! -d "$SHORTCUTS_DIR" ]; then
    echo "Warning: shortcuts/ directory not found. Skipping sync."
    exit 0
fi

# Copy shortcut YAML files (not config.yaml) from shortcuts/ to Defaults/
for file in "$SHORTCUTS_DIR"/*.yaml "$SHORTCUTS_DIR"/*.yml; do
    [ -f "$file" ] || continue
    basename="$(basename "$file")"
    # Skip config.yaml
    [ "$basename" = "config.yaml" ] && continue
    cp "$file" "$DEFAULTS_DIR/$basename"
done

echo "Shortcuts synced to $DEFAULTS_DIR"
