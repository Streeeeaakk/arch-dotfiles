import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal closeRequested()

    property string activeProfile: ""

    width: 420
    height: 230
    radius: 18

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
        anchors.margins: 20
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "󰒓  Quickshell Config"
                color: "#ffffff"
                font.family: "Figtree"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: activeProfile.length > 0 ? "Active profile: " + activeProfile : "Choose a profile"
                color: "#cfcfcf"
                font.family: "Figtree"
                font.pixelSize: 12
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.Colors.accent
            opacity: 0.45
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                id: currentButton

                property bool hovered: currentMouse.containsMouse
                property bool selected: activeProfile === "current"

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14

                color: selected
                    ? Theme.Colors.activeBg
                    : hovered
                        ? Theme.Colors.pillHover
                        : Theme.Colors.pillBg

                border.color: selected || hovered ? Theme.Colors.accent : Theme.Colors.border
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰔟"
                        color: currentButton.selected || currentButton.hovered ? Theme.Colors.accent : "#ffffff"
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Current"
                        color: "#ffffff"
                        font.family: "Figtree"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: currentButton.selected ? "Active" : "Stable profile"
                        color: "#cfcfcf"
                        font.family: "Figtree"
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    id: currentMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchProfile("current")
                }
            }

            Rectangle {
                id: waybarButton

                property bool hovered: waybarMouse.containsMouse
                property bool selected: activeProfile === "waybar-copy"

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14

                color: selected
                    ? Theme.Colors.activeBg
                    : hovered
                        ? Theme.Colors.pillHover
                        : Theme.Colors.pillBg

                border.color: selected || hovered ? Theme.Colors.accent : Theme.Colors.border
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰖲"
                        color: waybarButton.selected || waybarButton.hovered ? Theme.Colors.accent : "#ffffff"
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Waybar Copy"
                        color: "#ffffff"
                        font.family: "Figtree"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: waybarButton.selected ? "Active" : "Waybar-like layout"
                        color: "#cfcfcf"
                        font.family: "Figtree"
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    id: waybarMouse
                    anchors.fill: parent
                    hoverEnabled: true
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
