import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    property string ssid: "Disconnected"
    property string device: "-"
    property string ip: "-"
    property string gateway: "-"
    property int signal: 0
    property var networks: []

    width: 390
    height: 300
    radius: 16

    color: Theme.Colors.barBg
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function signalText(sig) {
        if (sig >= 75) return "Excellent"
        if (sig >= 55) return "Good"
        if (sig >= 35) return "Fair"
        if (sig > 0) return "Weak"
        return "No signal"
    }

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 13
        color: "transparent"
        border.color: Theme.Colors.accent
        border.width: 1
        opacity: 0.22
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "󰖩"
                color: Theme.Colors.accent
                font.pixelSize: 18
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.ssid
                    color: Theme.Colors.textHover
                    font.family: "Figtree"
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: signalText(root.signal) + "  •  " + root.signal + "%"
                    color: Theme.Colors.muted
                    font.family: "Figtree"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 8
            radius: 4
            color: Theme.Colors.pillBg
            clip: true

            Rectangle {
                width: parent.width * root.signal / 100
                height: parent.height
                radius: 4
                color: Theme.Colors.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 14
            rowSpacing: 4

            Text {
                text: "IP"
                color: Theme.Colors.muted
                font.family: "Figtree"
                font.pixelSize: 11
            }

            Text {
                text: root.ip
                color: Theme.Colors.text
                font.family: "Figtree"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "Gateway"
                color: Theme.Colors.muted
                font.family: "Figtree"
                font.pixelSize: 11
            }

            Text {
                text: root.gateway
                color: Theme.Colors.text
                font.family: "Figtree"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "Device"
                color: Theme.Colors.muted
                font.family: "Figtree"
                font.pixelSize: 11
            }

            Text {
                text: root.device
                color: Theme.Colors.text
                font.family: "Figtree"
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.Colors.accent
            opacity: 0.32
        }

        Text {
            text: "Nearby Networks"
            color: Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: true
        }

        ListView {
            id: networkList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.networks
            clip: true
            spacing: 4

            delegate: Rectangle {
                id: networkRow

                property bool hovered: rowMouse.containsMouse
                property int sig: parseInt(modelData.signal || "0")

                width: networkList.width
                height: 28
                radius: 7

                color: modelData.active
                    ? Theme.Colors.activeBg
                    : hovered
                        ? Theme.Colors.pillHover
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 9
                    spacing: 8

                    Text {
                        text: modelData.active ? "●" : "○"
                        color: modelData.active ? Theme.Colors.accent : Theme.Colors.muted
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: modelData.ssid || ""
                        color: Theme.Colors.text
                        font.family: "Figtree"
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.security && modelData.security !== "open" ? "" : ""
                        color: Theme.Colors.muted
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: String(networkRow.sig) + "%"
                        color: Theme.Colors.muted
                        font.family: "Figtree"
                        font.pixelSize: 10
                        Layout.preferredWidth: 34
                        horizontalAlignment: Text.AlignRight
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!modelData.active) {
                            commandProc.command = [
                                "sh",
                                "-c",
                                "nmcli device wifi connect " + root.shellQuote(modelData.ssid) + " >/dev/null 2>&1 || nm-connection-editor >/dev/null 2>&1 &"
                            ]
                            commandProc.running = true
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                width: 82
                height: 24
                radius: 8
                color: Theme.Colors.pillBg
                border.color: Theme.Colors.accent
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Rescan"
                    color: Theme.Colors.text
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        commandProc.command = ["sh", "-c", "nmcli device wifi rescan >/dev/null 2>&1"]
                        commandProc.running = true
                    }
                }
            }

            Rectangle {
                width: 82
                height: 24
                radius: 8
                color: Theme.Colors.pillBg
                border.color: Theme.Colors.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Settings"
                    color: Theme.Colors.text
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        commandProc.command = ["sh", "-c", "nm-connection-editor >/dev/null 2>&1 &"]
                        commandProc.running = true
                    }
                }
            }

            Rectangle {
                width: 82
                height: 24
                radius: 8
                color: Theme.Colors.pillBg
                border.color: Theme.Colors.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "nmtui"
                    color: Theme.Colors.text
                    font.family: "Figtree"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        commandProc.command = ["sh", "-c", "kitty -e nmtui >/dev/null 2>&1 &"]
                        commandProc.running = true
                    }
                }
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/network-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    let obj = JSON.parse(data.trim())

                    root.ssid = obj.connection || "Disconnected"
                    root.device = obj.device || "-"
                    root.ip = obj.ip || "-"
                    root.gateway = obj.gateway || "-"
                    root.signal = parseInt(obj.signal || "0")
                    root.networks = obj.networks || []
                } catch (e) {
                    root.ssid = "Network error"
                    root.networks = []
                }
            }
        }
    }

    Process {
        id: commandProc
        onExited: {
            infoProc.running = true
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }
}
