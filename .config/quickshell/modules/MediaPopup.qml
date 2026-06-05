import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string title: "No media"
    property string artist: ""
    property string status: "Stopped"
    property date now: new Date()

    width: 380
    height: 112
    radius: 16

    color: "#11111b"
    border.color: "#313244"
    border.width: 1
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            text: Qt.formatDateTime(root.now, "dddd, MMMM dd  •  h:mm AP")
            color: "#cdd6f4"
            font.pixelSize: 13
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            text: root.artist.length > 0 ? root.title + " — " + root.artist : root.title
            color: "#bac2de"
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                width: 42
                height: 28
                radius: 10
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: prevProc.running = true
                }
            }

            Rectangle {
                width: 52
                height: 28
                radius: 10
                color: "#45475a"

                Text {
                    anchors.centerIn: parent
                    text: root.status === "Playing" ? "󰏤" : "󰐊"
                    color: "#cdd6f4"
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: playProc.running = true
                }
            }

            Rectangle {
                width: 42
                height: 28
                radius: 10
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: nextProc.running = true
                }
            }
        }
    }

    Process {
        id: metadataProc
        command: ["sh", "-c", "playerctl metadata --format '{{title}}\t{{artist}}' 2>/dev/null || echo 'No media\t'"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                root.title = parts[0] || "No media"
                root.artist = parts[1] || ""
            }
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

    Process {
        id: prevProc
        command: ["playerctl", "previous"]
        onExited: {
            metadataProc.running = true
            statusProc.running = true
        }
    }

    Process {
        id: playProc
        command: ["playerctl", "play-pause"]
        onExited: {
            metadataProc.running = true
            statusProc.running = true
        }
    }

    Process {
        id: nextProc
        command: ["playerctl", "next"]
        onExited: {
            metadataProc.running = true
            statusProc.running = true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.now = new Date()
            metadataProc.running = true
            statusProc.running = true
        }
    }
}
