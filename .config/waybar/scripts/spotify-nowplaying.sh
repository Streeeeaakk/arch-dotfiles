#!/usr/bin/env bash
# Prints: "Artist — Title" (or nothing if Spotify not running)
# Also works with other players if Spotify isn't available.

PLAYER="spotify"

# Prefer Spotify; fall back to any player if spotify not found
if ! playerctl -p "$PLAYER" status >/dev/null 2>&1; then
  PLAYER="$(playerctl -l 2>/dev/null | head -n 1)"
fi

[ -z "$PLAYER" ] && exit 0

status="$(playerctl -p "$PLAYER" status 2>/dev/null || true)"
[ "$status" = "Stopped" ] && exit 0

artist="$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || true)"
title="$(playerctl -p "$PLAYER" metadata title 2>/dev/null || true)"

# Trim long titles so your bar stays clean
out="$artist — $title"
max=50
if [ "${#out}" -gt "$max" ]; then
  out="${out:0:$max}…"
fi

echo "󰓇 $out"
