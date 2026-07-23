import QtQuick
import Quickshell
import "../components"
import "../../common"

SettingsPage {
    id: page

    title: "Network"

    // SSID awaiting a password (secured network the user just tapped)
    property string pendingSsid: ""

    Component.onCompleted: {
        Network.refreshConnections();
        Network.scan();
    }

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

    SectionLabel { text: "NEARBY NETWORKS" }

    ButtonRow {
        label: Network.scanning ? "Scanning…"
            : Network.wifiNetworks.length + " networks found"
        buttonText: Network.scanning ? "…" : "Scan"
        onClicked: Network.scan()
    }

    Repeater {
        model: Network.wifiNetworks

        Item {
            id: netRow

            required property var modelData

            width: parent.width
            height: 26

            Rectangle {
                width: 8
                height: 8
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: netRow.modelData.active ? Theme.green : Theme.surface
            }

            Text {
                x: 16
                width: parent.width - 100
                anchors.verticalCenter: parent.verticalCenter
                text: netRow.modelData.ssid
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pointSize: 9
                color: netRow.modelData.active ? Theme.text : Theme.subtext
            }

            // lock glyph for secured networks (nf-fa-lock)
            Text {
                anchors.right: sig.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                visible: netRow.modelData.secured
                text: String.fromCodePoint(0xf023)
                font.family: Theme.iconFont
                font.pointSize: 8
                color: Theme.muted
            }

            Text {
                id: sig
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: netRow.modelData.signal + "%"
                font.family: Theme.fontFamily
                font.pointSize: 8
                color: Theme.muted
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (netRow.modelData.active)
                        return;
                    // open or already-saved → connect straight away;
                    // secured & unknown → ask for a password
                    if (!netRow.modelData.secured || netRow.modelData.known) {
                        Network.connectWifi(netRow.modelData.ssid, "");
                        page.pendingSsid = "";
                    } else {
                        page.pendingSsid = netRow.modelData.ssid;
                    }
                }
            }
        }
    }

    TextFieldRow {
        visible: page.pendingSsid !== ""
        label: "Password for " + page.pendingSsid
        placeholder: "Enter password, then press Enter"
        onAccepted: value => {
            Network.connectWifi(page.pendingSsid, value);
            page.pendingSsid = "";
        }
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
