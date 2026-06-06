import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    property string appClass: ""
    property string monitorName: ""
    property bool hovered: mouseArea.containsMouse

    implicitWidth: Math.min(92, Math.max(68, textRow.implicitWidth + 16))
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: 68
    Layout.maximumWidth: 92

    height: 24

    function appIcon(cls) {
        let c = cls.toLowerCase()

        if (c.includes("brave")) return ""
        if (c.includes("chrome")) return ""
        if (c.includes("firefox")) return ""
        if (c.includes("zen")) return "󰖟"
        if (c.includes("kitty")) return ""
        if (c.includes("alacritty")) return ""
        if (c.includes("code")) return "󰨞"
        if (c.includes("spotify")) return ""
        if (c.includes("thunar")) return "󰉋"
        if (c.includes("discord")) return ""
        if (c.includes("vesktop")) return ""
        if (c.includes("steam")) return ""
        if (c.includes("sublime")) return ""

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
        if (c.includes("code")) return "Code"
        if (c.includes("spotify")) return "Spotify"
        if (c.includes("thunar")) return "Thunar"
        if (c.includes("discord")) return "Discord"
        if (c.includes("vesktop")) return "Vesktop"
        if (c.includes("steam")) return "Steam"
        if (c.includes("sublime")) return "Sublime"

        return cls.length > 0 ? cls : "Desktop"
    }

    RowLayout {
        id: textRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.appIcon(root.appClass)
            color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
            font.pixelSize: 12
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.appName(root.appClass)
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: true
            Layout.maximumWidth: 54
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Process {
        id: titleProc
        command: [
            "sh",
            "-c",
            "mon=" + root.monitorName + "; ws=$(hyprctl monitors -j 2>/dev/null | jq -r --arg mon \"$mon\" '.[] | select(.name == $mon) | .activeWorkspace.id' | head -n1); hyprctl clients -j 2>/dev/null | jq -r --argjson ws \"${ws:-0}\" '[.[] | select(.workspace.id == $ws)] | sort_by(.focusHistoryID // 999999) | .[0].class // \"Desktop\"'"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => root.appClass = data.trim()
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: titleProc.running = true
    }
}
