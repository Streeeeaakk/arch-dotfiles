#!/usr/bin/env bash
set -euo pipefail

BAT_DIR="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1 || true)"
if [[ -z "${BAT_DIR}" ]]; then
  echo '{"text":"󰂑 N/A","tooltip":"No battery detected","class":"normal"}'
  exit 0
fi

CAP="$(cat "${BAT_DIR}/capacity" 2>/dev/null || echo 0)"
STATUS="$(cat "${BAT_DIR}/status" 2>/dev/null || echo "")"

CAP="${CAP//[^0-9]/}"
[[ -z "$CAP" ]] && CAP=0
(( CAP < 0 )) && CAP=0
(( CAP > 100 )) && CAP=100

# --- Nerd Font battery icons (10-step) ---
# 0..9 = empty..full
IDX=$(( CAP / 10 ))
(( IDX > 9 )) && IDX=9

# Charging icon override
ICON="󰁹"
ICONS=( "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" )

case "$STATUS" in
  Charging) ICON="󰂄" ;;   # charging
  Full)     ICON="󰂅" ;;   # full/plugged
  *)        ICON="${ICONS[$IDX]}" ;;
esac

# --- thin bar (optional, subtle) ---
SLOTS=6
FILLED=$(( (CAP * SLOTS) / 100 ))
EMPTY=$(( SLOTS - FILLED ))

BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="━"; done
for ((i=0; i<EMPTY;  i++)); do BAR+="─"; done

CLASS="normal"
if (( CAP <= 10 )); then
  CLASS="critical"
elif (( CAP <= 20 )); then
  CLASS="warning"
fi

# Looks like: 󰁿 67% ━━━━━━━───
TEXT="$ICON ${CAP}% $BAR"
echo "{\"text\":\"$TEXT\",\"tooltip\":\"Battery: ${CAP}% (${STATUS})\",\"class\":\"$CLASS\"}"