import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property date now: new Date()
    property string calendarText: ""

    width: 300
    height: 260
    radius: 16

    color: "#11111b"
    border.color: "#313244"
    border.width: 1
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            text: Qt.formatDateTime(root.now, "dddd, MMMM dd")
            color: "#cdd6f4"
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: Qt.formatDateTime(root.now, "h:mm:ss AP")
            color: "#bac2de"
            font.pixelSize: 13
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#313244"
        }

        Text {
            text: root.calendarText
            color: "#cdd6f4"
            font.family: "monospace"
            font.pixelSize: 13
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Process {
        id: calendarProc
        command: ["sh", "-c", "cal -m"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (root.calendarText.length === 0) {
                    root.calendarText = data
                } else {
                    root.calendarText = root.calendarText + "\n" + data
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.now = new Date()
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            root.calendarText = ""
            calendarProc.running = true
        }
    }
}
