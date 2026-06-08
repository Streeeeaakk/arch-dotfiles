import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property bool hovered: mouseArea.containsMouse

    implicitWidth: 120
    Layout.preferredWidth: 120
    Layout.minimumWidth: 120
    Layout.maximumWidth: 120

    height: 24

    RowLayout {
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: ""
            color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "Demeter"
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: root.hovered ? 58 : 34
        height: 2
        radius: 1
        color: Theme.Colors.accent
        opacity: root.hovered ? 0.9 : 0.45
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
