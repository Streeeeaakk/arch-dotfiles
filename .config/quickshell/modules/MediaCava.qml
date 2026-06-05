import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    signal clicked()

    property string bars: "▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
    property string status: "Stopped"
    property bool hovered: mouseArea.containsMouse
    property bool playing: status === "Playing"
    property date now: new Date()

    implicitWidth: 150
    Layout.preferredWidth: 150
    Layout.minimumWidth: 150
    Layout.maximumWidth: 150

    height: 24
    radius: 7
    color: root.hovered ? "#45475a" : "#313244"
    clip: true

    Text {
        anchors.centerIn: parent

        text: root.playing && !root.hovered
            ? root.bars
            : Qt.formatDateTime(root.now, root.hovered ? "MMM dd  h:mm:ss AP" : "MMM dd  h:mm AP")

        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
        width: parent.width - 10
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
        id: cavaProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-bars.sh"]
        running: root.playing

        stdout: SplitParser {
            onRead: data => root.bars = data
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "playerctl status 2>/dev/null || echo Stopped"]
        running: true

        stdout: SplitParser {
            onRead: data => root.status = data.trim()
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
