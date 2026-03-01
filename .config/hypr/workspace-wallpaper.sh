#!/usr/bin/env bash
set -euo pipefail

WALLDIR="$HOME/.config/hypr/wallpapers"
: "${HYPRLAND_INSTANCE_SIGNATURE:?Not running inside Hyprland}"

SOCK="/run/user/$UID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

apply_ws() {
    local ws="$1"
    local img="$WALLDIR/$ws.jpg"

    [[ -f "$img" ]] || return 0

    swww img "$img" \
        --transition-type any \
        --transition-fps 60 \
        --transition-duration 0.5
}

# Initial wallpaper
ws="$(hyprctl activeworkspace -j | grep -o '"id":[[:space:]]*[0-9]\+' | grep -o '[0-9]\+')"
apply_ws "$ws"

# Listen for workspace changes
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
