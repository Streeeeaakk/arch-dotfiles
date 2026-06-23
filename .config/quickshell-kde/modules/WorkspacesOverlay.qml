import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property bool open: false
    property int activeWorkspace: 1
    property string occupiedWorkspaces: "1"

    visible: open
    color: "#00000099"
    radius: 18
    width: 260
    height: 90

    Row {
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: 4

            Rectangle {
                width: 42
                height: 42
                radius: 14
                color: index === 0 ? "#ffffff22" : "transparent"
                border.width: 1
                border.color: "#ffffff55"

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    color: "white"
                    font.pixelSize: 15
                    font.bold: index === 0
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text: "KDE mode"
        color: "#ffffffaa"
        font.pixelSize: 11
    }
}
