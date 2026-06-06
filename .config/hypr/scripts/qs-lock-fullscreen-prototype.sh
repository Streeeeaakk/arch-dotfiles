#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="$HOME/.config/quickshell-lockscreen-fullscreen"
BG="/tmp/qs-lock-bg.png"
RAW="/tmp/qs-lock-bg-raw.png"

mkdir -p "$RUN_DIR"

grim "$RAW"
magick "$RAW" -resize 25% -blur 0x8 -resize 400% -brightness-contrast -12x-4 "$BG"
rm -f "$RAW"

cp "$HOME/.config/quickshell-profiles/current/lockscreen/LockscreenFullscreen.qml" \
  "$RUN_DIR/shell.qml"

rm -rf "$RUN_DIR/theme"
cp -a "$HOME/.config/quickshell-profiles/current/theme" \
  "$RUN_DIR/theme"

quickshell -p "$RUN_DIR" &
QS_PID=$!

sleep 0.7

hyprctl dispatch focuswindow "title:Quickshell Lockscreen Fullscreen Prototype" >/dev/null 2>&1 || true
hyprctl dispatch fullscreen 0 >/dev/null 2>&1 || true

wait "$QS_PID"
