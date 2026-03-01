#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
MONITORS=$(hyprctl monitors | grep "Monitor")

# Loop over each external monitor
for MON in $MONITORS; do
    # Pick a random wallpaper for this monitor
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f -iregex ".*\.\(jpg\|jpeg\|png\|webp\)$" | shuf -n 1)
    
    # Apply it
    hyprctl hyprpaper preload "$WALLPAPER"
    hyprctl hyprpaper wallpaper "$MON,$WALLPAPER,cover"
done   
