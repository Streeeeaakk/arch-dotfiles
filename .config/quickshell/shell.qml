import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "modules"

ShellRoot {
    id: shell

    property bool mediaPopupOpen: false
    property bool networkPopupOpen: false
    property bool audioPopupOpen: false
    property bool systemPopupOpen: false
    property bool calendarPopupOpen: false

    property string mediaStatus: "Stopped"
    property bool mediaPlaying: mediaStatus === "Playing"

    function closeOtherPopups(active) {
        if (active !== "media") shell.mediaPopupOpen = false
        if (active !== "network") shell.networkPopupOpen = false
        if (active !== "audio") shell.audioPopupOpen = false
        if (active !== "system") shell.systemPopupOpen = false
        if (active !== "calendar") shell.calendarPopupOpen = false
    }

    Process {
        id: mediaStatusProc

        command: [
            "sh",
            "-c",
            "playerctl -a status 2>/dev/null | grep -q '^Playing$' && echo Playing || echo Stopped"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => shell.mediaStatus = data.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: mediaStatusProc.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            property bool islandHovered: islandHover.hovered
            property bool normalMode: !shell.mediaPlaying || islandHovered
            property bool cavaMode: shell.mediaPlaying && !islandHovered

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
                anchors.topMargin: 8

                width: panel.cavaMode
                    ? Math.min(panel.width * 0.62, 760)
                    : centerRow.implicitWidth + 18

                height: 34
                radius: 17

                color: "#11111b"
                border.color: "#313244"
                border.width: 1
                clip: true

                HoverHandler {
                    id: islandHover
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                CavaFull {
                    visible: panel.cavaMode
                    opacity: panel.cavaMode ? 1 : 0

                    onClicked: {
                        shell.mediaPopupOpen = !shell.mediaPopupOpen
                        if (shell.mediaPopupOpen) shell.closeOtherPopups("media")
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                RowLayout {
                    id: centerRow

                    visible: panel.normalMode
                    opacity: panel.normalMode ? 1 : 0

                    anchors.centerIn: parent
                    spacing: 7

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    MediaCava {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.calendarPopupOpen = !shell.calendarPopupOpen
                            if (shell.calendarPopupOpen) shell.closeOtherPopups("calendar")
                        }
                    }

                    Temps {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.systemPopupOpen = !shell.systemPopupOpen
                            if (shell.systemPopupOpen) shell.closeOtherPopups("system")
                        }
                    }

                    ActiveWindow {
                        Layout.alignment: Qt.AlignVCenter
                        showCava: shell.mediaPlaying
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
                id: calendarPopupWindow

                visible: shell.calendarPopupOpen
                width: 300
                height: 260
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: shell.calendarPopupOpen ? 1 : 0
                    scale: shell.calendarPopupOpen ? 1 : 0.92
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

                    CalendarPopup {
                        anchors.fill: parent
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
