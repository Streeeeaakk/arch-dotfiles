#!/usr/bin/env bash

WALL_DIR="$HOME/.config/hypr/wallpapers"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

choice=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) \
  | sort -V \
  | xargs -n1 basename \
  | rofi -dmenu -i -p "Wallpaper" -theme "$HOME/.config/rofi/themes/hypr-settings.rasi")

[ -z "$choice" ] && exit 0

wallpaper="$WALL_DIR/$choice"

cat > "$HYPRPAPER_CONF" <<EOF
preload = $wallpaper

wallpaper {
    monitor = eDP-1
    path = $wallpaper
}

wallpaper {
    monitor = HDMI-A-1
    path = $wallpaper
}

splash = false
EOF

pkill -x hyprpaper 2>/dev/null || true
sleep 0.2
hyprpaper & disown

notify-send "Wallpaper" "Changed to $choice"
