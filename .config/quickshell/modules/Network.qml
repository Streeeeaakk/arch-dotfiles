import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string connectionType: "none"
    property string connectionName: "disconnected"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 90
    Layout.preferredWidth: 90
    Layout.minimumWidth: 90
    Layout.maximumWidth: 90

    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"
    clip: true

    Text {
        anchors.centerIn: parent

        text: {
            if (root.connectionType === "wifi") {
                return root.hovered ? "󰖩 " + root.connectionName : "󰖩 wifi"
            }

            if (root.connectionType === "ethernet") {
                return root.hovered ? "󰈀 " + root.connectionName : "󰈀 lan"
            }

            return root.hovered ? "󰤭 offline" : "󰤭 net"
        }

        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
        elide: Text.ElideRight
        width: parent.width - 10
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
            "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$2==\"connected\" && $1!=\"loopback\" {print $1\":\"$3; found=1; exit} END {if (!found) print \"none:disconnected\"}'"
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
