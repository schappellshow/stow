#!/usr/bin/env bash
# Bootstrap the dotfiles on OpenMandriva Lx: shell, terminals, editors and
# the small local scripts.
#
# Usage, on a fresh machine:
#   git clone git@github.com:schappellshow/stow.git ~/stow   # or https
#   cd ~/stow && ./install-dotfiles.sh
#
# The desktop environment (AwesomeWM + Quickshell) is NOT installed here —
# it lives in its own repo and has its own installer:
#   https://github.com/schappellshow/awesome-quickshell-de
#
# Idempotent: safe to re-run after a repo pull.
set -euo pipefail
cd "$(dirname "$0")"

info() { printf '\n==> %s\n' "$*"; }

if ! command -v dnf >/dev/null; then
    echo "This script targets OpenMandriva (dnf). Install packages manually elsewhere." >&2
    exit 1
fi

info "Installing packages"
sudo dnf install --allowerasing -y \
    ghostty kitty micro \
    conky \
    borgbackup bup \
    fonts-ttf-hack noto-sans-fonts fonts-ttf-nerd-jetbrains-mono \
    stow git curl

info "Stowing config packages (app-configs, local, pictures)"
# --adopt is intentionally NOT used: a conflict means a real file is in the
# way; inspect and remove it, then re-run.
stow -R app-configs local pictures

info "Directories"
mkdir -p "$HOME/Pictures/Screenshots"

info "systemd user units (backup-home.timer)"
systemctl --user daemon-reload || true
# Backup timer only fires usefully where /mnt/backup exists (the script
# no-ops with a notification otherwise) — safe to enable everywhere
systemctl --user enable backup-home.timer 2>/dev/null || true

info "Done"
cat <<'EOF'
Next steps:
  * Other stow packages are not stowed by this script; stow them
    individually if wanted:  stow -R shell zsh conky
    SDDM login theme (system-level):  sudo stow -t / sddm-theme
  * For the desktop environment (AwesomeWM + Quickshell), clone and run:
    https://github.com/schappellshow/awesome-quickshell-de
EOF
