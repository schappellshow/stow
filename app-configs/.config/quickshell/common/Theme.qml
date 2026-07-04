pragma Singleton
import QtQuick
import Quickshell

// OpenMandriva palette (accents shared between modes; surfaces flip with
// Settings.darkMode). Dark values match the original awesome theme.lua.
Singleton {
    id: root

    readonly property bool isDark: Settings.darkMode

    // Surfaces / text
    readonly property color base:       isDark ? "#232627" : "#ecf2ff"
    readonly property color surface:    isDark ? "#444444" : "#d6dce8"
    readonly property color surfaceAlt: isDark ? "#333637" : "#e1e6f2"
    readonly property color text:       isDark ? "#ffffff" : "#232627"
    readonly property color subtext:    isDark ? "#afb3bd" : "#4a5158"
    readonly property color muted:      isDark ? "#767676" : "#8f96a3"

    // OM accents
    readonly property color red:        "#cc2263"
    readonly property color green:      "#40da76"
    readonly property color orange:     "#da7340"
    readonly property color blue:       "#2080bb"   // primary OM accent
    readonly property color purple:     "#a740da"
    readonly property color teal:       "#61c583"
    readonly property color gold:       "#dac040"
    readonly property color brightBlue: "#40a5da"   // secondary accent / focus

    readonly property color accent:       blue
    readonly property color accentBright: brightBlue
    readonly property color urgent:       red

    readonly property string fontFamily: "Hack"
    readonly property int radius: 10
}
