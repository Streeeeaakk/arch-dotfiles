import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 32

        Rectangle {
            anchors.fill: parent
            color: "#11111b"

            Text {
                anchors.centerIn: parent
                text: "Quickshell test bar"
                color: "white"
            }
        }
    }
}
