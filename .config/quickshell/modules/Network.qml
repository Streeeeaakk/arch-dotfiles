import QtQuick

Item {
    id: root

    signal clicked()

    width: row.implicitWidth
    height: row.implicitHeight

    Row {
        id: row
        spacing: 6

        Text {
            text: "󰈀"
            color: "#e8e8e8"
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: "LAN"
            color: "#e8e8e8"
            font.pixelSize: 12
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
