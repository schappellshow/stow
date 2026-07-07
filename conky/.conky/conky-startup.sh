#!/bin/sh
# Conky launcher. Runs under the awesome DE session (or the old plasmax11
# one). Add it via Settings → Autostart, or call it manually.

case "$DESKTOP_SESSION" in
    awesome|plasmax11) ;;
    *) exit 0 ;;
esac

sleep 20
killall conky 2>/dev/null
cd "$HOME/.conky" || exit 1
conky -c "$HOME/.conky/titus_desktop.conkyrc" &
