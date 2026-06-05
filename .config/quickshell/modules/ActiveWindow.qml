import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string appClass: ""
    property string title: "Desktop"

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

    implicitWidth: 330
    Layout.preferredWidth: 330
    Layout.minimumWidth: 330
    Layout.maximumWidth: 330

    height: 24
    radius: 7
    color: "transparent"
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 7

        Text {
            text: root.appIcon(root.appClass)
            color: "#cdd6f4"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 20
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: root.title.length > 0 ? root.title : "Desktop"
            color: "#cdd6f4"
            font.pixelSize: 12
            font.bold: true

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
        }
    }

    Process {
        id: titleProc

        command: [
            "sh",
            "-c",
            "hyprctl activewindow -j 2>/dev/null | jq -r '[.class // \"\", .title // \"Desktop\"] | @tsv'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                root.appClass = parts[0] || ""
                root.title = parts[1] || "Desktop"
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
