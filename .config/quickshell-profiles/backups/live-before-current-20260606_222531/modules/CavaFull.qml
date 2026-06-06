import QtQuick
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    anchors.fill: parent
    clip: true

    property int pointCount: 56
    property var targetValues: []
    property var smoothValues: []
    property bool hovered: mouseArea.containsMouse

    function resetValues() {
        let arr = []
        let target = []

        for (let i = 0; i < root.pointCount; i++) {
            arr.push(0.02)
            target.push(0.02)
        }

        root.smoothValues = arr
        root.targetValues = target
    }

    function parseValues(data) {
        let parts = data.trim().split(",")
        let target = []

        for (let i = 0; i < root.pointCount; i++) {
            let raw = parseInt(parts[i] || "0")
            if (isNaN(raw)) raw = 0
            raw = Math.max(0, Math.min(100, raw))

            // Normalize and soften the motion.
            let v = raw / 100.0
            v = Math.pow(v, 0.72)
            target.push(v)
        }

        root.targetValues = target
    }

    Canvas {
        id: wave

        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            let ctx = getContext("2d")
            let w = width
            let h = height

            ctx.clearRect(0, 0, w, h)

            if (root.smoothValues.length < root.pointCount) {
                return
            }

            let mid = h / 2
            let amp = (h - 9) / 2
            let step = w / (root.pointCount - 1)

            // Soft center glow.
            ctx.globalAlpha = 0.18
            ctx.strokeStyle = Theme.Colors.accent
            ctx.lineWidth = 1

            ctx.beginPath()
            ctx.moveTo(12, mid)
            ctx.lineTo(w - 12, mid)
            ctx.stroke()

            // Main mirrored wave.
            ctx.globalAlpha = 0.78
            ctx.fillStyle = Theme.Colors.accent

            ctx.beginPath()

            // Upper curve
            for (let i = 0; i < root.pointCount; i++) {
                let x = i * step
                let y = mid - root.smoothValues[i] * amp

                if (i === 0) {
                    ctx.moveTo(x, y)
                } else {
                    let prevX = (i - 1) * step
                    let prevY = mid - root.smoothValues[i - 1] * amp
                    let cx = (prevX + x) / 2
                    let cy = (prevY + y) / 2

                    ctx.quadraticCurveTo(prevX, prevY, cx, cy)
                }
            }

            // Lower curve, reversed
            for (let j = root.pointCount - 1; j >= 0; j--) {
                let x2 = j * step
                let y2 = mid + root.smoothValues[j] * amp

                if (j === root.pointCount - 1) {
                    ctx.lineTo(x2, y2)
                } else {
                    let nextX = (j + 1) * step
                    let nextY = mid + root.smoothValues[j + 1] * amp
                    let cx2 = (nextX + x2) / 2
                    let cy2 = (nextY + y2) / 2

                    ctx.quadraticCurveTo(nextX, nextY, cx2, cy2)
                }
            }

            ctx.closePath()
            ctx.fill()

            // Bright wave line.
            ctx.globalAlpha = 0.95
            ctx.strokeStyle = Theme.Colors.text
            ctx.lineWidth = 1.2

            ctx.beginPath()

            for (let k = 0; k < root.pointCount; k++) {
                let lx = k * step
                let ly = mid - root.smoothValues[k] * amp

                if (k === 0) {
                    ctx.moveTo(lx, ly)
                } else {
                    let px = (k - 1) * step
                    let py = mid - root.smoothValues[k - 1] * amp
                    let mcx = (px + lx) / 2
                    let mcy = (py + ly) / 2

                    ctx.quadraticCurveTo(px, py, mcx, mcy)
                }
            }

            ctx.stroke()
            ctx.globalAlpha = 1
        }
    }

    Timer {
        interval: 16
        running: root.visible
        repeat: true

        onTriggered: {
            if (root.smoothValues.length < root.pointCount || root.targetValues.length < root.pointCount) {
                root.resetValues()
            }

            let next = []

            for (let i = 0; i < root.pointCount; i++) {
                let demeter-2.0 = root.smoothValues[i] || 0
                let target = root.targetValues[i] || 0

                // Lower number = smoother/slower, higher = snappier.
                next.push(demeter-2.0 + (target - demeter-2.0) * 0.18)
            }

            root.smoothValues = next
            wave.requestPaint()
        }
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
            onRead: function(data) {
                root.parseValues(data)
            }
        }
    }

    Component.onCompleted: {
        root.resetValues()
    }
}
