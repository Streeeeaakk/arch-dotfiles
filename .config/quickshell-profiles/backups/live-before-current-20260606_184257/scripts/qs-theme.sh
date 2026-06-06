#!/usr/bin/env bash

QS_DIR="$HOME/.config/quickshell"
MODE_FILE="$QS_DIR/.mode"
THEME_DIR="$QS_DIR/theme"
COLORS_FILE="$THEME_DIR/Colors.qml"

mode="${1:-toggle}"

current="cyan"
[ -f "$MODE_FILE" ] && current="$(cat "$MODE_FILE")"

if [ "$mode" = "toggle" ]; then
    if [ "$current" = "cyan" ]; then
        mode="gaming"
    else
        mode="cyan"
    fi
fi

if [ "$mode" = "sync" ]; then
    if [ -f "$HOME/.config/waybar/demeter-cyan/.mode" ]; then
        mode="$(cat "$HOME/.config/waybar/demeter-cyan/.mode")"
    elif [ -f "$HOME/.config/waybar/.mode" ]; then
        mode="$(cat "$HOME/.config/waybar/.mode")"
    else
        mode="cyan"
    fi
fi

case "$mode" in
    cyan|normal)
        mode="cyan"
        cat > "$COLORS_FILE" <<'QML'
pragma Singleton
import QtQuick

QtObject {
    property color barBg: "#11111b"
    property color pillBg: "#1b1d2e"
    property color pillHover: "#2a2d40"
    property color activeBg: "#24283b"
    property color activeHover: "#343850"
    property color border: "#242638"

    property color text: "#cdd6f4"
    property color textHover: "#ffffff"
    property color muted: "#7f849c"

    property color accent: "#89b4fa"
    property color accentText: "#11111b"
    property color warning: "#f9e2af"
}
QML
        ;;

    gaming)
        cat > "$COLORS_FILE" <<'QML'
pragma Singleton
import QtQuick

QtObject {
    property color barBg: "#08111f"
    property color pillBg: "#101b2e"
    property color pillHover: "#1b2b4d"
    property color activeBg: "#15345c"
    property color activeHover: "#1e4d85"
    property color border: "#1e3a5f"

    property color text: "#dce9ff"
    property color textHover: "#ffffff"
    property color muted: "#88a2c7"

    property color accent: "#3584e4"
    property color accentText: "#07111f"
    property color warning: "#7cc7ff"
}
QML
        ;;

    *)
        echo "Usage: qs-theme.sh cyan|gaming|toggle|sync"
        exit 1
        ;;
esac

echo "$mode" > "$MODE_FILE"

pkill quickshell 2>/dev/null || true
sleep 0.2
quickshell >/tmp/quickshell.log 2>&1 &
