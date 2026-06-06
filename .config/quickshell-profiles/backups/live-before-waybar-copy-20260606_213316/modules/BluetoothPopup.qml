import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    property string powered: "unknown"
    property string connected: ""
    property string devices: ""

    radius: 16
    color: Qt.rgba(Theme.Colors.barBg.r, Theme.Colors.barBg.g, Theme.Colors.barBg.b, 0.88)
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function refresh() {
        infoProc.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: " Bluetooth"
                color: Theme.Colors.textHover
                font.family: "Figtree"
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: root.powered === "yes" ? "ON" : "OFF"
                color: root.powered === "yes" ? Theme.Colors.accent : Theme.Colors.muted
                font.family: "Figtree"
                font.pixelSize: 11
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.Colors.accent
            opacity: 0.35
        }

        Text {
            text: root.connected.length > 0 ? "Connected: " + root.connected : "No connected device"
            color: Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: root.devices.length > 0 ? root.devices : "No paired devices found"
            color: Theme.Colors.muted
            font.family: "Figtree"
            font.pixelSize: 11
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: 4
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Rectangle {
                width: 86
                height: 28
                radius: 9
                color: Theme.Colors.pillBg
                border.color: Theme.Colors.accent
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.powered === "yes" ? "Turn Off" : "Turn On"
                    color: Theme.Colors.text
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggleProc.running = true
                }
            }

            Rectangle {
                width: 86
                height: 28
                radius: 9
                color: Theme.Colors.pillBg
                border.color: Theme.Colors.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Manager"
                    color: Theme.Colors.text
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: managerProc.running = true
                }
            }
        }
    }

    Process {
        id: infoProc
        command: [
            "sh",
            "-c",
            "power=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print tolower($2); exit}'); conn=$(bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [^ ]* //' | head -n1); paired=$(bluetoothctl devices Paired 2>/dev/null | sed 's/^Device [^ ]* //' | head -n4 | paste -sd ', ' -); echo \"$power|$conn|$paired\""
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("|")
                root.powered = parts[0] || "unknown"
                root.connected = parts[1] || ""
                root.devices = parts[2] || ""
            }
        }
    }

    Process {
        id: toggleProc
        command: ["sh", "-c", "if bluetoothctl show | grep -q 'Powered: yes'; then bluetoothctl power off; else bluetoothctl power on; fi"]
        onExited: root.refresh()
    }

    Process {
        id: managerProc
        command: ["sh", "-c", "blueman-manager >/dev/null 2>&1 &"]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
