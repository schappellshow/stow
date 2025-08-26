#!/bin/sh

# Get the hostname to determine which computer this is
HOSTNAME=$(hostname)

# Log file for debugging (optional)
LOG_FILE="$HOME/.conky/conky-startup.log"

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE" 2>/dev/null || true
}

# Kill any existing conky processes
log_message "Killing existing conky processes"
killall conky 2>/dev/null || true

# Wait a bit for desktop environment to fully start
log_message "Waiting for desktop environment to start..."
sleep 20s

# Change to conky directory
cd "$HOME/.conky" || {
    log_message "ERROR: Could not change to .conky directory"
    exit 1
}

# Choose conky config based on hostname
log_message "Detected hostname: $HOSTNAME"

case "$HOSTNAME" in
    "ROME-D")
        log_message "Using desktop configuration: titus_desktop.conkyrc"
        conky -c "$HOME/.conky/titus_desktop.conkyrc" &
        ;;
    "ROME-L")
        log_message "Using laptop configuration: titus_modified.conkyrc"
        conky -c "$HOME/.conky/titus_modified.conkyrc" &
        ;;
    *)
        log_message "Unknown hostname: $HOSTNAME, using default conky config"
        conky -c "$HOME/.conky/titus_modified.conkyrc" &
        ;;
esac

log_message "Conky startup completed"
exit 0
