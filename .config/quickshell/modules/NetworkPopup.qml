import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string connectionType: "none"
    property string connectionName: "Disconnected"
    property string device: "-"
    property string ipAddress: "-"
    property string gateway: "-"
    property string signal: "-"
    property string networks: "-"

    width: 420
    height: 162
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
            text: root.connectionType === "wifi"
                ? "󰖩  " + root.connectionName
                : root.connectionType === "ethernet"
                    ? "󰈀  " + root.connectionName
                    : "󰤭  Disconnected"

            color: "#cdd6f4"
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        GridLayout {
            columns: 2
            columnSpacing: 18
            rowSpacing: 4
            Layout.fillWidth: true

            Text {
                text: "Device"
                color: "#7f849c"
                font.pixelSize: 11
            }

            Text {
                text: root.device
                color: "#bac2de"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "IP"
                color: "#7f849c"
                font.pixelSize: 11
            }

            Text {
                text: root.ipAddress
                color: "#bac2de"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "Gateway"
                color: "#7f849c"
                font.pixelSize: 11
            }

            Text {
                text: root.gateway
                color: "#bac2de"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "Signal"
                color: "#7f849c"
                font.pixelSize: 11
                visible: root.connectionType === "wifi"
            }

            Text {
                text: root.signal + "%"
                color: "#bac2de"
                font.pixelSize: 11
                Layout.fillWidth: true
                visible: root.connectionType === "wifi"
                elide: Text.ElideRight
            }
        }

        Text {
            text: root.connectionType === "wifi"
                ? "Nearby: " + root.networks
                : "Nearby Wi-Fi hidden because active connection is not Wi-Fi"

            color: "#bac2de"
            font.pixelSize: 11
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Rectangle {
                width: 78
                height: 26
                radius: 9
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: "Rescan"
                    color: "#cdd6f4"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: rescanProc.running = true
                }
            }

            Rectangle {
                width: 78
                height: 26
                radius: 9
                color: "#313244"

                Text {
                    anchors.centerIn: parent
                    text: "nmtui"
                    color: "#cdd6f4"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: nmtuiProc.running = true
                }
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/network-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                root.connectionType = parts[0] || "none"
                root.connectionName = parts[1] || "Disconnected"
                root.device = parts[2] || "-"
                root.ipAddress = parts[3] || "-"
                root.gateway = parts[4] || "-"
                root.signal = parts[5] || "-"
                root.networks = parts[6] || "-"
            }
        }
    }

    Process {
        id: rescanProc
        command: ["sh", "-c", "nmcli dev wifi rescan >/dev/null 2>&1"]
        onExited: infoProc.running = true
    }

    Process {
        id: nmtuiProc
        command: ["sh", "-c", "kitty -e nmtui >/dev/null 2>&1 &"]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }
}
