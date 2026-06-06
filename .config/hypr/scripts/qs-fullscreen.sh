#!/usr/bin/env bash

STATE="/tmp/quickshell-bar-hidden"

monitor="$(
  hyprctl monitors -j 2>/dev/null |
  jq -r '.[] | select(.focused == true) | .name' |
  head -n1
)"

[ -z "$monitor" ] && monitor="unknown"

is_full="$(
  hyprctl activewindow -j 2>/dev/null |
  jq -r '.fullscreen // 0'
)"

# 0 = real fullscreen for current active window
hyprctl dispatch fullscreen 0 >/dev/null

if [ "$is_full" = "1" ] || [ "$is_full" = "true" ]; then
  printf '%s\t0\n' "$monitor" > "$STATE"
else
  printf '%s\t1\n' "$monitor" > "$STATE"
fi
