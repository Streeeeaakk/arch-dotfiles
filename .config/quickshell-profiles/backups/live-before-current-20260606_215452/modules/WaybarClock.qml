import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property date now: new Date()
    property bool hovered: mouseArea.containsMouse

    implicitWidth: hovered ? 178 : 122
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: 122
    Layout.maximumWidth: 178

    height: 24

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ""
            color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
            font.pixelSize: 11
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.hovered
                ? Qt.formatDateTime(root.now, "MM/dd, h:mm:ss AP")
                : Qt.formatDateTime(root.now, "MM/dd, h:mm AP")

            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: root.hovered
            Layout.alignment: Qt.AlignVCenter
        }
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
