import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string percent: "none"
    property string status: "Unknown"
    property bool hasBattery: percent !== "none"
    property bool hovered: mouseArea.containsMouse

    visible: hasBattery

    implicitWidth: hasBattery ? 82 : 0
    Layout.preferredWidth: hasBattery ? 82 : 0
    Layout.minimumWidth: hasBattery ? 82 : 0
    Layout.maximumWidth: hasBattery ? 82 : 0

    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"
    clip: true

    Text {
        anchors.centerIn: parent

        text: {
            if (!root.hasBattery) return ""

            let icon = "󰁹"

            if (root.status === "Charging") {
                icon = "󰂄"
            } else if (parseInt(root.percent) <= 15) {
                icon = "󰂎"
            } else if (parseInt(root.percent) <= 30) {
                icon = "󰁻"
            } else if (parseInt(root.percent) <= 60) {
                icon = "󰁾"
            } else {
                icon = "󰁹"
            }

            return root.hovered
                ? icon + " " + root.percent + "%"
                : icon + " " + root.percent + "%"
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
        id: batteryProc

        command: [
            "sh",
            "-c",
            "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] || continue; cap=$(cat \"$b/capacity\" 2>/dev/null); stat=$(cat \"$b/status\" 2>/dev/null); echo \"$cap:$stat\"; exit; done; echo \"none:Unknown\""
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.percent = parts[0] || "none"
                root.status = parts[1] || "Unknown"
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }
}
