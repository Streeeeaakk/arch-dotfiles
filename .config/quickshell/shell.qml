import Quickshell
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: shell

    property bool mediaPopupOpen: false
    property bool networkPopupOpen: false
    property bool audioPopupOpen: false
    property bool systemPopupOpen: false

    function closeOtherPopups(active) {
        if (active !== "media") shell.mediaPopupOpen = false
        if (active !== "network") shell.networkPopupOpen = false
        if (active !== "audio") shell.audioPopupOpen = false
        if (active !== "system") shell.systemPopupOpen = false
    }

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
                            if (shell.mediaPopupOpen) shell.closeOtherPopups("media")
                        }
                    }

                    Temps {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.systemPopupOpen = !shell.systemPopupOpen
                            if (shell.systemPopupOpen) shell.closeOtherPopups("system")
                        }
                    }

                    Network {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.networkPopupOpen = !shell.networkPopupOpen
                            if (shell.networkPopupOpen) shell.closeOtherPopups("network")
                        }
                    }

                    Battery {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Volume {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.audioPopupOpen = !shell.audioPopupOpen
                            if (shell.audioPopupOpen) shell.closeOtherPopups("audio")
                        }
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

                Item {
                    anchors.fill: parent
                    opacity: shell.mediaPopupOpen ? 1 : 0
                    scale: shell.mediaPopupOpen ? 1 : 0.92
                    transformOrigin: Item.Top

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    MediaPopup {
                        anchors.fill: parent
                    }
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

                Item {
                    anchors.fill: parent
                    opacity: shell.networkPopupOpen ? 1 : 0
                    scale: shell.networkPopupOpen ? 1 : 0.92
                    transformOrigin: Item.Top

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    NetworkPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: systemPopupWindow

                visible: shell.systemPopupOpen
                width: 420
                height: 214
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: shell.systemPopupOpen ? 1 : 0
                    scale: shell.systemPopupOpen ? 1 : 0.92
                    transformOrigin: Item.Top

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    SystemPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: audioPopupWindow

                visible: shell.audioPopupOpen
                width: 460
                height: 260
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: shell.audioPopupOpen ? 1 : 0
                    scale: shell.audioPopupOpen ? 1 : 0.92
                    transformOrigin: Item.Top

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }

                    AudioPopup {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
