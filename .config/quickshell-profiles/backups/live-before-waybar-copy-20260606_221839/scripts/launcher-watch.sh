#!/usr/bin/env bash

STATE="/tmp/quickshell-launcher-trigger"
last=""

while true; do
    current="$(cat "$STATE" 2>/dev/null || true)"

    if [ -n "$current" ] && [ "$current" != "$last" ]; then
        printf '%s\n' "$current"
        last="$current"
    fi

    sleep 0.10
done
