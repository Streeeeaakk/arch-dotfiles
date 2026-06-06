import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string cpuTemp: "?"
    property string cpuUsage: "?"
    property string gpuTemp: "?"
    property string gpuUsage: "?"
    property string ramUsed: "?"
    property string ramTotal: "?"
    property string ramPercent: "?"
    property string vramUsed: "?"
    property string vramTotal: "?"
    property string gpuPower: "?"

    width: 420
    height: 214
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
            text: "  System Monitor"
            color: "#cdd6f4"
            font.pixelSize: 15
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        GridLayout {
            columns: 2
            columnSpacing: 14
            rowSpacing: 8
            Layout.fillWidth: true

            Text {
                text: "CPU"
                color: "#7f849c"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: root.cpuTemp + "°C  •  " + root.cpuUsage + "%"
                color: "#cdd6f4"
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Text {
                text: "GPU"
                color: "#7f849c"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: root.gpuTemp + "°C  •  " + root.gpuUsage + "%"
                color: "#cdd6f4"
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Text {
                text: "RAM"
                color: "#7f849c"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: root.ramUsed + " / " + root.ramTotal + " MiB  •  " + root.ramPercent + "%"
                color: "#cdd6f4"
                font.pixelSize: 12
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "VRAM"
                color: "#7f849c"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: root.vramUsed + " / " + root.vramTotal + " MiB"
                color: "#cdd6f4"
                font.pixelSize: 12
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "Power"
                color: "#7f849c"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                text: root.gpuPower + " W"
                color: "#cdd6f4"
                font.pixelSize: 12
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#313244"
        }

        Text {
            text: "Updates every 2 seconds"
            color: "#7f849c"
            font.pixelSize: 11
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/system-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")

                root.cpuTemp = parts[0] || "?"
                root.cpuUsage = parts[1] || "?"
                root.gpuTemp = parts[2] || "?"
                root.gpuUsage = parts[3] || "?"
                root.ramUsed = parts[4] || "?"
                root.ramTotal = parts[5] || "?"
                root.ramPercent = parts[6] || "?"
                root.vramUsed = parts[7] || "?"
                root.vramTotal = parts[8] || "?"
                root.gpuPower = parts[9] || "?"
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }
}
