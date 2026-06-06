import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property string ssid: "wifi"
    property string signal: ""
    property bool connected: ssid !== "" && ssid !== "--" && ssid !== "Disconnected"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: Math.max(66, textRow.implicitWidth + 8)
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: 66
    Layout.maximumWidth: 120

    height: 24

    RowLayout {
        id: textRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: "󰖩"
            color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
            font.pixelSize: 12
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.connected ? root.ssid : "wifi"
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: root.hovered
            Layout.maximumWidth: 82
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Process {
        id: networkProc

        command: [
            "sh",
            "-c",
            "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1==\"yes\" {print $2\":\"$3; exit}'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.ssid = parts[0] || "wifi"
                root.signal = parts[1] || ""
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: networkProc.running = true
    }
}
