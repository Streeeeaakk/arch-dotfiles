import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property string percent: "none"
    property string status: "Unknown"
    property bool hasBattery: percent !== "none"
    property bool hovered: mouseArea.containsMouse
    property int pct: hasBattery ? parseInt(percent) : 0

    visible: hasBattery

    implicitWidth: hasBattery ? 56 : 0
    Layout.preferredWidth: hasBattery ? 56 : 0
    Layout.minimumWidth: hasBattery ? 56 : 0
    Layout.maximumWidth: hasBattery ? 56 : 0

    height: 24

    Canvas {
        id: ring

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        antialiasing: true
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            let ctx = getContext("2d")
            let w = width
            let h = height
            let cx = w / 2
            let cy = h / 2
            let r = 7
            let start = -Math.PI / 2
            let end = start + (Math.PI * 2 * Math.max(0, Math.min(100, root.pct)) / 100)

            ctx.clearRect(0, 0, w, h)

            ctx.lineWidth = 2.2
            ctx.lineCap = "round"

            ctx.beginPath()
            ctx.strokeStyle = Theme.Colors.border
            ctx.globalAlpha = 0.9
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()

            ctx.beginPath()
            ctx.strokeStyle = root.pct <= 15 ? Theme.Colors.warning : Theme.Colors.accent
            ctx.globalAlpha = 1
            ctx.arc(cx, cy, r, start, end)
            ctx.stroke()

            ctx.globalAlpha = 1
        }
    }

    Text {
        anchors.left: ring.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        text: root.percent + "%"
        color: root.hovered
            ? Theme.Colors.textHover
            : root.pct <= 15
                ? Theme.Colors.warning
                : Theme.Colors.text

        font.family: "Figtree"
        font.pixelSize: 12
        font.bold: root.hovered
        width: 32
        horizontalAlignment: Text.AlignLeft
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
        id: batteryProc

        command: [
            "sh",
            "-c",
            "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] || continue; cap=$(cat \"$b/capacity\" 2>/dev/null); stat=$(cat \"$b/status\" 2>/dev/null | tr 'A-Z' 'a-z'); echo \"$cap:$stat\"; exit; done; echo \"none:Unknown\""
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":")
                root.percent = parts[0] || "none"
                root.status = parts[1] || "Unknown"
                ring.requestPaint()
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }

    onPctChanged: ring.requestPaint()
    onHoveredChanged: ring.requestPaint()
}
