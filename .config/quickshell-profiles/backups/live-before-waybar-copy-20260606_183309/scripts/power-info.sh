#!/usr/bin/env bash

bat="$(upower -e 2>/dev/null | grep -m1 BAT)"

if [ -n "$bat" ]; then
    info="$(upower -i "$bat" 2>/dev/null)"

    percent="$(echo "$info" | awk -F: '/percentage/ {gsub(/[% ]/,"",$2); print $2; exit}')"
    state="$(echo "$info" | awk -F: '/state/ {gsub(/^ +/,"",$2); print $2; exit}')"
    time_left="$(echo "$info" | awk -F: '/time to empty|time to full/ {gsub(/^ +/,"",$2); print $2; exit}')"
    capacity="$(echo "$info" | awk -F: '/capacity/ {gsub(/[% ]/,"",$2); print $2; exit}')"
else
    percent="none"
    state="Unknown"
    time_left="-"
    capacity="-"
fi

brightness="$(brightnessctl g 2>/dev/null || echo 0)"
brightness_max="$(brightnessctl m 2>/dev/null || echo 1)"

if [ "$brightness_max" -gt 0 ] 2>/dev/null; then
    brightness_percent=$((brightness * 100 / brightness_max))
else
    brightness_percent=0
fi

[ -z "$percent" ] && percent="none"
[ -z "$state" ] && state="Unknown"
[ -z "$time_left" ] && time_left="-"
[ -z "$capacity" ] && capacity="-"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "$percent" \
    "$state" \
    "$time_left" \
    "$capacity" \
    "$brightness_percent"
