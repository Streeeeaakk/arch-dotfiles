#!/usr/bin/env bash
set -euo pipefail

theme="${1:-cyan}"

QS_THEME_DIR="$HOME/.config/quickshell/theme"
QS_COLORS="$QS_THEME_DIR/Colors.qml"

mkdir -p "$QS_THEME_DIR"

case "$theme" in
  cyan)
    barBg="#11111b"
    pillBg="#1b1d2e"
    pillHover="#2a2d40"
    activeBg="#1f3f4a"
    activeHover="#2c5968"
    border="#2f6b78"
    text="#cdd6f4"
    textHover="#ffffff"
    muted="#7f849c"
    accent="#89dceb"
    warning="#f9e2af"
    ;;

  red)
    barBg="#16090d"
    pillBg="#241016"
    pillHover="#3a1721"
    activeBg="#4a1b28"
    activeHover="#6b2437"
    border="#8f2d45"
    text="#f5d7df"
    textHover="#ffffff"
    muted="#b98a96"
    accent="#f38ba8"
    warning="#fab387"
    ;;

  white)
    barBg="#111114"
    pillBg="#202024"
    pillHover="#34343a"
    activeBg="#3b3b42"
    activeHover="#565660"
    border="#d8d8df"
    text="#f2f2f5"
    textHover="#ffffff"
    muted="#b8b8c0"
    accent="#ffffff"
    warning="#f9e2af"
    ;;

  green)
    barBg="#07140d"
    pillBg="#102018"
    pillHover="#1a3426"
    activeBg="#1f4a34"
    activeHover="#2d6b49"
    border="#4c956c"
    text="#d8f3dc"
    textHover="#ffffff"
    muted="#8fb89b"
    accent="#a6e3a1"
    warning="#f9e2af"
    ;;

  purple|mauve)
    barBg="#120d1b"
    pillBg="#1e172b"
    pillHover="#312342"
    activeBg="#442c5c"
    activeHover="#5d3d80"
    border="#9b5de5"
    text="#eadcff"
    textHover="#ffffff"
    muted="#a995c9"
    accent="#cba6f7"
    warning="#f9e2af"
    ;;

  *)
    barBg="#11111b"
    pillBg="#1b1d2e"
    pillHover="#2a2d40"
    activeBg="#24283b"
    activeHover="#343850"
    border="#313244"
    text="#cdd6f4"
    textHover="#ffffff"
    muted="#7f849c"
    accent="#89dceb"
    warning="#f9e2af"
    ;;
esac

cat > "$QS_COLORS" <<QML
pragma Singleton
import QtQuick

QtObject {
    property color barBg: "$barBg"
    property color pillBg: "$pillBg"
    property color pillHover: "$pillHover"
    property color activeBg: "$activeBg"
    property color activeHover: "$activeHover"
    property color border: "$border"

    property color text: "$text"
    property color textHover: "$textHover"
    property color muted: "$muted"

    property color accent: "$accent"
    property color accentText: "$barBg"
    property color warning: "$warning"
}
QML

echo "Quickshell colors applied: $theme"
