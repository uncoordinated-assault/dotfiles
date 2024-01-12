#!/usr/bin/env bash

xrandr --listmonitors | awk '{ print $4 }' | xargs -I{} xrandr --output "{}" --set "TearFree" "on" --dpi 92

exec i3 &> /dev/null && clear
