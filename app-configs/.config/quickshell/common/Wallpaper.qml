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
        // feh assigns one image per monitor, so a single path stretches
        // across the whole X screen on a multi-head setup. Repeat it once
        // per screen to fill each monitor individually (a 1-screen laptop
        // is unaffected — it just gets the single argument as before).
        const args = ["feh", "--bg-fill"];
        for (let i = 0; i < Math.max(1, Quickshell.screens.length); i++)
            args.push(p);
        Quickshell.execDetached(args);
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
