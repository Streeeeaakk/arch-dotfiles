import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    property string bars: "▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
    property string status: "Stopped"
    property bool hovered: mouseArea.containsMouse
    property bool playing: status === "Playing"
    property date now: new Date()

    width: hovered ? 165 : 120
    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"

    Text {
        anchors.centerIn: parent
        text: root.hovered
            ? Qt.formatDateTime(root.now, "MMM dd  h:mm:ss AP")
            : (root.playing ? root.bars : "󰝛  no music")
        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: cavaProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-bars.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => root.bars = data
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "playerctl status 2>/dev/null || echo Stopped"]
        running: true

        stdout: SplitParser {
            onRead: data => root.status = data
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.now = new Date()
            statusProc.running = true
        }
    }
}
