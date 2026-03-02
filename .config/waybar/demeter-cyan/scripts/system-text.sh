#!/usr/bin/env bash

STATE_FILE="$HOME/.config/waybar/demeter-cyan/.mode"

MODE="normal"
[[ -f "$STATE_FILE" ]] && MODE=$(cat "$STATE_FILE")

if [[ "$MODE" == "gaming" ]]; then
    echo '{"text":"Gaming","class":"gaming"}'
else
    echo '{"text":"Demeter","class":"normal"}'
fi
