#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

APP_SRC="build/KeyCat.app"
APP_DEST="/Applications/KeyCat.app"

if [ ! -d "$APP_SRC" ]; then
    echo "Error: $APP_SRC not found. Run package-app.sh first."
    exit 1
fi

echo "Installing KeyCat to /Applications..."

if [ -d "$APP_DEST" ]; then
    echo "Removing existing installation..."
    rm -rf "$APP_DEST"
fi

cp -R "$APP_SRC" "$APP_DEST"

echo "Updating Spotlight index..."
mdimport "$APP_DEST"

echo "Installation complete."
echo "Launch KeyCat from Spotlight (Cmd+Space → KeyCat) or run:"
echo "  open /Applications/KeyCat.app"
