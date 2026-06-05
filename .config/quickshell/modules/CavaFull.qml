import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    signal clicked()

    property string bars: "▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
    property bool hovered: mouseArea.containsMouse

    anchors.fill: parent
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    anchors.topMargin: 4
    anchors.bottomMargin: 4

    radius: 13
    color: hovered ? "#313244" : "transparent"
    clip: true

    Text {
        anchors.centerIn: parent
        text: root.bars
        color: "#cdd6f4"
        font.pixelSize: 17
        font.bold: true
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

    Process {
        id: cavaProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-wide-bars.sh"]
        running: root.visible

        stdout: SplitParser {
            onRead: data => root.bars = data
        }
    }
}
