import QtQuick
import Quickshell
import "../common"

// NET indicator: wifi shows signal %, ethernet shows ETH, disconnected "--".
// Left-click: network popup. Right-click: nm-connection-editor.
Item {
    id: root

    property bool panelOpen: false

    visible: Settings.showNetwork
    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 1

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "NET"
            font.family: Theme.fontFamily
            font.bold: true
            font.pointSize: 7
            color: Theme.muted
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: !Network.connected ? "--"
                : Network.type === "ethernet" ? "ETH"
                : Network.signalStrength + "%"
            font.family: Theme.fontFamily
            font.pointSize: 9
            color: !Network.connected ? Theme.urgent
                 : Network.type === "wifi" && Network.signalStrength < 40
                     ? Theme.gold : Theme.subtext
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouseEvent => {
            if (mouseEvent.button === Qt.RightButton) {
                Quickshell.execDetached(["nm-connection-editor"]);
            } else {
                if (!root.panelOpen)
                    Network.refreshConnections();
                root.panelOpen = !root.panelOpen;
            }
        }
    }
}
