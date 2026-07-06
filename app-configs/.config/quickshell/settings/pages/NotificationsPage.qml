import QtQuick
import "../components"
import "../../common"

SettingsPage {
    title: "Notifications"

    SectionLabel { text: "POPUPS" }

    ToggleRow {
        label: "Do not disturb"
        checked: Settings.doNotDisturb
        onToggled: value => Settings.doNotDisturb = value
    }

    SliderRow {
        label: "Popup timeout"
        from: 2
        to: 15
        step: 1
        suffix: "s"
        value: Settings.notifTimeoutMs / 1000
        onMoved: value => Settings.notifTimeoutMs = value * 1000
    }

    Text {
        width: parent.width
        text: "Apps can request their own timeout; this is the default when "
            + "they don't. Do-not-disturb hides popups entirely."
        wrapMode: Text.Wrap
        font.family: Theme.fontFamily
        font.pointSize: 8
        color: Theme.muted
    }
}
