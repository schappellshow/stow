#!/usr/bin/env bash
# Bootstrap the Awesome + Quickshell desktop environment on OpenMandriva Lx.
#
# Usage, on a fresh machine:
#   git clone git@github.com:schappellshow/stow.git ~/stow   # or https
#   cd ~/stow && ./install-desktop.sh
#
# Then pick the "awesome" session at the SDDM login screen.
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
    awesome quickshell quickshell-x11 \
    picom rofi rofi-themes \
    gammastep xsettingsd feh scrot playerctl \
    xdg-desktop-portal xdg-desktop-portal-gtk plasma-workspace \
    ghostty micro \
    fonts-ttf-hack noto-sans-fonts \
    stow git curl

info "Stowing config packages (app-configs, local, pictures)"
# --adopt is intentionally NOT used: a conflict means a real file is in the
# way; inspect and remove it, then re-run.
stow -R app-configs local pictures

info "greenclip (clipboard daemon; static binary, not packaged for OMLx)"
if ! command -v greenclip >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    url=$(curl -fsSL https://api.github.com/repos/erebe/greenclip/releases/latest \
        | grep -o '"browser_download_url": *"[^"]*"' | grep -o 'https://[^"]*' | head -1)
    if [ -n "$url" ]; then
        curl -fL "$url" -o "$HOME/.local/bin/greenclip"
        chmod +x "$HOME/.local/bin/greenclip"
    else
        echo "  !! could not resolve greenclip release URL; install manually:" >&2
        echo "     https://github.com/erebe/greenclip/releases" >&2
    fi
else
    echo "  already installed"
fi

info "rofimoji (emoji picker; not packaged for OMLx)"
if ! command -v rofimoji >/dev/null 2>&1; then
    if command -v pipx >/dev/null 2>&1; then
        pipx install rofimoji
    else
        python3 -m pip install --user rofimoji
    fi
else
    echo "  already installed"
fi

info "Directories"
mkdir -p "$HOME/Pictures/Screenshots"

info "Seeding dark theme on all system channels"
"$HOME/.local/bin/system-theme-apply" dark || true

info "Done"
cat <<'EOF'
Next steps:
  * Log out and pick the "awesome" session at the SDDM login screen.
  * Quickshell settings (dark mode, night light, bar width) live in
    ~/.local/state/quickshell/ and are controlled with Super+Shift+s.
  * Other stow packages (shell, zsh, conky, sddm-theme) are not stowed by
    this script; stow them individually if wanted: stow -R shell zsh
EOF
