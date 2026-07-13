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
    xsettingsd feh scrot flameshot playerctl \
    xdg-desktop-portal xdg-desktop-portal-gtk plasma-workspace \
    lxqt-policykit i3lock-color brightnessctl \
    pavucontrol-qt blueman networkmanager-applet thunar \
    ghostty micro \
    fonts-ttf-hack noto-sans-fonts \
    stow git curl \
    autoconf automake libtool slibtool gettext intltool pkgconf gcc make cmake \
    lib64x11-devel lib64xxf86vm-devel lib64xcb-devel lib64xcb-util-devel \
    lib64glib2.0-devel \
    lib64pam-devel lib64xcomposite-devel lib64xext-devel lib64xfixes-devel \
    lib64xft-devel lib64xmu-devel lib64xrandr-devel lib64xscrnsaver-devel \
    python-ensurepip

info "gammastep (built from source; OMLx rolling repo's gammastep RPM is stale"
info "and hard-requires python(abi)=3.11, which no longer exists in the repo)"
if ! command -v gammastep >/dev/null 2>&1; then
    build_dir="$(mktemp -d)"
    git clone --depth 1 https://gitlab.com/chinstrap/gammastep.git "$build_dir"
    (
        cd "$build_dir"
        ./bootstrap
        ./configure --enable-randr --enable-vidmode --disable-gui
        make -j"$(nproc)"
        sudo make install
    )
    rm -rf "$build_dir"
else
    echo "  already installed"
fi

info "xss-lock (built from source; not packaged for OMLx). Bridges the X"
info "screensaver and systemd to the lock-screen script (idle lock, loginctl"
info "lock-session, lock-before-suspend)."
if ! command -v xss-lock >/dev/null 2>&1; then
    build_dir="$(mktemp -d)"
    git clone --depth 1 https://bitbucket.org/raymonad/xss-lock.git "$build_dir"
    (
        cd "$build_dir"
        # Man pages need docbook2x, which OMLx lacks; skip that target
        sed -i '/add_subdirectory(man)/d' CMakeLists.txt
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        make -C build -j"$(nproc)"
        sudo make -C build install
    )
    rm -rf "$build_dir"
else
    echo "  already installed"
fi

info "xsecurelock (built from source; not packaged for OMLx). Login-style"
info "lock screen with a real password prompt; preferred by the lock-screen"
info "wrapper, which falls back to i3lock-color if this isn't installed."
if ! command -v xsecurelock >/dev/null 2>&1; then
    pam_service=system-auth
    [ -f /etc/pam.d/system-auth ] || pam_service=login
    build_dir="$(mktemp -d)"
    git clone --depth 1 https://github.com/google/xsecurelock.git "$build_dir"
    (
        cd "$build_dir"
        sh autogen.sh
        ./configure --prefix=/usr/local --with-pam-service-name="$pam_service"
        make -j"$(nproc)"
        sudo make install
    )
    rm -rf "$build_dir"
else
    echo "  already installed"
fi

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
    if command -v pipx >/dev/null 2>&1 && pipx --version >/dev/null 2>&1; then
        pipx install rofimoji
    else
        python3 -m pip install --user rofimoji
    fi
else
    echo "  already installed"
fi

info "Directories"
mkdir -p "$HOME/Pictures/Screenshots"

info "systemd user units (awesome-session.target)"
systemctl --user daemon-reload || true

info "Seeding dark theme on all system channels"
"$HOME/.local/bin/system-theme-apply" dark || true

info "Done"
cat <<'EOF'
Next steps:
  * Log out and pick the "awesome" session at the SDDM login screen.
  * Quickshell settings (dark mode, night light, bar width) live in
    ~/.local/state/quickshell/ and are controlled with Super+Shift+s.
  * Session keys: Super+BackSpace = power menu, Ctrl+Alt+L = lock screen.
    Idle lock kicks in at 10 minutes (xset s, set in awesome autostart).
  * Other stow packages (shell, zsh, conky, sddm-theme) are not stowed by
    this script; stow them individually if wanted: stow -R shell zsh
EOF
