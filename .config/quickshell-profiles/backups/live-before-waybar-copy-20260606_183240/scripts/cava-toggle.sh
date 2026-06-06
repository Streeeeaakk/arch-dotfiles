#!/usr/bin/env bash

STATE="$HOME/.config/quickshell/.cava-enabled"

case "${1:-status}" in
  on)
    echo "1" > "$STATE"
    ;;
  off)
    echo "0" > "$STATE"
    pkill -f "cava.*quickshell-cava" 2>/dev/null || true
    ;;
  toggle)
    if [ "$(cat "$STATE" 2>/dev/null || echo 1)" = "1" ]; then
      echo "0" > "$STATE"
      pkill -f "cava.*quickshell-cava" 2>/dev/null || true
    else
      echo "1" > "$STATE"
    fi
    ;;
  status)
    cat "$STATE" 2>/dev/null || echo "1"
    ;;
esac
