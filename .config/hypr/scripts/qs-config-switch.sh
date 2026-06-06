#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"

PROFILES_DIR="$HOME/.config/quickshell-profiles"
LIVE_DIR="$HOME/.config/quickshell"
BACKUP_DIR="$PROFILES_DIR/backups"

if [[ -z "$PROFILE" ]]; then
  echo "Usage: qs-config-switch.sh <profile>"
  echo
  echo "Available profiles:"
  find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name backups \
    -printf "  %f\n" | sort
  exit 1
fi

SRC="$PROFILES_DIR/$PROFILE"

if [[ ! -d "$SRC" ]]; then
  echo "Profile not found: $PROFILE"
  echo
  echo "Available profiles:"
  find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name backups \
    -printf "  %f\n" | sort
  exit 1
fi

mkdir -p "$BACKUP_DIR"

ts="$(date +%Y%m%d_%H%M%S)"

if [[ -d "$LIVE_DIR" ]]; then
  echo "Backing up live config..."
  rsync -a --delete "$LIVE_DIR/" "$BACKUP_DIR/live-before-$PROFILE-$ts/"
else
  mkdir -p "$LIVE_DIR"
fi

echo "Switching Quickshell profile to: $PROFILE"
rsync -a --delete "$SRC/" "$LIVE_DIR/"

echo "$PROFILE" > "$PROFILES_DIR/active-profile"

THEME_STATE="$PROFILES_DIR/theme-state"
ACTIVE_THEME="$(cat "$THEME_STATE" 2>/dev/null || true)"

if [[ -n "$ACTIVE_THEME" && -x "$LIVE_DIR/scripts/qs-theme.sh" ]]; then
  echo "Applying saved theme: $ACTIVE_THEME"
  QS_THEME_NO_RESTART=1 "$LIVE_DIR/scripts/qs-theme.sh" "$ACTIVE_THEME" || true
fi

echo "Restarting Quickshell..."
if command -v qsrestart >/dev/null 2>&1; then
  qsrestart
elif bash -lc 'type qsrestart >/dev/null 2>&1'; then
  bash -lc 'qsrestart'
else
  pkill quickshell 2>/dev/null || true
  nohup quickshell >/tmp/quickshell.log 2>&1 &
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Quickshell profile switched" "$PROFILE"
fi

echo "Done. Active profile: $PROFILE"
