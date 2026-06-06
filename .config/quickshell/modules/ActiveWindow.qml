import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Rectangle {
    id: root

    signal clicked()

    property string appClass: ""
    property bool showCava: false
    property bool hovered: mouseArea.containsMouse

    property int pointCount: 28
    property var targetValues: []
    property var smoothValues: []

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

            let v = raw / 100.0
            v = Math.pow(v, 0.72)
            target.push(v)
        }

        root.targetValues = target
    }

    function appIcon(cls) {
        let c = cls.toLowerCase()

        if (c.includes("brave")) return ""
        if (c.includes("chrome")) return ""
        if (c.includes("firefox")) return ""
        if (c.includes("zen")) return "󰖟"
        if (c.includes("kitty")) return ""
        if (c.includes("alacritty")) return ""
        if (c.includes("wezterm")) return ""
        if (c.includes("code")) return "󰨞"
        if (c.includes("spotify")) return ""
        if (c.includes("dolphin")) return "󰉋"
        if (c.includes("thunar")) return "Thunar"
        if (c.includes("discord")) return ""
        if (c.includes("vesktop")) return ""
        if (c.includes("caprine")) return "󰈎"
        if (c.includes("telegram")) return ""
        if (c.includes("obsidian")) return "󱓧"
        if (c.includes("steam")) return ""
        if (c.includes("libreoffice")) return "󰈙"
        if (c.includes("vlc")) return "󰕼"
        if (c.includes("gimp")) return ""
        if (c.includes("sublime")) return ""

        return "󰣆"
    }

    function appName(cls) {
        let c = cls.toLowerCase()

        if (c.includes("brave")) return "Brave"
        if (c.includes("chrome")) return "Chrome"
        if (c.includes("firefox")) return "Firefox"
        if (c.includes("zen")) return "Zen"
        if (c.includes("kitty")) return "Kitty"
        if (c.includes("alacritty")) return "Alacritty"
        if (c.includes("wezterm")) return "WezTerm"
        if (c.includes("code")) return "Code"
        if (c.includes("spotify")) return "Spotify"
        if (c.includes("dolphin")) return "Dolphin"
        if (c.includes("thunar")) return "Thunar"
        if (c.includes("discord")) return "Discord"
        if (c.includes("vesktop")) return "Vesktop"
        if (c.includes("caprine")) return "Caprine"
        if (c.includes("telegram")) return "Telegram"
        if (c.includes("obsidian")) return "Obsidian"
        if (c.includes("steam")) return "Steam"
        if (c.includes("libreoffice")) return "LibreOffice"
        if (c.includes("vlc")) return "VLC"
        if (c.includes("gimp")) return "GIMP"
        if (c.includes("sublime")) return "Sublime"

        return cls.length > 0 ? cls : "Desktop"
    }

    implicitWidth: 138
    Layout.preferredWidth: 138
    Layout.minimumWidth: 138
    Layout.maximumWidth: 138

    height: 24
    radius: 10
    color: root.hovered ? Theme.Colors.activeHover : Theme.Colors.activeBg
    clip: true

    Canvas {
        id: miniWave

        visible: root.showCava
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
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
            let amp = (h - 7) / 2
            let step = w / (root.pointCount - 1)

            ctx.globalAlpha = 0.75
            ctx.fillStyle = Theme.Colors.accent

            ctx.beginPath()

            for (let i = 0; i < root.pointCount; i++) {
                let x = i * step
                let y = mid - root.smoothValues[i] * amp

                if (i === 0) {
                    ctx.moveTo(x, y)
                } else {
                    let px = (i - 1) * step
                    let py = mid - root.smoothValues[i - 1] * amp
                    let cx = (px + x) / 2
                    let cy = (py + y) / 2
                    ctx.quadraticCurveTo(px, py, cx, cy)
                }
            }

            for (let j = root.pointCount - 1; j >= 0; j--) {
                let x2 = j * step
                let y2 = mid + root.smoothValues[j] * amp

                if (j === root.pointCount - 1) {
                    ctx.lineTo(x2, y2)
                } else {
                    let nx = (j + 1) * step
                    let ny = mid + root.smoothValues[j + 1] * amp
                    let cx2 = (nx + x2) / 2
                    let cy2 = (ny + y2) / 2
                    ctx.quadraticCurveTo(nx, ny, cx2, cy2)
                }
            }

            ctx.closePath()
            ctx.fill()

            ctx.globalAlpha = 0.95
            ctx.strokeStyle = Theme.Colors.text
            ctx.lineWidth = 1

            ctx.beginPath()

            for (let k = 0; k < root.pointCount; k++) {
                let lx = k * step
                let ly = mid - root.smoothValues[k] * amp

                if (k === 0) {
                    ctx.moveTo(lx, ly)
                } else {
                    let pxx = (k - 1) * step
                    let pyy = mid - root.smoothValues[k - 1] * amp
                    let mcx = (pxx + lx) / 2
                    let mcy = (pyy + ly) / 2
                    ctx.quadraticCurveTo(pxx, pyy, mcx, mcy)
                }
            }

            ctx.stroke()
            ctx.globalAlpha = 1
        }
    }

    RowLayout {
        visible: !root.showCava
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.appIcon(root.appClass)
            color: Theme.Colors.text
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.appName(root.appClass)
            color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }
    }

    Timer {
        interval: 16
        running: root.showCava
        repeat: true

        onTriggered: {
            if (root.smoothValues.length < root.pointCount || root.targetValues.length < root.pointCount) {
                root.resetValues()
            }

            let next = []

            for (let i = 0; i < root.pointCount; i++) {
                let current = root.smoothValues[i] || 0
                let target = root.targetValues[i] || 0

                next.push(current + (target - current) * 0.18)
            }

            root.smoothValues = next
            miniWave.requestPaint()
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
        id: titleProc

        command: [
            "sh",
            "-c",
            "hyprctl activewindow -j 2>/dev/null | jq -r '.class // \"Desktop\"'"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => root.appClass = data.trim()
        }
    }

    Process {
        id: cavaProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/cava-small-wave.sh"]
        running: root.showCava

        stdout: SplitParser {
            onRead: function(data) {
                root.parseValues(data)
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: titleProc.running = true
    }

    Component.onCompleted: {
        root.resetValues()
    }
}
