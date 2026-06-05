import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    signal clicked()

    property string volume: "?"
    property bool muted: false
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 74
    Layout.preferredWidth: 74
    Layout.minimumWidth: 74
    Layout.maximumWidth: 74

    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"
    clip: true

    Text {
        anchors.centerIn: parent
        text: root.muted ? "󰝟 mute" : "󰕾 " + root.volume + "%"
        color: "#cdd6f4"
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

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: refreshProc.running = true
    }
}
