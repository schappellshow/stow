pragma Singleton
import QtQuick
import Quickshell

// Screen blank/DPMS timeouts via xset (this is what triggers xss-lock's
// idle lock), plus a non-persisted keep-awake override. Owns the values
// that used to be hard-coded in awesome's autostart.
Singleton {
    id: root

    property bool keepAwake: false

    function init() { apply(); }

    function apply() {
        if (keepAwake) {
            Quickshell.execDetached(["sh", "-c", "xset s off; xset -dpms"]);
            return;
        }
        const b = Settings.blankMinutes * 60;
        const d = Settings.dpmsMinutes * 60;
        Quickshell.execDetached(["sh", "-c",
            (b > 0 ? "xset s " + b + " " + b : "xset s off") + "; " +
            (d > 0 ? "xset dpms 0 0 " + d : "xset -dpms")]);
    }

    onKeepAwakeChanged: apply()

    Connections {
        target: Settings
        function onBlankMinutesChanged() { debounce.restart(); }
        function onDpmsMinutesChanged() { debounce.restart(); }
    }

    Timer {
        id: debounce
        interval: 300
        onTriggered: root.apply()
    }
}
