import Quickshell
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: shell

    property bool mediaPopupOpen: false

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

            implicitHeight: shell.mediaPopupOpen ? 168 : 42
            color: "transparent"

            Rectangle {
                id: island

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 4

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

                    ActiveWindow {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    MediaCava {
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: shell.mediaPopupOpen = !shell.mediaPopupOpen
                    }

                    Temps {
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

            MediaPopup {
                id: mediaPopup

                visible: shell.mediaPopupOpen
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: island.bottom
                anchors.topMargin: 8
            }
        }
    }
}
