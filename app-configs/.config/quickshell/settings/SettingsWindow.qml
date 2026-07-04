import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// The "Settings app": a normal floating window (awesome rules float it),
// toggled with `qs ipc call settings toggle` (Super+Shift+s).
FloatingWindow {
    id: win

    title: "Shell Settings"
    visible: false
    implicitWidth: 420
    implicitHeight: 480
    color: Theme.base

    IpcHandler {
        target: "settings"

        function toggle(): void {
            win.visible = !win.visible;
        }

        function open(): void {
            win.visible = true;
        }

        function close(): void {
            win.visible = false;
        }
    }

    component SectionLabel: Text {
        font.family: Theme.fontFamily
        font.bold: true
        font.pointSize: 8
        font.letterSpacing: 1.5
        color: Theme.accentBright
    }

    component ToggleRow: Item {
        property string label
        property bool checked
        signal toggled(bool value)

        width: parent.width
        height: 28

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            font.family: Theme.fontFamily
            font.pointSize: 10
            color: Theme.text
        }

        Rectangle {
            id: track
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 24
            radius: 12
            color: parent.checked ? Theme.accent : Theme.surface

            Rectangle {
                width: 18
                height: 18
                radius: 9
                y: 3
                x: track.parent.checked ? track.width - width - 3 : 3
                color: Theme.text
                Behavior on x {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.toggled(!parent.checked)
        }
    }

    component SliderRow: Column {
        id: sliderRow

        property string label
        property real from: 0
        property real to: 100
        property real step: 1
        property real value
        property string suffix: ""

        signal moved(real value)

        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: labelText.implicitHeight

            Text {
                id: labelText
                text: sliderRow.label
                font.family: Theme.fontFamily
                font.pointSize: 10
                color: Theme.text
            }

            Text {
                anchors.right: parent.right
                text: sliderRow.value + sliderRow.suffix
                font.family: Theme.fontFamily
                font.pointSize: 10
                color: Theme.subtext
            }
        }

        Item {
            width: parent.width
            height: 20

            readonly property real ratio:
                (sliderRow.value - sliderRow.from) / (sliderRow.to - sliderRow.from)

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: Theme.surface
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.ratio * parent.width
                height: 4
                radius: 2
                color: Theme.accent
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: parent.ratio * (parent.width - width)
                width: 14
                height: 14
                radius: 7
                color: Theme.accentBright
            }

            MouseArea {
                anchors.fill: parent
                function update(mouseX) {
                    let r = Math.max(0, Math.min(1, mouseX / width));
                    let v = sliderRow.from + r * (sliderRow.to - sliderRow.from);
                    v = Math.round(v / sliderRow.step) * sliderRow.step;
                    sliderRow.moved(v);
                }
                onPressed: mouseEvent => update(mouseEvent.x)
                onPositionChanged: mouseEvent => {
                    if (pressed)
                        update(mouseEvent.x);
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Text {
            text: "Shell Settings"
            font.family: Theme.fontFamily
            font.bold: true
            font.pointSize: 14
            color: Theme.text
        }

        Rectangle { width: parent.width; height: 1; color: Theme.surface }

        SectionLabel { text: "APPEARANCE" }

        ToggleRow {
            label: "Dark mode"
            checked: Settings.darkMode
            onToggled: value => Settings.darkMode = value
        }

        SectionLabel { text: "NIGHT LIGHT" }

        ToggleRow {
            label: "Enabled"
            checked: Settings.nightLightEnabled
            onToggled: value => Settings.nightLightEnabled = value
        }

        SliderRow {
            label: "Temperature"
            from: 1500
            to: 4500
            step: 100
            suffix: "K"
            value: Settings.nightLightTemp
            onMoved: value => Settings.nightLightTemp = value
        }

        SectionLabel { text: "BAR" }

        SliderRow {
            label: "Bar width"
            from: 28
            to: 48
            step: 2
            suffix: "px"
            value: Settings.barWidth
            onMoved: value => Settings.barWidth = value
        }

        Item { width: 1; height: 6 }

        Text {
            width: parent.width
            text: "Settings persist to " + Settings.path
            wrapMode: Text.Wrap
            font.family: Theme.fontFamily
            font.pointSize: 7
            color: Theme.muted
        }
    }
}
