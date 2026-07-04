import QtQuick
import Quickshell
import "../common"

// Vertical left bar, one per screen. Transparent window; content sits in
// floating pills (taglist top, clock center, tray/battery/layout bottom).
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    // Awesome's view of this screen (tags, layout), matched by output name
    readonly property var awScreen: AwesomeState.forOutput(bar.screen.name)

    anchors {
        left: true
        top: true
        bottom: true
    }
    implicitWidth: Settings.barWidth
    color: "transparent"

    Item {
        anchors.fill: parent

        Pill {
            id: tagPill
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            visible: bar.awScreen !== null

            Workspaces {
                awScreen: bar.awScreen
            }
        }

        // Media section — only there when an MPRIS player exists.
        // Left-click: media panel; right-click: play/pause.
        Pill {
            id: mediaPill
            anchors.top: tagPill.visible ? tagPill.bottom : parent.top
            anchors.topMargin: tagPill.visible ? 6 : 8
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Media.active !== null
            padV: 5

            Item {
                width: 20
                height: 20

                Text {
                    anchors.centerIn: parent
                    text: Media.active && Media.active.isPlaying ? "⏸" : "▶"
                    font.pointSize: 10
                    color: Media.active && Media.active.isPlaying
                         ? Theme.accentBright : Theme.muted
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouseEvent => {
                        if (mouseEvent.button === Qt.RightButton) {
                            if (Media.active)
                                Media.active.togglePlaying();
                        } else {
                            Media.toggleOn(bar.screen.name);
                        }
                    }
                }
            }
        }

        Pill {
            anchors.centerIn: parent
            padH: 6

            ClockStack {}
        }

        Pill {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            padV: 6

            TrayColumn {
                barWindow: bar
            }

            Battery {}

            LayoutBox {
                screenIndex: bar.awScreen ? bar.awScreen.index : 1
                layoutName: bar.awScreen ? bar.awScreen.layout : ""
            }
        }
    }

    MediaPanel {
        barWindow: bar
        anchorItem: mediaPill
    }
}
