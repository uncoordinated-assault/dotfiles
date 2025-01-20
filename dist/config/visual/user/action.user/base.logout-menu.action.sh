#!/usr/bin/env bash

config="$HOME/.visual/rofi.user/mode.user/base.logout-menu.mode.rasi"

actions=$(echo -e "   Lock\n   Shutdown\n   Reboot\n $(printf '\u200A')  Suspend\n   Hibernate\n   Logout")

# Display logout menu
selected_option=$(echo -e "$actions" | rofi -dmenu -i -config "${config}")

# Perform actions based on the selected option
case "$selected_option" in
*Lock)
  swaylock -f
  ;;
*Shutdown)
  systemctl poweroff
  ;;
*Reboot)
  systemctl reboot
  ;;
*Suspend)
  systemctl suspend
  ;;
*Hibernate)
  systemctl hibernate
  ;;
*Logout)
  hyprctl dispatch exit 0
  ;;
esac