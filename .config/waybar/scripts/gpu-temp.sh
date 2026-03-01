#!/usr/bin/env bash

t=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)

if [[ -z "$t" ]]; then
  echo '{"text":"  N/A","class":"na"}'
  exit 0
fi

cls="normal"
if (( t >= 85 )); then
  cls="critical"
elif (( t >= 75 )); then
  cls="high"
fi

echo "{\"text\":\"GPU: ${t}°\",\"class\":\"$cls\"}"
