import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property date now: new Date()
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 96
    Layout.preferredWidth: 96
    Layout.minimumWidth: 96
    Layout.maximumWidth: 96

    height: 24

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.now, "h:mm AP")
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.pixelSize: 12
        font.bold: root.hovered
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
