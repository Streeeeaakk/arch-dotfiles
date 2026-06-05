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

    width: 360
    height: 138
    radius: 16

    color: "#11111b"
    border.color: "#242638"
    border.width: 1
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9

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
            columnSpacing: 14
            rowSpacing: 4
            Layout.fillWidth: true

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
            }

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
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                width: 78
                height: 24
                radius: 9
                color: "#1b1d2e"

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
                width: 86
                height: 24
                radius: 9
                color: "#1b1d2e"

                Text {
                    anchors.centerIn: parent
                    text: "Settings"
                    color: "#cdd6f4"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingsProc.running = true
                }
            }

            Rectangle {
                width: 72
                height: 24
                radius: 9
                color: "#1b1d2e"

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
        id: settingsProc
        command: ["sh", "-c", "nm-connection-editor >/dev/null 2>&1 &"]
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
