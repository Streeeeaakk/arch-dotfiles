import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    property string volume: "?"
    property bool muted: false
    property bool hovered: mouseArea.containsMouse

    width: hovered ? 105 : 70
    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"

    Text {
        anchors.centerIn: parent
        text: root.muted ? "󰝟 muted" : "󰕾 " + root.volume + "%"
        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: root.hovered
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            muteProc.running = true
        }

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                upProc.running = true
            } else {
                downProc.running = true
            }
        }
    }

    Process {
        id: refreshProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100), ($3 == \"[MUTED]\" ? \"muted\" : \"unmuted\")}'"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(" ")
                root.volume = parts[0]
                root.muted = parts[1] === "muted"
            }
        }
    }

    Process {
        id: upProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
        onExited: refreshProc.running = true
    }

    Process {
        id: downProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
        onExited: refreshProc.running = true
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: refreshProc.running = true
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: refreshProc.running = true
    }
}
