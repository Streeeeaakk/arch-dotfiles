#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="$HOME/.config/quickshell-lockscreen-fullscreen"

mkdir -p "$RUN_DIR"

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
