#!/bin/sh

if [ "$DESKTOP_SESSION" = "plasma" ]; then 
   sleep 20s
   killall conky
   cd "$HOME/.conky"
   conky -c "$HOME/.conky/titus_desktop.conkyrc" &
   exit 0
fi
if [ "$DESKTOP_SESSION" = "plasmax11" ]; then 
   sleep 20s
   killall conky
   cd "$HOME/.conky"
   conky -c "$HOME/.conky/titus_desktop.conkyrc" &
   exit 0
fi
