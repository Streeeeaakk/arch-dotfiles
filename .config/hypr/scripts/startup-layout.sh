#!/bin/bash

# wait for hyprland to fully start
sleep 3

# --- LEFT MONITOR WORKSPACES (HDMI-A-3) ---

hyprctl dispatch focusmonitor HDMI-A-3
hyprctl dispatch workspace 1
sleep 3
firefox &
sleep 3

hyprctl dispatch workspace 2
firefox --new-window http://34.177.89.165:8002/ &
sleep 0.5

hyprctl dispatch workspace 3
kitty &
sleep 0.2
kitty -e ssh scerp &
sleep 0.5

hyprctl dispatch workspace 4
sleep 0.5
thunar &
sleep 0.5


# --- RIGHT MONITOR WORKSPACES (HDMI-A-1) ---

hyprctl dispatch focusmonitor HDMI-A-1



hyprctl dispatch workspace 7
firefox --new-window https://chat.openai.com &
sleep 0.5

hyprctl dispatch workspace 9
kitty --title logs &
sleep 0.5


# --- SCRATCHPAD MUSIC ---

spotify &


# --- RETURN TO MAIN WORKSPACE ---

hyprctl dispatch focusmonitor HDMI-A-3
hyprctl dispatch workspace 1
