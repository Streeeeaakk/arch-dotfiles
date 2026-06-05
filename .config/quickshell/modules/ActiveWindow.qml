import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string appClass: ""

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

    implicitWidth: 130
    Layout.preferredWidth: 130
    Layout.minimumWidth: 130
    Layout.maximumWidth: 130

    height: 24
    radius: 7
    color: "#313244"
    clip: true

    RowLayout {
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.appIcon(root.appClass)
            color: "#cdd6f4"
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.appName(root.appClass)
            color: "#cdd6f4"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }
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
            onRead: data => {
                root.appClass = data.trim()
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: titleProc.running = true
    }
}
