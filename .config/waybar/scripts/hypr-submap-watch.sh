#!/usr/bin/env bash
SOCK="/run/user/1000/hypr/71a1216abcc7031776630a6d88f105605c4dc1c9_1771328904_595116357/.socket2.sock"

[ -S "$SOCK" ] || exit 0

# Start hidden
echo ""

socat -u "UNIX-CONNECT:$SOCK" - | while IFS= read -r line; do
  case "$line" in
    submap\>\>*)
      sub="${line#submap>>}"   # may be "" when leaving submap
      if [ "$sub" = "GAMING" ]; then
        echo "🎮 GAMING"
      else
        echo ""
      fi
      ;;
  esac
done
