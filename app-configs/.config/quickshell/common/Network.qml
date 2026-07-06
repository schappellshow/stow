pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network state via nmcli polling (quickshell has no NetworkManager service
// on X11, so this shells out every 5s — cheap, and matches what the bar
// needs). Connection secrets and captive flows stay in nm-connection-editor.
Singleton {
    id: root

    property bool connected: false
    property string type: ""            // "ethernet" | "wifi" | ""
    property string connectionName: ""
    property string ssid: ""
    property int signalStrength: 0      // wifi only, 0-100
    property bool wifiEnabled: true

    // [{ name, ctype, active }] for the bar popup; refreshed on demand
    property var savedConnections: []

    function refresh() {
        statusProc.running = true;
        radioProc.running = true;
    }

    function refreshConnections() {
        consProc.running = true;
    }

    function toggleWifi() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]);
        wifiEnabled = !wifiEnabled;   // optimistic; settle re-reads the truth
        settle.restart();
    }

    function activate(name) {
        Quickshell.execDetached(["nmcli", "connection", "up", name]);
        settle.restart();
    }

    function deactivate(name) {
        Quickshell.execDetached(["nmcli", "connection", "down", name]);
        settle.restart();
    }

    Timer {
        id: settle
        interval: 1500
        onTriggered: {
            root.refresh();
            root.refreshConnections();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "dev", "status"]
        stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
    }

    function parseStatus(t) {
        // e.g. "wifi:connected:HomeNet" / "ethernet:connected:Wired connection 1"
        // (loopback reports "connected (externally)" and is skipped)
        let found = null;
        for (const line of t.split("\n")) {
            const parts = line.split(":");
            if (parts.length < 3 || parts[1] !== "connected")
                continue;
            if (parts[0] === "ethernet") {
                found = { type: "ethernet", name: parts.slice(2).join(":") };
                break;
            }
            if (parts[0] === "wifi" && !found)
                found = { type: "wifi", name: parts.slice(2).join(":") };
        }
        connected = found !== null;
        type = found ? found.type : "";
        connectionName = found ? found.name : "";
        if (type === "wifi") {
            wifiProc.running = true;
        } else {
            ssid = "";
            signalStrength = 0;
        }
    }

    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    if (!line.startsWith("*:"))
                        continue;
                    const parts = line.split(":");
                    root.ssid = parts.slice(1, -1).join(":");
                    root.signalStrength = parseInt(parts[parts.length - 1]) || 0;
                    return;
                }
            }
        }
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: consProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const parts = line.split(":");
                    if (parts.length < 3)
                        continue;
                    const ctype = parts[parts.length - 2];
                    const device = parts[parts.length - 1];
                    const name = parts.slice(0, -2).join(":");
                    if (ctype.includes("wireless"))
                        out.push({ name: name, ctype: "wifi", active: device !== "" });
                    else if (ctype.includes("ethernet"))
                        out.push({ name: name, ctype: "ethernet", active: device !== "" });
                }
                root.savedConnections = out;
            }
        }
    }
}
