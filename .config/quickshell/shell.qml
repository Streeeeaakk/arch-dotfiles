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

            implicitHeight: 34
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#11111b"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Workspaces {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Clock {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
