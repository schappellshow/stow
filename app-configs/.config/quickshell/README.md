# Quickshell desktop shell (AwesomeWM + X11)

Quickshell provides the shell layer — bar, notifications, night light,
settings app — while AwesomeWM keeps window management: tags, tiling,
keybinds, rules.

## Layout

```
shell.qml                  root: bars per screen, notifications, settings, IPC
common/
  Theme.qml                OM palette; dark/light variants (dark default)
  Settings.qml             persistent settings (JSON in quickshell's state dir)
  AwesomeState.qml         watches awesome's state file; sends awesome-client cmds
  NightLight.qml           gammastep one-shot control
bar/                       vertical left bar (taglist / clock / tray+battery+layout)
notifications/             org.freedesktop.Notifications daemon + popups
settings/                  the settings window (Super+Shift+s)
```

## Awesome ↔ quickshell bridge

- `awesome/modules/quickshell.lua` writes tag/layout state per screen to
  `$XDG_RUNTIME_DIR/awesomewm-state.json` on every relevant signal.
- `common/AwesomeState.qml` watches that file and matches screens by output
  name (e.g. `eDP-1`); clicks call back via `awesome-client`.
- Awesome's naughty dbus module is stubbed out in `rc.lua` so quickshell can
  own `org.freedesktop.Notifications`; naughty still shows awesome's own
  startup/runtime errors.

## Install (OpenMandriva)

New machine: run `./install-desktop.sh` from the stow repo root — it
installs all packages (quickshell, picom, rofi, gammastep, portals, fonts,
...), stows the configs, fetches greenclip/rofimoji, and seeds the dark
theme. Minimal manual equivalent:

```sh
sudo dnf install quickshell quickshell-x11
```

## IPC

```sh
qs ipc call settings toggle      # Super+Shift+s
qs ipc call nightlight toggle    # Super+Shift+n
qs ipc call nightlight temp 2700
qs ipc call theme toggle         # Super+Shift+t (dark/light)
qs ipc call media toggle         # Super+a (media panel)
qs ipc call media playPause
```

## System-wide dark/light mode

`common/SystemTheme.qml` runs `~/.local/bin/system-theme-apply` (from the
`local` stow package) at shell startup and on every Super+Shift+t /
settings-app toggle. That script pushes the mode to every channel apps use
for the "system" theme: GSettings color-scheme/gtk-theme (read by the GTK
portal backend, which answers Electron apps like Slack — see
`.config/xdg-desktop-portal/portals.conf` for the routing), kdeglobals via
plasma-apply-colorscheme (Qt/KDE apps), and xsettingsd + gtk settings.ini
(GTK apps; files are created if missing, for fresh machines).

## Media player

`common/Media.qml` tracks MPRIS players (Spotify, browsers, mpv, ...). When
one exists, a play/pause section appears in the bar under the taglist:
left-click (or Super+a) opens a popup panel with album art, seekable
progress, and prev/play/next; right-click toggles play/pause directly.
Super+a asks awesome for the focused screen via `awesome-client`.

Settings persist to `~/.local/state/quickshell/by-shell/<id>/settings.json`,
not this repo. Quickshell hot-reloads when config files change.

## Testing outside awesome

The bar can be smoke-tested inside any X11 session (e.g. Plasma) with `qs`;
the taglist stays hidden until awesome writes its state file, and tray/menu
behavior may conflict with an existing shell.
