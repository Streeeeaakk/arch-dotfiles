#!/usr/bin/env bash

ws="$(hyprctl activeworkspace -j | jq -r '.name')"
state_file="/tmp/hypr_layout_${ws}"

if [[ -f "$state_file" ]]; then
    hyprctl keyword workspace "$ws, layout:dwindle"
    rm -f "$state_file"
    hyprctl notify 2 2000 "rgb(a6e3a1)" "󰝘 Dwindle layout enabled"
else
    hyprctl keyword workspace "$ws, layout:scrolling"
    touch "$state_file"
    hyprctl notify 2 2000 "rgb(33ccff)" " Scrolling layout enabled"
fi
