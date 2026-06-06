import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal closeRequested()

    property var apps: []
    property var filteredApps: []
    property string query: ""

    width: 560
    height: 480
    radius: 18

    color: Theme.Colors.barBg
    border.color: Theme.Colors.border
    border.width: 1
    clip: true

    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function refreshFilter() {
        let q = root.query.toLowerCase().trim()

        if (q.length === 0) {
            root.filteredApps = root.apps
            return
        }

        root.filteredApps = root.apps.filter(function(app) {
            let name = String(app.name || "").toLowerCase()
            let comment = String(app.comment || "").toLowerCase()
            return name.indexOf(q) !== -1 || comment.indexOf(q) !== -1
        })
    }

    function launchCurrent() {
        if (root.filteredApps.length === 0) return

        let idx = listView.currentIndex
        if (idx < 0 || idx >= root.filteredApps.length) idx = 0

        let app = root.filteredApps[idx]

        launchProc.command = [
            "sh",
            "-c",
            "~/.config/quickshell/scripts/app-launch.sh " + root.shellQuote(app.path)
        ]

        launchProc.running = true
        root.closeRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            height: 38
            spacing: 10

            Text {
                text: "󰀻"
                color: Theme.Colors.accent
                font.pixelSize: 20
                Layout.alignment: Qt.AlignVCenter
            }

            TextInput {
                id: searchInput

                Layout.fillWidth: true
                height: 36

                focus: true
                color: Theme.Colors.text
                selectedTextColor: Theme.Colors.accentText
                selectionColor: Theme.Colors.accent
                font.pixelSize: 17
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
                    text: "Search apps..."
                    visible: searchInput.text.length === 0
                    color: Theme.Colors.muted
                    font.pixelSize: 17
                    font.bold: true
                }

                Component.onCompleted: forceActiveFocus()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.Colors.border
            opacity: 0.75
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.filteredApps
            currentIndex: 0
            clip: true
            spacing: 6

            delegate: Rectangle {
                id: appRow

                property bool selected: ListView.isCurrentItem
                property bool hovered: rowMouse.containsMouse
                property string iconSource: modelData.icon || ""

                width: listView.width
                height: 44
                radius: 12

                color: selected
                    ? Theme.Colors.activeBg
                    : hovered
                        ? Theme.Colors.pillHover
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
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
                            font.pixelSize: 17
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: modelData.name || ""
                            color: Theme.Colors.text
                            font.pixelSize: 13
                            font.bold: appRow.selected
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.comment || modelData.path || ""
                            color: Theme.Colors.muted
                            font.pixelSize: 10
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
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
                text: "No apps found"
                visible: root.filteredApps.length === 0
                color: Theme.Colors.muted
                font.pixelSize: 14
                font.bold: true
            }
        }

        Text {
            text: "Enter to open  •  Esc to close"
            color: Theme.Colors.muted
            font.pixelSize: 11
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
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
                    root.filteredApps = []
                }
            }
        }
    }

    Process {
        id: launchProc
    }

    Component.onCompleted: {
        searchInput.forceActiveFocus()
    }
}
