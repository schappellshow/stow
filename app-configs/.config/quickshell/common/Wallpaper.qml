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
        if (Settings.wallpaperPath !== "")
            Quickshell.execDetached(["feh", "--bg-fill", expand(Settings.wallpaperPath)]);
    }

    Connections {
        target: Settings
        function onWallpaperPathChanged() { root.apply(); }
    }

    Component.onCompleted: apply()
}
