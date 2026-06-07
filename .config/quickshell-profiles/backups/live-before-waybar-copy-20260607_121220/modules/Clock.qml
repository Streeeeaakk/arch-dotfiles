import QtQuick

Rectangle {
    id: root

    property date now: new Date()
    property bool hovered: mouseArea.containsMouse

    width: hovered ? 210 : 145
    height: 24
    radius: 7
    color: hovered ? "#45475a" : "#313244"

    Text {
        anchors.centerIn: parent
        text: root.hovered
            ? Qt.formatDateTime(root.now, "dddd, MMMM dd yyyy  h:mm:ss AP")
            : Qt.formatDateTime(root.now, "MMM dd  h:mm AP")
        color: "#cdd6f4"
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
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
