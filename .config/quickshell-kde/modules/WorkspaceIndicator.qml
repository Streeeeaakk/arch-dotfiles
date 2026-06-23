import QtQuick
import QtQuick.Controls

Rectangle {
    width: 48
    height: 26
    radius: 13
    color: "transparent"
    border.width: 1
    border.color: "#ffffff44"

    Text {
        anchors.centerIn: parent
        text: "KDE"
        color: "white"
        font.pixelSize: 11
        font.bold: true
    }
}
