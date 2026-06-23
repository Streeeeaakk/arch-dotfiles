import QtQuick
import QtQuick.Controls

Item {
    id: root

    // Keep compatibility with the Hyprland version used by shell.qml
    property string monitorName: ""
    signal clicked()

    implicitWidth: label.implicitWidth
    implicitHeight: 24
    width: label.implicitWidth
    height: 24

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        text: "KDE Plasma"
        color: "white"
        font.pixelSize: 12
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
