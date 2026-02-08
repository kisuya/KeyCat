#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Syncing shortcuts..."
./Scripts/sync-shortcuts.sh

echo "Building KeyCat (release)..."
swift build -c release

echo "Build complete."
echo "Binary: $(swift build -c release --show-bin-path)/KeyCat"
