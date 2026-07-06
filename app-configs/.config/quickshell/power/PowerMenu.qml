import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Full-screen session menu on every screen, toggled with
// `qs ipc call power toggle` (Super+BackSpace).
// Mouse: click a button, or click anywhere else to dismiss.
// Keyboard: Left/Right + Enter, Escape dismisses (needs focus; see focusable).
Scope {
    id: root

    property bool shown: false
    property int selected: 0

    readonly property var actions: [
        { label: "Lock",      color: Theme.blue,   cmd: ["loginctl", "lock-session"] },
        { label: "Log Out",   color: Theme.teal,   cmd: ["awesome-client", "awesome.quit()"] },
        { label: "Suspend",   color: Theme.gold,   cmd: ["systemctl", "suspend"] },
        { label: "Restart",   color: Theme.orange, cmd: ["systemctl", "reboot"] },
        { label: "Shut Down", color: Theme.red,    cmd: ["systemctl", "poweroff"] }
    ]

    function activate(index) {
        const cmd = actions[index].cmd;
        shown = false;
        Quickshell.execDetached(cmd);
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            root.selected = 0;
            root.shown = !root.shown;
        }

        function open(): void {
            root.selected = 0;
            root.shown = true;
        }

        function close(): void {
            root.shown = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData

            screen: modelData
            visible: root.shown
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            focusable: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.65)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.shown = false
                }

                Item {
                    anchors.fill: parent
                    focus: true

                    Keys.onEscapePressed: root.shown = false
                    Keys.onLeftPressed: root.selected =
                        (root.selected + root.actions.length - 1) % root.actions.length
                    Keys.onRightPressed: root.selected =
                        (root.selected + 1) % root.actions.length
                    Keys.onReturnPressed: root.activate(root.selected)
                    Keys.onEnterPressed: root.activate(root.selected)

                    Row {
                        anchors.centerIn: parent
                        spacing: 24

                        Repeater {
                            model: root.actions

                            Column {
                                id: entry

                                required property var modelData
                                required property int index

                                readonly property bool current: root.selected === index

                                spacing: 10

                                Rectangle {
                                    width: 96
                                    height: 96
                                    radius: Theme.radius
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: hover.hovered || entry.current
                                        ? entry.modelData.color : Theme.surfaceAlt
                                    border.width: entry.current ? 2 : 0
                                    border.color: Theme.text

                                    Behavior on color {
                                        ColorAnimation { duration: 100 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: entry.modelData.label.charAt(0)
                                        font.family: Theme.fontFamily
                                        font.bold: true
                                        font.pointSize: 30
                                        color: Theme.text
                                    }

                                    HoverHandler { id: hover }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.activate(entry.index)
                                    }
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: entry.modelData.label
                                    font.family: Theme.fontFamily
                                    font.pointSize: 11
                                    color: Theme.text
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
