#!/usr/bin/env bash

SOCK="/run/user/1000/hypr/71a1216abcc7031776630a6d88f105605c4dc1c9_1771328904_595116357/.socket2.sock"
STATEFILE="$HOME/.cache/waybar_submap_state"

mkdir -p "$HOME/.cache"

emit() {
  local mode="$1"
  if [ "$mode" = "GAMING" ]; then
    echo '{"text":"GAMING","class":"gaming"}'
  else
    echo '{"text":"Demeter","class":"normal"}'
  fi
}

# On startup, read last known state (prevents flash after Waybar restart)
if [ -f "$STATEFILE" ]; then
  mode="$(cat "$STATEFILE" 2>/dev/null)"
else
  mode=""
fi
emit "$mode"

# If socket missing, just stay on Demeter
[ -S "$SOCK" ] || exit 0

# Listen for submap events and persist state
socat -u "UNIX-CONNECT:$SOCK" - | while IFS= read -r line; do
  case "$line" in
    submap\>\>GAMING)
      echo "GAMING" > "$STATEFILE"
      emit "GAMING"
      ;;
    submap\>\>)
      : > "$STATEFILE"
      emit ""
      ;;
  esac
done
