#!/usr/bin/env bash
set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
THEME="$(cat "$HYPR_DIR/current-theme" 2>/dev/null || echo purple)"
WALL_DIR="$HYPR_DIR/wallpapers/$THEME"

[ -d "$WALL_DIR" ] || WALL_DIR="$HYPR_DIR/wallpapers/purple"

W1="$WALL_DIR/1.jpg"
W5="$WALL_DIR/5.jpg"
W9="$WALL_DIR/9.jpg"

[ -f "$W1" ] || W1="$(find "$WALL_DIR" -type f | sort | head -1)"
[ -f "$W5" ] || W5="$W1"
[ -f "$W9" ] || W9="$W1"

cat > "$HYPR_DIR/hyprpaper.conf" <<EOC
preload = $W1
preload = $W5
preload = $W9

wallpaper = HDMI-A-3,$W1
wallpaper = HDMI-A-2,$W5
wallpaper = HDMI-A-1,$W9

splash = false
EOC

hyprpaper >/tmp/hyprpaper.log 2>&1 &
sleep 0.5

hyprctl hyprpaper unload all >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$W1" >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$W5" >/dev/null 2>&1 || true
hyprctl hyprpaper preload "$W9" >/dev/null 2>&1 || true

hyprctl hyprpaper wallpaper "HDMI-A-3,$W1" >/dev/null 2>&1 || true
hyprctl hyprpaper wallpaper "HDMI-A-2,$W5" >/dev/null 2>&1 || true
hyprctl hyprpaper wallpaper "HDMI-A-1,$W9" >/dev/null 2>&1 || true
