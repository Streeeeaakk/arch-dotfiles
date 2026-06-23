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
    property real position: 0
    property real length: 0
    property bool cavaEnabled: true

    signal toggleCavaRequested()

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

    function formatTime(seconds) {
        seconds = Math.max(0, Math.floor(seconds))
        let m = Math.floor(seconds / 60)
        let s = seconds % 60
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    function seekToRatio(ratio) {
        if (root.length <= 0) return

        let seconds = Math.max(0, Math.min(root.length, root.length * ratio))

        seekProc.command = [
            "sh",
            "-c",
            "playerctl position " + seconds
        ]

        seekProc.running = true
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
                spacing: 8

                Text {
                    text: root.player
                    color: Theme.Colors.accent
                    font.family: "Figtree"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: 76
                    height: 24
                    radius: 8
                    color: root.cavaEnabled ? Theme.Colors.activeBg : Theme.Colors.pillBg
                    border.color: Theme.Colors.accent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.cavaEnabled ? "Cava ON" : "Cava OFF"
                        color: root.cavaEnabled ? Theme.Colors.accent : Theme.Colors.muted
                        font.family: "Figtree"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleCavaRequested()
                    }
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.formatTime(root.position)
                    color: Theme.Colors.muted
                    font.family: "Figtree"
                    font.pixelSize: 10
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignLeft
                }

                Rectangle {
                    id: sliderTrack

                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    Layout.alignment: Qt.AlignVCenter
                    radius: 4
                    color: Theme.Colors.pillBg
                    border.color: Theme.Colors.border
                    border.width: 1
                    clip: true

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: root.length > 0 ? parent.width * Math.min(1, root.position / root.length) : 0
                        radius: 4
                        color: Theme.Colors.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.seekToRatio(mouseX / width)
                        }

                        onPositionChanged: {
                            if (pressed) {
                                root.seekToRatio(mouseX / width)
                            }
                        }
                    }
                }

                Text {
                    text: root.length > 0 ? root.formatTime(root.length) : "--:--"
                    color: Theme.Colors.muted
                    font.family: "Figtree"
                    font.pixelSize: 10
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                }
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
                    border.color: Theme.Colors.border
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
        command: ["sh", "-c", "/home/streak/.config/quickshell-kde/scripts/media-info.sh"]
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
                    root.position = Number(obj.position || 0)
                    root.length = Number(obj.length || 0)
                } catch (e) {
                    root.player = "No Player"
                    root.status = "Stopped"
                    root.title = "Nothing Playing"
                    root.artist = ""
                    root.album = ""
                    root.art = ""
                    root.position = 0
                    root.length = 0
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

    Process {
        id: seekProc
        onExited: root.refresh()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
