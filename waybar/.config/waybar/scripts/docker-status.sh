#!/bin/bash

# Check if Docker is running
if systemctl is-active --quiet docker; then
  # If running, output JSON for Waybar with 'running' class
  printf '{"text": "", "class": "running", "tooltip": "Docker is running"}'
else
  # If not running, output JSON for Waybar with 'stopped' class
  printf '{"text": "", "class": "stopped", "tooltip": "Docker is stopped"}'
fi
