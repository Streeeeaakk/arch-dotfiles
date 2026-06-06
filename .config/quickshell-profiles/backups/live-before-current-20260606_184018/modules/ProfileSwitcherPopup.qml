import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal closeRequested()

    property string activeProfile: ""

    width: 360
    height: 170
    radius: 16

    color: Qt.rgba(Theme.Colors.barBg.r, Theme.Colors.barBg.g, Theme.Colors.barBg.b, 0.94)
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
        anchors.margins: 16
        spacing: 12

        Text {
            text: "󰒓  Quickshell Config"
            color: "#ffffff"
            font.family: "Figtree"
            font.pixelSize: 16
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: activeProfile.length > 0 ? "Active: " + activeProfile : "Choose profile"
            color: "#cfcfcf"
            font.family: "Figtree"
            font.pixelSize: 11
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                width: 130
                height: 42
                radius: 12
                color: activeProfile === "current" ? Theme.Colors.activeBg : Theme.Colors.pillBg
                border.color: activeProfile === "current" ? Theme.Colors.accent : Theme.Colors.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Current"
                    color: "#ffffff"
                    font.family: "Figtree"
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchProfile("current")
                }
            }

            Rectangle {
                width: 130
                height: 42
                radius: 12
                color: activeProfile === "waybar-copy" ? Theme.Colors.activeBg : Theme.Colors.pillBg
                border.color: activeProfile === "waybar-copy" ? Theme.Colors.accent : Theme.Colors.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Waybar Copy"
                    color: "#ffffff"
                    font.family: "Figtree"
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchProfile("waybar-copy")
                }
            }
        }

        Text {
            text: "Esc closes this menu"
            color: "#cfcfcf"
            font.family: "Figtree"
            font.pixelSize: 10
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Process {
        id: switchProc
    }
}
