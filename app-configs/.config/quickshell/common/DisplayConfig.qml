pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// xrandr wrapper: probes connected outputs/modes for the Displays page and
// replays the saved layout (Settings.displayCmd) at login — xrandr state
// doesn't persist on its own.
Singleton {
    id: root

    // [{ name, primary, x, y, rotation, currentMode, modes: [string] }]
    property var outputs: []

    function init() {
        if (Settings.displayCmd !== "")
            Quickshell.execDetached(["sh", "-c", "xrandr " + Settings.displayCmd]);
    }

    function probe() {
        xrandrProc.running = true;
    }

    // profile: { outputName: { mode, primary, rotate } }, missing entries
    // keep current
    function apply(profile) {
        const args = [];
        for (const o of outputs) {
            const p = profile[o.name] || {};
            args.push("--output", o.name,
                "--mode", p.mode || o.currentMode,
                "--pos", o.x + "x" + o.y,
                "--rotate", p.rotate || o.rotation);
            if (p.primary === true || (p.primary === undefined && o.primary))
                args.push("--primary");
        }
        const cmd = args.join(" ");
        Quickshell.execDetached(["sh", "-c", "xrandr " + cmd]);
        Settings.displayCmd = cmd;
        reprobe.restart();
    }

    Timer {
        id: reprobe
        interval: 2000
        onTriggered: root.probe()
    }

    Process {
        id: xrandrProc
        command: ["xrandr", "--query"]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }

    function parse(t) {
        const outs = [];
        let cur = null;
        for (const line of t.split("\n")) {
            // "DisplayPort-2 connected primary 1920x1080+1080+0 (normal ...)"
            // Rotated outputs carry the rotation before the paren list:
            // "HDMI-A-0 connected 1080x1920+0+0 left (normal left ...)"
            let m = line.match(/^(\S+) (connected|disconnected)( primary)?( (\d+)x(\d+)\+(\d+)\+(\d+))?( (left|right|inverted))?/);
            if (m) {
                cur = null;
                if (m[2] === "connected") {
                    cur = {
                        name: m[1],
                        primary: !!m[3],
                        x: m[7] !== undefined ? parseInt(m[7]) : 0,
                        y: m[8] !== undefined ? parseInt(m[8]) : 0,
                        rotation: m[10] || "normal",
                        currentMode: "",
                        modes: []
                    };
                    outs.push(cur);
                }
                continue;
            }
            // "   1920x1080     60.00*+  59.94"
            m = line.match(/^\s+(\d+x\d+i?)\s+(.*)/);
            if (m && cur) {
                if (!cur.modes.includes(m[1]))
                    cur.modes.push(m[1]);
                if (m[2].includes("*"))
                    cur.currentMode = m[1];
            }
        }
        outputs = outs;
    }
}
