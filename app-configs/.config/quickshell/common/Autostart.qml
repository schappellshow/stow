pragma Singleton
import QtQuick
import Quickshell

// User-managed autostart entries (Settings app → Autostart page).
// Stack-critical daemons (picom, greenclip, xss-lock, ...) stay in
// awesome's autostart.lua; this is for extras like conky.
Singleton {
    id: root

    function init() {
        const list = Settings.autostartExtra || [];
        for (const e of list) {
            if (!e || e.enabled !== true || !e.command)
                continue;
            // pgrep guard so a shell restart doesn't spawn duplicates
            const q = "'" + e.command.replace(/'/g, "'\\''") + "'";
            Quickshell.execDetached(["sh", "-c",
                "pgrep -u $USER -f " + q + " >/dev/null || (" +
                e.command + " >/dev/null 2>&1 &)"]);
        }
    }
}
