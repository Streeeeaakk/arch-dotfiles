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

    width: 660
    height: 360
    radius: 22

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
            "~/.config/quickshell/scripts/app-launch.sh " + root.shellQuote(app.path)
        ]

        launchProc.running = true
        root.closeRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            height: 58
            radius: 17
            color: Theme.Colors.pillBg
            border.color: Theme.Colors.border
            border.width: 1
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 13

                Text {
                    text: "󰍉"
                    color: Theme.Colors.accent
                    font.pixelSize: 23
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: searchInput

                    Layout.fillWidth: true
                    height: parent.height

                    focus: true
                    color: Theme.Colors.text
                    selectedTextColor: Theme.Colors.accentText
                    selectionColor: Theme.Colors.accent
                    font.pixelSize: 22
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
                        text: "Spotlight Search"
                        visible: searchInput.text.length === 0
                        color: Theme.Colors.muted
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Component.onCompleted: forceActiveFocus()
                }
            }
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.filteredApps
            currentIndex: 0
            clip: true
            spacing: 7

            delegate: Rectangle {
                id: appRow

                property bool selected: ListView.isCurrentItem
                property bool hovered: rowMouse.containsMouse
                property string iconSource: modelData.icon || ""

                width: listView.width
                height: 46
                radius: 14

                color: selected
                    ? Theme.Colors.activeBg
                    : hovered
                        ? Theme.Colors.pillHover
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 13

                    Item {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
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
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: modelData.name || ""
                            color: Theme.Colors.text
                            font.pixelSize: 14
                            font.bold: appRow.selected
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.comment || ""
                            color: Theme.Colors.muted
                            font.pixelSize: 10
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }

                    Text {
                        visible: appRow.selected
                        text: "↵"
                        color: Theme.Colors.muted
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
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
                font.pixelSize: 15
                font.bold: true
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
