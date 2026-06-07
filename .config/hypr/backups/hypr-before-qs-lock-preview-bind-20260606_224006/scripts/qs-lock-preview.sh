#!/usr/bin/env bash
set -euo pipefail

PREVIEW_DIR="$HOME/.config/quickshell-lockscreen-preview"

mkdir -p "$PREVIEW_DIR"

cp "$HOME/.config/quickshell-profiles/current/lockscreen-preview.qml" \
  "$PREVIEW_DIR/shell.qml"

rm -rf "$PREVIEW_DIR/theme"
cp -a "$HOME/.config/quickshell-profiles/current/theme" \
  "$PREVIEW_DIR/theme"

exec quickshell -p "$PREVIEW_DIR"
