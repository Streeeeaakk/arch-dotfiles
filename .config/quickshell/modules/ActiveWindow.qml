import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string title: "Desktop"

    implicitWidth: 320
    Layout.preferredWidth: 320
    Layout.minimumWidth: 320
    Layout.maximumWidth: 320

    height: 24
    radius: 7
    color: "transparent"
    clip: true

    Text {
        anchors.centerIn: parent
        text: root.title.length > 0 ? root.title : "Desktop"

        color: "#cdd6f4"
        font.pixelSize: 12
        font.bold: true

        width: parent.width - 12
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    Process {
        id: titleProc

        command: [
            "sh",
            "-c",
            "hyprctl activewindow -j 2>/dev/null | jq -r '.title // .class // \"Desktop\"'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                root.title = data.trim()
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: titleProc.running = true
    }
}
