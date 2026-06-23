import QtQuick
import QtQuick.Controls

Row {
    spacing: 6

    Repeater {
        model: 4

        Rectangle {
            width: 26
            height: 22
            radius: 8
            color: "transparent"
            border.width: 1
            border.color: "#ffffff55"

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: "white"
                font.pixelSize: 11
                font.bold: index === 0
            }
        }
    }
}
