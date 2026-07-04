pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Persistent shell settings. Stored outside the stow repo in quickshell's
// per-shell state dir (~/.local/state/quickshell/by-shell/...) so runtime
// changes never dirty the config repo.
Singleton {
    id: root

    property alias darkMode: adapter.darkMode
    property alias nightLightEnabled: adapter.nightLightEnabled
    property alias nightLightTemp: adapter.nightLightTemp
    property alias barWidth: adapter.barWidth

    readonly property string path: Quickshell.statePath("settings.json")

    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property bool darkMode: true
            property bool nightLightEnabled: false
            property int nightLightTemp: 3000
            property int barWidth: 36
        }
    }
}
