import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root
    property string time: ""

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            height: 34
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#11111b"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        text: "  Quickshell"
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.time
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }

    Process {
        id: dateProc
        command: ["date", "+%a %b %d  %I:%M:%S %p"]
        running: true

        stdout: SplitParser {
            onRead: data => root.time = data
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
