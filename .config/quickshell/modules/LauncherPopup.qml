import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal closeRequested()
    signal toggleCavaRequested()

    property bool active: false
    property bool cavaEnabled: true

    property string mode: "apps"
    property string initialMode: "apps"
    property var apps: []
    property var clips: []
    property var filteredItems: []
    property string query: ""

    width: 800
    height: 500
    radius: 8

    focus: true
    activeFocusOnTab: true

    color: Theme.Colors.barBg
    border.color: Theme.Colors.accent
    border.width: 2
    clip: true

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function takeFocus() {
        root.forceActiveFocus()
        searchInput.forceActiveFocus()
        searchInput.cursorPosition = searchInput.text.length
    }

    function switchMode(newMode) {
        root.mode = newMode
        root.query = ""
        searchInput.text = ""
        root.refreshFilter()
        listView.currentIndex = 0
        root.takeFocus()
    }

    function toggleMode() {
        root.switchMode(root.mode === "apps" ? "clipboard" : "apps")
    }

    function refreshFilter() {
        let q = root.query.toLowerCase().trim()
        let source = root.mode === "apps" ? root.apps : root.clips

        if (q.length === 0) {
            root.filteredItems = source.slice(0, 8)
            return
        }

        root.filteredItems = source.filter(function(item) {
            let name = String(item.name || "").toLowerCase()
            let comment = String(item.comment || "").toLowerCase()
            return name.indexOf(q) !== -1 || comment.indexOf(q) !== -1
        }).slice(0, 8)
    }

    function activateCurrent() {
        if (root.filteredItems.length === 0) return

        let idx = listView.currentIndex
        if (idx < 0 || idx >= root.filteredItems.length) idx = 0

        let item = root.filteredItems[idx]

        if (root.mode === "apps") {
            launchProc.command = [
                "sh",
                "-c",
                "~/.config/quickshell/scripts/app-launch.sh " + root.shellQuote(item.path)
            ]
            launchProc.running = true
        } else {
            clipCopyProc.command = [
                "sh",
                "-c",
                "~/.config/quickshell/scripts/clipboard-copy.sh " + root.shellQuote(item.path)
            ]
            clipCopyProc.running = true
        }

        root.closeRequested()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            color: "#000000"
            clip: true

            Image {
                anchors.fill: parent
                source: "../assets/launcher.jpg"
                cache: false
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: false
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.08
            }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: Theme.Colors.accent
                opacity: 0.35
            }
        }

        Rectangle {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            color: Theme.Colors.barBg

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 16
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    height: 30
                    spacing: 8

                    Rectangle {
                        width: 72
                        height: 24
                        radius: 8
                        color: root.mode === "apps" ? Theme.Colors.activeBg : Theme.Colors.pillBg
                        border.color: Theme.Colors.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Apps"
                            color: root.mode === "apps" ? Theme.Colors.accent : Theme.Colors.muted
                            font.family: "Figtree"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.switchMode("apps")
                        }
                    }

                    Rectangle {
                        width: 96
                        height: 24
                        radius: 8
                        color: root.mode === "clipboard" ? Theme.Colors.activeBg : Theme.Colors.pillBg
                        border.color: Theme.Colors.accent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Clipboard"
                            color: root.mode === "clipboard" ? Theme.Colors.accent : Theme.Colors.muted
                            font.family: "Figtree"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.switchMode("clipboard")
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Tab"
                        color: Theme.Colors.muted
                        font.family: "Figtree"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 46
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: root.mode === "apps" ? "󰍉" : ""
                            color: Theme.Colors.accent
                            font.pixelSize: 17
                            Layout.alignment: Qt.AlignVCenter
                        }

                        TextInput {
                            id: searchInput

                            Layout.fillWidth: true
                            height: parent.height

                            focus: true
                            activeFocusOnTab: true

                            color: Theme.Colors.text
                            selectedTextColor: Theme.Colors.accentText
                            selectionColor: Theme.Colors.accent
                            font.family: "Figtree"
                            font.pixelSize: 16
                            font.bold: true
                            clip: true
                            verticalAlignment: TextInput.AlignVCenter

                            onTextChanged: {
                                root.query = text
                                root.refreshFilter()
                                listView.currentIndex = 0
                            }

                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Escape) {
                                    root.closeRequested()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Tab) {
                                    root.toggleMode()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Down) {
                                    listView.currentIndex = Math.min(listView.currentIndex + 1, root.filteredItems.length - 1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    listView.currentIndex = Math.max(listView.currentIndex - 1, 0)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.activateCurrent()
                                    event.accepted = true
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.mode === "apps" ? "Search Apps..." : "Search Clipboard..."
                                visible: searchInput.text.length === 0
                                color: Theme.Colors.muted
                                font.family: "Figtree"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Theme.Colors.accent
                        opacity: 0.35
                    }
                }

                ListView {
                    id: listView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: root.filteredItems
                    currentIndex: 0
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
                        id: itemRow

                        property bool selected: ListView.isCurrentItem
                        property bool hovered: rowMouse.containsMouse
                        property string iconSource: modelData.icon || ""

                        width: listView.width
                        height: 43
                        radius: 4

                        color: selected
                            ? Theme.Colors.activeBg
                            : hovered
                                ? Theme.Colors.pillHover
                                : "transparent"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 3
                            color: Theme.Colors.accent
                            visible: itemRow.selected || itemRow.hovered
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignVCenter

                                Image {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: itemRow.iconSource
                                    visible: root.mode === "apps" && itemRow.iconSource.length > 0
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    asynchronous: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: root.mode === "clipboard" || itemRow.iconSource.length === 0
                                    text: root.mode === "clipboard" ? "" : "󰣆"
                                    color: itemRow.selected ? Theme.Colors.accent : Theme.Colors.text
                                    font.pixelSize: 16
                                }
                            }

                            Text {
                                text: modelData.name || ""
                                color: itemRow.selected ? Theme.Colors.accent : Theme.Colors.text
                                font.family: "Figtree"
                                font.pixelSize: 13
                                font.bold: itemRow.selected
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: listView.currentIndex = index

                            onClicked: {
                                listView.currentIndex = index
                                root.activateCurrent()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.mode === "apps" ? "No apps found" : "No clipboard history"
                        visible: root.filteredItems.length === 0
                        color: Theme.Colors.muted
                        font.family: "Figtree"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
        }
    }

    Process {
        id: appsProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/app-list.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    root.apps = JSON.parse(data.trim())
                    root.refreshFilter()
                    listView.currentIndex = 0
                } catch (e) {
                    root.apps = []
                    root.refreshFilter()
                }
            }
        }
    }

    Process {
        id: clipsProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/clipboard-list.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    root.clips = JSON.parse(data.trim())
                    root.refreshFilter()
                    listView.currentIndex = 0
                } catch (e) {
                    root.clips = []
                    root.refreshFilter()
                }
            }
        }
    }

    Process {
        id: launchProc
    }

    Process {
        id: clipCopyProc
    }

    Timer {
        id: focusTimer
        interval: 80
        running: root.active
        repeat: true

        onTriggered: {
            root.takeFocus()
        }
    }

    onActiveChanged: {
        if (active) {
            appsProc.running = true
            clipsProc.running = true
            root.switchMode(root.initialMode)
            root.takeFocus()
            focusTimer.restart()
        }
    }

    Component.onCompleted: {
        root.refreshFilter()
        root.takeFocus()
    }
}
