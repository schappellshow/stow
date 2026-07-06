pragma Singleton
import QtQuick
import Quickshell

// Keyboard layout + repeat rate via setxkbmap/xset. Values live in
// Settings and are replayed at login (X doesn't persist them).
Singleton {
    id: root

    function init() { apply(); }

    function apply() {
        if (Settings.kbLayout !== "") {
            const parts = Settings.kbLayout.split(":");
            if (parts.length > 1)
                Quickshell.execDetached(["setxkbmap", parts[0], "-variant", parts[1]]);
            else
                Quickshell.execDetached(["setxkbmap", parts[0]]);
        }
        Quickshell.execDetached(["xset", "r", "rate",
            String(Settings.kbRepeatDelay), String(Settings.kbRepeatRate)]);
    }

    Connections {
        target: Settings
        function onKbLayoutChanged() { root.apply(); }
        function onKbRepeatDelayChanged() { debounce.restart(); }
        function onKbRepeatRateChanged() { debounce.restart(); }
    }

    // Sliders fire continuously while dragged
    Timer {
        id: debounce
        interval: 300
        onTriggered: root.apply()
    }
}
