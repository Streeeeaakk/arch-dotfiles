#!/usr/bin/env bash

item="$1"
low="$(printf '%s' "$item" | tr 'A-Z' 'a-z')"

if printf '%s' "$low" | grep -q 'image/jpeg\|image/jpg'; then
  printf '%s\n' "$item" | cliphist decode | wl-copy --type image/jpeg
elif printf '%s' "$low" | grep -q 'image/webp'; then
  printf '%s\n' "$item" | cliphist decode | wl-copy --type image/webp
elif printf '%s' "$low" | grep -q 'image/bmp'; then
  printf '%s\n' "$item" | cliphist decode | wl-copy --type image/bmp
elif printf '%s' "$low" | grep -q 'image/gif'; then
  printf '%s\n' "$item" | cliphist decode | wl-copy --type image/gif
elif printf '%s' "$low" | grep -q 'image/png\|\[image'; then
  printf '%s\n' "$item" | cliphist decode | wl-copy --type image/png
else
  printf '%s\n' "$item" | cliphist decode | wl-copy
fi
