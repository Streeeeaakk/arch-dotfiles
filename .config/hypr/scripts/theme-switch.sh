#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 ]]; then
  theme="$1"
else
  theme="$(
    printf "cyan\\nred\\ngreen\\npurple\\nwhite\\n" |
      rofi -dmenu -i -p "Theme" -theme "$HOME/.config/rofi/config.rasi"
  )"

  [[ -z "${theme:-}" ]] && exit 0
fi

HYPR_DIR="$HOME/.config/hypr"
WAYBAR_DIR="$HOME/.config/waybar/demeter-cyan"

HYPR_SRC="$HYPR_DIR/themes/$theme/theme.conf"
HYPR_ACTIVE="$HYPR_DIR/user-settings/theme.conf"

WAYBAR_SRC="$WAYBAR_DIR/themes/$theme.css"
WAYBAR_ACTIVE="$WAYBAR_DIR/colors.css"

WAYBAR_CFG="$WAYBAR_DIR/config.jsonc"
WAYBAR_STYLE="$WAYBAR_DIR/style.css"

QS_THEME_SCRIPT="$HOME/.config/quickshell/scripts/apply-theme-colors.sh"

ROFI_DIR="$HOME/.config/rofi"
ROFI_SRC="$ROFI_DIR/theme-colors/$theme.rasi"
ROFI_ACTIVE="$ROFI_DIR/colors.rasi"
ROFI_PIC_SRC="$ROFI_DIR/pictures/$theme.jpg"
ROFI_PIC_ACTIVE="$ROFI_DIR/pic.jpg"

KITTY_DIR="$HOME/.config/kitty"
KITTY_SRC="$KITTY_DIR/themes/$theme.conf"
KITTY_ACTIVE="$KITTY_DIR/kitty.conf"

GTK_SRC="$HOME/.config/gtk-theme-colors/$theme.css"
GTK3_ACTIVE="$HOME/.config/gtk-3.0/theme-colors.css"
GTK4_ACTIVE="$HOME/.config/gtk-4.0/theme-colors.css"

if [[ "$theme" == "gaming" ]]; then
  echo "Gaming theme is only for Game Mode. Use gamemode.conf instead." >&2
  exit 1
fi

if [[ ! -f "$HYPR_SRC" ]]; then
  echo "Hyprland theme not found: $HYPR_SRC" >&2
  exit 1
fi

if [[ ! -f "$WAYBAR_SRC" ]]; then
  echo "Waybar theme not found: $WAYBAR_SRC" >&2
  exit 1
fi

if [[ ! -f "$ROFI_SRC" ]]; then
  echo "Rofi theme not found: $ROFI_SRC" >&2
  exit 1
fi

if [[ ! -f "$KITTY_SRC" ]]; then
  echo "Kitty theme not found: $KITTY_SRC" >&2
  exit 1
fi

cp -f "$HYPR_SRC" "$HYPR_ACTIVE"
cp -f "$WAYBAR_SRC" "$WAYBAR_ACTIVE"
cp -f "$ROFI_SRC" "$ROFI_ACTIVE"
[[ -f "$ROFI_PIC_SRC" ]] && cp -f "$ROFI_PIC_SRC" "$ROFI_PIC_ACTIVE"
cp -f "$KITTY_SRC" "$KITTY_ACTIVE"
[[ -f "$GTK_SRC" ]] && cp -f "$GTK_SRC" "$GTK3_ACTIVE"
[[ -f "$GTK_SRC" ]] && cp -f "$GTK_SRC" "$GTK4_ACTIVE"

echo "$theme" >"$HOME/.config/hypr/demeter-2.0-theme"
echo "$theme" >"$HOME/.config/hypr/current-theme"

[[ -x "$QS_THEME_SCRIPT" ]] && "$QS_THEME_SCRIPT" "$theme"

echo "normal" >"$WAYBAR_DIR/.mode"

hyprctl reload

pkill -x waybar 2>/dev/null || true
sleep 0.2

#waybar -c "$WAYBAR_CFG" -s "$WAYBAR_STYLE" >/dev/null 2>&1 &
#disown || true

rm -f /tmp/quickshell-launcher-trigger /tmp/quickshell-workspace-trigger 2>/dev/null || true
pkill -x quickshell 2>/dev/null || true
sleep 0.5

nohup quickshell >/tmp/quickshell.log 2>&1 &
disown || true
sleep 0.3

pkill -f workspace-wallpaper.sh 2>/dev/null || true
sleep 0.2
nohup "$HOME/.config/hypr/workspace-wallpaper.sh" >/tmp/workspace-wallpaper.log 2>&1 &
