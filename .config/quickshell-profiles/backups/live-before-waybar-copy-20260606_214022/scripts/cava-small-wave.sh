#!/usr/bin/env bash

N=28
FIFO="/tmp/quickshell-cava-small-$$.fifo"
CONF="/tmp/quickshell-cava-small-$$.conf"

cleanup() {
    kill "$CAVA_PID" 2>/dev/null || true
    rm -f "$FIFO" "$CONF"
}

trap cleanup EXIT INT TERM

mkfifo "$FIFO"

cat > "$CONF" <<CAVACONF
[general]
bars = $N
framerate = 45
autosens = 1
sensitivity = 80

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = $FIFO
data_format = ascii
ascii_max_range = 100
CAVACONF

cava -p "$CONF" >/dev/null 2>&1 &
CAVA_PID=$!

while IFS= read -r line; do
    out=""
    IFS=';' read -ra vals <<< "$line"

    for ((i=0; i<N; i++)); do
        v="${vals[$i]:-0}"
        [[ "$v" =~ ^[0-9]+$ ]] || v=0
        (( v < 0 )) && v=0
        (( v > 100 )) && v=100

        if [ -z "$out" ]; then
            out="$v"
        else
            out="$out,$v"
        fi
    done

    printf '%s\n' "$out"
done < "$FIFO"
