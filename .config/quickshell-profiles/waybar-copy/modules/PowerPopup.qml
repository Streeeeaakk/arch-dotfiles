import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string percent: "none"
    property string state: "Unknown"
    property string timeLeft: "-"
    property string capacity: "-"
    property int brightness: 0

    width: 360
    height: 176
    radius: 16

    color: "#11111b"
    border.color: "#242638"
    border.width: 1
    clip: true

    function clamp(v) {
        return Math.max(0, Math.min(100, Math.round(v)))
    }

    function setBrightnessFromMouse(x, w) {
        let percent = clamp((x / w) * 100)
        commandProc.command = ["sh", "-c", "brightnessctl set " + percent + "% >/dev/null 2>&1"]
        commandProc.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            text: "󰁹  Battery"
            color: "#cdd6f4"
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: root.percent + "%  •  " + root.state + "  •  " + root.timeLeft
            color: "#bac2de"
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        GridLayout {
            columns: 2
            columnSpacing: 14
            rowSpacing: 5
            Layout.fillWidth: true

            Text {
                text: "Health"
                color: "#7f849c"
                font.pixelSize: 11
            }

            Text {
                text: root.capacity + "%"
                color: "#cdd6f4"
                font.pixelSize: 11
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Brightness"
                color: "#bac2de"
                font.pixelSize: 12
                Layout.preferredWidth: 78
            }

            Rectangle {
                id: brightnessSlider
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#1b1d2e"
                clip: true

                Rectangle {
                    width: parent.width * root.brightness / 100
                    height: parent.height
                    radius: 5
                    color: "#f9e2af"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: root.setBrightnessFromMouse(mouse.x, width)
                    onPositionChanged: {
                        if (pressed) root.setBrightnessFromMouse(mouse.x, width)
                    }
                }
            }

            Text {
                text: root.brightness + "%"
                color: "#cdd6f4"
                font.pixelSize: 11
                Layout.preferredWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                width: 86
                height: 24
                radius: 9
                color: "#1b1d2e"

                Text {
                    anchors.centerIn: parent
                    text: "Lock"
                    color: "#cdd6f4"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        commandProc.command = ["sh", "-c", "hyprlock >/dev/null 2>&1 &"]
                        commandProc.running = true
                    }
                }
            }

            Rectangle {
                width: 86
                height: 24
                radius: 9
                color: "#1b1d2e"

                Text {
                    anchors.centerIn: parent
                    text: "Sleep"
                    color: "#cdd6f4"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        commandProc.command = ["systemctl", "suspend"]
                        commandProc.running = true
                    }
                }
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/power-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")

                root.percent = parts[0] || "none"
                root.state = parts[1] || "Unknown"
                root.timeLeft = parts[2] || "-"
                root.capacity = parts[3] || "-"
                root.brightness = parseInt(parts[4] || "0")
            }
        }
    }

    Process {
        id: commandProc
        onExited: infoProc.running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }
}
