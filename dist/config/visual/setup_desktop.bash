#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.sh" ] && source "$HOME/util/standard_lib.sh"

xrandr --dpi 84

i3 -c "$HOME/.i3wm" &> /dev/null && clear