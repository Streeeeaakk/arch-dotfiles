#!/usr/bin/env bash

# CPU temp
cpu_temp="$(sensors 2>/dev/null | awk '
/Package id 0:/ {gsub(/[+°C]/,"",$4); print int($4); exit}
/Tctl:/ {gsub(/[+°C]/,"",$2); print int($2); exit}
/CPU:/ {gsub(/[+°C]/,"",$2); print int($2); exit}
')"

# CPU usage from /proc/stat
read -r _ u1 n1 s1 i1 io1 irq1 sirq1 steal1 _ < /proc/stat
total1=$((u1+n1+s1+i1+io1+irq1+sirq1+steal1))
idle1=$((i1+io1))

sleep 0.2

read -r _ u2 n2 s2 i2 io2 irq2 sirq2 steal2 _ < /proc/stat
total2=$((u2+n2+s2+i2+io2+irq2+sirq2+steal2))
idle2=$((i2+io2))

dt=$((total2-total1))
di=$((idle2-idle1))

if [ "$dt" -gt 0 ]; then
    cpu_usage=$((100 * (dt - di) / dt))
else
    cpu_usage="?"
fi

# RAM
ram_used="$(free -m | awk '/Mem:/ {print $3}')"
ram_total="$(free -m | awk '/Mem:/ {print $2}')"
ram_percent="$(free | awk '/Mem:/ {printf "%.0f", $3 * 100 / $2}')"

# NVIDIA GPU
gpu_data="$(nvidia-smi \
    --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw \
    --format=csv,noheader,nounits 2>/dev/null | head -n1)"

if [ -n "$gpu_data" ]; then
    gpu_temp="$(echo "$gpu_data" | awk -F', ' '{print $1}')"
    gpu_usage="$(echo "$gpu_data" | awk -F', ' '{print $2}')"
    vram_used="$(echo "$gpu_data" | awk -F', ' '{print $3}')"
    vram_total="$(echo "$gpu_data" | awk -F', ' '{print $4}')"
    gpu_power="$(echo "$gpu_data" | awk -F', ' '{print int($5)}')"
else
    gpu_temp="?"
    gpu_usage="?"
    vram_used="?"
    vram_total="?"
    gpu_power="?"
fi

[ -z "$cpu_temp" ] && cpu_temp="?"
[ -z "$cpu_usage" ] && cpu_usage="?"
[ -z "$ram_used" ] && ram_used="?"
[ -z "$ram_total" ] && ram_total="?"
[ -z "$ram_percent" ] && ram_percent="?"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$cpu_temp" \
    "$cpu_usage" \
    "$gpu_temp" \
    "$gpu_usage" \
    "$ram_used" \
    "$ram_total" \
    "$ram_percent" \
    "$vram_used" \
    "$vram_total" \
    "$gpu_power"
