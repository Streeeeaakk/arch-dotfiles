import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal clicked()

    property string cpuTemp: "?"
    property string gpuTemp: "?"
    property bool hovered: mouseArea.containsMouse

    implicitWidth: 92
    Layout.preferredWidth: 92
    Layout.minimumWidth: 92
    Layout.maximumWidth: 92

    height: 24
    radius: 9
    color: root.hovered ? Theme.Colors.pillHover : Theme.Colors.pillBg
    clip: true

    Text {
        anchors.centerIn: parent
        text: " " + root.cpuTemp + "°  " + root.gpuTemp + "°"
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.pixelSize: 12
        font.bold: root.hovered
        width: parent.width - 8
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
        command: [
            "sh",
            "-c",
            "cpu=$(sensors 2>/dev/null | awk '/Package id 0:/ {gsub(/[+°C]/,\"\",$4); print int($4); exit} /Tctl:/ {gsub(/[+°C]/,\"\",$2); print int($2); exit} /CPU:/ {gsub(/[+°C]/,\"\",$2); print int($2); exit}'); gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1); [ -z \"$cpu\" ] && cpu=\"?\"; [ -z \"$gpu\" ] && gpu=\"?\"; echo \"$cpu:$gpu\""
        ]
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
