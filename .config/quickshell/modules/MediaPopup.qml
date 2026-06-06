import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    property string player: "No Player"
    property string status: "Stopped"
    property string title: "Nothing Playing"
    property string artist: ""
    property string album: ""
    property string art: ""

    width: 540
    height: 230
    radius: 18

    color: Theme.Colors.barBg
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function refresh() {
        infoProc.running = true
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 160
            Layout.preferredHeight: 160
            Layout.alignment: Qt.AlignVCenter
            radius: 14
            color: Theme.Colors.pillBg
            border.color: Theme.Colors.accent
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                source: root.art
                visible: root.art.length > 0
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: false
            }

            Text {
                anchors.centerIn: parent
                visible: root.art.length === 0
                text: "󰎆"
                color: Theme.Colors.accent
                font.pixelSize: 48
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.player
                    color: Theme.Colors.accent
                    font.family: "Figtree"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.status
                    color: Theme.Colors.muted
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Text {
                text: root.title
                color: Theme.Colors.textHover
                font.family: "Figtree"
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                text: root.artist.length > 0 ? root.artist : "Unknown Artist"
                color: Theme.Colors.text
                font.family: "Figtree"
                font.pixelSize: 14
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.album
                visible: root.album.length > 0
                color: Theme.Colors.muted
                font.family: "Figtree"
                font.pixelSize: 13
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Rectangle {
                    width: 48
                    height: 32
                    radius: 10
                    color: Theme.Colors.pillBg
                    border.color: Theme.Colors.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Theme.Colors.text
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: prevProc.running = true
                    }
                }

                Rectangle {
                    width: 60
                    height: 34
                    radius: 11
                    color: Theme.Colors.activeBg
                    border.color: Theme.Colors.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.status === "Playing" ? "" : ""
                        color: Theme.Colors.textHover
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: playPauseProc.running = true
                    }
                }

                Rectangle {
                    width: 48
                    height: 32
                    radius: 10
                    color: Theme.Colors.pillBg
                    border.color: Theme.Colors.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Theme.Colors.text
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nextProc.running = true
                    }
                }
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/media-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    let obj = JSON.parse(data.trim())
                    root.player = obj.player || "No Player"
                    root.status = obj.status || "Stopped"
                    root.title = obj.title || "Nothing Playing"
                    root.artist = obj.artist || ""
                    root.album = obj.album || ""
                    root.art = obj.art || ""
                } catch (e) {
                    root.player = "No Player"
                    root.status = "Stopped"
                    root.title = "Nothing Playing"
                    root.artist = ""
                    root.album = ""
                    root.art = ""
                }
            }
        }
    }

    Process {
        id: playPauseProc
        command: ["playerctl", "play-pause"]
        onExited: root.refresh()
    }

    Process {
        id: prevProc
        command: ["playerctl", "previous"]
        onExited: root.refresh()
    }

    Process {
        id: nextProc
        command: ["playerctl", "next"]
        onExited: root.refresh()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
