#!/usr/bin/env bash

target="$1"

if [ -z "$target" ]; then
  exit 1
fi

# Direct special-case fix for Theme Switcher
case "$target" in
  *theme-switcher.desktop*|*"Theme Switcher"*)
    nohup /home/mis/.config/hypr/scripts/theme-switch.sh >/tmp/theme-switcher.log 2>&1 &
    exit 0
    ;;
esac

# If target is a .desktop file, parse Exec manually
if [ -f "$target" ]; then
  exec_cmd="$(grep -m1 '^Exec=' "$target" | cut -d= -f2-)"
  exec_cmd="$(echo "$exec_cmd" | sed 's/ %[fFuUdDnNickvm]//g' | sed 's/@@u//g' | sed 's/@@//g')"

  if [ -n "$exec_cmd" ]; then
    nohup sh -c "$exec_cmd" >/tmp/quickshell-app-launch.log 2>&1 &
    exit 0
  fi
fi

# Fallback: run target as command
nohup sh -c "$target" >/tmp/quickshell-app-launch.log 2>&1 &
