import QtQuick
import "../common"

// Awesome taglist. Left-click: view tag; right-click: toggle tag into view;
// scroll: next/prev tag — same bindings as the old wibar taglist.
Column {
    id: root

    property var awScreen

    spacing: 4

    Repeater {
        model: root.awScreen ? root.awScreen.tags : []

        delegate: Rectangle {
            id: tagPill

            required property var modelData

            width: 22
            height: 26
            radius: width / 2
            color: modelData.urgent   ? Theme.urgent
                 : modelData.selected ? Theme.accent
                 : modelData.occupied ? Theme.surface
                 : "transparent"

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.accent
                opacity: mouse.containsMouse && !tagPill.modelData.selected ? 0.33 : 0
            }

            Text {
                anchors.centerIn: parent
                text: tagPill.modelData.name
                font.family: Theme.fontFamily
                font.bold: true
                font.pointSize: 9
                color: tagPill.modelData.urgent   ? Theme.text
                     : tagPill.modelData.selected ? Theme.text
                     : tagPill.modelData.occupied ? Theme.subtext
                     : Theme.muted
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouseEvent => {
                    if (mouseEvent.button === Qt.RightButton)
                        AwesomeState.toggleTag(root.awScreen.index, tagPill.modelData.index);
                    else
                        AwesomeState.viewTag(root.awScreen.index, tagPill.modelData.index);
                }
                onWheel: wheelEvent => {
                    if (wheelEvent.angleDelta.y > 0)
                        AwesomeState.viewNext(root.awScreen.index);
                    else
                        AwesomeState.viewPrev(root.awScreen.index);
                }
            }
        }
    }
}
