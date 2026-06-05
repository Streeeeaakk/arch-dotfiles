import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    property string appClass: ""
    property bool showCava: false
    property string bars: "▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
    property bool hovered: mouseArea.containsMouse

    function appIcon(cls) {
        let c = cls.toLowerCase()

        if (c.includes("brave")) return ""
        if (c.includes("chrome")) return ""
        if (c.includes("firefox")) return ""
        if (c.includes("zen")) return "󰖟"
        if (c.includes("kitty")) return ""
        if (c.includes("alacritty")) return ""
        if (c.includes("wezterm")) return ""
        if (c.includes("code")) return "󰨞"
        if (c.includes("spotify")) return ""
        if (c.includes("dolphin")) return "󰉋"
        if (c.includes("thunar")) return "󰉋"
        if (c.includes("discord")) return ""
        if (c.includes("vesktop")) return ""
        if (c.includes("caprine")) return "󰈎"
        if (c.includes("telegram")) return ""
        if (c.includes("obsidian")) return "󱓧"
        if (c.includes("steam")) return ""
        if (c.includes("libreoffice")) return "󰈙"
        if (c.includes("vlc")) return "󰕼"
        if (c.includes("gimp")) return ""

        return "󰣆"
    }

    function appName(cls) {
        let c = cls.toLowerCase()

        if (c.includes("brave")) return "Brave"
        if (c.includes("chrome")) return "Chrome"
        if (c.includes("firefox")) return "Firefox"
        if (c.includes("zen")) return "Zen"
        if (c.includes("kitty")) return "Kitty"
        if (c.includes("alacritty")) return "Alacritty"
        if (c.includes("wezterm")) return "WezTerm"
        if (c.includes("code")) return "Code"
        if (c.includes("spotify")) return "Spotify"
        if (c.includes("dolphin")) return "Dolphin"
        if (c.includes("thunar")) return "Thunar"
        if (c.includes("discord")) return "Discord"
        if (c.includes("vesktop")) return "Vesktop"
        if (c.includes("caprine")) return "Caprine"
        if (c.includes("telegram")) return "Telegram"
        if (c.includes("obsidian")) return "Obsidian"
        if (c.includes("steam")) return "Steam"
        if (c.includes("libreoffice")) return "LibreOffice"
        if (c.includes("vlc")) return "VLC"
        if (c.includes("gimp")) return "GIMP"

        return cls.length > 0 ? cls : "Desktop"
    }

    implicitWidth: 138
    Layout.preferredWidth: 138
    Layout.minimumWidth: 138
    Layout.maximumWidth: 138

    height: 24
    radius: 10
    color: root.hovered ? Theme.Colors.activeHover : Theme.Colors.activeBg
    clip: true

    Text {
        visible: root.showCava
        anchors.centerIn: parent
        text: root.bars
        color: Theme.Colors.text
        font.pixelSize: 14
        font.bold: true
        width: parent.width - 12
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    RowLayout {
        visible: !root.showCava
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.appIcon(root.appClass)
            color: Theme.Colors.text
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.appName(root.appClass)
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Process {
        id: titleProc

        command: [
            "sh",
            "-c",
            "hyprctl activewindow -j 2>/dev/null | jq -r '.class // \"Desktop\"'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => root.appClass = data.trim()
        }
    }

    Process {
        id: cavaProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-bars.sh"]
        running: root.showCava

        stdout: SplitParser {
            onRead: data => root.bars = data
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: titleProc.running = true
    }
}
