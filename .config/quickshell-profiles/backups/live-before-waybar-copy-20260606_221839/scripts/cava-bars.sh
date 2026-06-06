#!/usr/bin/env bash

CONF="$HOME/.config/cava/quickshell.conf"
N=14

bars=( "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" )

cava -p "$CONF" 2>/tmp/quickshell-cava.err | while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  out=""
  IFS=';' read -ra vals <<< "$line"

  for ((i=0; i<N; i++)); do
    v="${vals[$i]:-0}"
    idx=$(( v * 8 / 100 ))
    (( idx < 0 )) && idx=0
    (( idx > 7 )) && idx=7
    out+="${bars[$idx]}"
  done

  echo "$out"
done
