import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    property string connectionType: "none"
    property string connectionName: "disconnected"
    property bool hovered: mouseArea.containsMouse

    width: hovered ? 170 : 82
    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"

    Text {
        anchors.centerIn: parent

        text: {
            if (root.connectionType === "wifi") {
                return root.hovered ? "󰖩  " + root.connectionName : "󰖩 wifi"
            }

            if (root.connectionType === "ethernet") {
                return root.hovered ? "󰈀  " + root.connectionName : "󰈀 lan"
            }

            return root.hovered ? "󰤭 disconnected" : "󰤭 net"
        }

        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
        elide: Text.ElideRight
        width: parent.width - 12
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: networkProc

        command: [
            "sh",
            "-c",
            "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$2==\"connected\" && $1!=\"loopback\" {print $1\":\"$3; exit} END {if (NR==0) print \"none:disconnected\"}'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.connectionType = parts[0] || "none"
                root.connectionName = parts[1] || "disconnected"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: networkProc.running = true
    }
}
