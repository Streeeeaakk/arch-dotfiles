import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

RowLayout {
    id: root

    property int activeWorkspace: 1
    property string occupiedWorkspaces: ""
    property int groupStart: 1
    property int groupEnd: 5
    property int workspaceCount: groupEnd - groupStart + 1

    spacing: 8

    Repeater {
        model: root.workspaceCount

        Item {
            id: wsItem

            property int ws: root.groupStart + index
            property bool active: root.activeWorkspace === ws
            property bool occupied: root.occupiedWorkspaces.split(",").indexOf(String(ws)) !== -1
            property bool hovered: mouseArea.containsMouse

            width: active ? 18 : 24
            height: 20

            Rectangle {
                anchors.centerIn: parent

                width: wsItem.active ? 10 : 22
                height: wsItem.active ? 10 : 3
                radius: wsItem.active ? 5 : 2

                color: wsItem.active
                    ? Theme.Colors.accent
                    : wsItem.occupied
                        ? Theme.Colors.text
                        : Theme.Colors.muted

                opacity: wsItem.hovered ? 1.0 : (wsItem.active ? 1.0 : wsItem.occupied ? 0.75 : 0.45)

                Behavior on width {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    switchProc.command = ["hyprctl", "dispatch", "workspace", String(wsItem.ws)]
                    switchProc.running = true
                }
            }
        }
    }

    Process {
        id: switchProc
    }

    Process {
        id: workspaceProc

        command: ["sh", "-c", "~/.config/quickshell/scripts/workspace-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                root.activeWorkspace = parseInt(parts[0] || "1")
                root.occupiedWorkspaces = parts[1] || String(root.activeWorkspace)
                root.groupStart = parseInt(parts[2] || "1")
                root.groupEnd = parseInt(parts[3] || "5")
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: workspaceProc.running = true
    }
}
