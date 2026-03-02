#!/usr/bin/env bash
set -euo pipefail

theme="${1:-cyan}"

WAYBAR_DIR="$HOME/.config/waybar/demeter-cyan"
THEMES_DIR="$WAYBAR_DIR/themes"          # where cyan.css / gaming.css live
ACTIVE_FILE="$WAYBAR_DIR/colors.css"
STYLE_FILE="$WAYBAR_DIR/style.css"
STATE_FILE="$WAYBAR_DIR/.mode"

LEFT_CFG="$WAYBAR_DIR/config-left.jsonc"
RIGHT_CFG="$WAYBAR_DIR/config-right.jsonc"

SRC_FILE="$THEMES_DIR/$theme.css"
[[ -f "$SRC_FILE" ]] || { echo "Theme not found: $SRC_FILE" >&2; exit 1; }

# 1) Apply theme (colors only)
cp -f "$SRC_FILE" "$ACTIVE_FILE"

# 2) Set mode for your custom text script
if [[ "$theme" == "gaming" ]]; then
  echo "gaming" > "$STATE_FILE"
else
  echo "normal" > "$STATE_FILE"
fi

# 3) Restart both waybar instances + force CSS with -s
pkill -x waybar 2>/dev/null || true
sleep 0.2

waybar -c "$RIGHT_CFG" -s "$STYLE_FILE" >/dev/null 2>&1 &
waybar -c "$LEFT_CFG"  -s "$STYLE_FILE" >/dev/null 2>&1 &
disown || true