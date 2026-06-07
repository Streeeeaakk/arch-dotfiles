#!/usr/bin/env bash
set -euo pipefail

BASE_WALLDIR="$HOME/.config/hypr/wallpapers"
THEME_FILE="$HOME/.config/hypr/current-theme"

: "${HYPRLAND_INSTANCE_SIGNATURE:?Not running inside Hyprland}"

SOCK="/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Ensure awww daemon is running
if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon >/dev/null 2>&1 &
fi

# Wait for awww socket to be ready
for i in {1..20}; do
    if awww query >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done


get_theme() {
    if [[ -f "$THEME_FILE" ]]; then
        cat "$THEME_FILE"
    else
        echo "cyan"
    fi
}

get_output_for_ws() {
    local ws="$1"

    if (( ws >= 1 && ws <= 5 )); then
        echo "eDP-1"
    elif (( ws >= 6 && ws <= 10 )); then
        echo "HDMI-A-1"
    else
        echo "eDP-1"
    fi
}

apply_ws() {
    local ws="$1"
    local theme output img fallback default

    theme="$(get_theme)"
    output="$(get_output_for_ws "$ws")"

    img="$BASE_WALLDIR/$theme/$ws.jpg"
    fallback="$BASE_WALLDIR/cyan/$ws.jpg"
    default="$BASE_WALLDIR/cyan/1.jpg"

    if [[ -f "$img" ]]; then
        awww img "$img" --outputs "$output" --transition-type fade --transition-fps 60 --transition-duration 0.15
    elif [[ -f "$fallback" ]]; then
        awww img "$fallback" --outputs "$output" --transition-type fade --transition-fps 60 --transition-duration 0.15
    elif [[ -f "$default" ]]; then
        awww img "$default" --outputs "$output" --transition-type fade --transition-fps 60 --transition-duration 0.15
    fi
}

sleep 0.5

# Apply wallpaper to active workspace on every monitor
if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j | jq -r '.[].activeWorkspace.id' | while read -r ws; do
        [[ -n "$ws" && "$ws" != "null" ]] && apply_ws "$ws"
    done
else
    ws="$(hyprctl activeworkspace -j | grep -o '"id":[[:space:]]*[0-9]\+' | grep -o '[0-9]\+' | head -n1)"
    apply_ws "$ws"
fi

socat -u "UNIX-CONNECT:$SOCK" - | while IFS= read -r line; do
    case "$line" in
        workspace\>\>*)
            ws="${line#workspace>>}"
            apply_ws "$ws"
            ;;
        workspacev2\>\>*)
            ws="${line#workspacev2>>}"
            ws="${ws%%,*}"
            apply_ws "$ws"
            ;;
    esac
done
