import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    property string dateText: Qt.formatDate(new Date(), "MMM dd")
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 66
    Layout.preferredWidth: 66
    Layout.minimumWidth: 66
    Layout.maximumWidth: 66

    height: 24

    Text {
        anchors.centerIn: parent
        text: root.dateText
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.family: "Figtree"
        font.pixelSize: 12
        font.bold: root.hovered
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.dateText = Qt.formatDate(new Date(), "MMM dd")
    }
}
