#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/"
theme='style'

# Icons and Commands
shutdown_icon="⏻"
reboot_icon=""
lock_icon=""
suspend_icon=""
hibernate_icon="⏾"
logout_icon=""
yes_icon="✓"
no_icon="✗"

shutdown=" $shutdown_icon  Shutdown"
reboot=" $reboot_icon  Reboot"
lock=" $lock_icon  Lock"
suspend=" $suspend_icon  Suspend"
hibernate=" $hibernate_icon  Hibernate"
logout=" $logout_icon  Logout"
yes=" $yes_icon yes"
no=" $no_icon no"

# System Information
uptime="$(uptime -p | sed -e 's/up //g' -e 's/hour/hr/g' -e 's/minute/min/g')"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p " $USER" \
        -mesg " Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi"
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme "${dir}/confirmation.rasi"
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$shutdown\n$reboot\n$lock\n$suspend\n$hibernate\n$logout" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    # Compare only the text portion after the icon
    if [[ "$selected" == *"yes"* ]]; then
        case $1 in
            '--shutdown')
                systemctl poweroff
                ;;
            '--reboot')
                systemctl reboot
                ;;
            '--hibernate')
                systemctl hibernate
                ;;
            '--suspend')
                mpc -q pause
                amixer set Master mute
                systemctl suspend
                ;;
            '--logout')
                hyprctl dispatch exit
                ;;
        esac
    else
        exit 0
    fi
}

# Main Menu
chosen="$(run_rofi)"
case "${chosen}" in
    *"Shutdown"*)
        run_cmd --shutdown
        ;;
    *"Reboot"*)
        run_cmd --reboot
        ;;
    *"Hibernate"*)
        run_cmd --hibernate
        ;;
    "$lock")
        if command -v hyprlock >/dev/null; then
            hyprlock
        else
            echo "Error: hyprlock is not installed!" >&2
            # Optional: Add fallback notification
            notify-send "Lock Failed" "hyprlock is not installed"
            exit 1
        fi
        ;;
    *"Suspend"*)
        run_cmd --suspend
        ;;
    *"Logout"*)
        run_cmd --logout
        ;;
esac

