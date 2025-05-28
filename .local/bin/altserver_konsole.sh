#!/bin/zsh

# Paths
APP_DIR=~/Applications/AltServer
ANISETTE="$APP_DIR/anisette-server-x86_64"
ALTSERVER_MAIN="$APP_DIR/main.py"

# Launch anisette server in a new Konsole tab
konsole --new-tab -e "$ANISETTE -n 127.0.0.1 -p 6969" &

# Wait a moment for anisette to start
sleep 2

# Launch AltServer in a second Konsole tab
konsole --new-tab -e "zsh -c 'cd $APP_DIR && export ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6969 && python3 main.py'" &
