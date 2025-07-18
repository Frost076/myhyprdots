#!/usr/bin/env bash

# Improved brightness control script

# Configuration
msgID="92375"
iconDir="/home/frost/.local/share/cat"  # More descriptive variable name

# Verify dependencies
if ! command -v brightnessctl &> /dev/null; then
    echo "Error: brightnessctl not found. Please install it first."
    exit 1
fi

# Handle arguments
case "$1" in
    up)
        brightnessctl set +5%
        ;;
    down)
        current=$(brightnessctl get)
        max=$(brightnessctl max)
        min=$((max / 100))  # 1% of max brightness
        
        # Calculate 5% of max value for proportional decrease
        step=$((max / 20))
        new=$((current - step))
        
        # Ensure brightness doesn't go below minimum
        (( new < min )) && brightnessctl set "$min" || brightnessctl set "$new"
        ;;
    *)
        echo "Usage: $0 [up|down]"
        exit 1
        ;;
esac

# Get updated brightness value
value=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

# Select icon based on brightness level
if (( value == 0 )); then
    icon="$iconDir/notification-display-brightness-off.svg"
elif (( value <= 30 )); then
    icon="$iconDir/brightness_1.png"
elif (( value <= 65 )); then
    icon="$iconDir/brightness_3.png"
elif (( value <= 80 )); then
    icon="$iconDir/brightness_5.png"
else
    icon="$iconDir/brightness_7.png"
fi

# Send notification
dunstify "Brightness" "Level: ${value}%" \
    -h "int:value:$value" \
    -i "$icon" \
    -r "$msgID"
