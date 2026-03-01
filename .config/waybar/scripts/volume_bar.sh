#!/usr/bin/env bash
set -euo pipefail

INFO="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
if [[ -z "$INFO" ]]; then
  echo '{"text":"󰖁 N/A","tooltip":"No default audio sink","class":"muted"}'
  exit 0
fi

VOL_RAW="$(awk '{print $2}' <<< "$INFO")"
MUTED="$(grep -q 'MUTED' <<< "$INFO" && echo 1 || echo 0)"

# Convert 0.00–1.00 to percent
VOL="$(awk -v v="$VOL_RAW" 'BEGIN { printf("%d\n", v*100 + 0.5) }')"

(( VOL < 0 )) && VOL=0
(( VOL > 150 )) && VOL=150   # allow >100% if you use it, adjust if you want

# --- icon set (Nerd Font) ---
# muted, low, mid, high
if (( MUTED == 1 )); then
  ICON="󰖁"
elif (( VOL == 0 )); then
  ICON="󰕿"
elif (( VOL < 35 )); then
  ICON="󰖀"
else
  ICON="󰕾"
fi

# --- class logic (for CSS) ---
CLASS="normal"
if (( MUTED == 1 )); then
  CLASS="muted"
elif (( VOL == 0 )); then
  CLASS="critical"
elif (( VOL <= 20 )); then
  CLASS="warning"
fi

# --- optional thin bar (remove if you want icon+% only) ---
SLOTS=6
FILLED=$(( (VOL * SLOTS) / 100 ))
(( FILLED > SLOTS )) && FILLED=$SLOTS
EMPTY=$(( SLOTS - FILLED ))

BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="━"; done
for ((i=0; i<EMPTY;  i++)); do BAR+="─"; done

# Choose one:
# Minimal:
# TEXT="$ICON ${VOL}%"
# With thin bar:
TEXT="$ICON ${VOL}% $BAR"

echo "{\"text\":\"$TEXT\",\"tooltip\":\"Volume: ${VOL}%\",\"class\":\"$CLASS\"}"