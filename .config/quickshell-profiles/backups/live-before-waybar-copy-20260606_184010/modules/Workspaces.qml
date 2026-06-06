import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 6

    Repeater {
        model: 12

        Rectangle {
            property int ws: index + 1
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === ws

            width: isFocused ? 34 : 26
            height: 24
            radius: 7
            color: isFocused ? "#89b4fa" : "#313244"

            Text {
                anchors.centerIn: parent
                text: ws
                color: parent.isFocused ? "#11111b" : "#cdd6f4"
                font.pixelSize: 12
                font.bold: parent.isFocused
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + ws)
            }
        }
    }
}
