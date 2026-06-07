#!/usr/bin/env bash

STATE="/tmp/quickshell-workspace-trigger"
target="$1"

if [ -z "$target" ]; then
    exit 1
fi

hyprctl dispatch workspace "$target" >/dev/null 2>&1
sleep 0.05

active_json="$(hyprctl activeworkspace -j 2>/dev/null)"
active_ws="$(echo "$active_json" | jq -r '.id // '"$target")"
active_monitor="$(echo "$active_json" | jq -r '.monitor // ""')"

if [ -z "$active_monitor" ] || [ "$active_monitor" = "null" ]; then
    active_monitor="$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -n1)"
fi

if [ "$active_ws" -le 5 ]; then
    group_start=1
    group_end=5
else
    group_start=6
    group_end=10
fi

printf '%s\t%s\t%s\t%s\t%s\n' \
    "$(date +%s%N)" \
    "$active_ws" \
    "$group_start" \
    "$group_end" \
    "$active_monitor" > "$STATE"
