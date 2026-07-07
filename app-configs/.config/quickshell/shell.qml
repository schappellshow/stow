import QtQuick
import Quickshell
import Quickshell.Io
import "./common"
import "./bar"
import "./notifications"
import "./settings"
import "./power"
import "./osd"

ShellRoot {
    // Startup apply chain: settings.json is the source of truth, but X11
    // state (theme channels, wallpaper, xrandr, setxkbmap, xset, xinput)
    // doesn't persist across logins — re-apply everything, idempotently.
    // init() also forces the lazy singletons to life.
    Component.onCompleted: {
        SystemTheme.apply();
        Wallpaper.init();
        DisplayConfig.init();
        Keyboard.init();
        InputDevices.init();
        PowerConfig.init();
        PowerEvents.init();
        Autostart.init();
    }

    Variants {
        // One bar on Settings.barScreen; if it's unset or that output isn't
        // connected (laptop away from the dock), bars on every screen.
        model: {
            const match = Quickshell.screens.filter(
                s => s.name === Settings.barScreen);
            return match.length > 0 ? match : Quickshell.screens;
        }
        Bar {}
    }

    NotificationPopups {}

    NotificationCenter {}

    SettingsWindow {}

    // Session menu — `qs ipc call power toggle`, bound to Super+BackSpace
    PowerMenu {}

    // Volume/brightness pill, driven by the audio/brightness handlers below
    Osd { id: osd }

    // `qs ipc call audio raise|lower|muteToggle` — volume keys in awesome
    IpcHandler {
        target: "audio"

        function raise(): void {
            Audio.raise();
            osd.showVolume();
        }

        function lower(): void {
            Audio.lower();
            osd.showVolume();
        }

        function muteToggle(): void {
            Audio.toggleMute();
            osd.showVolume();
        }
    }

    // `qs ipc call notifs toggle` — Super+Shift+b in awesome
    IpcHandler {
        target: "notifs"

        function toggle(): void {
            NotifHistory.toggleCenter();
        }

        function close(): void {
            NotifHistory.centerOpen = false;
        }

        function clearAll(): void {
            NotifHistory.clear();
        }

        function dnd(): void {
            Settings.doNotDisturb = !Settings.doNotDisturb;
        }
    }

    // `qs ipc call brightness up|down` — XF86MonBrightness keys in awesome
    IpcHandler {
        target: "brightness"

        function up(): void {
            Brightness.up();
            osd.showBrightness();
        }

        function down(): void {
            Brightness.down();
            osd.showBrightness();
        }
    }

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
