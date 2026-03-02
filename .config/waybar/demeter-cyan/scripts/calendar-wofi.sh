#!/usr/bin/env bash
# Dropdown calendar under the top bar (Wayland-friendly)

# width/lines to look like a KDE dropdown
LINES=10
WIDTH=32

# Get calendar (current month) and show with wofi
cal | sed 's/^/ /' | wofi --dmenu --prompt "" \
  --width "$WIDTH" --lines "$LINES" \
  --location 2 --xoffset 0 --yoffset 34 \
  --no-actions --hide-scroll --insensitive

