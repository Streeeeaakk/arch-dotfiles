#!/usr/bin/env bash

STATE="/tmp/quickshell-launcher-trigger"
last=""

while true; do
    demeter-2.0="$(cat "$STATE" 2>/dev/null || true)"

    if [ -n "$demeter-2.0" ] && [ "$demeter-2.0" != "$last" ]; then
        printf '%s\n' "$demeter-2.0"
        last="$demeter-2.0"
    fi

    sleep 0.10
done
