import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property string status: "off"
    property string device: ""
    property bool hovered: mouseArea.containsMouse
    property bool enabled: status === "on"

    implicitWidth: enabled && device.length > 0 ? Math.min(110, textRow.implicitWidth + 12) : 34
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: 34
    Layout.maximumWidth: 110

    height: 24

    RowLayout {
        id: textRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: ""
            color: root.hovered ? Theme.Colors.accent : root.enabled ? Theme.Colors.text : Theme.Colors.muted
            font.pixelSize: 12
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.enabled && root.device.length > 0
            text: root.device
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: root.hovered
            Layout.maximumWidth: 78
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
        id: btProc
        command: [
            "sh",
            "-c",
            "power=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print tolower($2); exit}'); dev=$(bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [^ ]* //' | head -n1); [ \"$power\" = \"yes\" ] && echo \"on:$dev\" || echo \"off:\""
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.status = parts[0] || "off"
                root.device = parts.slice(1).join(":") || ""
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: btProc.running = true
    }
}
