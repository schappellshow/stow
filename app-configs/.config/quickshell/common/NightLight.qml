pragma Singleton
import QtQuick
import Quickshell

// Night light via gammastep in one-shot mode. State lives in Settings so the
// settings window, `qs ipc call nightlight toggle`, and restarts all agree.
Singleton {
    id: root

    function toggle() {
        Settings.nightLightEnabled = !Settings.nightLightEnabled;
    }

    function apply() {
        if (Settings.nightLightEnabled)
            Quickshell.execDetached(["gammastep", "-O", String(Settings.nightLightTemp), "-P"]);
        else
            Quickshell.execDetached(["gammastep", "-x"]);
    }

    Connections {
        target: Settings
        function onNightLightEnabledChanged() { root.apply(); }
        function onNightLightTempChanged() {
            if (Settings.nightLightEnabled)
                debounce.restart();
        }
    }

    // Don't hammer gammastep while the temperature slider is dragged
    Timer {
        id: debounce
        interval: 300
        onTriggered: root.apply()
    }

    Component.onCompleted: {
        if (Settings.nightLightEnabled)
            apply();
    }
}
