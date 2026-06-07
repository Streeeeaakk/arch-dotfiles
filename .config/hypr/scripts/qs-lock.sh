#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="$HOME/.config/quickshell-lockscreen"
BG="/tmp/qs-lock-bg.png"
RAW="/tmp/qs-lock-bg-raw.png"
LOCK_FILE="/tmp/qs-lockscreen.lock"
TITLE="Quickshell LockScreen"

# Prevent duplicate lockscreen instances.
if [[ -f "$LOCK_FILE" ]]; then
  OLD_PID="$(cat "$LOCK_FILE" 2>/dev/null || true)"

  if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
    hyprctl dispatch focuswindow "title:$TITLE" >/dev/null 2>&1 || true
    hyprctl dispatch fullscreen 0 >/dev/null 2>&1 || true
    hyprctl dispatch submap QSLOCK >/dev/null 2>&1 || true
    exit 0
  fi

  rm -f "$LOCK_FILE"
fi

mkdir -p "$RUN_DIR"

grim "$RAW"
magick "$RAW" -resize 25% -blur 0x8 -resize 400% -brightness-contrast -12x-4 "$BG"
rm -f "$RAW"

cp "$HOME/.config/quickshell-profiles/current/lockscreen/LockScreen.qml" \
  "$RUN_DIR/shell.qml"

rm -rf "$RUN_DIR/theme"
cp -a "$HOME/.config/quickshell-profiles/current/theme" \
  "$RUN_DIR/theme"

setsid -f quickshell -p "$RUN_DIR" >/tmp/qs-lockscreen.log 2>&1

sleep 0.7

QS_PID="$(
  hyprctl clients -j 2>/dev/null \
    | jq -r '.[] | select(.title == "'"$TITLE"'") | .pid' \
    | head -n1
)"

if [[ -n "${QS_PID:-}" && "$QS_PID" != "null" ]]; then
  echo "$QS_PID" > "$LOCK_FILE"
fi

hyprctl dispatch focuswindow "title:$TITLE" >/dev/null 2>&1 || true
hyprctl dispatch fullscreen 0 >/dev/null 2>&1 || true
hyprctl dispatch submap QSLOCK >/dev/null 2>&1 || true
