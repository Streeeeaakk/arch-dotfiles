import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

Rectangle {
    id: root

    property date now: new Date()
    property int year: now.getFullYear()
    property int month: now.getMonth()
    property int today: now.getDate()

    width: 300
    height: 260
    radius: 16

    color: Theme.Colors.barBg
    border.color: Theme.Colors.accent
    border.width: 1
    clip: true

    function monthName(m) {
        return [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ][m]
    }

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    function firstDayOffset(y, m) {
        // Monday-first calendar
        let sundayBased = new Date(y, m, 1).getDay()
        return (sundayBased + 6) % 7
    }

    function dayFor(index) {
        let offset = firstDayOffset(root.year, root.month)
        let day = index - offset + 1
        let max = daysInMonth(root.year, root.month)

        if (day < 1 || day > max) return 0
        return day
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 13
        color: "transparent"
        border.color: Theme.Colors.accent
        border.width: 1
        opacity: 0.22
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: Qt.formatDateTime(root.now, "dddd, MMMM d")
                color: Theme.Colors.textHover
                font.family: "Figtree"
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: Qt.formatDateTime(root.now, "h:mm:ss AP")
                color: Theme.Colors.accent
                font.family: "Figtree"
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.Colors.accent
            opacity: 0.35
        }

        Text {
            text: root.monthName(root.month) + " " + root.year
            color: Theme.Colors.text
            font.family: "Figtree"
            font.pixelSize: 13
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        GridLayout {
            Layout.alignment: Qt.AlignHCenter
            columns: 7
            rowSpacing: 5
            columnSpacing: 5

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                Text {
                    text: modelData
                    color: Theme.Colors.muted
                    font.family: "Figtree"
                    font.pixelSize: 10
                    font.bold: true
                    Layout.preferredWidth: 25
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Repeater {
                model: 42

                Item {
                    id: dayCell

                    property int dayNumber: root.dayFor(index)
                    property bool isToday: dayNumber === root.today

                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 20

                    Rectangle {
                        anchors.centerIn: parent
                        width: dayCell.isToday ? 22 : 20
                        height: dayCell.isToday ? 20 : 18
                        radius: 7
                        visible: dayCell.dayNumber > 0
                        color: dayCell.isToday ? Theme.Colors.accent : "transparent"
                        opacity: dayCell.isToday ? 0.95 : 1

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.color: Theme.Colors.accent
                            border.width: 1
                            visible: dayCell.isToday
                            opacity: 0.75
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: dayCell.dayNumber > 0 ? String(dayCell.dayNumber) : ""
                        color: dayCell.isToday ? Theme.Colors.accentText : Theme.Colors.text
                        font.family: "Figtree"
                        font.pixelSize: 11
                        font.bold: dayCell.isToday
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.now = new Date()
        }
    }
}
