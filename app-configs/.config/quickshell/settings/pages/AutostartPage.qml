import QtQuick
import "../components"
import "../../common"

// Extra user autostart commands, spawned by the shell at startup with a
// pgrep guard. Core daemons stay in awesome's autostart.lua.
SettingsPage {
    id: page

    title: "Autostart"

    function entries() {
        return Settings.autostartExtra || [];
    }

    function setEntries(list) {
        Settings.autostartExtra = list;
    }

    SectionLabel { text: "EXTRA COMMANDS" }

    Text {
        visible: page.entries().length === 0
        text: "Nothing here yet — add a command below."
        font.family: Theme.fontFamily
        font.pointSize: 9
        color: Theme.muted
    }

    Repeater {
        model: Settings.autostartExtra

        Item {
            id: row

            required property var modelData
            required property int index

            width: parent.width
            height: 28

            Rectangle {
                id: enableBox
                width: 18
                height: 18
                radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color: row.modelData.enabled ? Theme.accent : Theme.surface

                Text {
                    anchors.centerIn: parent
                    visible: row.modelData.enabled
                    text: "✓"
                    font.pointSize: 9
                    color: Theme.text
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const list = page.entries().map((e, i) => i === row.index
                            ? { command: e.command, enabled: !e.enabled } : e);
                        page.setEntries(list);
                    }
                }
            }

            Text {
                x: 28
                width: parent.width - 28 - 30
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.command
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pointSize: 9
                color: row.modelData.enabled ? Theme.text : Theme.muted
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "✕"
                font.pointSize: 10
                color: removeHover.hovered ? Theme.urgent : Theme.muted

                HoverHandler { id: removeHover }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: page.setEntries(
                        page.entries().filter((e, i) => i !== row.index))
                }
            }
        }
    }

    TextFieldRow {
        label: "Add command (Enter to add — runs at every login)"
        placeholder: "e.g. ~/.conky/conky-startup.sh"
        onAccepted: value => {
            if (value.trim() === "")
                return;
            page.setEntries(page.entries().concat(
                [{ command: value.trim(), enabled: true }]));
        }
    }

    Text {
        width: parent.width
        text: "New/re-enabled entries start at the next login or shell "
            + "restart; disabling doesn't kill a running process."
        wrapMode: Text.Wrap
        font.family: Theme.fontFamily
        font.pointSize: 8
        color: Theme.muted
    }
}
