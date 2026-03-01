#!/usr/bin/env bash
FIFO=/tmp/cava.fifo
N=20  # fixed width (match bars=20 in cava config)

[ -p "$FIFO" ] || (rm -f "$FIFO"; mkfifo "$FIFO")
pgrep -x cava >/dev/null || (cava >/dev/null 2>&1 & disown)

bars=( "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" )

while IFS= read -r line; do
  out=""
  IFS=';' read -ra vals <<< "$line"

  for ((i=0; i<N; i++)); do
    v="${vals[$i]:-0}"
    [[ "$v" =~ ^[0-7]$ ]] || v=0
    out+="${bars[$v]}"
  done
# If basically silent, show a stable idle line instead of blank
if [[ "$out" =~ ^▁+$ ]]; then
  out=$(printf '' $(seq 1 $N))
fi
  echo "$out"
done < "$FIFO"
