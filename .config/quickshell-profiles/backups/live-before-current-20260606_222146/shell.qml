import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "modules"
import "theme" as Theme

ShellRoot {
    id: shell

    property bool mediaPopupOpen: false
    property bool networkPopupOpen: false
    property bool bluetoothPopupOpen: false
    property bool audioPopupOpen: false
    property bool systemPopupOpen: false
    property bool calendarPopupOpen: false
    property bool powerPopupOpen: false
    property bool configPopupOpen: false
    property bool launcherOpen: false
    property bool barHidden: false
    property string barHiddenMonitor: ""
    property string barHiddenMonitors: ""
    property bool anyPopupOpen: mediaPopupOpen || networkPopupOpen || audioPopupOpen || systemPopupOpen || calendarPopupOpen || powerPopupOpen || configPopupOpen

    property string popupMonitor: ""
    property string launcherMonitor: ""
    property string launcherMode: "apps"
    property string lastLauncherTrigger: ""
    property string activeProfile: ""

    property bool workspaceOverlayOpen: false
    property string lastWorkspaceTrigger: ""
    property string workspaceTriggerMonitor: ""

    property string mediaStatus: "Stopped"
    property bool cavaEnabled: true
    property bool mediaPlaying: cavaEnabled && mediaStatus === "Playing"

    function toggleCava() {
        shell.cavaEnabled = !shell.cavaEnabled

        cavaToggleProc.command = [
            "sh",
            "-c",
            "~/.config/quickshell/scripts/cava-toggle.sh " + (shell.cavaEnabled ? "on" : "off")
        ]

        cavaToggleProc.running = true
    }

    function closeAllPopups() {
        shell.mediaPopupOpen = false
        shell.networkPopupOpen = false
        shell.bluetoothPopupOpen = false
        shell.audioPopupOpen = false
        shell.systemPopupOpen = false
        shell.calendarPopupOpen = false
        shell.powerPopupOpen = false
        shell.configPopupOpen = false
        shell.launcherOpen = false
        shell.popupMonitor = ""
        shell.launcherMonitor = ""
    }

    function openLauncher(monitor, mode) {
        shell.closeAllPopups()
        shell.launcherMonitor = monitor
        shell.launcherMode = mode || "apps"
        shell.launcherOpen = true
    }

    function togglePopup(name, monitor) {
        let sameMonitor = shell.popupMonitor === monitor
        let alreadyOpen = false

        if (name === "media") alreadyOpen = shell.mediaPopupOpen
        if (name === "network") alreadyOpen = shell.networkPopupOpen
        if (name === "bluetooth") alreadyOpen = shell.bluetoothPopupOpen
        if (name === "audio") alreadyOpen = shell.audioPopupOpen
        if (name === "system") alreadyOpen = shell.systemPopupOpen
        if (name === "calendar") alreadyOpen = shell.calendarPopupOpen
        if (name === "power") alreadyOpen = shell.powerPopupOpen
        if (name === "config") alreadyOpen = shell.configPopupOpen

        shell.closeAllPopups()

        if (alreadyOpen && sameMonitor) return

        shell.popupMonitor = monitor

        if (name === "media") shell.mediaPopupOpen = true
        if (name === "network") shell.networkPopupOpen = true
        if (name === "bluetooth") shell.bluetoothPopupOpen = true
        if (name === "audio") shell.audioPopupOpen = true
        if (name === "system") shell.systemPopupOpen = true
        if (name === "calendar") shell.calendarPopupOpen = true
        if (name === "power") shell.powerPopupOpen = true
        if (name === "config") shell.configPopupOpen = true
    }

    Process {
        id: cavaStatusProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-toggle.sh status"]
        running: true

        stdout: SplitParser {
            onRead: data => shell.cavaEnabled = data.trim() !== "0"
        }
    }

    Process {
        id: cavaToggleProc
    }

    Process {
        id: activeProfileProc
        command: [
            "sh",
            "-c",
            "cat ~/.config/quickshell-profiles/active-profile 2>/dev/null || echo unknown"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => shell.activeProfile = data.trim()
        }
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

        onTriggered: {
            mediaStatusProc.running = true
            cavaStatusProc.running = true
        }
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
        interval: 550
        repeat: false

        onTriggered: {
            shell.workspaceOverlayOpen = false
            shell.workspaceTriggerMonitor = ""
        }
    }

    Process {
        id: launcherTriggerProc
        command: [
            "sh",
            "-c",
            "cat /tmp/quickshell-launcher-trigger 2>/dev/null || true"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let current = data.trim()

                if (current.length > 0 && current !== shell.lastLauncherTrigger) {
                    let parts = current.split("\t")
                    shell.openLauncher(parts[1] || "", parts[2] || "apps")
                    shell.lastLauncherTrigger = current
                }
            }
        }
    }

    Timer {
        interval: 120
        running: true
        repeat: true
        onTriggered: launcherTriggerProc.running = true
    }

    Process {
        id: barHiddenProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/bar-hide-state.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("\t")
                shell.barHiddenMonitor = parts[0] || ""
                shell.barHidden = (parts.length >= 2 && (parts[1] || "0") === "1")
            }
        }
    }

    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: barHiddenProc.running = true
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
            visible: shell.barHiddenMonitors.indexOf("|" + panel.screenName + "|") === -1
            focusable: shell.anyPopupOpen && !shell.launcherOpen

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: "transparent"

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    shell.closeAllPopups()
                    event.accepted = true
                }
            }

            


            Item {
                id: islandWrap

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                height: 40

                Rectangle {
                    id: leftIsland

                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.top: parent.top
                    anchors.topMargin: 8

                    width: Math.min(parent.width * 0.45, leftRow.implicitWidth + 24)
                    height: 28
                    radius: 14

                    color: Theme.Colors.barBg
                    opacity: 0.88
                    border.color: Theme.Colors.accent
                    border.width: 1
                    clip: true

                    RowLayout {
                        id: leftRow
                        anchors.centerIn: parent
                        spacing: 8

                        HostCenter {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("media", panel.screenName)
                        }

                        WaybarWorkspaces {
                            Layout.alignment: Qt.AlignVCenter
                            monitorName: panel.screenName
                        }

                        ActiveWindow {
                            Layout.alignment: Qt.AlignVCenter
                            monitorName: panel.screenName

                            onClicked: {
                                activeProfileProc.running = true
                                shell.togglePopup("config", panel.screenName)
                            }
                        }
                    }
                }

                Rectangle {
                    id: island

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8

                    width: panel.workspaceMode
                        ? workspaceRow.implicitWidth + 28
                        : panel.cavaMode
                            ? Math.min(panel.width * 0.42, 560)
                            : centerRow.implicitWidth + 28

                    height: 28
                    radius: 14

                    color: Theme.Colors.barBg
                    opacity: 0.88
                    border.color: Theme.Colors.accent
                    border.width: 1
                    clip: true

                    HoverHandler {
                        id: islandHover
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }

                    CavaFull {
                        visible: panel.cavaMode
                        opacity: panel.cavaMode ? 1 : 0
                        onClicked: shell.togglePopup("media", panel.screenName)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 90
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
                                duration: 90
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
                        spacing: 6

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 90
                                easing.type: Easing.OutCubic
                            }
                        }

                        WaybarClock {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("calendar", panel.screenName)
                        }
                    }
                }

                Rectangle {
                    id: rightIsland

                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.top: parent.top
                    anchors.topMargin: 8

                    width: Math.min(parent.width * 0.48, rightRow.implicitWidth + 24)
                    height: 28
                    radius: 14

                    color: Theme.Colors.barBg
                    opacity: 0.88
                    border.color: Theme.Colors.accent
                    border.width: 1
                    clip: true

                    RowLayout {
                        id: rightRow
                        anchors.centerIn: parent
                        spacing: 7

                        WaybarNowPlaying {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("media", panel.screenName)
                        }

                        Temps {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("system", panel.screenName)
                        }

                        Network {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("network", panel.screenName)
                        }

                        Bluetooth {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("bluetooth", panel.screenName)
                        }

                        SearchButton {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.openLauncher(panel.screenName, "apps")
                        }

                        Volume {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("audio", panel.screenName)
                        }

                        Battery {
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: shell.togglePopup("power", panel.screenName)
                        }
                    }
                }
            }

            PopupWindow {
                id: launcherWindow
                visible: false
                width: 810
                height: 510
                color: "transparent"

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: modelData.height / 2 - height / 2

                


                Item {
                    anchors.fill: parent
                    opacity: launcherWindow.visible ? 1 : 0
                    scale: launcherWindow.visible ? 1 : 0.94
                    transformOrigin: Item.Center

                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    LauncherPopup {
                        anchors.centerIn: parent
                        width: 800
                        height: 500
                        cavaEnabled: shell.cavaEnabled

                        onToggleCavaRequested: shell.toggleCava()

                        onCloseRequested: {
                            shell.launcherOpen = false
                            shell.launcherMonitor = ""
                        }
                    }
                }
            }

            PopupWindow {
                id: configPopupWindow
                visible: shell.configPopupOpen && shell.popupMonitor === panel.screenName
                width: 270
                height: 140
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: 18
                anchor.rect.y: 44

                Item {
                    anchors.fill: parent
                    opacity: configPopupWindow.visible ? 1 : 0
                    scale: configPopupWindow.visible ? 1 : 0.92
                    transformOrigin: Item.TopLeft

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

                    ConfigProfilePopup {
                        anchors.fill: parent
                        activeProfile: shell.activeProfile

                        onCloseRequested: {
                            shell.configPopupOpen = false
                            shell.popupMonitor = ""
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
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: calendarPopupWindow.visible ? 1 : 0
                    scale: calendarPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    CalendarPopup { anchors.fill: parent }
                }
            }

            PopupWindow {
                id: mediaPopupWindow
                visible: shell.mediaPopupOpen && shell.popupMonitor === panel.screenName
                width: 540
                height: 230
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: mediaPopupWindow.visible ? 1 : 0
                    scale: mediaPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    MediaPopup {
                        anchors.fill: parent
                        cavaEnabled: shell.cavaEnabled
                        onToggleCavaRequested: shell.toggleCava()
                    }
                }
            }

            PopupWindow {
                id: networkPopupWindow
                visible: shell.networkPopupOpen && shell.popupMonitor === panel.screenName
                width: 390
                height: 300
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: networkPopupWindow.visible ? 1 : 0
                    scale: networkPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    NetworkPopup { anchors.fill: parent }
                }
            }

            PopupWindow {
                id: bluetoothPopupWindow
                visible: shell.bluetoothPopupOpen && shell.popupMonitor === panel.screenName
                width: 360
                height: 190
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: bluetoothPopupWindow.visible ? 1 : 0
                    scale: bluetoothPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top
                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    BluetoothPopup { anchors.fill: parent }
                }
            }

            PopupWindow {
                id: powerPopupWindow
                visible: shell.powerPopupOpen && shell.popupMonitor === panel.screenName
                width: 360
                height: 176
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: powerPopupWindow.visible ? 1 : 0
                    scale: powerPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    PowerPopup { anchors.fill: parent }
                }
            }

            PopupWindow {
                id: audioPopupWindow
                visible: shell.audioPopupOpen && shell.popupMonitor === panel.screenName
                width: 460
                height: 260
                color: "transparent"
                grabFocus: true

                anchor.window: panel
                anchor.rect.x: panel.width / 2 - width / 2
                anchor.rect.y: islandWrap.y + island.height + 8

                Item {
                    anchors.fill: parent
                    opacity: audioPopupWindow.visible ? 1 : 0
                    scale: audioPopupWindow.visible ? 1 : 0.90
                    transformOrigin: Item.Top

                    focus: true
                    activeFocusOnTab: true

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            shell.closeAllPopups()
                            event.accepted = true
                        }
                    }

                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                    AudioPopup { anchors.fill: parent }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: launcherOverlayPanel

            property var modelData
            property string screenName: modelData.name

            screen: modelData
            visible: shell.launcherOpen && shell.launcherMonitor === screenName
            focusable: shell.launcherOpen
            color: "transparent"

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    shell.launcherOpen = false
                    shell.launcherMonitor = ""
                    event.accepted = true
                }
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    shell.launcherOpen = false
                    shell.launcherMonitor = ""
                }
            }

            Item {
                id: launcherOverlayBox

                anchors.centerIn: parent
                width: 800
                height: 500

                opacity: launcherOverlayPanel.visible ? 1 : 0
                scale: launcherOverlayPanel.visible ? 1 : 0.94
                transformOrigin: Item.Center

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutBack
                    }
                }

                LauncherPopup {
                    anchors.fill: parent
                    active: launcherOverlayPanel.visible
                    initialMode: shell.launcherMode
                    cavaEnabled: shell.cavaEnabled

                    onToggleCavaRequested: shell.toggleCava()

                    onCloseRequested: {
                        shell.launcherOpen = false
                        shell.launcherMonitor = ""
                    }
                }

            }
        }
    }

}
