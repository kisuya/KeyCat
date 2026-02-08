#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Syncing shortcuts..."
./Scripts/sync-shortcuts.sh

echo "Building release binary..."
swift build -c release

BIN_PATH=$(swift build -c release --show-bin-path)
APP_DIR="build/KeyCat.app"

echo "Creating .app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH/KeyCat" "$APP_DIR/Contents/MacOS/KeyCat"
cp "Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

BUNDLE_DIR=$(find "$BIN_PATH" -name "KeyCat_KeyCat.bundle" -type d 2>/dev/null | head -1)
if [ -n "$BUNDLE_DIR" ]; then
    cp -R "$BUNDLE_DIR" "$APP_DIR/Contents/Resources/"
    echo "Copied resource bundle."
fi

echo "App bundle created at: $APP_DIR"
