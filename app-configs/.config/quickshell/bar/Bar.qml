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

    // Tags are per-screen in awesome; with one bar we show every screen's
    // taglist, ordered to match the physical left→right arrangement.
    // Clicks/scrolls in a section drive THAT screen (the bridge commands
    // take a screen index).
    readonly property var tagSections: {
        const sections = [];
        for (const aws of AwesomeState.screens) {
            let x = 999999;
            let label = "?";
            let isHere = false;
            for (const out of (aws.outputs || [])) {
                for (const qs of Quickshell.screens)
                    if (qs.name === out)
                        x = Math.min(x, qs.x);
                if (out === bar.screen.name)
                    isHere = true;
                label = out.replace("DisplayPort-", "DP")
                           .replace("HDMI-A-", "HD");
            }
            sections.push({ aw: aws, x: x, label: label, isHere: isHere });
        }
        // This screen's full list first, then the other monitors'
        // compact sections in physical left→right order
        sections.sort((a, b) => (b.isHere - a.isHere) || (a.x - b.x));
        return sections;
    }

    anchors {
        left: true
        top: true
        bottom: true
    }
    implicitWidth: Settings.barWidth
    color: "transparent"

    // No strut: X11 struts can't reserve the left edge of a middle monitor.
    // Awesome pads the screen instead (modules/quickshell.lua
    // apply_bar_padding, re-pushed by common/BarSpace.qml on changes).
    exclusionMode: ExclusionMode.Ignore

    Item {
        anchors.fill: parent

        Pill {
            id: tagPill
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            visible: bar.tagSections.length > 0

            Repeater {
                model: bar.tagSections

                Column {
                    id: section

                    required property var modelData

                    spacing: 3

                    Text {
                        // Label only the OTHER monitors' compact sections;
                        // the full list is implicitly this screen
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: bar.tagSections.length > 1
                            && !section.modelData.isHere
                        text: section.modelData.label
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pointSize: 6
                        color: Theme.muted
                    }

                    Workspaces {
                        awScreen: section.modelData.aw
                        compact: !section.modelData.isHere
                    }
                }
            }
        }

        // Media section — only there when an MPRIS player exists.
        // Left-click: media panel; right-click: play/pause.
        Pill {
            id: mediaPill
            anchors.top: tagPill.visible ? tagPill.bottom : parent.top
            anchors.topMargin: tagPill.visible ? 6 : 8
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Media.active !== null && Settings.showMediaPill
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
            id: clockPill
            anchors.centerIn: parent
            padH: 6

            ClockStack {}
        }

        // Click the clock for the calendar (Pill routes children into its
        // column, so the MouseArea overlays it from outside)
        MouseArea {
            anchors.fill: clockPill
            onClicked: bar.calendarOpen = !bar.calendarOpen
        }

        Pill {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            padV: 6

            TrayColumn {
                barWindow: bar
                visible: Settings.showTray
            }

            NotifBell {}

            VolumeWidget { id: volumeWidget }

            NetworkWidget { id: networkWidget }

            BluetoothWidget { id: bluetoothWidget }

            SysMonWidget {}

            Battery {}

            LayoutBox {
                visible: Settings.showLayoutBox
                screenIndex: bar.awScreen ? bar.awScreen.index : 1
                layoutName: bar.awScreen ? bar.awScreen.layout : ""
            }
        }
    }

    property bool calendarOpen: false

    MediaPanel {
        barWindow: bar
        anchorItem: mediaPill
    }

    CalendarPopup {
        barWindow: bar
        anchorItem: clockPill
        shown: bar.calendarOpen
    }

    NetworkPanel {
        barWindow: bar
        anchorItem: networkWidget
        shown: networkWidget.panelOpen
        onDismiss: networkWidget.panelOpen = false
    }

    BluetoothPanel {
        barWindow: bar
        anchorItem: bluetoothWidget
        shown: bluetoothWidget.panelOpen
        onDismiss: bluetoothWidget.panelOpen = false
    }
}
