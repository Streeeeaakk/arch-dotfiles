#!/usr/bin/env bash

active="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1')"
occupied="$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' | sort -n | paste -sd ',' -)"

if [ "$active" -le 5 ]; then
    group_start=1
    group_end=5
else
    group_start=6
    group_end=10
fi

[ -z "$active" ] && active="1"
[ -z "$occupied" ] && occupied="$active"

printf '%s\t%s\t%s\t%s\n' "$active" "$occupied" "$group_start" "$group_end"
