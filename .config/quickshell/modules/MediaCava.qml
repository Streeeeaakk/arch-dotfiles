import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property bool hovered: mouseArea.containsMouse
    property string dateTimeText: Qt.formatDateTime(new Date(), "MMMM d, h:mm AP")

    implicitWidth: 158
    Layout.preferredWidth: 158
    Layout.minimumWidth: 158
    Layout.maximumWidth: 158

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
            text: root.dateTimeText
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 12
            font.bold: root.hovered
            elide: Text.ElideRight
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
        onTriggered: root.dateTimeText = Qt.formatDateTime(new Date(), "MMMM d, h:mm AP")
    }
}
