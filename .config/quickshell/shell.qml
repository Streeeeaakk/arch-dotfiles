import Quickshell
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: shell

    property bool mediaPopupOpen: false
    property bool networkPopupOpen: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Keep the reserved space small.
            // Popups will overlay instead of pushing windows down.
            implicitHeight: 42
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

                        onClicked: {
                            shell.mediaPopupOpen = !shell.mediaPopupOpen

                            if (shell.mediaPopupOpen) {
                                shell.networkPopupOpen = false
                            }
                        }
                    }

                    Temps {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Network {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.networkPopupOpen = !shell.networkPopupOpen

                            if (shell.networkPopupOpen) {
                                shell.mediaPopupOpen = false
                            }
                        }
                    }

                    Battery {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Volume {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            PopupWindow {
                id: mediaPopupWindow

                visible: shell.mediaPopupOpen
                width: 380
                height: 112
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                MediaPopup {
                    anchors.fill: parent
                }
            }

            PopupWindow {
                id: networkPopupWindow

                visible: shell.networkPopupOpen
                width: 420
                height: 162
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                NetworkPopup {
                    anchors.fill: parent
                }
            }
        }
    }
}
