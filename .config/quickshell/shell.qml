import Quickshell
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
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

            implicitHeight: 46
            color: "transparent"

            Rectangle {
                id: island

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 6

                width: centerRow.implicitWidth + 18
                height: 34
                radius: 17

                color: "#11111b"
                border.color: "#313244"
                border.width: 1

                RowLayout {
                    id: centerRow

                    anchors.centerIn: parent
                    spacing: 8

                    MediaCava {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Network {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Battery {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Volume {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
