#!/usr/bin/env bash

xrandr --listmonitors | awk '{ print $4 }' | xargs -I{} xrandr --output "{}" --set "TearFree" "on" --dpi 92

i3 -c "$HOME/.i3wm" &> /dev/null && clear
