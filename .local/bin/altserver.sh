#!/bin/zsh

SOCKET="/tmp/kitty.socket"
ALT_DIR="$HOME/Applications/AltServer"
ANISETTE_CMD="./anisette-server-x86_64 -n 127.0.0.1 -p 6969"
ALTSERVER_CMD="export ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6969; python3 main.py"

# Start kitty with remote control only if needed
if ! [ -S "$SOCKET" ]; then
    echo "Starting new Kitty instance with socket..."
    kitty --listen-on=unix:$SOCKET &
    KITTY_PID=$!
    sleep 1
fi

# Open anisette server in a new tab
kitty @ --to unix:$SOCKET launch --type=tab --cwd "$ALT_DIR" zsh -c "$ANISETTE_CMD; exec bash"

# Optional: Wait for the server to be reachable (basic TCP check)
echo "Waiting for anisette server to be ready..."
while ! nc -z 127.0.0.1 6969; do
    sleep 0.5
done

# Open AltServer in a second tab
kitty @ --to unix:$SOCKET launch --type=tab --cwd "$ALT_DIR" zsh -c "$ALTSERVER_CMD; exec bash"

