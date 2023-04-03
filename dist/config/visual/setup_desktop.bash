#!/usr/bin/env bash

xrandr --dpi 84

i3 -c "$HOME/.i3wm" &> /dev/null && clear
