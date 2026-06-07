import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as Theme

Item {
    id: root

    signal clicked()

    property string textValue: ""
    property bool hovered: mouseArea.containsMouse

    visible: textValue.length > 0

    implicitWidth: visible ? Math.min(210, Math.max(90, label.implicitWidth + 14)) : 0
    Layout.preferredWidth: implicitWidth
    Layout.minimumWidth: visible ? 90 : 0
    Layout.maximumWidth: 210

    height: 24

    Text {
        id: label
        anchors.centerIn: parent
        width: parent.width - 8
        text: root.textValue
        color: root.hovered ? Theme.Colors.textHover : Theme.Colors.text
        font.family: "Figtree"
        font.pixelSize: 12
        font.bold: root.hovered
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Process {
        id: mediaProc
        command: [
            "sh",
            "-c",
            "p=$(playerctl -l 2>/dev/null | head -n1); [ -z \"$p\" ] && exit 0; s=$(playerctl -p \"$p\" status 2>/dev/null || true); [ \"$s\" = Stopped ] && exit 0; a=$(playerctl -p \"$p\" metadata artist 2>/dev/null || true); t=$(playerctl -p \"$p\" metadata title 2>/dev/null || true); out=\"$a — $t\"; out=${out:0:48}; [ -n \"$out\" ] && echo \"󰓇 $out\""
        ]
        running: true

        stdout: SplitParser {
            onRead: data => root.textValue = data.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: mediaProc.running = true
    }
}
