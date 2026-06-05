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

    property bool workspaceOverlayOpen: false
    property string lastWorkspaceTrigger: ""
    property string workspaceTriggerMonitor: ""

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

    Process {
        id: workspaceTriggerProc
        command: [
            "sh",
            "-c",
            "cat /tmp/quickshell-workspace-trigger 2>/dev/null || true"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let current = data.trim()

                if (current.length > 0 && current !== shell.lastWorkspaceTrigger) {
                    let parts = current.split("\t")

                    shell.workspaceTriggerMonitor = parts[4] || ""
                    shell.workspaceOverlayOpen = true

                    workspaceOverlayTimer.restart()
                    shell.closeOtherPopups("")
                    shell.lastWorkspaceTrigger = current
                }
            }
        }
    }

    Timer {
        interval: 120
        running: true
        repeat: true
        onTriggered: workspaceTriggerProc.running = true
    }

    Timer {
        id: workspaceOverlayTimer
        interval: 1200
        repeat: false

        onTriggered: {
            shell.workspaceOverlayOpen = false
            shell.workspaceTriggerMonitor = ""
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            property string screenName: modelData.name
            property bool islandHovered: islandHover.hovered
            property bool workspaceMode: shell.workspaceOverlayOpen && shell.workspaceTriggerMonitor === screenName
            property bool normalMode: !workspaceMode && (!shell.mediaPlaying || islandHovered)
            property bool cavaMode: !workspaceMode && shell.mediaPlaying && !islandHovered

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: "transparent"

            Rectangle {
                id: island

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8

                width: panel.workspaceMode
                    ? workspaceRow.implicitWidth + 18
                    : panel.cavaMode
                        ? Math.min(panel.width * 0.56, 680)
                        : centerRow.implicitWidth + 18

                height: 28
                radius: 14

                color: "#11111b"
                opacity: 0.96
                border.color: "#242638"
                border.width: 1
                clip: true

                HoverHandler {
                    id: islandHover
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 180
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
                    id: workspaceRow

                    visible: panel.workspaceMode
                    opacity: panel.workspaceMode ? 1 : 0

                    anchors.centerIn: parent
                    spacing: 6

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    WorkspacesOverlay {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                RowLayout {
                    id: centerRow

                    visible: panel.normalMode
                    opacity: panel.normalMode ? 1 : 0

                    anchors.centerIn: parent
                    spacing: 5

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

                CalendarPopup {
                    anchors.fill: parent
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

            PopupWindow {
                id: systemPopupWindow
                visible: shell.systemPopupOpen
                width: 420
                height: 214
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                SystemPopup {
                    anchors.fill: parent
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

                AudioPopup {
                    anchors.fill: parent
                }
            }
        }
    }
}
