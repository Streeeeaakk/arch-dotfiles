import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property string cpuTemp: "?"
    property string gpuTemp: "?"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 76
    Layout.preferredWidth: 76
    Layout.minimumWidth: 76
    Layout.maximumWidth: 76

    height: 24

    Text {
        anchors.centerIn: parent
        text: " " + root.cpuTemp + "° " + root.gpuTemp + "°"
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

    Process {
        id: tempProc
        command: ["sh", "-c", "/home/streak/.config/quickshell-kde/scripts/temps-info.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.cpuTemp = parts[0] || "?"
                root.gpuTemp = parts[1] || "?"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: tempProc.running = true
    }
}
