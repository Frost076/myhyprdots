#!/bin/bash

# Configuration
msgID="100"
iconPath="$HOME/.local/share/cat"

# Ensure volume is always even
adjust_volume_parity() {
    local vol
    vol=$(pamixer --get-volume)
    if (( vol % 2 != 0 )); then
        pactl set-sink-volume @DEFAULT_SINK@ +1%
    fi
}

# Handle volume changes
case "$1" in
    "up")
        current_vol=$(pamixer --get-volume)
        if (( current_vol >= 108 )); then
            pactl set-sink-volume @DEFAULT_SINK@ 110%
        else
            pactl set-sink-volume @DEFAULT_SINK@ +2%
            adjust_volume_parity
        fi
        ;;
        
    "down")
        pactl set-sink-volume @DEFAULT_SINK@ -2%
        adjust_volume_parity
        ;;
        
    "mute")
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
esac

# Get current state after changes
isMuted=$(pamixer --get-mute)
volume=$(pamixer --get-volume)

# Select appropriate notification
if "$isMuted"; then
    dunstify "Volume Muted" -i "$iconPath/audio-volume-muted-symbolic.svg" -r "$msgID"
else
    icon=""
    if (( volume == 0 )); then
        icon="audio-volume-muted-symbolic.svg"
    elif (( volume <= 40 )); then
        icon="audio-volume-low-symbolic.svg"
    elif (( volume <= 75 )); then
        icon="audio-volume-medium-symbolic.svg"
    elif (( volume <= 100 )); then
        icon="audio-volume-high-symbolic.svg"
    else
        icon="audio-volume-overamplified-symbolic.svg"
    fi

    # Special color for >100% volume
    if (( volume > 100 )); then
        dunstify "Sound" "Volume: [$volume%]" \
            -h "int:value:$volume" \
            -h "string:fgcolor:#ff4444" \
            -h "string:frcolor:#ba0606" \
            -i "$iconPath/$icon" \
            -r "$msgID"
    else
        dunstify "Sound" "Volume: [$volume%]" \
            -h "int:value:$volume" \
            -i "$iconPath/$icon" \
            -r "$msgID"
    fi
fi
