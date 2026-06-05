#!/usr/bin/env bash
set -euo pipefail

theme="${1:-cyan}"

WAYBAR_DIR="$HOME/.config/waybar/demeter-cyan"
THEMES_DIR="$WAYBAR_DIR/themes"
ACTIVE_FILE="$WAYBAR_DIR/colors.css"
STYLE_FILE="$WAYBAR_DIR/style.css"
STATE_FILE="$WAYBAR_DIR/.mode"
CFG="$WAYBAR_DIR/config.jsonc"

SRC_FILE="$THEMES_DIR/$theme.css"

if [[ ! -f "$SRC_FILE" ]]; then
  echo "Theme not found: $SRC_FILE" >&2
  exit 1
fi

if [[ ! -f "$CFG" ]]; then
  echo "Waybar config not found: $CFG" >&2
  exit 1
fi

# 1) Apply Waybar colors
cp -f "$SRC_FILE" "$ACTIVE_FILE"

# 2) Set mode for custom text script
if [[ "$theme" == "gaming" ]]; then
  echo "gaming" > "$STATE_FILE"
else
  echo "normal" > "$STATE_FILE"
fi

# 3) Restart Waybar using the single shared config
pkill -x waybar 2>/dev/null || true
sleep 0.2

waybar -c "$CFG" -s "$STYLE_FILE" >/dev/null 2>&1 &
disown || true
