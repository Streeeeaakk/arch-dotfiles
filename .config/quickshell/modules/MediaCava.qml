import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Rectangle {
    id: root

    signal clicked()

    property date now: new Date()
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 130
    Layout.preferredWidth: 130
    Layout.minimumWidth: 130
    Layout.maximumWidth: 130

    height: 24
    radius: 9
    color: root.hovered ? Theme.Colors.pillHover : Theme.Colors.pillBg
    clip: true

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.now, root.hovered ? "MMM dd  h:mm:ss AP" : "MMM dd  h:mm AP")
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.pixelSize: 12
        font.bold: root.hovered
        width: parent.width - 10
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
