#!/bin/bash

# Get cursor position
pos=$(hyprctl cursorpos)
x=$(echo $pos | awk '{print $1}')
y=$(echo $pos | awk '{print $2}')

# Slight offset so it appears under the bar
y=$((y + 10))

yad --calendar \
    --undecorated \
    --fixed \
    --skip-taskbar \
    --close-on-unfocus \
    --no-buttons \
    --width=300 \
    --height=220 \
    --posx="$x" \
    --posy="$y"
