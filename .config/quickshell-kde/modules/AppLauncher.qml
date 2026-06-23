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
    property var apps: []
    property var filteredApps: []
    property string query: ""

    width: 800
    height: 500
    radius: 8

    color: Theme.Colors.barBg
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function takeFocus() {
        searchInput.forceActiveFocus()
        searchInput.cursorPosition = searchInput.text.length
    }

    function refreshFilter() {
        let q = root.query.toLowerCase().trim()

        if (q.length === 0) {
            root.filteredApps = root.apps.slice(0, 8)
            return
        }

        root.filteredApps = root.apps.filter(function(app) {
            let name = String(app.name || "").toLowerCase()
            let comment = String(app.comment || "").toLowerCase()
            let iconName = String(app.iconName || "").toLowerCase()

            return name.indexOf(q) !== -1
                || comment.indexOf(q) !== -1
                || iconName.indexOf(q) !== -1
        }).slice(0, 8)
    }

    function launchCurrent() {
        if (root.filteredApps.length === 0) return

        let idx = listView.currentIndex
        if (idx < 0 || idx >= root.filteredApps.length) idx = 0

        let app = root.filteredApps[idx]

        launchProc.command = [
            "sh",
            "-c",
            "/home/streak/.config/quickshell-kde/scripts/app-launch.sh " + root.shellQuote(app.path)
        ]

        launchProc.running = true
        root.closeRequested()
    }

    onActiveChanged: {
        if (active) {
            focusTimer.restart()
        }
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
                opacity: 0.25
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 46
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: "󰍉"
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
                                } else if (event.key === Qt.Key_Down) {
                                    listView.currentIndex = Math.min(listView.currentIndex + 1, root.filteredApps.length - 1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    listView.currentIndex = Math.max(listView.currentIndex - 1, 0)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.launchCurrent()
                                    event.accepted = true
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Search Apps..."
                                visible: searchInput.text.length === 0
                                color: Theme.Colors.muted
                                font.family: "Figtree"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: 78
                            height: 24
                            radius: 8
                            color: root.cavaEnabled ? Theme.Colors.activeBg : Theme.Colors.pillBg
                            border.color: Theme.Colors.accent
                            border.width: 1
                            opacity: 0.9
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: root.cavaEnabled ? "Cava ON" : "Cava OFF"
                                color: root.cavaEnabled ? Theme.Colors.accent : Theme.Colors.muted
                                font.family: "Figtree"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.toggleCavaRequested()
                                    focusTimer.restart()
                                }
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

                    model: root.filteredApps
                    currentIndex: 0
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
                        id: appRow

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
                            visible: appRow.selected || appRow.hovered
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
                                    source: appRow.iconSource
                                    visible: appRow.iconSource.length > 0
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    asynchronous: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appRow.iconSource.length === 0
                                    text: "󰣆"
                                    color: appRow.selected ? Theme.Colors.accent : Theme.Colors.text
                                    font.pixelSize: 16
                                }
                            }

                            Text {
                                text: modelData.name || ""
                                color: appRow.selected ? Theme.Colors.accent : Theme.Colors.text
                                font.family: "Figtree"
                                font.pixelSize: 13
                                font.bold: appRow.selected
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
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
                                root.launchCurrent()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "No results"
                        visible: root.filteredApps.length === 0
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
        command: ["sh", "-c", "/home/streak/.config/quickshell-kde/scripts/app-list.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    root.apps = JSON.parse(data.trim())
                    root.refreshFilter()
                    listView.currentIndex = 0
                } catch (e) {
                    root.apps = []
                    root.filteredApps = []
                }
            }
        }
    }

    Process {
        id: launchProc
    }

    Timer {
        id: focusTimer
        interval: 60
        running: false
        repeat: false
        onTriggered: root.takeFocus()
    }

    Timer {
        id: focusRetryTimer
        interval: 180
        running: root.active
        repeat: true
        onTriggered: root.takeFocus()
    }

    Component.onCompleted: {
        root.refreshFilter()
        focusTimer.restart()
    }
}
