# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

# Session environment. SDDM starts the X session via
# /usr/share/X11/xdm/Xsession, which is `#!/bin/bash -l` (so it sources
# this file) and then execs /etc/X11/Xsession — and neither of those ever
# sources ~/.xprofile. Only SDDM's own scripts/Xsession does that, and
# OMLx doesn't use it. Without this line the session gets no ~/.xprofile
# at all: QT_QPA_PLATFORMTHEME stays unset and Qt menus (quickshell's
# tray right-click, pavucontrol-qt, ...) fall back to light Fusion.
if [ -f ~/.xprofile ]; then
    . ~/.xprofile
fi
