import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal closeRequested()

    property string activeProfile: ""

    width: 760
    height: 500
    radius: 14

    color: Qt.rgba(Theme.Colors.barBg.r, Theme.Colors.barBg.g, Theme.Colors.barBg.b, 0.96)
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function switchProfile(profile) {
        switchProc.command = [
            "sh",
            "-c",
            "~/.config/hypr/scripts/qs-config-switch.sh " + profile
        ]
        switchProc.running = true
        root.closeRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 12
            color: Theme.Colors.pillBg

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: "Quickshell Config"
                    color: "#ffffff"
                    font.family: "Figtree"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Search profiles..."
                    color: "#9ca3af"
                    font.family: "Figtree"
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        ProfileRow {
            title: "Current"
            subtitle: "Stable center-island layout"
            icon: "󰔟"
            selected: root.activeProfile === "current"
            onClicked: root.switchProfile("current")
        }

        ProfileRow {
            title: "Waybar Copy"
            subtitle: "Waybar-like left / center / right island layout"
            icon: "󰖲"
            selected: root.activeProfile === "waybar-copy"
            onClicked: root.switchProfile("waybar-copy")
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            text: "Esc closes this menu"
            color: "#9ca3af"
            font.family: "Figtree"
            font.pixelSize: 11
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    component ProfileRow: Rectangle {
        id: row

        signal clicked()

        property string title: ""
        property string subtitle: ""
        property string icon: ""
        property bool selected: false
        property bool hovered: mouseArea.containsMouse

        Layout.fillWidth: true
        height: 48
        radius: 12

        color: selected
            ? Theme.Colors.activeBg
            : hovered
                ? Theme.Colors.pillHover
                : Theme.Colors.pillBg

        border.color: selected || hovered ? Theme.Colors.accent : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            Text {
                text: row.icon
                color: row.selected || row.hovered ? Theme.Colors.accent : "#ffffff"
                font.pixelSize: 22
                Layout.preferredWidth: 28
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: row.title
                color: "#ffffff"
                font.family: "Figtree"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "— " + row.subtitle
                color: "#9ca3af"
                font.family: "Figtree"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: row.selected
                text: "Active"
                color: Theme.Colors.accent
                font.family: "Figtree"
                font.pixelSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    Process {
        id: switchProc
    }
}
