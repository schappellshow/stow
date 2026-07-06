import QtQuick
import "../components"
import "../../common"

SettingsPage {
    title: "Night Light"

    SectionLabel { text: "GAMMASTEP" }

    ToggleRow {
        label: "Enabled"
        checked: Settings.nightLightEnabled
        onToggled: value => Settings.nightLightEnabled = value
    }

    SliderRow {
        label: "Temperature"
        from: 1500
        to: 4500
        step: 100
        suffix: "K"
        value: Settings.nightLightTemp
        onMoved: value => Settings.nightLightTemp = value
    }

    Text {
        width: parent.width
        text: "Also on Super+Shift+N. Lower temperature = warmer screen."
        wrapMode: Text.Wrap
        font.family: Theme.fontFamily
        font.pointSize: 8
        color: Theme.muted
    }
}
