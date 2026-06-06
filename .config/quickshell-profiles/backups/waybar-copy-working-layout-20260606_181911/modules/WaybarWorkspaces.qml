import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

RowLayout {
    id: root

    property string monitorName: ""
    property int activeWorkspace: 1
    property string occupiedWorkspaces: ""
    property int groupStart: monitorName === "eDP-1" ? 1 : 6
    property int groupEnd: monitorName === "eDP-1" ? 5 : 10
    property int workspaceCount: groupEnd - groupStart + 1

    spacing: 6

    Repeater {
        model: root.workspaceCount

        Item {
            id: wsItem

            property int ws: root.groupStart + index
            property bool active: root.activeWorkspace === ws
            property bool occupied: root.occupiedWorkspaces.split(",").indexOf(String(ws)) !== -1
            property bool hovered: mouseArea.containsMouse

            Layout.preferredWidth: 14
            Layout.minimumWidth: 14
            Layout.maximumWidth: 14
            height: 24

            Text {
                anchors.centerIn: parent
                text: wsItem.active || wsItem.occupied ? "●" : "○"
                color: wsItem.active
                    ? Theme.Colors.textHover
                    : wsItem.hovered
                        ? Theme.Colors.accent
                        : Theme.Colors.text

                opacity: wsItem.active ? 1.0 : wsItem.occupied ? 0.75 : 0.55
                font.pixelSize: wsItem.active ? 10 : 9
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
        command: [
            "sh",
            "-c",
            "active=$(hyprctl monitors -j 2>/dev/null | jq -r --arg mon '" + root.monitorName + "' '.[] | select(.name==$mon) | .activeWorkspace.id' | head -n1); occupied=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' | sort -n | paste -sd ',' -); echo \"${active:-1}\t${occupied:-}\""
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                root.activeWorkspace = parseInt(parts[0] || "1")
                root.occupiedWorkspaces = parts[1] || ""
            }
        }
    }

    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: workspaceProc.running = true
    }
}
