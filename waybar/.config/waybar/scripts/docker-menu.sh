#!/bin/bash
set -x # Enable debug printing

echo "Script started"

# Check if wofi is available
if ! command -v wofi &> /dev/null
then
    echo "wofi command not found. Please install wofi."
    exit 1
fi

echo "Wofi found. Launching menu..."

# Present a menu with wofi to start or stop Docker
chosen=$(printf "Start Docker\nStop Docker" | wofi --dmenu -p "Docker Management")

echo "Wofi finished. User chose: [$chosen]"

# Execute the chosen action
case "$chosen" in
    "Start Docker")
        echo "Executing: systemctl start docker"
        systemctl start docker
        ;;
    "Stop Docker")
        echo "Executing: systemctl stop docker"
        systemctl stop docker
        ;;
    *)
        echo "No option chosen or menu cancelled."
        ;;
esac

echo "Script finished. Refreshing Waybar."
# Send a signal to Waybar to refresh the module
pkill -RTMIN+8 waybar

set +x
