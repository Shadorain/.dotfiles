#!/bin/bash

# Terminate already running bar instances
killall polybar

# Wait until procs have been shut down
#if pgrep polybar; then
#    sleep 1;  
# Launch polybar, using default config loc ~/.config/polybar/config
polybar mybar &
polybar bottom &
polybar desktops &
echo "Polybar Launched..."
