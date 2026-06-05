#!/usr/bin/env bash
set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
WAYBAR_DIR="$HOME/.config/waybar/demeter-cyan"
ROFI_DIR="$HOME/.config/rofi"
KITTY_DIR="$HOME/.config/kitty"

CURRENT_THEME_FILE="$HYPR_DIR/current-theme"
PREV_THEME_FILE="$HYPR_DIR/.pre-gamemode-theme"

prev="$(cat "$CURRENT_THEME_FILE" 2>/dev/null || echo cyan)"
echo "$prev" > "$PREV_THEME_FILE"

# Hyprland gaming theme
cp -f "$HYPR_DIR/themes/gaming/theme.conf" "$HYPR_DIR/user-settings/theme.conf"

# Waybar gaming theme
cp -f "$WAYBAR_DIR/themes/gaming.css" "$WAYBAR_DIR/colors.css"
echo "gaming" > "$WAYBAR_DIR/.mode"

# Rofi gaming theme
cp -f "$ROFI_DIR/theme-colors/gaming.rasi" "$ROFI_DIR/colors.rasi"

# Kitty gaming theme
cp -f "$KITTY_DIR/themes/gaming.conf" "$KITTY_DIR/kitty.conf"
pkill -USR1 kitty 2>/dev/null || true

# GTK / Thunar gaming accent
cp -f "$HOME/.config/gtk-theme-colors/gaming.css" "$HOME/.config/gtk-3.0/theme-colors.css"
cp -f "$HOME/.config/gtk-theme-colors/gaming.css" "$HOME/.config/gtk-4.0/theme-colors.css"

hyprctl reload

pkill -x waybar 2>/dev/null || true
sleep 0.2
waybar -c "$WAYBAR_DIR/config.jsonc" -s "$WAYBAR_DIR/style.css" >/dev/null 2>&1 &
disown || true

hyprctl notify 2 2000 "rgb(3584e4)" "🎮 Gaming Mode Active"
