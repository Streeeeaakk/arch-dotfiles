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

    property string popupMonitor: ""

    property bool workspaceOverlayOpen: false
    property string lastWorkspaceTrigger: ""
    property string workspaceTriggerMonitor: ""

    property string mediaStatus: "Stopped"
    property bool mediaPlaying: mediaStatus === "Playing"

    function closeAllPopups() {
        shell.mediaPopupOpen = false
        shell.networkPopupOpen = false
        shell.audioPopupOpen = false
        shell.systemPopupOpen = false
        shell.calendarPopupOpen = false
        shell.popupMonitor = ""
    }

    function togglePopup(name, monitor) {
        let sameMonitor = shell.popupMonitor === monitor
        let alreadyOpen = false

        if (name === "media") alreadyOpen = shell.mediaPopupOpen
        if (name === "network") alreadyOpen = shell.networkPopupOpen
        if (name === "audio") alreadyOpen = shell.audioPopupOpen
        if (name === "system") alreadyOpen = shell.systemPopupOpen
        if (name === "calendar") alreadyOpen = shell.calendarPopupOpen

        shell.closeAllPopups()

        if (alreadyOpen && sameMonitor) {
            return
        }

        shell.popupMonitor = monitor

        if (name === "media") shell.mediaPopupOpen = true
        if (name === "network") shell.networkPopupOpen = true
        if (name === "audio") shell.audioPopupOpen = true
        if (name === "system") shell.systemPopupOpen = true
        if (name === "calendar") shell.calendarPopupOpen = true
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
        interval: 200
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
                    shell.closeAllPopups()
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
                        shell.togglePopup("media", panel.screenName)
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
                            shell.togglePopup("calendar", panel.screenName)
                        }
                    }

                    Temps {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.togglePopup("system", panel.screenName)
                        }
                    }

                    ActiveWindow {
                        Layout.alignment: Qt.AlignVCenter
                        showCava: shell.mediaPlaying
                    }

                    Network {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.togglePopup("network", panel.screenName)
                        }
                    }

                    Battery {
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Volume {
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            shell.togglePopup("audio", panel.screenName)
                        }
                    }
                }
            }

            PopupWindow {
                id: calendarPopupWindow

                visible: shell.calendarPopupOpen && shell.popupMonitor === panel.screenName
                width: 300
                height: 260
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: calendarPopupWindow.visible ? 1 : 0
                    scale: calendarPopupWindow.visible ? 1 : 0.90
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
                            easing.type: Easing.OutBack
                        }
                    }

                    CalendarPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: mediaPopupWindow

                visible: shell.mediaPopupOpen && shell.popupMonitor === panel.screenName
                width: 380
                height: 112
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: mediaPopupWindow.visible ? 1 : 0
                    scale: mediaPopupWindow.visible ? 1 : 0.90
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
                            easing.type: Easing.OutBack
                        }
                    }

                    MediaPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: networkPopupWindow

                visible: shell.networkPopupOpen && shell.popupMonitor === panel.screenName
                width: 360
                height: 138
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: networkPopupWindow.visible ? 1 : 0
                    scale: networkPopupWindow.visible ? 1 : 0.90
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
                            easing.type: Easing.OutBack
                        }
                    }

                    NetworkPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: systemPopupWindow

                visible: shell.systemPopupOpen && shell.popupMonitor === panel.screenName
                width: 420
                height: 214
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: systemPopupWindow.visible ? 1 : 0
                    scale: systemPopupWindow.visible ? 1 : 0.90
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
                            easing.type: Easing.OutBack
                        }
                    }

                    SystemPopup {
                        anchors.fill: parent
                    }
                }
            }

            PopupWindow {
                id: audioPopupWindow

                visible: shell.audioPopupOpen && shell.popupMonitor === panel.screenName
                width: 460
                height: 260
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: island.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: audioPopupWindow.visible ? 1 : 0
                    scale: audioPopupWindow.visible ? 1 : 0.90
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
                            easing.type: Easing.OutBack
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
