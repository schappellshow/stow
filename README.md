# OpenMandriva Desktop Environment + Dotfiles

A full desktop environment replacing KDE Plasma — **AwesomeWM** (X11, window
management) + **Quickshell** (bar, notifications, Settings app, power menu,
OSD) — plus dotfiles, all organized as GNU Stow packages for deployment
across fresh OpenMandriva installations.

## Quick start (fresh machine)

```bash
git clone git@github.com:schappellshow/stow.git ~/stow   # or https
cd ~/stow && ./install-desktop.sh
```

Then log out and pick the **awesome** session at the SDDM login screen.

`install-desktop.sh` installs every package the DE needs (dnf), builds the
few tools OMLx doesn't ship (gammastep, xss-lock, xsecurelock), stows the
config packages, and seeds the dark theme. It's idempotent — re-run it
after every pull.

## The desktop, in brief

| Piece | What / where |
|---|---|
| Window manager | AwesomeWM — `app-configs/.config/awesome/` (tags, tiling, keybinds, rules) |
| Shell layer | Quickshell — `app-configs/.config/quickshell/` (bar, widgets, notifications + history, Settings app, power menu, volume/brightness OSD, night light) |
| Settings app | Super+Shift+S — 14 pages, writes one settings.json, replayed at login |
| Locking | xss-lock → `lock-screen` wrapper (xsecurelock, i3lock-color fallback); Ctrl+Alt+L |
| Launcher | rofi (Super+Space) + greenclip clipboard + rofimoji |
| Compositor | picom · **Wallpaper**: feh, managed by Settings · **Screenshots**: flameshot (Print) |
| Theming | Breeze dark/light everywhere via `system-theme-apply` + `icon-theme-apply` |

Architecture details and every keybind/IPC command:
`app-configs/.config/quickshell/README.md`.

## Stow packages

```
~/stow/
├── app-configs/     # ~/.config — awesome, quickshell, picom, rofi, kitty, ghostty, ...
├── local/           # ~/.local — scripts (lock-screen, *-apply), .desktop entries
├── pictures/        # ~/Pictures — wallpapers, OM logos
├── shell/           # .bashrc, .zshrc
├── zsh/             # Oh-My-Zsh customizations
├── conky/           # Conky widget themes (+ conky-startup.sh)
└── sddm-theme/      # SDDM Sugar Candy login theme (system-level, sudo)
```

`install-desktop.sh` stows `app-configs local pictures`. The rest are
opt-in:

```bash
cd ~/stow
stow shell zsh conky            # user-level extras
sudo stow -t / sddm-theme       # login theme, then set Current=sugar-candy
                                # in /etc/sddm.conf [Theme]
```

## Managing packages

```bash
stow <package>       # install (symlink into $HOME)
stow -R <package>    # restow after changes
stow -D <package>    # remove
stow --simulate --verbose <package>   # dry run
```

Everything is symlinked, so edits in the repo are live immediately
(quickshell hot-reloads; awesome reloads with Super+Ctrl+R).

## Notes

- Shell/session state (settings.json) lives in `~/.local/state/quickshell/`,
  deliberately **outside** this repo, so runtime changes never dirty git.
- The Settings app is the intended way to change wallpaper, displays,
  keyboard, power, etc. — config files rarely need hand-editing.
- KDE-independence is a goal: the polkit agent is lxqt-policykit, and the
  remaining KDE ties (Breeze themes, portal-kde, plasma-apply-colorscheme)
  are isolated inside `system-theme-apply` for future replacement.
