import QtQuick
import Quickshell
import Quickshell.Io
import "./common"
import "./bar"
import "./notifications"
import "./settings"

ShellRoot {
    // Enforce the saved dark/light mode on every system channel at startup;
    // SystemTheme re-applies automatically whenever darkMode changes.
    Component.onCompleted: SystemTheme.apply()

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    NotificationPopups {}

    SettingsWindow {}

    // `qs ipc call nightlight toggle` — bound to Super+Shift+n in awesome
    IpcHandler {
        target: "nightlight"

        function toggle(): void {
            NightLight.toggle();
        }

        function temp(kelvin: int): void {
            Settings.nightLightTemp = kelvin;
        }
    }

    // `qs ipc call media toggle` — bound to Super+a in awesome
    IpcHandler {
        target: "media"

        function toggle(): void {
            Media.toggleFocused();
        }

        function playPause(): void {
            if (Media.active)
                Media.active.togglePlaying();
        }
    }

    // `qs ipc call theme toggle` — bound to Super+Shift+t in awesome
    IpcHandler {
        target: "theme"

        function toggle(): void {
            Settings.darkMode = !Settings.darkMode;
        }

        function dark(): void {
            Settings.darkMode = true;
        }

        function light(): void {
            Settings.darkMode = false;
        }
    }
}
