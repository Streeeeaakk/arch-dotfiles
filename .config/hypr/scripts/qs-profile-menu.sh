#!/usr/bin/env bash
set -euo pipefail

PROFILES_DIR="$HOME/.config/quickshell-profiles"
SWITCHER="$HOME/.config/hypr/scripts/qs-config-switch.sh"

profiles="$(
  find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name backups \
    -printf "%f\n" | sort
)"

if [ -z "$profiles" ]; then
  notify-send "Quickshell Config Switcher" "No profiles found"
  exit 1
fi

active="$(cat "$PROFILES_DIR/active-profile" 2>/dev/null || true)"

menu_items="$(
  while IFS= read -r p; do
    if [ "$p" = "$active" ]; then
      echo "● $p"
    else
      echo "○ $p"
    fi
  done <<< "$profiles"
)"

choice=""

if command -v rofi >/dev/null 2>&1; then
  choice="$(printf "%s\n" "$menu_items" | rofi -dmenu -i -p "Quickshell Config")"
elif command -v wofi >/dev/null 2>&1; then
  choice="$(printf "%s\n" "$menu_items" | wofi --dmenu --prompt "Quickshell Config" --width 360 --height 180)"
elif command -v fuzzel >/dev/null 2>&1; then
  choice="$(printf "%s\n" "$menu_items" | fuzzel --dmenu --prompt "Quickshell Config: ")"
elif command -v tofi >/dev/null 2>&1; then
  choice="$(printf "%s\n" "$menu_items" | tofi --prompt-text "Quickshell Config: ")"
else
  notify-send "Quickshell Config Switcher" "No menu tool found: install rofi, wofi, fuzzel, or tofi"
  exit 1
fi

[ -z "$choice" ] && exit 0

profile="$(printf "%s" "$choice" | sed 's/^[●○] //')"

"$SWITCHER" "$profile"
