#!/usr/bin/env bash

clean() {
    sed 's/[	;|]/ /g'
}

out_vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' 'NR==1 {gsub(/[% ]/,"",$2); print $2; exit}')"
out_muted="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')"

in_vol="$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk -F'/' 'NR==1 {gsub(/[% ]/,"",$2); print $2; exit}')"
in_muted="$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')"

default_sink="$(pactl get-default-sink 2>/dev/null)"
default_source="$(pactl get-default-source 2>/dev/null)"

sinks="$(pactl list short sinks 2>/dev/null | awk '{print $2}' | paste -sd ';' -)"
sources="$(pactl list short sources 2>/dev/null | awk '{print $2}' | grep -v '\.monitor$' | paste -sd ';' -)"

[ -z "$out_vol" ] && out_vol="0"
[ -z "$in_vol" ] && in_vol="0"
[ -z "$out_muted" ] && out_muted="no"
[ -z "$in_muted" ] && in_muted="no"
[ -z "$default_sink" ] && default_sink="-"
[ -z "$default_source" ] && default_source="-"
[ -z "$sinks" ] && sinks="-"
[ -z "$sources" ] && sources="-"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$out_vol" \
    "$out_muted" \
    "$in_vol" \
    "$in_muted" \
    "$default_sink" \
    "$default_source" \
    "$sinks" \
    "$sources"
