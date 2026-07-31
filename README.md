# Dotfiles (OpenMandriva)

Shell, terminal and app configuration, organized as GNU Stow packages for
deployment across fresh OpenMandriva installations.

> **The desktop environment moved out.** AwesomeWM + Quickshell — the bar,
> notifications, Settings app, power menu, locking, theming — now live in
> their own repo:
> **[awesome-quickshell-de](https://github.com/schappellshow/awesome-quickshell-de)**.
> Install it from there; the two repos are independent and neither links to
> the other.

## Quick start (fresh machine)

```bash
git clone git@github.com:schappellshow/stow.git ~/stow   # or https
cd ~/stow && ./install-dotfiles.sh
```

`install-dotfiles.sh` installs the apps these configs are for (dnf), stows
`app-configs local pictures`, and enables the backup timer. It's
idempotent — re-run it after every pull.

## Stow packages

```
~/stow/
├── app-configs/     # ~/.config — kitty, ghostty, micro, espanso, fastfetch,
│                    #             systemd user units (backup-home)
├── local/           # ~/.local — update.sh, backup-home, .desktop entries
├── pictures/        # ~/Pictures — wallpapers, OM logos
├── shell/           # .bashrc, .zshrc, .bash_profile
├── zsh/             # Oh-My-Zsh customizations
├── conky/           # Conky widget themes (+ conky-startup.sh)
└── sddm-theme/      # SDDM Sugar Candy login theme (system-level, sudo)
```

`install-dotfiles.sh` stows `app-configs local pictures`. The rest are
opt-in:

```bash
cd ~/stow
stow shell zsh conky            # user-level extras
sudo stow -t / sddm-theme       # login theme, then set Current=sugar-candy
                                # in /etc/sddm.conf [Theme]
```

The `conky` package is also what the desktop repo's `Super+Shift+M` system
monitor pops out — that feature reads whatever conkyrc path you set in its
Settings app, so it's optional and requires no coupling between the repos.

## Managing packages

```bash
stow <package>       # install (symlink into $HOME)
stow -R <package>    # restow after changes
stow -D <package>    # remove
stow --simulate --verbose <package>   # dry run
```

Everything is symlinked, so edits in the repo are live immediately.

## Notes

- `docs/laptop-credentials-runbook.md` covers the laptop's
  Mailspring/SSH credential prompts.
- The backup timer (`backup-home.timer`) only does useful work where
  `/mnt/backup` exists; it no-ops with a notification otherwise, so it's
  safe to enable everywhere.
