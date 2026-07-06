import QtQuick
import Quickshell
import "../components"
import "../../common"

SettingsPage {
    id: page

    title: "Network"

    Component.onCompleted: Network.refreshConnections()

    SectionLabel { text: "STATUS" }

    InfoRow {
        label: "State"
        value: Network.connected
            ? "Connected (" + Network.type + ")" : "Disconnected"
    }

    InfoRow {
        visible: Network.type === "wifi"
        label: "Wi-Fi network"
        value: Network.ssid + "  (" + Network.signalStrength + "%)"
    }

    InfoRow {
        visible: Network.connected
        label: "Connection"
        value: Network.connectionName
    }

    ToggleRow {
        label: "Wi-Fi radio"
        checked: Network.wifiEnabled
        onToggled: Network.toggleWifi()
    }

    SectionLabel { text: "SAVED CONNECTIONS" }

    Repeater {
        model: Network.savedConnections

        Item {
            id: row

            required property var modelData

            width: parent.width
            height: 24

            Rectangle {
                width: 8
                height: 8
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: row.modelData.active ? Theme.green : Theme.surface
            }

            Text {
                x: 16
                width: parent.width - 70
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.name
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pointSize: 9
                color: row.modelData.active ? Theme.text : Theme.subtext
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.ctype
                font.family: Theme.fontFamily
                font.pointSize: 8
                color: Theme.muted
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (row.modelData.active)
                        Network.deactivate(row.modelData.name);
                    else
                        Network.activate(row.modelData.name);
                }
            }
        }
    }

    ButtonRow {
        label: "Add or edit connections (passwords, VPN, ...)"
        buttonText: "Editor…"
        onClicked: Quickshell.execDetached(["nm-connection-editor"])
    }
}
