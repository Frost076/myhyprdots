#!/bin/bash

# Load pywal colors
source "${HOME}/.cache/wal/colors.sh"

# Set Dunst config path
DUNST_CONFIG="${HOME}/.config/dunst/dunstrc"

# Update dunstrc colors
sed -i "s/^    frame_color = .*/    frame_color = \"${foreground}\"/" "$DUNST_CONFIG"
sed -i "s/^    background = .*/    background = \"${background}\"/" "$DUNST_CONFIG"
sed -i "s/^    foreground = .*/    foreground = \"${foreground}\"/" "$DUNST_CONFIG"

# Restart dunst
killall dunst && dunst &

