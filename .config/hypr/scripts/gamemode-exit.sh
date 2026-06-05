#!/usr/bin/env bash
set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
PREV_THEME_FILE="$HYPR_DIR/.pre-gamemode-theme"

prev="$(cat "$PREV_THEME_FILE" 2>/dev/null || echo cyan)"

"$HYPR_DIR/scripts/theme-switch.sh" "$prev"

pkill -USR1 kitty 2>/dev/null || true

hyprctl notify 2 2000 "rgb(00ff99)" "🟢 Game Mode Off: Restored $prev"

