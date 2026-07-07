import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../common"

// Freedesktop notification daemon + popup stack (top-right), styled like the
// old naughty theme. Requires naughty's dbus module to be disabled in
// awesome's rc.lua so quickshell can own org.freedesktop.Notifications.
// Every notification is also copied into NotifHistory for the center panel;
// do-not-disturb suppresses popups but history still records.
Scope {
    id: root

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: notification => {
            notification.tracked = true;
            NotifHistory.add(notification);
        }
    }

    PanelWindow {
        id: win

        visible: server.trackedNotifications.values.length > 0
              && !Settings.doNotDisturb

        anchors {
            top: true
            right: true
        }
        margins {
            top: 12
            right: 12
        }
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 360
        implicitHeight: stack.implicitHeight
        color: "transparent"

        Column {
            id: stack
            width: parent.width
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card

                    required property var modelData

                    readonly property string iconSrc: NotifHistory.iconSource(
                        modelData.image || "", modelData.appIcon || "")
                    readonly property int textX: iconSrc !== "" ? 52 : 12

                    width: stack.width
                    implicitHeight: Math.max(
                        body.y + body.implicitHeight + 12,
                        iconSrc !== "" ? 56 : 0)
                    radius: Theme.radius
                    color: Theme.surface
                    border.color: card.modelData.urgency === NotificationUrgency.Critical
                        ? Theme.urgent : Theme.accentBright
                    border.width: 2
                    opacity: 0.95

                    Image {
                        x: 12
                        y: 12
                        width: 32
                        height: 32
                        visible: card.iconSrc !== ""
                        source: card.iconSrc
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        sourceSize.width: 64
                    }

                    Text {
                        id: appName
                        x: card.textX
                        y: 8
                        width: parent.width - card.textX - 12
                        text: card.modelData.appName || "notification"
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pointSize: 7
                        color: Theme.muted
                    }

                    Text {
                        id: summary
                        x: card.textX
                        y: appName.y + appName.implicitHeight + 2
                        width: parent.width - card.textX - 12
                        text: card.modelData.summary
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pointSize: 10
                        color: Theme.text
                    }

                    Text {
                        id: body
                        x: card.textX
                        y: summary.y + summary.implicitHeight + (text.length > 0 ? 4 : 0)
                        width: parent.width - card.textX - 12
                        visible: text.length > 0
                        text: card.modelData.body
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pointSize: 9
                        color: Theme.subtext
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }

                    Timer {
                        interval: card.modelData.expireTimeout > 0
                                ? card.modelData.expireTimeout
                                : Settings.notifTimeoutMs
                        running: true
                        onTriggered: card.modelData.expire()
                    }
                }
            }
        }
    }
}
