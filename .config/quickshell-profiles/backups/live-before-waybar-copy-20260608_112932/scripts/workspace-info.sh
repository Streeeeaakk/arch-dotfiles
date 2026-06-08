#!/usr/bin/env bash

active_ws="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1')"

occupied="$(
  hyprctl workspaces -j 2>/dev/null |
    jq -r '[.[].id] | sort | map(tostring) | join(",")'
)"

if [ "$active_ws" -ge 1 ] && [ "$active_ws" -le 4 ]; then
    group_start=1
    group_end=4
elif [ "$active_ws" -ge 5 ] && [ "$active_ws" -le 8 ]; then
    group_start=5
    group_end=8
else
    group_start=9
    group_end=12
fi

printf '%s\t%s\t%s\t%s\n' "$active_ws" "$occupied" "$group_start" "$group_end"
