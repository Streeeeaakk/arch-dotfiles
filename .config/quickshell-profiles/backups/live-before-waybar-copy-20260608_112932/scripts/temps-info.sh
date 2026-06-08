#!/usr/bin/env bash

CPU_FILE="/sys/class/hwmon/hwmon1/temp1_input"

if [ -r "$CPU_FILE" ]; then
  cpu_raw="$(cat "$CPU_FILE" 2>/dev/null)"
  cpu="$((cpu_raw / 1000))"
else
  cpu="?"
fi

gpu="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)"

[ -z "$gpu" ] && gpu="?"

echo "$cpu:$gpu"
