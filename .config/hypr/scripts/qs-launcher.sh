#!/usr/bin/env bash

STATE="/tmp/quickshell-launcher-trigger"

monitor="$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -n1)"

[ -z "$monitor" ] && monitor="unknown"

printf '%s\t%s\n' "$(date +%s%N)" "$monitor" > "$STATE"
