#!/usr/bin/env bash
set -euo pipefail

THEME="${ROFI_POWER_THEME:-$HOME/.config/rofi/themes/power-menu.rasi}"

choice="$(
  printf "Lock\nLogout\nReboot\nShutdown\nCancel\n" \
  | rofi -dmenu -i -p "Power" -no-custom -theme "$THEME"
)"

case "$choice" in
  Lock)
    # Use whatever you have installed:
    if command -v hyprlock >/dev/null 2>&1; then
      hyprlock
    elif command -v swaylock >/dev/null 2>&1; then
      swaylock
    elif command -v loginctl >/dev/null 2>&1; then
      loginctl lock-session
    fi
    ;;
  Logout)
    # Hyprland logout
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl dispatch exit
    else
      loginctl terminate-user "$USER"
    fi
    ;;
  Reboot)
    systemctl reboot
    ;;
  Shutdown)
    systemctl poweroff
    ;;
  Cancel|"")
    exit 0
    ;;
esac
