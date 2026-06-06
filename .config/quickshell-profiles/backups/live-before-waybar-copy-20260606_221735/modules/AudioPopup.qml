import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property int outVol: 0
    property int inVol: 0
    property bool outMuted: false
    property bool inMuted: false
    property string defaultSink: "-"
    property string defaultSource: "-"
    property var sinks: []
    property var sources: []

    width: 460
    height: 260
    radius: 16

    color: "#11111b"
    border.color: "#313244"
    border.width: 1
    clip: true

    function clamp(v) {
        return Math.max(0, Math.min(100, Math.round(v)))
    }

    function setOutVolumeFromMouse(x, w) {
        let percent = clamp((x / w) * 100)
        commandProc.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + percent + "%"]
        commandProc.running = true
    }

    function setInVolumeFromMouse(x, w) {
        let percent = clamp((x / w) * 100)
        commandProc.command = ["sh", "-c", "pactl set-source-volume @DEFAULT_SOURCE@ " + percent + "%"]
        commandProc.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            text: "󰕾  Audio"
            color: "#cdd6f4"
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: root.outMuted ? "Output muted" : "Output " + root.outVol + "%"
                color: "#bac2de"
                font.pixelSize: 12
                Layout.preferredWidth: 92
            }

            Rectangle {
                id: outSlider
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#313244"
                clip: true

                Rectangle {
                    width: parent.width * root.outVol / 100
                    height: parent.height
                    radius: 5
                    color: root.outMuted ? "#7f849c" : "#89b4fa"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: root.setOutVolumeFromMouse(mouse.x, width)
                    onPositionChanged: {
                        if (pressed) root.setOutVolumeFromMouse(mouse.x, width)
                    }
                }
            }

            Rectangle {
                width: 58
                height: 24
                radius: 8
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: root.outMuted ? "Unmute" : "Mute"
                    color: "#cdd6f4"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        commandProc.command = ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
                        commandProc.running = true
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: root.inMuted ? "Mic muted" : "Mic " + root.inVol + "%"
                color: "#bac2de"
                font.pixelSize: 12
                Layout.preferredWidth: 92
            }

            Rectangle {
                id: inSlider
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#313244"
                clip: true

                Rectangle {
                    width: parent.width * root.inVol / 100
                    height: parent.height
                    radius: 5
                    color: root.inMuted ? "#7f849c" : "#a6e3a1"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: root.setInVolumeFromMouse(mouse.x, width)
                    onPositionChanged: {
                        if (pressed) root.setInVolumeFromMouse(mouse.x, width)
                    }
                }
            }

            Rectangle {
                width: 58
                height: 24
                radius: 8
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: root.inMuted ? "Unmute" : "Mute"
                    color: "#cdd6f4"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        commandProc.command = ["sh", "-c", "pactl set-source-mute @DEFAULT_SOURCE@ toggle"]
                        commandProc.running = true
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#313244"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "Output device"
                    color: "#7f849c"
                    font.pixelSize: 11
                    font.bold: true
                }

                Repeater {
                    model: root.sinks

                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        radius: 8
                        color: modelData === root.defaultSink ? "#45475a" : "#313244"
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "#cdd6f4"
                            font.pixelSize: 10
                            width: parent.width - 10
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandProc.command = ["sh", "-c", "pactl set-default-sink '" + modelData.replace(/'/g, "'\\''") + "'"]
                                commandProc.running = true
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "Input source"
                    color: "#7f849c"
                    font.pixelSize: 11
                    font.bold: true
                }

                Repeater {
                    model: root.sources

                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        radius: 8
                        color: modelData === root.defaultSource ? "#45475a" : "#313244"
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "#cdd6f4"
                            font.pixelSize: 10
                            width: parent.width - 10
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandProc.command = ["sh", "-c", "pactl set-default-source '" + modelData.replace(/'/g, "'\\''") + "'"]
                                commandProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/audio-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")

                root.outVol = parseInt(parts[0] || "0")
                root.outMuted = (parts[1] || "no") === "yes"

                root.inVol = parseInt(parts[2] || "0")
                root.inMuted = (parts[3] || "no") === "yes"

                root.defaultSink = parts[4] || "-"
                root.defaultSource = parts[5] || "-"

                root.sinks = (parts[6] || "-").split(";").filter(x => x.length > 0 && x !== "-")
                root.sources = (parts[7] || "-").split(";").filter(x => x.length > 0 && x !== "-")
            }
        }
    }

    Process {
        id: commandProc
        onExited: infoProc.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }
}
