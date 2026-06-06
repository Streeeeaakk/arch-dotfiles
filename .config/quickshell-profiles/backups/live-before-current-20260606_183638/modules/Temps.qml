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

    implicitWidth: 142
    Layout.preferredWidth: 142
    Layout.minimumWidth: 142
    Layout.maximumWidth: 142

    height: 24

    Text {
        anchors.centerIn: parent
        text: "CPU: " + root.cpuTemp + "°C    GPU: " + root.gpuTemp + "°"
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.family: "Figtree"
        font.pixelSize: 12
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
        id: tempProc
        command: [
            "sh",
            "-c",
            "cpu=''; for z in /sys/class/thermal/thermal_zone*/temp; do type=$(cat ${z%/temp}/type 2>/dev/null); if [ \"$type\" = \"acpitz\" ]; then raw=$(cat \"$z\" 2>/dev/null); cpu=$((raw/1000)); break; fi; done; if [ -z \"$cpu\" ]; then cpu=$(sensors 2>/dev/null | awk '/acpitz-acpi-0/{found=1} found && /temp1:/ {gsub(/[+°C]/,\"\",$2); print int($2); exit}'); fi; gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1); [ -z \"$cpu\" ] && cpu=\"?\"; [ -z \"$gpu\" ] && gpu=\"?\"; echo \"$cpu:$gpu\""
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
        interval: 2000
        running: true
        repeat: true
        onTriggered: tempProc.running = true
    }
}
