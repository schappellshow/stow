pragma Singleton
import QtQuick
import Quickshell

// Wallpaper via feh, driven by Settings.wallpaperPath (set from the
// Settings app's Wallpaper page). Replaces the old hard-coded feh line in
// awesome's autostart.
Singleton {
    id: root

    // Called from shell.qml's startup chain (singletons are lazy)
    function init() {}

    function expand(p) {
        return p.startsWith("~/") ? Quickshell.env("HOME") + p.slice(1) : p;
    }

    function apply() {
        if (Settings.wallpaperPath === "")
            return;
        const p = expand(Settings.wallpaperPath);
        Quickshell.execDetached(["feh", "--bg-fill", p]);
        // Rebuild the lock screen's blurred/dimmed cache to match
        // (betterlockscreen lives in ~/.local/bin; skip silently if absent)
        Quickshell.execDetached(["sh", "-c",
            "command -v betterlockscreen >/dev/null && " +
            "betterlockscreen -u '" + p + "' >/dev/null 2>&1 || true"]);
    }

    Connections {
        target: Settings
        function onWallpaperPathChanged() { root.apply(); }
    }

    Component.onCompleted: apply()
}
