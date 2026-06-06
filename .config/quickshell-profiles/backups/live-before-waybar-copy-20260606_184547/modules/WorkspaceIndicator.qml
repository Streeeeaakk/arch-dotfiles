import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    property string workspace: "1"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 48
    Layout.preferredWidth: 48
    Layout.minimumWidth: 48
    Layout.maximumWidth: 48

    height: 24

    RowLayout {
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: "●"
            color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
            font.pixelSize: 8
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.workspace
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: true
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
        id: workspaceProc

        command: [
            "sh",
            "-c",
            "hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => root.workspace = data.trim()
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: workspaceProc.running = true
    }
}
