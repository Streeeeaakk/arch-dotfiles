import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    signal clicked()

    property date now: new Date()
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 150
    Layout.preferredWidth: 150
    Layout.minimumWidth: 150
    Layout.maximumWidth: 150

    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"
    clip: true

    Text {
        anchors.centerIn: parent

        text: root.hovered
            ? Qt.formatDateTime(root.now, "MMM dd  h:mm:ss AP")
            : Qt.formatDateTime(root.now, "MMM dd  h:mm AP")

        color: "#cdd6f4"
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
