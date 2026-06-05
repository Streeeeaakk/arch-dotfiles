import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    signal clicked()

    property string connectionType: "none"
    property string connectionName: "disconnected"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 72
    Layout.preferredWidth: 72
    Layout.minimumWidth: 72
    Layout.maximumWidth: 72

    height: 24
    radius: 9
    color: root.hovered ? "#2a2d40" : "#1b1d2e"
    clip: true

    Text {
        anchors.centerIn: parent

        text: {
            if (root.connectionType === "wifi") return "󰖩 wifi"
            if (root.connectionType === "ethernet") return "󰈀 lan"
            return "󰤭 net"
        }

        color: root.hovered ? "#ffffff" : "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
        width: parent.width - 8
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
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
