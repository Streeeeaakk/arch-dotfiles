import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property bool hovered: mouseArea.containsMouse

    implicitWidth: 26
    Layout.preferredWidth: 26
    Layout.minimumWidth: 26
    Layout.maximumWidth: 26

    height: 24

    Text {
        anchors.centerIn: parent
        text: "󰍉"
        color: root.hovered ? Theme.Colors.accent : Theme.Colors.text
        font.pixelSize: 12
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: root.hovered ? 14 : 0
        height: 2
        radius: 1
        color: Theme.Colors.accent
        opacity: root.hovered ? 0.8 : 0

        Behavior on width {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
